<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";
require_once __DIR__ . "/../upload/cloudinary_helper.php";

$contentType = $_SERVER["CONTENT_TYPE"] ?? $_SERVER["HTTP_CONTENT_TYPE"] ?? "";
$isMultipart = stripos($contentType, "multipart/form-data") !== false;

if ($isMultipart) {
    $data = $_POST;
} else {
    $data = json_decode(file_get_contents("php://input"), true) ?? [];
}

$action     = trim($data["action"] ?? "");
$sinhVienId = (int)($data["sinh_vien_id"] ?? 0);

function respond($status, $message, $extra = []) {
    echo json_encode(
        array_merge(["status" => $status, "message" => $message], $extra),
        JSON_UNESCAPED_UNICODE
    );
    exit();
}

function dt_now_ts() {
    return time();
}

function normalize_ext_list($raw) {
    if ($raw === null) return [];
    $parts = is_array($raw) ? $raw : explode(',', (string)$raw);
    $out = [];
    foreach ($parts as $p) {
        $e = strtolower(trim((string)$p));
        $e = ltrim($e, '.');
        if ($e !== '' && preg_match('/^[a-z0-9]+$/', $e)) $out[] = $e;
    }
    return array_values(array_unique($out));
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

function trang_thai_db_sang_mobile($value) {
    return match (trim((string)$value)) {
        'dang_mo' => 'hien_thi',
        'da_dong' => 'an',
        'hien_thi', 'an' => trim((string)$value),
        default => 'hien_thi',
    };
}

function trang_thai_mo($value): bool {
    return in_array(trim((string)$value), ['hien_thi', 'dang_mo'], true);
}

function ten_file_host($name): string {
    $name = basename((string)$name);
    if ($name === '') return 'file';
    // Host Web đang khai báo bai_nop.ten_file_goc VARCHAR(50).
    // Cắt an toàn để tránh lỗi SQL khi tên file quá dài.
    return function_exists('mb_substr') ? mb_substr($name, 0, 50, 'UTF-8') : substr($name, 0, 50);
}


function ensure_assignment_file_schema(PDO $conn) {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();

    $addCol = function ($table, $column, $definition) use ($conn, $db) {
        $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?");
        $stmt->execute([$db, $table, $column]);
        if ((int)$stmt->fetchColumn() === 0) {
            $conn->exec("ALTER TABLE `$table` ADD COLUMN $definition");
        }
    };

    $addCol('bai_tap', 'yeu_cau_nop_file', 'yeu_cau_nop_file TINYINT(1) DEFAULT 1 AFTER duong_dan_file');
    $addCol('bai_tap', 'dinh_dang_file_cho_phep', 'dinh_dang_file_cho_phep VARCHAR(255) NULL AFTER yeu_cau_nop_file');
    $addCol('bai_tap', 'so_file_toi_da', 'so_file_toi_da INT DEFAULT 1 AFTER dinh_dang_file_cho_phep');
    $addCol('bai_tap', 'dung_luong_toi_da_mb', 'dung_luong_toi_da_mb INT DEFAULT 25 AFTER so_file_toi_da');
    $addCol('bai_tap', 'cho_phep_nop_lai', 'cho_phep_nop_lai TINYINT(1) DEFAULT 1 AFTER dung_luong_toi_da_mb');
    $addCol('bai_tap', 'cho_phep_nop_muon', 'cho_phep_nop_muon TINYINT(1) DEFAULT 1 AFTER cho_phep_nop_lai');
    $addCol('bai_tap', 'diem_toi_da', 'diem_toi_da DECIMAL(5,2) DEFAULT 10 AFTER cho_phep_nop_muon');
    $addCol('bai_tap', 'file_url', 'file_url TEXT NULL AFTER cho_phep_nop_muon');
    $addCol('bai_tap', 'file_name', 'file_name VARCHAR(255) NULL AFTER file_url');

    // Host Web đã gộp bảng bai_nop_file vào bai_nop.
    // Mobile chỉ cần đảm bảo bai_nop có cột ten_file_goc để lưu tên file gốc.
    $addCol('bai_nop', 'ten_file_goc', 'ten_file_goc VARCHAR(50) NULL AFTER sinh_vien_id');
    if (db_has_table($conn, 'bai_kiem_tra')) {
        $addCol('bai_kiem_tra', 'chu_de_id', 'chu_de_id INT NULL AFTER lop_hoc_phan_id');
    }
}

function collect_uploaded_files() {
    $result = [];
    foreach (["files", "files[]", "file", "tep_tin", "bai_nop_file"] as $key) {
        if (!isset($_FILES[$key])) continue;
        $f = $_FILES[$key];
        if (is_array($f["name"])) {
            $count = count($f["name"]);
            for ($i = 0; $i < $count; $i++) {
                if ((int)$f["error"][$i] === UPLOAD_ERR_NO_FILE) continue;
                $result[] = [
                    "name" => $f["name"][$i],
                    "type" => $f["type"][$i] ?? "",
                    "tmp_name" => $f["tmp_name"][$i],
                    "error" => (int)$f["error"][$i],
                    "size" => (int)$f["size"][$i],
                ];
            }
        } else {
            if ((int)$f["error"] === UPLOAD_ERR_NO_FILE) continue;
            $result[] = [
                "name" => $f["name"],
                "type" => $f["type"] ?? "",
                "tmp_name" => $f["tmp_name"],
                "error" => (int)$f["error"],
                "size" => (int)$f["size"],
            ];
        }
    }
    return $result;
}


function lay_files_bai_tap_sv(PDO $conn, int $baiTapId): array {
    if ($baiTapId <= 0 || !db_has_table($conn, 'tep_tin') || !db_has_table($conn, 'tep_tin_bai_tap')) return [];
    $stmt = $conn->prepare("SELECT tt.id, tt.ten_file, tt.duong_dan, tt.loai_file, tt.kich_thuoc, tt.ngay_tao
        FROM tep_tin_bai_tap ttbt
        JOIN tep_tin tt ON tt.id = ttbt.tep_tin_id
        WHERE ttbt.bai_tap_id=? AND COALESCE(tt.trang_thai, 'dang_su_dung')='dang_su_dung'
        ORDER BY ttbt.id ASC");
    $stmt->execute([$baiTapId]);
    return array_map(static function ($r) {
        return [
            'id' => (int)$r['id'],
            'ten_file' => $r['ten_file'],
            'ten_file_goc' => $r['ten_file'],
            'duong_dan' => $r['duong_dan'],
            'duong_dan_file' => $r['duong_dan'],
            'loai_file' => $r['loai_file'],
            'kich_thuoc' => (int)($r['kich_thuoc'] ?? 0),
            'ngay_tao' => $r['ngay_tao'],
        ];
    }, $stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($sinhVienId <= 0) {
    http_response_code(400);
    respond("error", "ID sinh viên không hợp lệ");
}

try {
    if ($action === 'nop_bai') {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_bai_tap($conn, (int)($data['bai_tap_id'] ?? 0)));
    }

    ensure_assignment_file_schema($conn);

    // ─── DANH SÁCH BÀI TẬP CỦA MỘT LỚP ─────────────────────
    if ($action === "danh_sach_theo_lop") {
        $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);

        $chuDeIds = $data["chu_de_ids"] ?? [];
        if (!is_array($chuDeIds)) $chuDeIds = [];
        $rawChuDeIds = array_map("intval", $chuDeIds);
        $locChuaPhanLoai = in_array(-1, $rawChuDeIds, true);
        $chuDeIds = array_values(array_filter($rawChuDeIds, fn($x) => $x > 0));

        if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");

        $sql = "
            SELECT
                bt.id,
                bt.tieu_de,
                bt.mo_ta,
                COALESCE(bt.loai_bai_tap, 'nop_file') AS loai_bai_tap,
                COALESCE(bt.duong_dan_file, bt.file_url, (SELECT tt.duong_dan FROM tep_tin_bai_tap ttbt JOIN tep_tin tt ON tt.id = ttbt.tep_tin_id WHERE ttbt.bai_tap_id = bt.id AND COALESCE(tt.trang_thai, 'dang_su_dung') = 'dang_su_dung' ORDER BY ttbt.id ASC LIMIT 1)) AS duong_dan_file,
                COALESCE(bt.file_name, (SELECT tt.ten_file FROM tep_tin_bai_tap ttbt JOIN tep_tin tt ON tt.id = ttbt.tep_tin_id WHERE ttbt.bai_tap_id = bt.id AND COALESCE(tt.trang_thai, 'dang_su_dung') = 'dang_su_dung' ORDER BY ttbt.id ASC LIMIT 1)) AS file_name,
                bt.yeu_cau_nop_file,
                bt.dinh_dang_file_cho_phep,
                bt.so_file_toi_da,
                bt.dung_luong_toi_da_mb,
                bt.cho_phep_nop_lai,
                bt.cho_phep_nop_muon,
                bt.diem_toi_da,
                bt.han_nop,
                bt.thoi_gian_gui,
                bt.thoi_gian_lam,
                bt.cho_xem_dap_an,
                bt.dao_cau_hoi,
                bt.dao_dap_an,
                bt.lop_hoc_phan_id,
                bt.chu_de_id,
                cd.ten_chu_de,
                bt.trang_thai,
                bt.ngay_tao,
                nd.ho_ten AS ten_nguoi_tao,

                bn.id AS bai_nop_id,
                bn.duong_dan_file AS file_da_nop,
                bn.ten_file_goc AS ten_file_goc_da_nop,
                bn.diem,
                bn.nhan_xet,
                bn.trang_thai AS trang_thai_nop,
                bn.ngay_nop,

                NULL AS bai_lam_quiz_id,
                NULL AS diem_quiz,
                NULL AS trang_thai_quiz,
                NULL AS thoi_gian_nop_quiz,
                0 AS so_cau_hoi

            FROM bai_tap bt
            LEFT JOIN chu_de cd ON bt.chu_de_id = cd.id
            LEFT JOIN nguoi_dung nd ON bt.nguoi_tao_id = nd.id
            LEFT JOIN bai_nop bn ON bn.bai_tap_id = bt.id AND bn.sinh_vien_id = :sv_id
            WHERE bt.lop_hoc_phan_id = :lhp_id
              AND bt.trang_thai <> 'an'
              AND COALESCE(bt.loai_bai_tap, 'nop_file') <> 'quiz'
              AND (bt.thoi_gian_gui IS NULL OR bt.thoi_gian_gui <= NOW())
        ";

        if (!empty($chuDeIds) || $locChuaPhanLoai) {
            $topicParts = [];
            if (!empty($chuDeIds)) {
                $placeholders = [];
                foreach ($chuDeIds as $i => $id) $placeholders[] = ":chu_de_id_" . $i;
                $topicParts[] = "bt.chu_de_id IN (" . implode(",", $placeholders) . ")";
            }
            if ($locChuaPhanLoai) {
                $topicParts[] = "bt.chu_de_id IS NULL";
            }
            $sql .= " AND (" . implode(" OR ", $topicParts) . ")";
        }

        $sql .= " ORDER BY COALESCE(cd.thu_tu, 9999) ASC, bt.ngay_tao DESC";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(":sv_id", $sinhVienId, PDO::PARAM_INT);
        $stmt->bindValue(":lhp_id", $lopHocPhanId, PDO::PARAM_INT);
        foreach ($chuDeIds as $i => $id) $stmt->bindValue(":chu_de_id_" . $i, $id, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Host Web không còn bảng bai_nop_file. Tạo mảng files_da_nop từ chính bai_nop.
        $result = array_map(function ($r) use ($conn) {
            $baiNopId = $r["bai_nop_id"] !== null ? (int)$r["bai_nop_id"] : null;
            return [
                "id" => (int)$r["id"],
                "tieu_de" => $r["tieu_de"],
                "mo_ta" => $r["mo_ta"],
                "loai_bai_tap" => $r["loai_bai_tap"] ?: "nop_file",
                "duong_dan_file" => $r["duong_dan_file"],
                "file_name" => $r["file_name"],
                "yeu_cau_nop_file" => (int)($r["yeu_cau_nop_file"] ?? 1),
                "dinh_dang_file_cho_phep" => $r["dinh_dang_file_cho_phep"],
                // CSDL bai_nop hiện chỉ lưu được một file cho mỗi sinh viên/bài tập.
                "so_file_toi_da" => 1,
                "dung_luong_toi_da_mb" => max(1, (int)($r["dung_luong_toi_da_mb"] ?? 25)),
                "cho_phep_nop_lai" => (int)($r["cho_phep_nop_lai"] ?? 1),
                "cho_phep_nop_muon" => (int)($r["cho_phep_nop_muon"] ?? 1),
                "diem_toi_da" => $r["diem_toi_da"] !== null ? (float)$r["diem_toi_da"] : 10.0,
                "han_nop" => $r["han_nop"],
                "thoi_gian_gui" => $r["thoi_gian_gui"],
                "thoi_gian_lam" => $r["thoi_gian_lam"] !== null ? (int)$r["thoi_gian_lam"] : null,
                "cho_xem_dap_an" => isset($r["cho_xem_dap_an"]) ? (int)$r["cho_xem_dap_an"] : 0,
                "dao_cau_hoi" => isset($r["dao_cau_hoi"]) ? (int)$r["dao_cau_hoi"] : 0,
                "dao_dap_an" => isset($r["dao_dap_an"]) ? (int)$r["dao_dap_an"] : 0,
                "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
                "chu_de_id" => $r["chu_de_id"] !== null ? (int)$r["chu_de_id"] : null,
                "ten_chu_de" => $r["ten_chu_de"],
                "trang_thai" => trang_thai_db_sang_mobile($r["trang_thai"]),
                "ngay_tao" => $r["ngay_tao"],
                "ten_nguoi_tao" => $r["ten_nguoi_tao"],
                "bai_nop_id" => $baiNopId,
                "file_da_nop" => $r["file_da_nop"],
                "files_da_nop" => ($baiNopId !== null && trim((string)$r["file_da_nop"]) !== "") ? [[
                    "id" => $baiNopId,
                    "ten_file_goc" => $r["ten_file_goc_da_nop"] ?: basename(parse_url($r["file_da_nop"], PHP_URL_PATH) ?: $r["file_da_nop"]),
                    "duong_dan_file" => $r["file_da_nop"],
                    "loai_file" => strtolower(pathinfo(parse_url($r["file_da_nop"], PHP_URL_PATH) ?: $r["file_da_nop"], PATHINFO_EXTENSION)),
                    "kich_thuoc" => 0,
                    "ngay_tao" => $r["ngay_nop"],
                ]] : [],
                "diem" => $r["diem"] !== null ? (float)$r["diem"] : null,
                "nhan_xet" => $r["nhan_xet"],
                "trang_thai_nop" => $r["trang_thai_nop"],
                "ngay_nop" => $r["ngay_nop"],
                "bai_lam_quiz_id" => $r["bai_lam_quiz_id"] !== null ? (int)$r["bai_lam_quiz_id"] : null,
                "diem_quiz" => $r["diem_quiz"] !== null ? (float)$r["diem_quiz"] : null,
                "trang_thai_quiz" => $r["trang_thai_quiz"],
                "thoi_gian_nop_quiz" => $r["thoi_gian_nop_quiz"],
                "so_cau_hoi" => (int)$r["so_cau_hoi"],
                "files" => lay_files_bai_tap_sv($conn, (int)$r["id"]),
            ];
        }, $rows);


        // Ghép thêm bài kiểm tra/quiz theo mô hình Web. Sinh viên chỉ thấy quiz đã hiển thị và thuộc lớp đang học.
        if (db_has_table($conn, 'bai_kiem_tra')) {
            $sqlQuiz = "SELECT bkt.*, cd.ten_chu_de, nd.ho_ten AS ten_nguoi_tao,
                    kq.id AS bai_lam_quiz_id,
                    kq.tong_diem AS diem_quiz,
                    kq.trang_thai AS trang_thai_quiz,
                    kq.thoi_gian_nop_bai AS thoi_gian_nop_quiz,
                    (SELECT COUNT(*) FROM cau_hoi ch WHERE ch.bai_kiem_tra_id = bkt.id) AS so_cau_hoi
                FROM bai_kiem_tra bkt
                JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = bkt.lop_hoc_phan_id AND svlhp.sinh_vien_id = :svq AND svlhp.trang_thai <> 'da_huy'
                LEFT JOIN chu_de cd ON cd.id = bkt.chu_de_id
                LEFT JOIN nguoi_dung nd ON nd.id = bkt.nguoi_tao_id
                LEFT JOIN ket_qua_kiem_tra kq ON kq.bai_kiem_tra_id = bkt.id AND kq.sinh_vien_id = :svq2 AND kq.trang_thai <> 'dang_lam'
                WHERE bkt.lop_hoc_phan_id = :lhpq
                  AND bkt.trang_thai = 'hien_thi'
                  AND (bkt.thoi_gian_bat_dau IS NULL OR bkt.thoi_gian_bat_dau <= NOW())";
            $paramsQuiz = [':svq' => $sinhVienId, ':svq2' => $sinhVienId, ':lhpq' => $lopHocPhanId];
            if (!empty($chuDeIds) || $locChuaPhanLoai) {
                $topicPartsQuiz = [];
                if (!empty($chuDeIds)) {
                    $placeholdersQuiz = [];
                    foreach ($chuDeIds as $i => $id) {
                        $ph = ':q_chu_de_id_' . $i;
                        $placeholdersQuiz[] = $ph;
                        $paramsQuiz[$ph] = $id;
                    }
                    $topicPartsQuiz[] = 'bkt.chu_de_id IN (' . implode(',', $placeholdersQuiz) . ')';
                }
                if ($locChuaPhanLoai) {
                    $topicPartsQuiz[] = 'bkt.chu_de_id IS NULL';
                }
                $sqlQuiz .= ' AND (' . implode(' OR ', $topicPartsQuiz) . ')';
            }
            $sqlQuiz .= " ORDER BY COALESCE(cd.thu_tu, 9999) ASC, bkt.ngay_tao DESC";
            $stmtQuiz = $conn->prepare($sqlQuiz);
            foreach ($paramsQuiz as $k => $v) {
                $isInt = in_array($k, [':svq', ':svq2', ':lhpq'], true) || str_starts_with($k, ':q_chu_de_id_');
                $stmtQuiz->bindValue($k, $v, $isInt ? PDO::PARAM_INT : PDO::PARAM_STR);
            }
            $stmtQuiz->execute();
            foreach ($stmtQuiz->fetchAll(PDO::FETCH_ASSOC) as $qz) {
                    $result[] = [
                        'id' => (int)$qz['id'],
                        'bai_kiem_tra_id' => (int)$qz['id'],
                        'tieu_de' => $qz['tieu_de'],
                        'mo_ta' => $qz['mo_ta'],
                        'loai_bai_tap' => 'quiz',
                        'duong_dan_file' => null,
                        'yeu_cau_nop_file' => 0,
                        'dinh_dang_file_cho_phep' => null,
                        'so_file_toi_da' => 0,
                        'dung_luong_toi_da_mb' => 0,
                        'cho_phep_nop_lai' => 0,
                        'cho_phep_nop_muon' => 0,
                        'diem_toi_da' => (float)$qz['diem_toi_da'],
                        'han_nop' => $qz['thoi_gian_ket_thuc'],
                        'thoi_gian_gui' => $qz['thoi_gian_bat_dau'],
                        'thoi_gian_lam' => (int)$qz['thoi_gian_lam_bai'],
                        'cho_xem_dap_an' => (int)$qz['hien_dap_an_sau_nop'],
                        'dao_cau_hoi' => (int)$qz['xao_tron_cau_hoi'],
                        'dao_dap_an' => (int)$qz['xao_tron_dap_an'],
                        'lop_hoc_phan_id' => (int)$qz['lop_hoc_phan_id'],
                        'chu_de_id' => $qz['chu_de_id'] !== null ? (int)$qz['chu_de_id'] : null,
                        'ten_chu_de' => $qz['ten_chu_de'] ?: 'Bài kiểm tra',
                        'trang_thai' => 'hien_thi',
                        'ngay_tao' => $qz['ngay_tao'],
                        'ten_nguoi_tao' => $qz['ten_nguoi_tao'],
                        'bai_nop_id' => null,
                        'file_da_nop' => null,
                        'files_da_nop' => [],
                        'diem' => null,
                        'nhan_xet' => null,
                        'trang_thai_nop' => null,
                        'ngay_nop' => null,
                        'bai_lam_quiz_id' => $qz['bai_lam_quiz_id'] !== null ? (int)$qz['bai_lam_quiz_id'] : null,
                        'diem_quiz' => $qz['diem_quiz'] !== null ? (float)$qz['diem_quiz'] : null,
                        'trang_thai_quiz' => $qz['trang_thai_quiz'],
                        'thoi_gian_nop_quiz' => $qz['thoi_gian_nop_quiz'],
                        'so_cau_hoi' => (int)$qz['so_cau_hoi'],
                    ];
                }
            }

        respond("success", "Lấy danh sách bài tập thành công", ["data" => $result]);
    }

    // ─── BÀI TẬP CHƯA NỘP ───────────────────────────────────
    if ($action === "chua_nop") {
        $stmt = $conn->prepare("
            SELECT bt.id, bt.tieu_de, bt.han_nop, bt.lop_hoc_phan_id, lhp.ten_lop, lhp.ma_lop_hoc_phan, mh.ten_mon
            FROM bai_tap bt
            JOIN sinh_vien_lop_hoc_phan svlhp ON bt.lop_hoc_phan_id = svlhp.lop_hoc_phan_id
            JOIN lop_hoc_phan lhp ON bt.lop_hoc_phan_id = lhp.id
            LEFT JOIN mon_hoc mh ON lhp.mon_hoc_id = mh.id
            WHERE svlhp.sinh_vien_id = ?
              AND svlhp.trang_thai = 'dang_hoc'
              AND lhp.trang_thai = 'dang_mo'
              AND bt.trang_thai = 'hien_thi'
              AND (bt.thoi_gian_gui IS NULL OR bt.thoi_gian_gui <= NOW())
              AND COALESCE(bt.loai_bai_tap, 'nop_file') = 'nop_file'
              AND COALESCE(bt.yeu_cau_nop_file, 1) = 1
              AND NOT EXISTS (SELECT 1 FROM bai_nop bn WHERE bn.bai_tap_id = bt.id AND bn.sinh_vien_id = ?)
            ORDER BY bt.han_nop ASC
        ");
        $stmt->execute([$sinhVienId, $sinhVienId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $result = array_map(fn($r) => [
            "id" => (int)$r["id"],
            "tieu_de" => $r["tieu_de"],
            "han_nop" => $r["han_nop"],
            "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
            "ten_lop" => $r["ten_lop"],
            "ma_lop_hoc_phan" => $r["ma_lop_hoc_phan"],
            "ten_mon" => $r["ten_mon"],
        ], $rows);

        respond("success", "Lấy bài tập chưa nộp thành công", ["data" => $result]);
    }

    // ─── NỘP BÀI FILE, HỖ TRỢ 1 HOẶC NHIỀU FILE ────────────
    if ($action === "nop_bai") {
        $baiTapId = (int)($data["bai_tap_id"] ?? 0);
        $duongDanFileCu = trim($data["duong_dan_file"] ?? "");

        if ($baiTapId <= 0) respond("error", "ID bài tập không hợp lệ");

        $chk = $conn->prepare("
            SELECT
                id, han_nop, thoi_gian_gui, trang_thai,
                COALESCE(loai_bai_tap, 'nop_file') AS loai_bai_tap,
                COALESCE(yeu_cau_nop_file, 1) AS yeu_cau_nop_file,
                dinh_dang_file_cho_phep,
                COALESCE(so_file_toi_da, 1) AS so_file_toi_da,
                COALESCE(dung_luong_toi_da_mb, 25) AS dung_luong_toi_da_mb,
                COALESCE(cho_phep_nop_lai, 1) AS cho_phep_nop_lai,
                COALESCE(cho_phep_nop_muon, 1) AS cho_phep_nop_muon
            FROM bai_tap
            WHERE id = ?
            LIMIT 1
        ");
        $chk->execute([$baiTapId]);
        $bt = $chk->fetch(PDO::FETCH_ASSOC);

        if (!$bt) respond("error", "Bài tập không tồn tại");
        if ($bt["loai_bai_tap"] === "quiz") respond("error", "Bài tập quiz không nộp file tại đây");
        if ((int)$bt["yeu_cau_nop_file"] !== 1) respond("error", "Bài tập này không yêu cầu nộp file");
        if (!trang_thai_mo($bt["trang_thai"])) respond("error", "Bài tập đã đóng hoặc đã bị xóa, không thể nộp");
        if ($bt["thoi_gian_gui"] !== null && strtotime($bt["thoi_gian_gui"]) > dt_now_ts()) respond("error", "Bài tập chưa đến thời gian mở");

        $isLate = $bt["han_nop"] !== null && strtotime($bt["han_nop"]) < dt_now_ts();
        if ($isLate && (int)$bt["cho_phep_nop_muon"] !== 1) respond("error", "Bài tập đã quá hạn nộp");
        $trangThaiNop = $isLate ? "nop_muon" : "da_nop";

        $existing = $conn->prepare("SELECT id FROM bai_nop WHERE bai_tap_id = ? AND sinh_vien_id = ? LIMIT 1");
        $existing->execute([$baiTapId, $sinhVienId]);
        $baiNopCu = $existing->fetch(PDO::FETCH_ASSOC);

        if ($baiNopCu && (int)$bt["cho_phep_nop_lai"] !== 1) respond("error", "Bài tập này không cho phép nộp lại");

        $uploaded = $isMultipart ? collect_uploaded_files() : [];

        if (!$isMultipart && $duongDanFileCu !== "") {
            $uploaded = [];
        }

        if ($isMultipart && empty($uploaded)) respond("error", "Vui lòng chọn file để nộp");
        if (!$isMultipart && $duongDanFileCu === "") respond("error", "Vui lòng chọn file để nộp");

        // Host Web đã gộp bai_nop_file vào bai_nop nên mỗi lần nộp chỉ lưu 1 file.
        $maxFiles = 1;
        if (!empty($uploaded) && count($uploaded) > 1) respond("error", "Hệ thống host hiện chỉ hỗ trợ nộp 1 file cho mỗi bài. Vui lòng chọn 1 file.");

        $allowed = normalize_ext_list($bt["dinh_dang_file_cho_phep"] ?? "");
        $maxBytes = max(1, (int)$bt["dung_luong_toi_da_mb"]) * 1024 * 1024;

        $conn->beginTransaction();

        if ($baiNopCu) {
            $baiNopId = (int)$baiNopCu["id"];
            // Giữ ID bài nộp cũ, thông tin file sẽ cập nhật sau khi upload thành công.
        } else {
            $stmt = $conn->prepare("INSERT INTO bai_nop (bai_tap_id, sinh_vien_id, ten_file_goc, duong_dan_file, trang_thai) VALUES (?, ?, NULL, NULL, ?)");
            $stmt->execute([$baiTapId, $sinhVienId, $trangThaiNop]);
            $baiNopId = (int)$conn->lastInsertId();
        }

        $savedFiles = [];
        $firstPath = $duongDanFileCu;

        $tenFileGoc = null;
        $loaiFile = null;
        $kichThuocFile = 0;

        if (!empty($uploaded)) {
            $file = $uploaded[0];
            if ((int)$file["error"] !== UPLOAD_ERR_OK) throw new RuntimeException("Upload file thất bại");
            if ((int)$file["size"] > $maxBytes) throw new RuntimeException("File {$file['name']} vượt quá dung lượng cho phép {$bt['dung_luong_toi_da_mb']}MB");

            $tenGoc = basename($file["name"] ?? "");
            $ext = strtolower(pathinfo($tenGoc, PATHINFO_EXTENSION));
            if ($ext === "") throw new RuntimeException("File {$tenGoc} không có định dạng");
            if (!empty($allowed) && !in_array($ext, $allowed, true)) {
                throw new RuntimeException("File {$tenGoc} không đúng định dạng cho phép: " . implode(', ', $allowed));
            }

            $uploadedCloud = ckc_upload_to_cloudinary($file, 'submissions');
            $firstPath = $uploadedCloud['secure_url'];
            $tenFileGoc = ten_file_host($tenGoc);
            $loaiFile = $ext;
            $kichThuocFile = (int)($uploadedCloud['bytes'] ?? $file["size"]);
            $savedFiles[] = [
                "id" => $baiNopId,
                "ten_file_goc" => $tenFileGoc,
                "duong_dan_file" => $firstPath,
                "loai_file" => $loaiFile,
                "kich_thuoc" => $kichThuocFile,
                "public_id" => $uploadedCloud['public_id'] ?? null,
            ];
        } else {
            // Tương thích cũ: nếu Flutter vẫn gửi đường dẫn text thay vì upload thật.
            $ext = strtolower(pathinfo($duongDanFileCu, PATHINFO_EXTENSION));
            if (!empty($allowed) && !in_array($ext, $allowed, true)) {
                throw new RuntimeException("File không đúng định dạng cho phép: " . implode(', ', $allowed));
            }
            $firstPath = $duongDanFileCu;
            $tenFileGoc = ten_file_host($duongDanFileCu);
            $loaiFile = $ext ?: null;
            $savedFiles[] = ["id" => $baiNopId, "ten_file_goc" => $tenFileGoc, "duong_dan_file" => $firstPath, "loai_file" => $loaiFile, "kich_thuoc" => 0];
        }

        $stmt = $conn->prepare("UPDATE bai_nop SET ten_file_goc = ?, duong_dan_file = ?, trang_thai = ?, ngay_cap_nhat = NOW() WHERE id = ?");
        $stmt->execute([$tenFileGoc, $firstPath, $trangThaiNop, $baiNopId]);

        $conn->commit();

        respond("success", $baiNopCu ? "Cập nhật bài nộp thành công" : "Nộp bài thành công", [
            "id" => $baiNopId,
            "trang_thai_nop" => $trangThaiNop,
            "duong_dan_file" => $firstPath,
            "files" => $savedFiles,
        ]);
    }

    http_response_code(400);
    respond("error", "Hành động không hợp lệ");

} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
