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

function str_val($arr, $key, $default = "") {
    return trim((string)($arr[$key] ?? $default));
}

function int_val($arr, $key, $default = 0) {
    return (int)($arr[$key] ?? $default);
}

function bool_int($v) {
    return ($v === true || $v === 1 || $v === "1" || $v === "true") ? 1 : 0;
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



function clean_ext_csv($raw) {
    $parts = is_array($raw) ? $raw : explode(',', (string)$raw);
    $out = [];
    foreach ($parts as $p) {
        $e = strtolower(trim((string)$p));
        $e = ltrim($e, '.');
        if ($e !== '' && preg_match('/^[a-z0-9]+$/', $e)) {
            $out[] = $e;
        }
    }
    $out = array_values(array_unique($out));
    return empty($out) ? null : implode(',', $out);
}

function clamp_int($value, $default, $min, $max) {
    $n = (int)$value;
    if ($n <= 0) $n = $default;
    if ($n < $min) $n = $min;
    if ($n > $max) $n = $max;
    return $n;
}

function float_or_default($value, $default) {
    if ($value === null || $value === '') return (float)$default;
    $n = (float)$value;
    return $n > 0 ? $n : (float)$default;
}

function ensure_assignment_schema(PDO $conn) {
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
    $addCol('bai_tap', 'noi_dung', 'noi_dung TEXT NULL AFTER tieu_de');
    $addCol('bai_tap', 'huong_dan', 'huong_dan TEXT NULL AFTER noi_dung');
    $addCol('bai_tap', 'file_url', 'file_url TEXT NULL AFTER cho_phep_nop_muon');
    $addCol('bai_tap', 'file_name', 'file_name VARCHAR(255) NULL AFTER file_url');
    $addCol('bai_tap', 'cho_phep_nop_tre', 'cho_phep_nop_tre TINYINT(1) DEFAULT 0 AFTER dao_dap_an');
    $addCol('bai_tap', 'tyle_phat_tre', 'tyle_phat_tre INT DEFAULT 10 AFTER cho_phep_nop_tre');
    if (db_has_table($conn, 'bai_kiem_tra')) {
        $addCol('bai_kiem_tra', 'chu_de_id', 'chu_de_id INT NULL AFTER lop_hoc_phan_id');
    }

    // Host Web đã gộp bai_nop_file vào bai_nop nên không tạo bảng phụ nữa.

}

function lay_dap_an_theo_cau_hoi($conn, $cauHoiId, $hienDapAnDung = true) {
    $stmt = $conn->prepare("SELECT id, cau_hoi_id, noi_dung, la_dap_an_dung, thu_tu FROM dap_an_quiz WHERE cau_hoi_id = ? AND trang_thai = 'hien_thi' ORDER BY thu_tu ASC, id ASC");
    $stmt->execute([$cauHoiId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_map(function ($r) use ($hienDapAnDung) {
        $item = [
            "id"         => (int)$r["id"],
            "cau_hoi_id" => (int)$r["cau_hoi_id"],
            "noi_dung"   => $r["noi_dung"],
            "thu_tu"     => (int)$r["thu_tu"],
        ];
        if ($hienDapAnDung) {
            $item["la_dap_an_dung"] = (int)$r["la_dap_an_dung"];
        }
        return $item;
    }, $rows);
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
    return $value === 'hien_thi' ? 'dang_mo' : $value;
}

function trang_thai_mobile_sang_db($value) {
    // CSDL chung cho phép cả dang_mo và hien_thi. Giữ dang_mo cho Mobile để không vỡ UI,
    // Web vẫn đọc được vì enum đã mở rộng.
    return in_array($value, ['dang_mo', 'hien_thi', 'da_dong', 'an'], true) ? $value : 'dang_mo';
}

function first_file_url_for_assignment(PDO $conn, int $baiTapId): ?string {
    if (!db_has_table($conn, 'tep_tin') || !db_has_table($conn, 'tep_tin_bai_tap')) return null;
    $stmt = $conn->prepare("SELECT tt.duong_dan
        FROM tep_tin_bai_tap ttbt
        JOIN tep_tin tt ON tt.id = ttbt.tep_tin_id
        WHERE ttbt.bai_tap_id = ? AND COALESCE(tt.trang_thai, 'dang_su_dung') = 'dang_su_dung'
        ORDER BY ttbt.id ASC LIMIT 1");
    $stmt->execute([$baiTapId]);
    $url = $stmt->fetchColumn();
    return $url !== false && trim((string)$url) !== '' ? (string)$url : null;
}

function sync_bai_tap_file_metadata(PDO $conn, int $baiTapId, ?string $url, ?string $tenFile, int $nguoiTaoId = 0): void {
    $url = trim((string)$url);
    if ($url === '' || !db_has_table($conn, 'tep_tin') || !db_has_table($conn, 'tep_tin_bai_tap')) return;

    $tenFile = trim((string)$tenFile);
    if ($tenFile === '') $tenFile = ckc_file_name_from_url($url);
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

    $chk = $conn->prepare("SELECT COUNT(*) FROM tep_tin_bai_tap WHERE bai_tap_id = ? AND tep_tin_id = ?");
    $chk->execute([$baiTapId, $tepTinId]);
    if ((int)$chk->fetchColumn() === 0) {
        $stmt = $conn->prepare("INSERT INTO tep_tin_bai_tap (bai_tap_id, tep_tin_id, created_at, updated_at) VALUES (?, ?, NOW(), NOW())");
        $stmt->execute([$baiTapId, $tepTinId]);
    }
}

try {
    ensure_assignment_schema($conn);

    // Các action quiz cũ trong file này dùng bảng cau_hoi_quiz/dap_an_quiz/bai_lam_quiz.
    // Sau khi chuyển sang mô hình Web, không cho chạy các action cũ để tránh lỗi 500 nếu đã DROP bảng quiz Mobile.
    if (in_array($action, ["them_quiz", "chi_tiet_quiz", "ket_qua_quiz"], true)) {
        respond("error", "Quiz đã chuyển sang mô hình Web. Hãy dùng endpoint giang_vien/quiz_giang_vien.php");
    }

    switch ($action) {
        // ─── DANH SÁCH BÀI TẬP / QUIZ THEO LỚP ─────────────────────
        case "danh_sach": {
    $lopHocPhanId = int_val($data, "lop_hoc_phan_id");
    $trangThai    = str_val($data, "trang_thai");
    $tuKhoa       = str_val($data, "tu_khoa");

    $chuDeIds = $data["chu_de_ids"] ?? [];
    if (!is_array($chuDeIds)) {
        $chuDeIds = [];
    }

    // Cho phép lọc thêm nhóm "Chưa phân loại" bằng id đặc biệt -1.
    // Khi không chọn chủ đề nào: hiển thị tất cả.
    // Khi chọn -1: hiển thị bài chưa gắn chủ đề và các quiz Web chưa có chu_de_id.
    $rawChuDeIds = array_map("intval", $chuDeIds);
    $locChuaPhanLoai = in_array(-1, $rawChuDeIds, true);
    $chuDeIds = array_values(array_filter($rawChuDeIds, function ($x) {
        return $x > 0;
    }));

    if ($lopHocPhanId <= 0) {
        respond("error", "ID lớp học phần không hợp lệ");
    }

    $sql = "SELECT bt.*,
                COALESCE(bt.loai_bai_tap, 'nop_file') AS loai_bai_tap,
                cd.ten_chu_de,
                nd.ho_ten AS ten_nguoi_tao,
                (SELECT tt.duong_dan FROM tep_tin_bai_tap ttbt JOIN tep_tin tt ON tt.id = ttbt.tep_tin_id WHERE ttbt.bai_tap_id = bt.id AND COALESCE(tt.trang_thai, 'dang_su_dung') = 'dang_su_dung' ORDER BY ttbt.id ASC LIMIT 1) AS tep_tin_dau,
                (SELECT COUNT(*) FROM bai_nop bn 
                 WHERE bn.bai_tap_id = bt.id) AS so_bai_nop_file,
                (SELECT COUNT(*) FROM bai_nop bn2 
                 WHERE bn2.bai_tap_id = bt.id 
                 AND bn2.trang_thai = 'da_cham') AS so_da_cham,
                0 AS so_bai_lam_quiz,
                0 AS so_cau_hoi
            FROM bai_tap bt
            LEFT JOIN chu_de cd ON bt.chu_de_id = cd.id
            LEFT JOIN nguoi_dung nd ON bt.nguoi_tao_id = nd.id
            WHERE bt.lop_hoc_phan_id = :lhp_id
              AND bt.trang_thai <> 'an'
              AND COALESCE(bt.loai_bai_tap, 'nop_file') <> 'quiz'";

    $params = [
        ":lhp_id" => $lopHocPhanId,
    ];

    if ($tuKhoa !== "") {
        $sql .= " AND bt.tieu_de LIKE :tk";
        $params[":tk"] = "%$tuKhoa%";
    }

    if ($trangThai !== "") {
        $sql .= " AND bt.trang_thai = :tt";
        $params[":tt"] = $trangThai;
    }

    if (!empty($chuDeIds) || $locChuaPhanLoai) {
        $topicParts = [];
        if (!empty($chuDeIds)) {
            $placeholders = [];
            foreach ($chuDeIds as $i => $id) {
                $ph = ":chu_de_id_" . $i;
                $placeholders[] = $ph;
                $params[$ph] = $id;
            }
            $topicParts[] = "bt.chu_de_id IN (" . implode(",", $placeholders) . ")";
        }
        if ($locChuaPhanLoai) {
            $topicParts[] = "bt.chu_de_id IS NULL";
        }
        $sql .= " AND (" . implode(" OR ", $topicParts) . ")";
    }

    $sql .= " ORDER BY COALESCE(cd.thu_tu, 9999) ASC, bt.ngay_tao DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $k => $v) {
        $isInt = $k === ":lhp_id" || str_starts_with($k, ":chu_de_id_");
        $stmt->bindValue($k, $v, $isInt ? PDO::PARAM_INT : PDO::PARAM_STR);
    }

    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $result = array_map(function ($r) {
        return [
            "id"              => (int)$r["id"],
            "tieu_de"         => $r["tieu_de"],
            "mo_ta"           => $r["mo_ta"],
            "loai_bai_tap"    => $r["loai_bai_tap"] ?? "nop_file",
            "duong_dan_file"  => $r["duong_dan_file"] ?: ($r["file_url"] ?? ($r["tep_tin_dau"] ?? null)),
            "yeu_cau_nop_file" => isset($r["yeu_cau_nop_file"]) ? (int)$r["yeu_cau_nop_file"] : 1,
            "dinh_dang_file_cho_phep" => $r["dinh_dang_file_cho_phep"] ?? null,
            "so_file_toi_da" => isset($r["so_file_toi_da"]) ? (int)$r["so_file_toi_da"] : 1,
            "dung_luong_toi_da_mb" => isset($r["dung_luong_toi_da_mb"]) ? (int)$r["dung_luong_toi_da_mb"] : 25,
            "cho_phep_nop_lai" => isset($r["cho_phep_nop_lai"]) ? (int)$r["cho_phep_nop_lai"] : 1,
            "cho_phep_nop_muon" => isset($r["cho_phep_nop_muon"]) ? (int)$r["cho_phep_nop_muon"] : 1,
            "diem_toi_da" => isset($r["diem_toi_da"]) ? (float)$r["diem_toi_da"] : 10,
            "han_nop"         => $r["han_nop"],
            "thoi_gian_gui"   => $r["thoi_gian_gui"],
            "trang_thai_gui"  => trang_thai_gui($r["thoi_gian_gui"]),
            "thoi_gian_lam"   => $r["thoi_gian_lam"] !== null ? (int)$r["thoi_gian_lam"] : null,
            "cho_xem_dap_an"  => isset($r["cho_xem_dap_an"]) ? (int)$r["cho_xem_dap_an"] : 0,
            "dao_cau_hoi"     => isset($r["dao_cau_hoi"]) ? (int)$r["dao_cau_hoi"] : 0,
            "dao_dap_an"      => isset($r["dao_dap_an"]) ? (int)$r["dao_dap_an"] : 0,
            "lop_hoc_phan_id" => (int)$r["lop_hoc_phan_id"],
            "chu_de_id"       => $r["chu_de_id"] !== null ? (int)$r["chu_de_id"] : null,
            "ten_chu_de"      => $r["ten_chu_de"],
            "nguoi_tao_id"    => (int)$r["nguoi_tao_id"],
            "ten_nguoi_tao"   => $r["ten_nguoi_tao"],
            "trang_thai"      => trang_thai_db_sang_mobile($r["trang_thai"]),
            "ngay_tao"        => $r["ngay_tao"],
            "ngay_cap_nhat"   => $r["ngay_cap_nhat"],
            "so_bai_nop"      => ($r["loai_bai_tap"] ?? "nop_file") === "quiz"
                ? (int)$r["so_bai_lam_quiz"]
                : (int)$r["so_bai_nop_file"],
            "so_bai_nop_file" => (int)$r["so_bai_nop_file"],
            "so_da_cham"      => (int)$r["so_da_cham"],
            "so_bai_lam_quiz" => (int)$r["so_bai_lam_quiz"],
            "so_cau_hoi"      => (int)$r["so_cau_hoi"],
        ];
    }, $rows);


    // Ghép thêm quiz theo mô hình Web: bai_kiem_tra -> cau_hoi -> ket_qua_kiem_tra.
    // Quiz cũng có chu_de_id để lọc/quản lý giống bài tập nộp file.
    if (db_has_table($conn, 'bai_kiem_tra')) {
        $sqlQuiz = "SELECT bkt.*, cd.ten_chu_de, nd.ho_ten AS ten_nguoi_tao,
                (SELECT COUNT(*) FROM ket_qua_kiem_tra kq WHERE kq.bai_kiem_tra_id = bkt.id AND kq.trang_thai <> 'dang_lam') AS so_bai_lam_quiz,
                (SELECT COUNT(*) FROM ket_qua_kiem_tra kq2 WHERE kq2.bai_kiem_tra_id = bkt.id AND kq2.trang_thai = 'da_cham') AS so_da_cham_quiz,
                (SELECT COUNT(*) FROM cau_hoi ch WHERE ch.bai_kiem_tra_id = bkt.id) AS so_cau_hoi
            FROM bai_kiem_tra bkt
            LEFT JOIN chu_de cd ON cd.id = bkt.chu_de_id
            LEFT JOIN nguoi_dung nd ON nd.id = bkt.nguoi_tao_id
            WHERE bkt.lop_hoc_phan_id = :lhp_id
              AND bkt.trang_thai <> 'nhap'
              AND bkt.trang_thai <> 'an'";
        $paramsQuiz = [':lhp_id' => $lopHocPhanId];
        if ($tuKhoa !== '') {
            $sqlQuiz .= " AND bkt.tieu_de LIKE :tk";
            $paramsQuiz[':tk'] = "%$tuKhoa%";
        }
        if ($trangThai !== '') {
            $sqlQuiz .= " AND bkt.trang_thai = :tt";
            $paramsQuiz[':tt'] = trang_thai_mobile_sang_db($trangThai);
        }
        if (!empty($chuDeIds) || $locChuaPhanLoai) {
            $topicPartsQuiz = [];
            if (!empty($chuDeIds)) {
                $placeholdersQuiz = [];
                foreach ($chuDeIds as $i => $id) {
                    $ph = ":q_chu_de_id_" . $i;
                    $placeholdersQuiz[] = $ph;
                    $paramsQuiz[$ph] = $id;
                }
                $topicPartsQuiz[] = "bkt.chu_de_id IN (" . implode(",", $placeholdersQuiz) . ")";
            }
            if ($locChuaPhanLoai) {
                $topicPartsQuiz[] = "bkt.chu_de_id IS NULL";
            }
            $sqlQuiz .= " AND (" . implode(" OR ", $topicPartsQuiz) . ")";
        }
        $sqlQuiz .= " ORDER BY COALESCE(cd.thu_tu, 9999) ASC, bkt.ngay_tao DESC";
        $stmtQuiz = $conn->prepare($sqlQuiz);
        foreach ($paramsQuiz as $k => $v) {
            $isInt = $k === ':lhp_id' || str_starts_with($k, ':q_chu_de_id_');
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
                'trang_thai_gui' => trang_thai_gui($qz['thoi_gian_bat_dau']),
                'thoi_gian_lam' => (int)$qz['thoi_gian_lam_bai'],
                'cho_xem_dap_an' => (int)$qz['hien_dap_an_sau_nop'],
                'dao_cau_hoi' => (int)$qz['xao_tron_cau_hoi'],
                'dao_dap_an' => (int)$qz['xao_tron_dap_an'],
                'lop_hoc_phan_id' => (int)$qz['lop_hoc_phan_id'],
                'chu_de_id' => $qz['chu_de_id'] !== null ? (int)$qz['chu_de_id'] : null,
                'ten_chu_de' => $qz['ten_chu_de'] ?: 'Bài kiểm tra',
                'nguoi_tao_id' => (int)$qz['nguoi_tao_id'],
                'ten_nguoi_tao' => $qz['ten_nguoi_tao'],
                'trang_thai' => trang_thai_db_sang_mobile($qz['trang_thai']),
                'ngay_tao' => $qz['ngay_tao'],
                'ngay_cap_nhat' => $qz['ngay_cap_nhat'],
                'so_bai_nop' => (int)$qz['so_bai_lam_quiz'],
                'so_bai_nop_file' => 0,
                'so_da_cham' => (int)$qz['so_da_cham_quiz'],
                'so_bai_lam_quiz' => (int)$qz['so_bai_lam_quiz'],
                'so_cau_hoi' => (int)$qz['so_cau_hoi'],
            ];
        }
    }

    respond("success", "Lấy danh sách bài tập thành công", [
        "data" => $result,
    ]);
}

        // ─── THÊM BÀI TẬP NỘP FILE - GIỮ TƯƠNG THÍCH CODE CŨ ──────
        case "them": {
            $tieuDe        = str_val($data, "tieu_de");
            $moTa          = str_val($data, "mo_ta");
            $duongDanFile  = str_val($data, "duong_dan_file");
            $hanNop        = norm_datetime($data["han_nop"] ?? "");
            $thoiGianGui   = norm_datetime($data["thoi_gian_gui"] ?? "");
            $lopHocPhanId  = int_val($data, "lop_hoc_phan_id");
            $chuDeId       = int_val($data, "chu_de_id");
            $nguoiTaoId    = int_val($data, "nguoi_tao_id");
            $trangThai     = str_val($data, "trang_thai", "dang_mo");
            $yeuCauNopFile = bool_int($data["yeu_cau_nop_file"] ?? 1);
            $dinhDangFileChoPhep = clean_ext_csv($data["dinh_dang_file_cho_phep"] ?? "");
            $soFileToiDa = clamp_int($data["so_file_toi_da"] ?? 1, 1, 1, 10);
            $dungLuongToiDaMb = clamp_int($data["dung_luong_toi_da_mb"] ?? 25, 25, 1, 100);
            $choPhepNopLai = bool_int($data["cho_phep_nop_lai"] ?? 1);
            $choPhepNopMuon = bool_int($data["cho_phep_nop_muon"] ?? 1);
            $diemToiDa = float_or_default($data["diem_toi_da"] ?? 10, 10);

            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");
            if ($nguoiTaoId <= 0) respond("error", "ID người tạo không hợp lệ");
            $trangThai = trang_thai_mobile_sang_db($trangThai);
            if (!in_array($trangThai, ["dang_mo", "hien_thi", "da_dong"], true)) $trangThai = "dang_mo";

            $fileName = $duongDanFile !== "" ? ckc_file_name_from_url($duongDanFile) : null;
            $conn->beginTransaction();
            $stmt = $conn->prepare("INSERT INTO bai_tap
                (tieu_de, noi_dung, huong_dan, mo_ta, loai_bai_tap, duong_dan_file, file_url, file_name, yeu_cau_nop_file, dinh_dang_file_cho_phep, so_file_toi_da, dung_luong_toi_da_mb, cho_phep_nop_lai, cho_phep_nop_muon, cho_phep_nop_tre, diem_toi_da, han_nop, thoi_gian_gui, lop_hoc_phan_id, chu_de_id, nguoi_tao_id, trang_thai)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
            $stmt->execute([
                $tieuDe,
                $moTa ?: null,
                $moTa ?: null,
                $moTa ?: null,
                "nop_file",
                $duongDanFile ?: null,
                $duongDanFile ?: null,
                $fileName,
                $yeuCauNopFile,
                $dinhDangFileChoPhep,
                $soFileToiDa,
                $dungLuongToiDaMb,
                $choPhepNopLai,
                $choPhepNopMuon,
                $choPhepNopMuon,
                $diemToiDa,
                $hanNop,
                $thoiGianGui,
                $lopHocPhanId,
                $chuDeId > 0 ? $chuDeId : null,
                $nguoiTaoId,
                $trangThai
            ]);
            $newId = (int)$conn->lastInsertId();
            sync_bai_tap_file_metadata($conn, $newId, $duongDanFile ?: null, $fileName, $nguoiTaoId);
            $conn->commit();

            respond("success", "Thêm bài tập thành công", ["id" => $newId]);
        }

        // ─── THÊM QUIZ / TRẮC NGHIỆM ───────────────────────────────
        case "them_quiz": {
            $tieuDe        = str_val($data, "tieu_de");
            $moTa          = str_val($data, "mo_ta");
            $hanNop        = norm_datetime($data["han_nop"] ?? "");
            $thoiGianGui   = norm_datetime($data["thoi_gian_gui"] ?? "");
            $lopHocPhanId  = int_val($data, "lop_hoc_phan_id");
            $chuDeId       = int_val($data, "chu_de_id");
            $nguoiTaoId    = int_val($data, "nguoi_tao_id");
            $trangThai     = str_val($data, "trang_thai", "dang_mo");
            $thoiGianLam   = int_val($data, "thoi_gian_lam", 0);
            $choXemDapAn   = bool_int($data["cho_xem_dap_an"] ?? 0);
            $daoCauHoi     = bool_int($data["dao_cau_hoi"] ?? 0);
            $daoDapAn      = bool_int($data["dao_dap_an"] ?? 0);
            $cauHoiList    = $data["cau_hoi"] ?? [];

            if ($tieuDe === "") respond("error", "Tiêu đề quiz không được để trống");
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");
            if ($nguoiTaoId <= 0) respond("error", "ID người tạo không hợp lệ");
            if (!is_array($cauHoiList) || count($cauHoiList) === 0) respond("error", "Quiz phải có ít nhất 1 câu hỏi");
            if (!in_array($trangThai, ["dang_mo", "da_dong"], true)) $trangThai = "dang_mo";

            foreach ($cauHoiList as $idx => $ch) {
                $noiDungCH = trim((string)($ch["noi_dung"] ?? ""));
                $loaiCH    = trim((string)($ch["loai_cau_hoi"] ?? "mot_dap_an"));
                $dapAnList = $ch["dap_an"] ?? [];

                if ($noiDungCH === "") respond("error", "Câu hỏi thứ " . ($idx + 1) . " chưa có nội dung");
                if (!in_array($loaiCH, ["mot_dap_an", "nhieu_dap_an", "dung_sai"], true)) {
                    respond("error", "Loại câu hỏi thứ " . ($idx + 1) . " không hợp lệ");
                }
                if (!is_array($dapAnList) || count($dapAnList) < 2) {
                    respond("error", "Câu hỏi thứ " . ($idx + 1) . " phải có ít nhất 2 đáp án");
                }

                $soDung = 0;
                foreach ($dapAnList as $j => $da) {
                    if (trim((string)($da["noi_dung"] ?? "")) === "") {
                        respond("error", "Đáp án thứ " . ($j + 1) . " của câu " . ($idx + 1) . " đang trống");
                    }
                    if (bool_int($da["la_dap_an_dung"] ?? 0) === 1) $soDung++;
                }

                if ($loaiCH === "mot_dap_an" || $loaiCH === "dung_sai") {
                    if ($soDung !== 1) respond("error", "Câu hỏi thứ " . ($idx + 1) . " phải có đúng 1 đáp án đúng");
                } else {
                    if ($soDung < 1) respond("error", "Câu hỏi thứ " . ($idx + 1) . " phải có ít nhất 1 đáp án đúng");
                }
            }

            $conn->beginTransaction();

            $trangThai = trang_thai_mobile_sang_db($trangThai);
            $stmt = $conn->prepare("INSERT INTO bai_tap
                (tieu_de, noi_dung, huong_dan, mo_ta, loai_bai_tap, duong_dan_file, han_nop, thoi_gian_gui, thoi_gian_lam, cho_xem_dap_an, dao_cau_hoi, dao_dap_an, lop_hoc_phan_id, chu_de_id, nguoi_tao_id, trang_thai)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
            $stmt->execute([
                $tieuDe,
                $moTa ?: null,
                $moTa ?: null,
                $moTa ?: null,
                "quiz",
                null,
                $hanNop,
                $thoiGianGui,
                $thoiGianLam > 0 ? $thoiGianLam : null,
                $choXemDapAn,
                $daoCauHoi,
                $daoDapAn,
                $lopHocPhanId,
                $chuDeId > 0 ? $chuDeId : null,
                $nguoiTaoId,
                $trangThai
            ]);
            $baiTapId = (int)$conn->lastInsertId();

            $stmtCH = $conn->prepare("INSERT INTO cau_hoi_quiz (bai_tap_id, noi_dung, loai_cau_hoi, diem, thu_tu) VALUES (?,?,?,?,?)");
            $stmtDA = $conn->prepare("INSERT INTO dap_an_quiz (cau_hoi_id, noi_dung, la_dap_an_dung, thu_tu) VALUES (?,?,?,?)");

            foreach ($cauHoiList as $i => $ch) {
                $stmtCH->execute([
                    $baiTapId,
                    trim((string)$ch["noi_dung"]),
                    trim((string)($ch["loai_cau_hoi"] ?? "mot_dap_an")),
                    (float)($ch["diem"] ?? 1),
                    $i + 1
                ]);
                $cauHoiId = (int)$conn->lastInsertId();

                foreach (($ch["dap_an"] ?? []) as $j => $da) {
                    $stmtDA->execute([
                        $cauHoiId,
                        trim((string)$da["noi_dung"]),
                        bool_int($da["la_dap_an_dung"] ?? 0),
                        $j + 1
                    ]);
                }
            }

            $conn->commit();
            respond("success", "Tạo quiz thành công", ["id" => $baiTapId]);
        }

        // ─── CHI TIẾT QUIZ CHO GIẢNG VIÊN ──────────────────────────
        case "chi_tiet_quiz": {
            $baiTapId = int_val($data, "bai_tap_id");
            if ($baiTapId <= 0) respond("error", "ID bài tập không hợp lệ");

            $stmt = $conn->prepare("SELECT bt.*, COALESCE(bt.loai_bai_tap, 'nop_file') AS loai_bai_tap, cd.ten_chu_de, nd.ho_ten AS ten_nguoi_tao
                                    FROM bai_tap bt
                                    LEFT JOIN chu_de cd ON bt.chu_de_id = cd.id
                                    LEFT JOIN nguoi_dung nd ON bt.nguoi_tao_id = nd.id
                                    WHERE bt.id = ? LIMIT 1");
            $stmt->execute([$baiTapId]);
            $bt = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$bt) respond("error", "Bài tập không tồn tại");
            if (($bt["loai_bai_tap"] ?? "nop_file") !== "quiz") respond("error", "Bài tập này không phải quiz");

            $stmtCH = $conn->prepare("SELECT * FROM cau_hoi_quiz WHERE bai_tap_id = ? AND trang_thai = 'hien_thi' ORDER BY thu_tu ASC, id ASC");
            $stmtCH->execute([$baiTapId]);
            $cauHoiRows = $stmtCH->fetchAll(PDO::FETCH_ASSOC);

            $cauHoi = [];
            foreach ($cauHoiRows as $ch) {
                $cauHoi[] = [
                    "id"            => (int)$ch["id"],
                    "bai_tap_id"    => (int)$ch["bai_tap_id"],
                    "noi_dung"      => $ch["noi_dung"],
                    "loai_cau_hoi"  => $ch["loai_cau_hoi"],
                    "diem"          => (float)$ch["diem"],
                    "thu_tu"        => (int)$ch["thu_tu"],
                    "dap_an"        => lay_dap_an_theo_cau_hoi($conn, (int)$ch["id"], true),
                ];
            }

            respond("success", "Lấy chi tiết quiz thành công", ["data" => [
                "id"              => (int)$bt["id"],
                "tieu_de"         => $bt["tieu_de"],
                "mo_ta"           => $bt["mo_ta"],
                "loai_bai_tap"    => $bt["loai_bai_tap"],
                "han_nop"         => $bt["han_nop"],
                "thoi_gian_gui"   => $bt["thoi_gian_gui"],
                "trang_thai_gui"  => trang_thai_gui($bt["thoi_gian_gui"]),
                "thoi_gian_lam"   => $bt["thoi_gian_lam"] !== null ? (int)$bt["thoi_gian_lam"] : null,
                "cho_xem_dap_an"  => (int)$bt["cho_xem_dap_an"],
                "dao_cau_hoi"     => (int)$bt["dao_cau_hoi"],
                "dao_dap_an"      => (int)$bt["dao_dap_an"],
                "lop_hoc_phan_id" => (int)$bt["lop_hoc_phan_id"],
                "chu_de_id"       => $bt["chu_de_id"] !== null ? (int)$bt["chu_de_id"] : null,
                "ten_chu_de"      => $bt["ten_chu_de"],
                "nguoi_tao_id"    => (int)$bt["nguoi_tao_id"],
                "ten_nguoi_tao"   => $bt["ten_nguoi_tao"],
                "trang_thai"      => trang_thai_db_sang_mobile($bt["trang_thai"]),
                "cau_hoi"         => $cauHoi,
            ]]);
        }

        // ─── KẾT QUẢ QUIZ CHO GIẢNG VIÊN ───────────────────────────
        case "ket_qua_quiz": {
            $baiTapId = int_val($data, "bai_tap_id");
            if ($baiTapId <= 0) respond("error", "ID bài tập không hợp lệ");

            $stmt = $conn->prepare("SELECT
                    blq.id,
                    blq.bai_tap_id,
                    blq.sinh_vien_id,
                    sv.ma_sinh_vien,
                    nd.ho_ten,
                    blq.thoi_gian_bat_dau,
                    blq.thoi_gian_nop,
                    blq.tong_cau,
                    blq.so_cau_dung,
                    blq.diem,
                    blq.trang_thai
                FROM bai_lam_quiz blq
                JOIN sinh_vien sv ON blq.sinh_vien_id = sv.id
                JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
                WHERE blq.bai_tap_id = ?
                ORDER BY blq.thoi_gian_nop DESC, blq.ngay_tao DESC");
            $stmt->execute([$baiTapId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $result = array_map(fn($r) => [
                "id"                 => (int)$r["id"],
                "bai_tap_id"         => (int)$r["bai_tap_id"],
                "sinh_vien_id"       => (int)$r["sinh_vien_id"],
                "ma_sinh_vien"       => $r["ma_sinh_vien"],
                "ho_ten"             => $r["ho_ten"],
                "thoi_gian_bat_dau"  => $r["thoi_gian_bat_dau"],
                "thoi_gian_nop"      => $r["thoi_gian_nop"],
                "tong_cau"           => (int)$r["tong_cau"],
                "so_cau_dung"        => (int)$r["so_cau_dung"],
                "diem"               => $r["diem"] !== null ? (float)$r["diem"] : null,
                "trang_thai"         => $r["trang_thai"],
            ], $rows);

            respond("success", "Lấy kết quả quiz thành công", ["data" => $result]);
        }

        // ─── SỬA BÀI TẬP NỘP FILE CƠ BẢN ───────────────────────────
        case "sua": {
            $id           = int_val($data, "id");
            $tieuDe       = str_val($data, "tieu_de");
            $moTa         = str_val($data, "mo_ta");
            $duongDanFile = str_val($data, "duong_dan_file");
            $hanNop       = norm_datetime($data["han_nop"] ?? "");
            $thoiGianGui  = norm_datetime($data["thoi_gian_gui"] ?? "");
            $chuDeId      = int_val($data, "chu_de_id");
            $trangThai    = str_val($data, "trang_thai", "dang_mo");
            $yeuCauNopFile = bool_int($data["yeu_cau_nop_file"] ?? 1);
            $dinhDangFileChoPhep = clean_ext_csv($data["dinh_dang_file_cho_phep"] ?? "");
            $soFileToiDa = clamp_int($data["so_file_toi_da"] ?? 1, 1, 1, 10);
            $dungLuongToiDaMb = clamp_int($data["dung_luong_toi_da_mb"] ?? 25, 25, 1, 100);
            $choPhepNopLai = bool_int($data["cho_phep_nop_lai"] ?? 1);
            $choPhepNopMuon = bool_int($data["cho_phep_nop_muon"] ?? 1);
            $diemToiDa = float_or_default($data["diem_toi_da"] ?? 10, 10);

            if ($id <= 0) respond("error", "ID bài tập không hợp lệ");
            if ($tieuDe === "") respond("error", "Tiêu đề không được để trống");
            $trangThai = trang_thai_mobile_sang_db($trangThai);
            if (!in_array($trangThai, ["dang_mo", "hien_thi", "da_dong"], true)) $trangThai = "dang_mo";

            $fileName = $duongDanFile !== "" ? ckc_file_name_from_url($duongDanFile) : null;
            $conn->beginTransaction();
            $stmt = $conn->prepare("UPDATE bai_tap
                SET tieu_de=?, noi_dung=?, huong_dan=?, mo_ta=?, duong_dan_file=?, file_url=?, file_name=?, yeu_cau_nop_file=?, dinh_dang_file_cho_phep=?, so_file_toi_da=?, dung_luong_toi_da_mb=?, cho_phep_nop_lai=?, cho_phep_nop_muon=?, cho_phep_nop_tre=?, diem_toi_da=?, han_nop=?, thoi_gian_gui=?, chu_de_id=?, trang_thai=?, ngay_cap_nhat=NOW()
                WHERE id=? AND COALESCE(loai_bai_tap, 'nop_file')='nop_file'");
            $stmt->execute([
                $tieuDe,
                $moTa ?: null,
                $moTa ?: null,
                $moTa ?: null,
                $duongDanFile ?: null,
                $duongDanFile ?: null,
                $fileName,
                $yeuCauNopFile,
                $dinhDangFileChoPhep,
                $soFileToiDa,
                $dungLuongToiDaMb,
                $choPhepNopLai,
                $choPhepNopMuon,
                $choPhepNopMuon,
                $diemToiDa,
                $hanNop,
                $thoiGianGui,
                $chuDeId > 0 ? $chuDeId : null,
                $trangThai,
                $id
            ]);
            sync_bai_tap_file_metadata($conn, $id, $duongDanFile ?: null, $fileName, 0);
            $conn->commit();

            respond("success", "Cập nhật bài tập thành công");
        }

        // ─── XÓA MỀM BÀI TẬP: ẩn khỏi sinh viên, không mất bài nộp/kết quả quiz ───
        case "xoa": {
            $id = int_val($data, "id");
            if ($id <= 0) respond("error", "ID bài tập không hợp lệ");

            $stmt = $conn->prepare("UPDATE bai_tap SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=?");
            $stmt->execute([$id]);

            respond("success", "Xóa bài tập thành công");
        }

        default:
            http_response_code(400);
            respond("error", "Hành động không hợp lệ");
    }
} catch (PDOException $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
} catch (Throwable $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond("error", "Lỗi xử lý: " . $e->getMessage());
}
?>
