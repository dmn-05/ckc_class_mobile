<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";
require_once __DIR__ . "/../upload/cloudinary_helper.php";

$rawInput = file_get_contents("php://input");
$jsonData = json_decode($rawInput, true);
$data = is_array($jsonData) ? $jsonData : $_POST;
$action = trim($data["action"] ?? "");

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function norm_datetime($value) {
    $s = trim((string)$value);
    if ($s === "" || strtolower($s) === "null") return null;
    $ts = strtotime($s);
    if ($ts === false) return null;
    return date("Y-m-d H:i:s", $ts);
}

function trang_thai_gui($thoiGianGui) {
    return ($thoiGianGui !== null && strtotime($thoiGianGui) > time()) ? "hen_gio" : "da_gui";
}

function ensure_thong_bao_schema(PDO $conn) {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME='thong_bao' AND COLUMN_NAME='bai_viet_id'");
    $stmt->execute([$db]);
    if ((int)$stmt->fetchColumn() === 0) {
        $conn->exec("ALTER TABLE thong_bao ADD COLUMN bai_viet_id INT NULL AFTER nguoi_tao_id");
        try { $conn->exec("ALTER TABLE thong_bao ADD INDEX idx_thong_bao_bai_viet (bai_viet_id)"); } catch (Throwable $e) {}
    }
}

function tao_bai_viet_thong_bao(PDO $conn, string $tieuDe, ?string $noiDung, int $lopHocPhanId, int $nguoiTaoId, string $trangThai): int {
    $stmt = $conn->prepare("INSERT INTO bai_viet
        (tieu_de, noi_dung, lop_hoc_phan_id, nguoi_tao_id, loai_bai_viet, loai_tai_nguyen, trang_thai)
        VALUES (?, ?, ?, ?, 'thong_bao', 'document', ?)");
    $stmt->execute([$tieuDe, $noiDung, $lopHocPhanId, $nguoiTaoId, $trangThai]);
    return (int)$conn->lastInsertId();
}

function cap_nhat_bai_viet_thong_bao(PDO $conn, int $baiVietId, string $tieuDe, ?string $noiDung, string $trangThai) {
    $stmt = $conn->prepare("UPDATE bai_viet SET tieu_de=?, noi_dung=?, loai_bai_viet='thong_bao', trang_thai=?, ngay_cap_nhat=NOW() WHERE id=?");
    $stmt->execute([$tieuDe, $noiDung, $trangThai, $baiVietId]);
}

function lay_bai_viet_id_cua_thong_bao(PDO $conn, int $thongBaoId): ?int {
    $stmt = $conn->prepare("SELECT bai_viet_id FROM thong_bao WHERE id=?");
    $stmt->execute([$thongBaoId]);
    $v = $stmt->fetchColumn();
    return $v ? (int)$v : null;
}

function ensure_bai_viet_for_thong_bao(PDO $conn, int $thongBaoId): int {
    $stmt = $conn->prepare("SELECT tb.*, COALESCE(tb.bai_viet_id, 0) AS bvid FROM thong_bao tb WHERE tb.id=?");
    $stmt->execute([$thongBaoId]);
    $tb = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$tb) throw new RuntimeException('Thông báo không tồn tại');
    if ((int)$tb['bvid'] > 0) return (int)$tb['bvid'];

    $baiVietId = tao_bai_viet_thong_bao(
        $conn,
        (string)$tb['tieu_de'],
        $tb['noi_dung'] ?: null,
        (int)$tb['lop_hoc_phan_id'],
        (int)$tb['nguoi_tao_id'],
        (string)$tb['trang_thai']
    );
    $conn->prepare("UPDATE thong_bao SET bai_viet_id=? WHERE id=?")->execute([$baiVietId, $thongBaoId]);
    return $baiVietId;
}

function luu_file_thong_bao(PDO $conn, int $baiVietId, int $nguoiTaoId, array $files): array {
    $saved = [];
    foreach ($files as $file) {
        $up = ckc_upload_to_cloudinary($file, 'posts');
        $tenFile = $up['original_filename'] ?: ($file['name'] ?? 'file');
        $loaiFile = $up['format'] ?: strtolower(pathinfo($tenFile, PATHINFO_EXTENSION));
        $kichThuoc = (float)($up['bytes'] ?? ($file['size'] ?? 0));
        $url = $up['secure_url'];

        $stmt = $conn->prepare("INSERT INTO tep_tin
            (ten_file, ten_file_luu, duong_dan, loai_file, kich_thuoc, nguoi_tao_id, trang_thai)
            VALUES (?, ?, ?, ?, ?, ?, 'dang_su_dung')");
        $stmt->execute([$tenFile, $up['public_id'] ?? null, $url, $loaiFile, $kichThuoc, $nguoiTaoId]);
        $tepTinId = (int)$conn->lastInsertId();

        $stmt = $conn->prepare("INSERT INTO tep_tin_bai_viet (tep_tin_id, bai_viet_id) VALUES (?, ?)");
        $stmt->execute([$tepTinId, $baiVietId]);

        $saved[] = [
            'id' => $tepTinId,
            'ten_file' => $tenFile,
            'duong_dan' => $url,
            'loai_file' => $loaiFile,
            'kich_thuoc' => (int)$kichThuoc,
        ];
    }
    return $saved;
}

function lay_files_thong_bao(PDO $conn, ?int $baiVietId): array {
    if (!$baiVietId) return [];
    $stmt = $conn->prepare("SELECT tt.id, tt.ten_file, tt.ten_file_luu, tt.duong_dan, tt.loai_file, tt.kich_thuoc, tt.ngay_tao
        FROM tep_tin_bai_viet tbv
        JOIN tep_tin tt ON tt.id = tbv.tep_tin_id
        WHERE tbv.bai_viet_id = ? AND tt.trang_thai <> 'da_xoa'
        ORDER BY tbv.id ASC");
    $stmt->execute([$baiVietId]);
    return array_map(fn($r) => [
        'id' => (int)$r['id'],
        'ten_file' => $r['ten_file'],
        'ten_file_goc' => $r['ten_file'],
        'duong_dan' => $r['duong_dan'],
        'duong_dan_file' => $r['duong_dan'],
        'loai_file' => $r['loai_file'],
        'kich_thuoc' => (int)$r['kich_thuoc'],
        'ngay_tao' => $r['ngay_tao'],
    ], $stmt->fetchAll(PDO::FETCH_ASSOC));
}

try {
    if ($action === 'them') {
        ckc_require_lhp_mutable($conn, (int)($data['lop_hoc_phan_id'] ?? 0));
    } elseif (in_array($action, ['sua', 'xoa'], true)) {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_thong_bao($conn, (int)($data['id'] ?? 0)));
    }
    ensure_thong_bao_schema($conn);

    switch ($action) {
        case "danh_sach": {
            $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
            $trangThai = trim($data["trang_thai"] ?? "");
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");

            $sql = "SELECT tb.*, nd.ho_ten AS ten_nguoi_tao,
                        (SELECT COUNT(*) FROM binh_luan bl
                         WHERE bl.bai_viet_id = tb.bai_viet_id
                           AND bl.trang_thai = 'hien_thi') AS so_binh_luan
                    FROM thong_bao tb
                    LEFT JOIN nguoi_dung nd ON tb.nguoi_tao_id = nd.id
                    WHERE tb.lop_hoc_phan_id = :lhp_id";
            $params = [":lhp_id" => $lopHocPhanId];
            if ($trangThai !== "") {
                $sql .= " AND tb.trang_thai = :tt";
                $params[":tt"] = $trangThai;
            } else {
                $sql .= " AND tb.trang_thai <> 'an'";
            }
            $sql .= " ORDER BY CASE WHEN tb.thoi_gian_gui IS NOT NULL AND tb.thoi_gian_gui > NOW() THEN 0 ELSE 1 END ASC,
                       COALESCE(tb.thoi_gian_gui, tb.ngay_tao) DESC, tb.ngay_tao DESC";
            $stmt = $conn->prepare($sql);
            foreach ($params as $k => $v) $stmt->bindValue($k, $v, $k === ":lhp_id" ? PDO::PARAM_INT : PDO::PARAM_STR);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $result = [];
            foreach ($rows as $r) {
                $baiVietId = !empty($r['bai_viet_id']) ? (int)$r['bai_viet_id'] : null;
                $result[] = [
                    "id" => (int)$r["id"],
                    "bai_viet_id" => $baiVietId,
                    "tieu_de" => $r["tieu_de"],
                    "noi_dung" => $r["noi_dung"],
                    "thoi_gian_gui" => $r["thoi_gian_gui"],
                    "trang_thai_gui" => trang_thai_gui($r["thoi_gian_gui"]),
                    "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
                    "nguoi_tao_id" => (int)$r["nguoi_tao_id"],
                    "ten_nguoi_tao" => $r["ten_nguoi_tao"],
                    "trang_thai" => $r["trang_thai"],
                    "ngay_tao" => $r["ngay_tao"],
                    "ngay_cap_nhat" => $r["ngay_cap_nhat"],
                    "so_binh_luan" => (int)$r["so_binh_luan"],
                    "files" => lay_files_thong_bao($conn, $baiVietId),
                ];
            }
            respond("success", "Lấy danh sách thông báo thành công", ["data" => $result]);
        }

        case "them": {
            $tieuDe = trim($data["tieu_de"] ?? "");
            $noiDung = trim($data["noi_dung"] ?? "");
            $thoiGianGui = norm_datetime($data["thoi_gian_gui"] ?? "");
            $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
            $nguoiTaoId = (int)($data["nguoi_tao_id"] ?? 0);
            $trangThai = trim($data["trang_thai"] ?? "hien_thi");
            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");
            if ($nguoiTaoId <= 0) respond("error", "ID người tạo không hợp lệ");
            if (!in_array($trangThai, ["hien_thi", "an"], true)) $trangThai = "hien_thi";

            $conn->beginTransaction();
            $baiVietId = tao_bai_viet_thong_bao($conn, $tieuDe, $noiDung ?: null, $lopHocPhanId, $nguoiTaoId, $trangThai);
            $stmt = $conn->prepare("INSERT INTO thong_bao
                (tieu_de, noi_dung, thoi_gian_gui, lop_hoc_phan_id, nguoi_tao_id, bai_viet_id, trang_thai)
                VALUES (?,?,?,?,?,?,?)");
            $stmt->execute([$tieuDe, $noiDung ?: null, $thoiGianGui, $lopHocPhanId, $nguoiTaoId, $baiVietId, $trangThai]);
            $thongBaoId = (int)$conn->lastInsertId();
            $files = ckc_collect_uploads(['file', 'files', 'files[]']);
            $savedFiles = [];
            if (!empty($files)) $savedFiles = luu_file_thong_bao($conn, $baiVietId, $nguoiTaoId, $files);
            $conn->commit();
            respond("success", "Đăng thông báo thành công", ["id" => $thongBaoId, "bai_viet_id" => $baiVietId, "files" => $savedFiles]);
        }

        case "sua": {
            $id = (int)($data["id"] ?? 0);
            $tieuDe = trim($data["tieu_de"] ?? "");
            $noiDung = trim($data["noi_dung"] ?? "");
            $thoiGianGui = norm_datetime($data["thoi_gian_gui"] ?? "");
            $trangThai = trim($data["trang_thai"] ?? "hien_thi");
            $nguoiTaoId = (int)($data["nguoi_tao_id"] ?? 0);
            if ($id <= 0) respond("error", "ID thông báo không hợp lệ");
            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");
            if (!in_array($trangThai, ["hien_thi", "an"], true)) $trangThai = "hien_thi";

            $conn->beginTransaction();
            $baiVietId = ensure_bai_viet_for_thong_bao($conn, $id);
            cap_nhat_bai_viet_thong_bao($conn, $baiVietId, $tieuDe, $noiDung ?: null, $trangThai);
            $stmt = $conn->prepare("UPDATE thong_bao SET tieu_de=?, noi_dung=?, thoi_gian_gui=?, trang_thai=?, bai_viet_id=?, ngay_cap_nhat=NOW() WHERE id=?");
            $stmt->execute([$tieuDe, $noiDung ?: null, $thoiGianGui, $trangThai, $baiVietId, $id]);
            $files = ckc_collect_uploads(['file', 'files', 'files[]']);
            $savedFiles = [];
            if (!empty($files)) $savedFiles = luu_file_thong_bao($conn, $baiVietId, $nguoiTaoId, $files);
            $conn->commit();
            respond("success", "Cập nhật thông báo thành công", ["bai_viet_id" => $baiVietId, "files" => $savedFiles]);
        }

        case "xoa": {
            $id = (int)($data["id"] ?? 0);
            if ($id <= 0) respond("error", "ID thông báo không hợp lệ");
            $baiVietId = lay_bai_viet_id_cua_thong_bao($conn, $id);
            $stmt = $conn->prepare("UPDATE thong_bao SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=?");
            $stmt->execute([$id]);
            if ($baiVietId) $conn->prepare("UPDATE bai_viet SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=?")->execute([$baiVietId]);
            respond("success", "Xóa thông báo thành công");
        }

        default:
            http_response_code(400);
            respond("error", "Hành động không hợp lệ");
    }
} catch (Throwable $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
