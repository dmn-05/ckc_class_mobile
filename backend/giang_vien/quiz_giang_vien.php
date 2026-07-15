<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim((string)($data["action"] ?? ""));

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}
function int_val($arr, $key, $default = 0) { return (int)($arr[$key] ?? $default); }
function dt_mysql($value) {
    if ($value === null) return null;
    $s = trim((string)$value);
    if ($s === "" || strtolower($s) === "null") return null;
    $s = str_replace('T', ' ', $s);
    $s = preg_replace('/\.\d+/', '', $s);
    $s = preg_replace('/(Z|[+-]\d{2}:?\d{2})$/', '', $s);
    $ts = strtotime($s);
    return $ts === false ? null : date('Y-m-d H:i:s', $ts);
}
function bool_int($v): int { return ($v === true || $v === 1 || $v === '1' || $v === 'true') ? 1 : 0; }
function db_has_column(PDO $conn, string $table, string $column): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME=? AND COLUMN_NAME=?");
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}
function ensure_quiz_schema(PDO $conn): void {
    if (!db_has_column($conn, 'bai_kiem_tra', 'chu_de_id')) {
        $conn->exec("ALTER TABLE bai_kiem_tra ADD COLUMN chu_de_id INT NULL AFTER lop_hoc_phan_id");
    }
}
function mobile_status_to_web($v): string {
    $v = trim((string)$v);
    if ($v === 'dang_mo' || $v === 'hien_thi') return 'hien_thi';
    if ($v === 'da_dong' || $v === 'an') return 'an';
    if ($v === 'nhap') return 'nhap';
    return 'hien_thi';
}
function web_status_to_mobile($v): string { return $v === 'hien_thi' ? 'dang_mo' : 'da_dong'; }
function mobile_type_to_web($v): string {
    return match(trim((string)$v)) {
        'nhieu_dap_an' => 'multiple_choice',
        'dung_sai' => 'true_false',
        'tu_luan', 'essay' => 'essay',
        default => 'single_choice',
    };
}
function web_type_to_mobile($v): string {
    return match(trim((string)$v)) {
        'multiple_choice' => 'nhieu_dap_an',
        'true_false' => 'dung_sai',
        'essay' => 'tu_luan',
        default => 'mot_dap_an',
    };
}
function exam_form_type(array $questions): string {
    $hasEssay = false; $hasChoice = false;
    foreach ($questions as $q) {
        if ($q['loai'] === 'essay') $hasEssay = true; else $hasChoice = true;
    }
    if ($hasEssay && $hasChoice) return 'hon_hop';
    if ($hasEssay) return 'tu_luan';
    return 'trac_nghiem';
}
function normalize_questions($raw) {
    if (!is_array($raw)) respond('error', 'Dữ liệu câu hỏi không hợp lệ');
    if (count($raw) <= 0) respond('error', 'Quiz phải có ít nhất 1 câu hỏi');
    $out = [];
    foreach ($raw as $i => $q) {
        $noiDung = trim((string)($q['noi_dung'] ?? $q['content'] ?? ''));
        $loai = mobile_type_to_web($q['loai_cau_hoi'] ?? $q['type'] ?? 'mot_dap_an');
        $diem = (float)($q['diem'] ?? $q['score'] ?? 1);
        $giaiThich = trim((string)($q['giai_thich'] ?? $q['explanation'] ?? ''));
        $dapAnRaw = $q['dap_an'] ?? $q['options'] ?? [];
        if ($noiDung === '') respond('error', 'Câu ' . ($i + 1) . ' chưa có nội dung');
        if ($diem <= 0) respond('error', 'Điểm câu ' . ($i + 1) . ' không hợp lệ');
        $dapAn = [];
        if ($loai !== 'essay') {
            if (!is_array($dapAnRaw) || count($dapAnRaw) < 2) respond('error', 'Câu ' . ($i + 1) . ' phải có ít nhất 2 đáp án');
            $soDung = 0;
            foreach ($dapAnRaw as $j => $a) {
                $noiDungDA = trim((string)($a['noi_dung'] ?? $a['content'] ?? ''));
                $laDung = bool_int($a['la_dap_an_dung'] ?? $a['isCorrect'] ?? 0);
                if ($noiDungDA === '') respond('error', 'Đáp án ' . ($j + 1) . ' của câu ' . ($i + 1) . ' đang trống');
                if ($laDung) $soDung++;
                $dapAn[] = [
                    'id' => (int)($a['id'] ?? 0),
                    'noi_dung' => $noiDungDA,
                    'la_dap_an_dung' => $laDung,
                    'thu_tu' => (int)($a['thu_tu'] ?? $j),
                ];
            }
            if (($loai === 'single_choice' || $loai === 'true_false') && $soDung !== 1) respond('error', 'Câu ' . ($i + 1) . ' phải có đúng 1 đáp án đúng');
            if ($loai === 'multiple_choice' && $soDung < 1) respond('error', 'Câu ' . ($i + 1) . ' phải có ít nhất 1 đáp án đúng');
        }
        $out[] = [
            'id' => (int)($q['id'] ?? 0),
            'noi_dung' => $noiDung,
            'loai' => $loai,
            'diem' => $diem,
            'giai_thich' => $giaiThich !== '' ? $giaiThich : null,
            'thu_tu' => (int)($q['thu_tu'] ?? $q['order'] ?? ($i + 1)),
            'dap_an' => $dapAn,
        ];
    }
    return $out;
}
function find_exam_for_lecturer(PDO $conn, int $examId, int $nguoiTaoId = 0) {
    $sql = "SELECT bkt.* FROM bai_kiem_tra bkt WHERE bkt.id = ?";
    $params = [$examId];
    if ($nguoiTaoId > 0) { $sql .= " AND bkt.nguoi_tao_id = ?"; $params[] = $nguoiTaoId; }
    $stmt = $conn->prepare($sql . " LIMIT 1");
    $stmt->execute($params);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) respond('error', 'Bài kiểm tra không tồn tại hoặc bạn không có quyền thao tác');
    return $row;
}
function replace_questions(PDO $conn, int $examId, array $questions): void {
    $count = (int)$conn->query("SELECT COUNT(*) FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = " . (int)$examId)->fetchColumn();
    if ($count > 0) respond('error', 'Bài kiểm tra đã có sinh viên làm, không thể thay đổi câu hỏi để tránh sai kết quả');
    $stmt = $conn->prepare("DELETE FROM cau_hoi WHERE bai_kiem_tra_id = ?");
    $stmt->execute([$examId]);
    $stmtQ = $conn->prepare("INSERT INTO cau_hoi (bai_kiem_tra_id, loai, noi_dung, diem, giai_thich, thu_tu) VALUES (?,?,?,?,?,?)");
    $stmtA = $conn->prepare("INSERT INTO dap_an (cau_hoi_id, noi_dung, la_dap_an_dung, thu_tu) VALUES (?,?,?,?)");
    foreach ($questions as $i => $q) {
        $stmtQ->execute([$examId, $q['loai'], $q['noi_dung'], $q['diem'], $q['giai_thich'], $q['thu_tu']]);
        $qid = (int)$conn->lastInsertId();
        foreach ($q['dap_an'] as $a) {
            $stmtA->execute([$qid, $a['noi_dung'], $a['la_dap_an_dung'] ? 1 : 0, $a['thu_tu']]);
        }
    }
}
function exam_detail_payload(PDO $conn, array $exam): array {
    $stmtQ = $conn->prepare("SELECT * FROM cau_hoi WHERE bai_kiem_tra_id = ? ORDER BY thu_tu ASC, id ASC");
    $stmtQ->execute([(int)$exam['id']]);
    $qs = $stmtQ->fetchAll(PDO::FETCH_ASSOC);
    $questions = [];
    foreach ($qs as $q) {
        $stmtA = $conn->prepare("SELECT * FROM dap_an WHERE cau_hoi_id = ? ORDER BY thu_tu ASC, id ASC");
        $stmtA->execute([(int)$q['id']]);
        $answers = $stmtA->fetchAll(PDO::FETCH_ASSOC);
        $questions[] = [
            'id' => (int)$q['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'noi_dung' => $q['noi_dung'],
            'loai_cau_hoi' => web_type_to_mobile($q['loai']),
            'diem' => (float)$q['diem'],
            'giai_thich' => $q['giai_thich'],
            'thu_tu' => (int)$q['thu_tu'],
            'dap_an' => array_map(fn($a) => [
                'id' => (int)$a['id'],
                'cau_hoi_id' => (int)$a['cau_hoi_id'],
                'noi_dung' => $a['noi_dung'],
                'la_dap_an_dung' => (int)$a['la_dap_an_dung'],
                'thu_tu' => (int)$a['thu_tu'],
            ], $answers),
        ];
    }
    return [
        'id' => (int)$exam['id'],
        'bai_tap_id' => (int)$exam['id'],
        'bai_kiem_tra_id' => (int)$exam['id'],
        'tieu_de' => $exam['tieu_de'],
        'mo_ta' => $exam['mo_ta'],
        'lop_hoc_phan_id' => (int)$exam['lop_hoc_phan_id'],
        'chu_de_id' => isset($exam['chu_de_id']) && $exam['chu_de_id'] !== null ? (int)$exam['chu_de_id'] : null,
        'nguoi_tao_id' => (int)$exam['nguoi_tao_id'],
        'han_nop' => $exam['thoi_gian_ket_thuc'],
        'thoi_gian_lam' => (int)$exam['thoi_gian_lam_bai'],
        'cho_xem_dap_an' => (int)$exam['hien_dap_an_sau_nop'],
        'dao_cau_hoi' => (int)$exam['xao_tron_cau_hoi'],
        'dao_dap_an' => (int)$exam['xao_tron_dap_an'],
        'trang_thai' => web_status_to_mobile($exam['trang_thai']),
        'ngay_tao' => $exam['ngay_tao'],
        'ngay_cap_nhat' => $exam['ngay_cap_nhat'],
        'cau_hoi' => $questions,
    ];
}


function current_questions_signature(PDO $conn, int $examId): array {
    $stmtQ = $conn->prepare("SELECT id, loai, noi_dung, diem, COALESCE(giai_thich,'') AS giai_thich, thu_tu FROM cau_hoi WHERE bai_kiem_tra_id = ? ORDER BY thu_tu ASC, id ASC");
    $stmtQ->execute([$examId]);
    $out = [];
    foreach ($stmtQ->fetchAll(PDO::FETCH_ASSOC) as $q) {
        $stmtA = $conn->prepare("SELECT id, noi_dung, la_dap_an_dung, thu_tu FROM dap_an WHERE cau_hoi_id = ? ORDER BY thu_tu ASC, id ASC");
        $stmtA->execute([(int)$q['id']]);
        $answers = [];
        foreach ($stmtA->fetchAll(PDO::FETCH_ASSOC) as $a) {
            $answers[] = [
                'noi_dung' => trim((string)$a['noi_dung']),
                'la_dap_an_dung' => (int)$a['la_dap_an_dung'],
                'thu_tu' => (int)$a['thu_tu'],
            ];
        }
        $out[] = [
            'loai' => (string)$q['loai'],
            'noi_dung' => trim((string)$q['noi_dung']),
            'diem' => round((float)$q['diem'], 4),
            'giai_thich' => trim((string)$q['giai_thich']),
            'thu_tu' => (int)$q['thu_tu'],
            'dap_an' => $answers,
        ];
    }
    return $out;
}
function submitted_questions_signature(array $questions): array {
    $out = [];
    foreach ($questions as $q) {
        $answers = [];
        foreach (($q['dap_an'] ?? []) as $a) {
            $answers[] = [
                'noi_dung' => trim((string)$a['noi_dung']),
                'la_dap_an_dung' => !empty($a['la_dap_an_dung']) ? 1 : 0,
                'thu_tu' => (int)$a['thu_tu'],
            ];
        }
        $out[] = [
            'loai' => (string)$q['loai'],
            'noi_dung' => trim((string)$q['noi_dung']),
            'diem' => round((float)$q['diem'], 4),
            'giai_thich' => trim((string)($q['giai_thich'] ?? '')),
            'thu_tu' => (int)$q['thu_tu'],
            'dap_an' => $answers,
        ];
    }
    return $out;
}
function quiz_has_results(PDO $conn, int $examId): bool {
    $stmt = $conn->prepare("SELECT COUNT(*) FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = ?");
    $stmt->execute([$examId]);
    return (int)$stmt->fetchColumn() > 0;
}
function same_question_content(PDO $conn, int $examId, array $questions): bool {
    return json_encode(current_questions_signature($conn, $examId), JSON_UNESCAPED_UNICODE) === json_encode(submitted_questions_signature($questions), JSON_UNESCAPED_UNICODE);
}

try {
    if ($action === 'tao_quiz') {
        ckc_require_lhp_mutable($conn, (int)($data['lop_hoc_phan_id'] ?? 0));
    } elseif (in_array($action, ['sua_quiz', 'xoa_quiz'], true)) {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_quiz($conn, (int)($data['bai_tap_id'] ?? 0)));
    } elseif ($action === 'cham_tu_luan') {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_ket_qua_quiz($conn, (int)($data['bai_lam_quiz_id'] ?? 0)));
    }

    ensure_quiz_schema($conn);

    if ($action === 'tao_quiz') {
        $tieuDe = trim((string)($data['tieu_de'] ?? ''));
        $moTa = trim((string)($data['mo_ta'] ?? ''));
        $lopHocPhanId = int_val($data, 'lop_hoc_phan_id');
        $nguoiTaoId = int_val($data, 'nguoi_tao_id');
        $hanNop = dt_mysql($data['han_nop'] ?? null);
        $thoiGianLam = int_val($data, 'thoi_gian_lam', 60);
        $questions = normalize_questions($data['cau_hoi'] ?? []);
        $diemToiDa = array_sum(array_map(fn($q) => (float)$q['diem'], $questions));
        if ($tieuDe === '') respond('error', 'Tiêu đề quiz không được trống');
        if ($lopHocPhanId <= 0) respond('error', 'ID lớp học phần không hợp lệ');
        if ($nguoiTaoId <= 0) respond('error', 'ID người tạo không hợp lệ');
        if ($thoiGianLam <= 0) $thoiGianLam = 60;
        $conn->beginTransaction();
        $chuDeId = int_val($data, 'chu_de_id');
        $stmt = $conn->prepare("INSERT INTO bai_kiem_tra
            (tieu_de, mo_ta, lop_hoc_phan_id, chu_de_id, nguoi_tao_id, thoi_gian_bat_dau, thoi_gian_ket_thuc, thoi_gian_lam_bai, diem_toi_da, diem_dat, so_lan_thi_toi_da, hinh_thuc, xao_tron_cau_hoi, xao_tron_dap_an, hien_dap_an_sau_nop, trang_thai)
            VALUES (?,?,?,?,?,NULL,?,?,?,?,?,?,?,?,?,?)");
        $stmt->execute([$tieuDe, $moTa ?: null, $lopHocPhanId, $chuDeId > 0 ? $chuDeId : null, $nguoiTaoId, $hanNop, $thoiGianLam, $diemToiDa > 0 ? $diemToiDa : 10, max(0, ($diemToiDa > 0 ? $diemToiDa : 10) / 2), 1, exam_form_type($questions), bool_int($data['dao_cau_hoi'] ?? 0), bool_int($data['dao_dap_an'] ?? 0), bool_int($data['cho_xem_dap_an'] ?? 1), mobile_status_to_web($data['trang_thai'] ?? 'dang_mo')]);
        $examId = (int)$conn->lastInsertId();
        replace_questions($conn, $examId, $questions);
        $conn->commit();
        respond('success', 'Tạo bài kiểm tra thành công', ['id' => $examId, 'bai_kiem_tra_id' => $examId]);
    }
    if ($action === 'chi_tiet_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        $nguoiTaoId = int_val($data, 'nguoi_tao_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $exam = find_exam_for_lecturer($conn, $examId, $nguoiTaoId);
        respond('success', 'Lấy chi tiết bài kiểm tra thành công', ['data' => exam_detail_payload($conn, $exam)]);
    }
    if ($action === 'sua_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        $nguoiTaoId = int_val($data, 'nguoi_tao_id');
        $exam = find_exam_for_lecturer($conn, $examId, $nguoiTaoId);
        $questions = normalize_questions($data['cau_hoi'] ?? []);
        $diemToiDa = array_sum(array_map(fn($q) => (float)$q['diem'], $questions));
        $chuDeId = int_val($data, 'chu_de_id');
        $hasResults = quiz_has_results($conn, $examId);
        $conn->beginTransaction();
        if ($hasResults) {
            if (!same_question_content($conn, $examId, $questions)) {
                $conn->rollBack();
                respond('error', 'Bài kiểm tra đã có sinh viên làm, không thể thay đổi câu hỏi để tránh sai kết quả');
            }
            // Đã có sinh viên làm: vẫn cho sửa thông tin quản lý như tiêu đề, mô tả, hạn, trạng thái và chủ đề.
            // Không cập nhật lại câu hỏi/đáp án/điểm tối đa để không làm sai lịch sử kết quả.
            $stmt = $conn->prepare("UPDATE bai_kiem_tra SET tieu_de=?, mo_ta=?, chu_de_id=?, thoi_gian_ket_thuc=?, thoi_gian_lam_bai=?, trang_thai=?, ngay_cap_nhat=NOW() WHERE id=?");
            $stmt->execute([trim((string)$data['tieu_de']), trim((string)($data['mo_ta'] ?? '')) ?: null, $chuDeId > 0 ? $chuDeId : null, dt_mysql($data['han_nop'] ?? null), int_val($data, 'thoi_gian_lam', 60), mobile_status_to_web($data['trang_thai'] ?? 'dang_mo'), $examId]);
        } else {
            $stmt = $conn->prepare("UPDATE bai_kiem_tra SET tieu_de=?, mo_ta=?, chu_de_id=?, thoi_gian_ket_thuc=?, thoi_gian_lam_bai=?, diem_toi_da=?, diem_dat=?, hinh_thuc=?, xao_tron_cau_hoi=?, xao_tron_dap_an=?, hien_dap_an_sau_nop=?, trang_thai=?, ngay_cap_nhat=NOW() WHERE id=?");
            $stmt->execute([trim((string)$data['tieu_de']), trim((string)($data['mo_ta'] ?? '')) ?: null, $chuDeId > 0 ? $chuDeId : null, dt_mysql($data['han_nop'] ?? null), int_val($data, 'thoi_gian_lam', 60), $diemToiDa > 0 ? $diemToiDa : 10, max(0, ($diemToiDa > 0 ? $diemToiDa : 10)/2), exam_form_type($questions), bool_int($data['dao_cau_hoi'] ?? 0), bool_int($data['dao_dap_an'] ?? 0), bool_int($data['cho_xem_dap_an'] ?? 1), mobile_status_to_web($data['trang_thai'] ?? 'dang_mo'), $examId]);
            replace_questions($conn, $examId, $questions);
        }
        $conn->commit();
        respond('success', $hasResults ? 'Cập nhật thông tin quản lý bài kiểm tra thành công' : 'Cập nhật bài kiểm tra thành công');
    }
    if ($action === 'xoa_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        $nguoiTaoId = int_val($data, 'nguoi_tao_id');
        find_exam_for_lecturer($conn, $examId, $nguoiTaoId);
        $stmt = $conn->prepare("DELETE FROM bai_kiem_tra WHERE id = ?");
        $stmt->execute([$examId]);
        respond('success', 'Xóa bài kiểm tra thành công');
    }
    if ($action === 'ket_qua_quiz_giang_vien') {
        $examId = int_val($data, 'bai_tap_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $stmt = $conn->prepare("SELECT kq.*, bkt.diem_toi_da, sv.ma_sinh_vien, nd.ho_ten, nd.email,
                (SELECT COUNT(*) FROM cau_hoi WHERE bai_kiem_tra_id = kq.bai_kiem_tra_id) AS tong_cau,
                (SELECT COUNT(*) FROM chi_tiet_ket_qua ct WHERE ct.ket_qua_kiem_tra_id = kq.id AND ct.diem_dat > 0) AS so_cau_dung,
                (SELECT COUNT(*) FROM cau_hoi ch WHERE ch.bai_kiem_tra_id = kq.bai_kiem_tra_id AND ch.loai = 'essay') AS so_cau_tu_luan,
                (SELECT COUNT(*)
                   FROM chi_tiet_ket_qua ct
                   JOIN cau_hoi ch ON ch.id = ct.cau_hoi_id
                  WHERE ct.ket_qua_kiem_tra_id = kq.id
                    AND ch.loai = 'essay'
                    AND (ct.diem_dat IS NULL OR ct.diem_dat = 0)
                    AND COALESCE(ct.dap_an_tu_luan, '') <> '') AS so_cau_tu_luan_chua_cham
            FROM ket_qua_kiem_tra kq
            JOIN bai_kiem_tra bkt ON bkt.id = kq.bai_kiem_tra_id
            JOIN sinh_vien sv ON sv.id = kq.sinh_vien_id
            JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
            WHERE kq.bai_kiem_tra_id = ?
            ORDER BY kq.thoi_gian_nop_bai DESC, kq.ngay_tao DESC");
        $stmt->execute([$examId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $result = array_map(fn($r) => [
            'bai_lam_quiz_id' => (int)$r['id'],
            'bai_tap_id' => (int)$r['bai_kiem_tra_id'],
            'bai_kiem_tra_id' => (int)$r['bai_kiem_tra_id'],
            'sinh_vien_id' => (int)$r['sinh_vien_id'],
            'ma_sinh_vien' => $r['ma_sinh_vien'],
            'ho_ten' => $r['ho_ten'],
            'email' => $r['email'],
            'trang_thai' => $r['trang_thai'],
            'tong_cau' => (int)$r['tong_cau'],
            'so_cau_dung' => (int)$r['so_cau_dung'],
            'diem' => (float)$r['tong_diem'],
            'diem_trac_nghiem' => (float)$r['diem_trac_nghiem'],
            'diem_tu_luan' => (float)$r['diem_tu_luan'],
            'diem_toi_da' => (float)$r['diem_toi_da'],
            'so_cau_tu_luan' => (int)$r['so_cau_tu_luan'],
            'so_cau_tu_luan_chua_cham' => (int)$r['so_cau_tu_luan_chua_cham'],
            'can_cham_tu_luan' => ((int)$r['so_cau_tu_luan'] > 0 && $r['trang_thai'] === 'da_nop') ? 1 : 0,
            'thoi_gian_bat_dau' => $r['thoi_gian_bat_dau'],
            'thoi_gian_nop' => $r['thoi_gian_nop_bai'],
        ], $rows);
        respond('success', 'Lấy kết quả bài kiểm tra thành công', ['data' => $result]);
    }

    if ($action === 'chi_tiet_bai_lam_quiz_giang_vien') {
        $ketQuaId = int_val($data, 'bai_lam_quiz_id');
        if ($ketQuaId <= 0) respond('error', 'ID bài làm không hợp lệ');
        $stmt = $conn->prepare("SELECT kq.*, bkt.tieu_de, bkt.diem_toi_da, sv.ma_sinh_vien, nd.ho_ten, nd.email
            FROM ket_qua_kiem_tra kq
            JOIN bai_kiem_tra bkt ON bkt.id = kq.bai_kiem_tra_id
            JOIN sinh_vien sv ON sv.id = kq.sinh_vien_id
            JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
            WHERE kq.id = ? LIMIT 1");
        $stmt->execute([$ketQuaId]);
        $kq = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$kq) respond('error', 'Không tìm thấy bài làm');

        $stmt = $conn->prepare("SELECT ch.id AS cau_hoi_id, ch.noi_dung, ch.diem AS diem_toi_da, ch.giai_thich,
                ct.dap_an_tu_luan, ct.diem_dat, ct.id AS chi_tiet_id
            FROM cau_hoi ch
            LEFT JOIN chi_tiet_ket_qua ct ON ct.cau_hoi_id = ch.id AND ct.ket_qua_kiem_tra_id = ?
            WHERE ch.bai_kiem_tra_id = ? AND ch.loai = 'essay'
            ORDER BY ch.thu_tu ASC, ch.id ASC");
        $stmt->execute([$ketQuaId, (int)$kq['bai_kiem_tra_id']]);
        $essayRows = array_map(fn($r) => [
            'chi_tiet_id' => $r['chi_tiet_id'] !== null ? (int)$r['chi_tiet_id'] : null,
            'cau_hoi_id' => (int)$r['cau_hoi_id'],
            'noi_dung' => $r['noi_dung'],
            'giai_thich' => $r['giai_thich'],
            'dap_an_tu_luan' => $r['dap_an_tu_luan'],
            'diem_toi_da' => (float)$r['diem_toi_da'],
            'diem_dat' => $r['diem_dat'] !== null ? (float)$r['diem_dat'] : 0,
        ], $stmt->fetchAll(PDO::FETCH_ASSOC));

        respond('success', 'Lấy chi tiết bài tự luận thành công', ['data' => [
            'bai_lam_quiz_id' => (int)$kq['id'],
            'bai_tap_id' => (int)$kq['bai_kiem_tra_id'],
            'bai_kiem_tra_id' => (int)$kq['bai_kiem_tra_id'],
            'tieu_de' => $kq['tieu_de'],
            'sinh_vien_id' => (int)$kq['sinh_vien_id'],
            'ma_sinh_vien' => $kq['ma_sinh_vien'],
            'ho_ten' => $kq['ho_ten'],
            'email' => $kq['email'],
            'trang_thai' => $kq['trang_thai'],
            'diem_trac_nghiem' => (float)$kq['diem_trac_nghiem'],
            'diem_tu_luan' => (float)$kq['diem_tu_luan'],
            'tong_diem' => (float)$kq['tong_diem'],
            'diem_toi_da' => (float)$kq['diem_toi_da'],
            'cau_hoi_tu_luan' => $essayRows,
        ]]);
    }

    if ($action === 'cham_tu_luan') {
        $ketQuaId = int_val($data, 'bai_lam_quiz_id');
        $diemRows = $data['diem_tu_luan'] ?? [];
        if ($ketQuaId <= 0) respond('error', 'ID bài làm không hợp lệ');
        if (!is_array($diemRows)) respond('error', 'Dữ liệu điểm tự luận không hợp lệ');

        $stmt = $conn->prepare("SELECT * FROM ket_qua_kiem_tra WHERE id = ? LIMIT 1");
        $stmt->execute([$ketQuaId]);
        $kq = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$kq) respond('error', 'Không tìm thấy bài làm');

        $scoreMap = [];
        foreach ($diemRows as $row) {
            $qid = (int)($row['cau_hoi_id'] ?? 0);
            if ($qid <= 0) continue;
            $scoreMap[$qid] = (float)($row['diem'] ?? 0);
        }

        $stmtQ = $conn->prepare("SELECT id, diem FROM cau_hoi WHERE bai_kiem_tra_id = ? AND loai = 'essay'");
        $stmtQ->execute([(int)$kq['bai_kiem_tra_id']]);
        $essayQuestions = $stmtQ->fetchAll(PDO::FETCH_ASSOC);
        if (!$essayQuestions) respond('error', 'Bài kiểm tra này không có câu tự luận');

        $conn->beginTransaction();
        $upd = $conn->prepare("UPDATE chi_tiet_ket_qua SET diem_dat = ? WHERE ket_qua_kiem_tra_id = ? AND cau_hoi_id = ?");
        $essayTotal = 0.0;
        foreach ($essayQuestions as $q) {
            $qid = (int)$q['id'];
            $max = (float)$q['diem'];
            $score = $scoreMap[$qid] ?? 0.0;
            if ($score < 0 || $score > $max) {
                throw new RuntimeException('Điểm câu tự luận không được nhỏ hơn 0 hoặc lớn hơn điểm tối đa');
            }
            $upd->execute([$score, $ketQuaId, $qid]);
            $essayTotal += $score;
        }
        $tong = (float)$kq['diem_trac_nghiem'] + $essayTotal;
        $stmt = $conn->prepare("UPDATE ket_qua_kiem_tra SET diem_tu_luan = ?, tong_diem = ?, trang_thai = 'da_cham', ngay_cap_nhat = NOW() WHERE id = ?");
        $stmt->execute([$essayTotal, $tong, $ketQuaId]);
        $conn->commit();
        respond('success', 'Chấm tự luận thành công', ['data' => [
            'bai_lam_quiz_id' => $ketQuaId,
            'diem_tu_luan' => $essayTotal,
            'tong_diem' => $tong,
            'trang_thai' => 'da_cham',
        ]]);
    }

    http_response_code(400); respond('error', 'Hành động không hợp lệ');
} catch (PDOException $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    http_response_code(500); respond('error', 'Lỗi server: ' . $e->getMessage());
} catch (Throwable $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    http_response_code(500); respond('error', 'Lỗi xử lý: ' . $e->getMessage());
}
?>
