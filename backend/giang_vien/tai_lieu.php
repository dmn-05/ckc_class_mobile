<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../upload/cloudinary_helper.php";

$data   = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim($data["action"] ?? "");

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}


function db_has_table(PDO $conn, string $table): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $stmt->execute([$db, $table]);
    return (int)$stmt->fetchColumn() > 0;
}

function db_has_column(PDO $conn, string $table, string $column): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?");
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

function ensure_tai_lieu_web_schema(PDO $conn): void {
    // Không tự ALTER tai_lieu trong request; nếu host có tai_lieu.bai_viet_id thì sẽ đồng bộ sang bai_viet.
    if (db_has_table($conn, 'bai_viet')) {
        if (!db_has_column($conn, 'bai_viet', 'external_url')) {
            $conn->exec("ALTER TABLE bai_viet ADD COLUMN external_url TEXT NULL AFTER hinh_anh");
        }
        if (!db_has_column($conn, 'bai_viet', 'loai_tai_nguyen')) {
            $conn->exec("ALTER TABLE bai_viet ADD COLUMN loai_tai_nguyen ENUM('document','video','link','image','other') DEFAULT 'document' AFTER loai_bai_viet");
        }
    }
}

function loai_tai_nguyen_tu_url(?string $url): string {
    $url = trim((string)$url);
    if ($url === '') return 'document';
    if (preg_match('/^https?:\/\//i', $url) && !preg_match('/\.(pdf|doc|docx|xls|xlsx|ppt|pptx|zip|rar|txt|sql|jpg|jpeg|png|gif|webp)(\?|$)/i', $url)) {
        return 'link';
    }
    if (preg_match('/\.(jpg|jpeg|png|gif|webp)(\?|$)/i', $url)) return 'image';
    return 'document';
}

function sync_tep_tin_bai_viet(PDO $conn, int $baiVietId, ?string $url, int $nguoiTaoId = 0): void {
    $url = trim((string)$url);
    if ($url === '' || !db_has_table($conn, 'tep_tin') || !db_has_table($conn, 'tep_tin_bai_viet')) return;
    $tenFile = ckc_file_name_from_url($url);
    $ext = strtolower(pathinfo(parse_url($url, PHP_URL_PATH) ?: $tenFile, PATHINFO_EXTENSION));

    $stmt = $conn->prepare("SELECT id FROM tep_tin WHERE duong_dan = ? LIMIT 1");
    $stmt->execute([$url]);
    $tepTinId = (int)($stmt->fetchColumn() ?: 0);
    if ($tepTinId <= 0) {
        $stmt = $conn->prepare("INSERT INTO tep_tin (ten_file, ten_file_luu, duong_dan, loai_file, kich_thuoc, nguoi_tao_id, trang_thai)
            VALUES (?, ?, ?, ?, 0, ?, 'dang_su_dung')");
        $stmt->execute([$tenFile, basename(parse_url($url, PHP_URL_PATH) ?: $tenFile), $url, $ext ?: null, $nguoiTaoId > 0 ? $nguoiTaoId : null]);
        $tepTinId = (int)$conn->lastInsertId();
    }

    $chk = $conn->prepare("SELECT COUNT(*) FROM tep_tin_bai_viet WHERE tep_tin_id=? AND bai_viet_id=?");
    $chk->execute([$tepTinId, $baiVietId]);
    if ((int)$chk->fetchColumn() === 0) {
        $stmt = $conn->prepare("INSERT INTO tep_tin_bai_viet (tep_tin_id, bai_viet_id, ngay_tao) VALUES (?, ?, NOW())");
        $stmt->execute([$tepTinId, $baiVietId]);
    }
}

function sync_tai_lieu_sang_bai_viet(PDO $conn, int $taiLieuId, string $tieuDe, ?string $moTa, ?string $url, int $lopHocPhanId, int $nguoiTaoId, string $trangThai): ?int {
    if (!db_has_table($conn, 'bai_viet') || !db_has_column($conn, 'tai_lieu', 'bai_viet_id')) return null;

    $stmt = $conn->prepare("SELECT bai_viet_id FROM tai_lieu WHERE id=? LIMIT 1");
    $stmt->execute([$taiLieuId]);
    $baiVietId = (int)($stmt->fetchColumn() ?: 0);
    $loaiTaiNguyen = loai_tai_nguyen_tu_url($url);

    if ($baiVietId > 0) {
        $stmt = $conn->prepare("UPDATE bai_viet SET tieu_de=?, noi_dung=?, external_url=?, lop_hoc_phan_id=?, nguoi_tao_id=?, loai_bai_viet='tai_lieu', loai_tai_nguyen=?, trang_thai=?, ngay_cap_nhat=NOW() WHERE id=?");
        $stmt->execute([$tieuDe, $moTa ?: null, $url ?: null, $lopHocPhanId, $nguoiTaoId, $loaiTaiNguyen, $trangThai, $baiVietId]);
    } else {
        $stmt = $conn->prepare("INSERT INTO bai_viet (tieu_de, noi_dung, external_url, lop_hoc_phan_id, nguoi_tao_id, loai_bai_viet, loai_tai_nguyen, trang_thai) VALUES (?, ?, ?, ?, ?, 'tai_lieu', ?, ?)");
        $stmt->execute([$tieuDe, $moTa ?: null, $url ?: null, $lopHocPhanId, $nguoiTaoId, $loaiTaiNguyen, $trangThai]);
        $baiVietId = (int)$conn->lastInsertId();
        $conn->prepare("UPDATE tai_lieu SET bai_viet_id=? WHERE id=?")->execute([$baiVietId, $taiLieuId]);
    }

    sync_tep_tin_bai_viet($conn, $baiVietId, $url, $nguoiTaoId);
    return $baiVietId;
}

function bai_viet_file_url_expr(): string {
    return "COALESCE(bv.external_url, (SELECT tt.duong_dan FROM tep_tin_bai_viet ttbv JOIN tep_tin tt ON tt.id = ttbv.tep_tin_id WHERE ttbv.bai_viet_id = bv.id AND COALESCE(tt.trang_thai, 'dang_su_dung')='dang_su_dung' ORDER BY ttbv.id ASC LIMIT 1))";
}

try {
    ensure_tai_lieu_web_schema($conn);
    switch ($action) {
        // ─── DANH SÁCH ───────────────────────────────────────────
        case "danh_sach": {
            $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
            $tuKhoa       = trim($data["tu_khoa"] ?? "");
            $trangThai    = trim($data["trang_thai"] ?? "");

            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");

            $sql = "SELECT tl.*, nd.ho_ten AS ten_nguoi_tao
                    FROM tai_lieu tl
                    LEFT JOIN nguoi_dung nd ON tl.nguoi_tao_id = nd.id
                    WHERE tl.lop_hoc_phan_id = :lhp_id";
            $params = [":lhp_id" => $lopHocPhanId];

            if ($tuKhoa !== "") {
                $sql .= " AND tl.tieu_de LIKE :tk";
                $params[":tk"] = "%$tuKhoa%";
            }
            if ($trangThai !== "") {
                $sql .= " AND tl.trang_thai = :tt";
                $params[":tt"] = $trangThai;
            }
            $sql .= " ORDER BY tl.ngay_tao DESC";

            $stmt = $conn->prepare($sql);
            $stmt->bindValue(":lhp_id", $lopHocPhanId, PDO::PARAM_INT);
            foreach (array_filter($params, fn($k) => $k !== ":lhp_id", ARRAY_FILTER_USE_KEY) as $k => $v) {
                $stmt->bindValue($k, $v, PDO::PARAM_STR);
            }
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $result = array_map(fn($r) => [
                "id"              => (int)$r["id"],
                "tieu_de"         => $r["tieu_de"],
                "mo_ta"           => $r["mo_ta"],
                "duong_dan_file"  => $r["duong_dan_file"],
                "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
                "nguoi_tao_id"    => (int)$r["nguoi_tao_id"],
                "ten_nguoi_tao"   => $r["ten_nguoi_tao"],
                "trang_thai"      => $r["trang_thai"],
                "ngay_tao"        => $r["ngay_tao"],
                "ngay_cap_nhat"   => $r["ngay_cap_nhat"],
                "nguon"           => "tai_lieu",
            ], $rows);

            // Thêm tài nguyên do Web tạo trong bai_viet để Mobile vẫn nhìn thấy.
            if (db_has_table($conn, 'bai_viet')) {
                $fileExpr = bai_viet_file_url_expr();
                $sqlWeb = "SELECT bv.*, nd.ho_ten AS ten_nguoi_tao, $fileExpr AS duong_dan_file_web
                           FROM bai_viet bv
                           LEFT JOIN nguoi_dung nd ON bv.nguoi_tao_id = nd.id
                           WHERE bv.lop_hoc_phan_id = :lhp_id
                             AND bv.loai_bai_viet = 'tai_lieu'
                             AND bv.trang_thai <> 'an'";
                $paramsWeb = [':lhp_id' => $lopHocPhanId];
                if ($tuKhoa !== '') { $sqlWeb .= " AND bv.tieu_de LIKE :tk"; $paramsWeb[':tk'] = "%$tuKhoa%"; }
                if ($trangThai !== '') { $sqlWeb .= " AND bv.trang_thai = :tt"; $paramsWeb[':tt'] = $trangThai; }
                $sqlWeb .= " ORDER BY bv.ngay_tao DESC";
                $webStmt = $conn->prepare($sqlWeb);
                foreach ($paramsWeb as $k => $v) $webStmt->bindValue($k, $v, $k === ':lhp_id' ? PDO::PARAM_INT : PDO::PARAM_STR);
                $webStmt->execute();
                foreach ($webStmt->fetchAll(PDO::FETCH_ASSOC) as $r) {
                    $result[] = [
                        "id" => -1 * (int)$r['id'],
                        "tieu_de" => $r['tieu_de'],
                        "mo_ta" => $r['noi_dung'],
                        "duong_dan_file" => $r['duong_dan_file_web'],
                        "lop_hoc_phan_id" => (int)$r['lop_hoc_phan_id'],
                        "nguoi_tao_id" => (int)$r['nguoi_tao_id'],
                        "ten_nguoi_tao" => $r['ten_nguoi_tao'],
                        "trang_thai" => $r['trang_thai'],
                        "ngay_tao" => $r['ngay_tao'],
                        "ngay_cap_nhat" => $r['ngay_cap_nhat'],
                        "nguon" => "bai_viet",
                    ];
                }
            }

            respond("success", "Lấy danh sách tài liệu thành công", ["data" => $result]);
        }

        // ─── THÊM ────────────────────────────────────────────────
        case "them": {
            $tieuDe        = trim($data["tieu_de"] ?? "");
            $moTa          = trim($data["mo_ta"] ?? "");
            $duongDanFile  = trim($data["duong_dan_file"] ?? "");
            $lopHocPhanId  = (int)($data["lop_hoc_phan_id"] ?? 0);
            $nguoiTaoId    = (int)($data["nguoi_tao_id"] ?? 0);
            $trangThai     = trim($data["trang_thai"] ?? "hien_thi");

            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");
            if ($nguoiTaoId <= 0) respond("error", "ID người tạo không hợp lệ");

            $conn->beginTransaction();
            $stmt = $conn->prepare("INSERT INTO tai_lieu (tieu_de, mo_ta, duong_dan_file, lop_hoc_phan_id, nguoi_tao_id, trang_thai) VALUES (?,?,?,?,?,?)");
            $stmt->execute([$tieuDe, $moTa ?: null, $duongDanFile ?: null, $lopHocPhanId, $nguoiTaoId, $trangThai]);
            $idMoi = (int)$conn->lastInsertId();
            sync_tai_lieu_sang_bai_viet($conn, $idMoi, $tieuDe, $moTa ?: null, $duongDanFile ?: null, $lopHocPhanId, $nguoiTaoId, $trangThai);
            $conn->commit();
            respond("success", "Thêm tài liệu thành công", ["id" => $idMoi]);
        }

        // ─── SỬA ─────────────────────────────────────────────────
        case "sua": {
            $id           = (int)($data["id"] ?? 0);
            $tieuDe       = trim($data["tieu_de"] ?? "");
            $moTa         = trim($data["mo_ta"] ?? "");
            $duongDanFile = trim($data["duong_dan_file"] ?? "");
            $trangThai    = trim($data["trang_thai"] ?? "hien_thi");

            if ($id === 0) respond("error", "ID tài liệu không hợp lệ");
            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");

            // ID âm là tài nguyên Web từ bai_viet.
            if ($id < 0) {
                $baiVietId = abs($id);
                $stmt = $conn->prepare("UPDATE bai_viet SET tieu_de=?, noi_dung=?, external_url=?, loai_tai_nguyen=?, trang_thai=?, ngay_cap_nhat=NOW() WHERE id=? AND loai_bai_viet='tai_lieu'");
                $stmt->execute([$tieuDe, $moTa ?: null, $duongDanFile ?: null, loai_tai_nguyen_tu_url($duongDanFile), $trangThai, $baiVietId]);
                sync_tep_tin_bai_viet($conn, $baiVietId, $duongDanFile ?: null, 0);
                respond("success", "Cập nhật tài liệu thành công");
            }

            $stmtOld = $conn->prepare("SELECT lop_hoc_phan_id, nguoi_tao_id FROM tai_lieu WHERE id=? LIMIT 1");
            $stmtOld->execute([$id]);
            $old = $stmtOld->fetch(PDO::FETCH_ASSOC);
            if (!$old) respond("error", "Không tìm thấy tài liệu");

            $conn->beginTransaction();
            $stmt = $conn->prepare("UPDATE tai_lieu SET tieu_de=?, mo_ta=?, duong_dan_file=?, trang_thai=? WHERE id=?");
            $stmt->execute([$tieuDe, $moTa ?: null, $duongDanFile ?: null, $trangThai, $id]);
            sync_tai_lieu_sang_bai_viet($conn, $id, $tieuDe, $moTa ?: null, $duongDanFile ?: null, (int)$old['lop_hoc_phan_id'], (int)$old['nguoi_tao_id'], $trangThai);
            $conn->commit();
            respond("success", "Cập nhật tài liệu thành công");
        }

        // ─── XÓA ─────────────────────────────────────────────────
        case "xoa": {
            $id = (int)($data["id"] ?? 0);
            if ($id === 0) respond("error", "ID tài liệu không hợp lệ");
            if ($id < 0) {
                $conn->prepare("UPDATE bai_viet SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=? AND loai_bai_viet='tai_lieu'")->execute([abs($id)]);
                respond("success", "Xóa tài liệu thành công");
            }
            if (db_has_column($conn, 'tai_lieu', 'bai_viet_id')) {
                $stmt = $conn->prepare("SELECT bai_viet_id FROM tai_lieu WHERE id=? LIMIT 1");
                $stmt->execute([$id]);
                $bvId = (int)($stmt->fetchColumn() ?: 0);
                if ($bvId > 0) {
                    $conn->prepare("UPDATE bai_viet SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=?")->execute([$bvId]);
                }
            }
            $conn->prepare("DELETE FROM tai_lieu WHERE id=?")->execute([$id]);
            respond("success", "Xóa tài liệu thành công");
        }

        default:
            http_response_code(400);
            respond("error", "Hành động không hợp lệ");
    }
} catch (PDOException $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>