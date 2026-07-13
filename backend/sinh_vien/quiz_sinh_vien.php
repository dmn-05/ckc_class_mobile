<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim((string)($data["action"] ?? ""));
$sinhVienId = (int)($data["sinh_vien_id"] ?? 0);

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}
function int_val($arr, $key, $default = 0) { return (int)($arr[$key] ?? $default); }
function sort_int_array($arr) { $out = array_values(array_unique(array_map('intval', is_array($arr) ? $arr : []))); sort($out); return $out; }
function web_type_to_mobile($v): string {
    return match(trim((string)$v)) {
        'multiple_choice' => 'nhieu_dap_an',
        'true_false' => 'dung_sai',
        'essay' => 'tu_luan',
        default => 'mot_dap_an',
    };
}
function lay_exam_va_quyen(PDO $conn, int $examId, int $sinhVienId, bool $checkOpen = true) {
    $stmt = $conn->prepare("SELECT bkt.*
        FROM bai_kiem_tra bkt
        JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = bkt.lop_hoc_phan_id
        WHERE bkt.id = ? AND svlhp.sinh_vien_id = ? AND svlhp.trang_thai = 'dang_hoc'
        LIMIT 1");
    $stmt->execute([$examId, $sinhVienId]);
    $exam = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$exam) respond('error', 'Bạn không có quyền làm bài kiểm tra này hoặc bài không tồn tại');
    if ($checkOpen) {
        if ($exam['trang_thai'] !== 'hien_thi') respond('error', 'Bài kiểm tra chưa được mở hoặc đã bị ẩn');
        if (!empty($exam['thoi_gian_bat_dau']) && strtotime($exam['thoi_gian_bat_dau']) > time()) respond('error', 'Bài kiểm tra chưa đến thời gian làm');
        if (!empty($exam['thoi_gian_ket_thuc']) && strtotime($exam['thoi_gian_ket_thuc']) < time()) respond('error', 'Bài kiểm tra đã hết hạn');
    }
    return $exam;
}
function latest_attempt(PDO $conn, int $examId, int $sinhVienId) {
    $stmt = $conn->prepare("SELECT * FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = ? AND sinh_vien_id = ? ORDER BY id DESC LIMIT 1");
    $stmt->execute([$examId, $sinhVienId]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}
function start_attempt(PDO $conn, array $exam, int $sinhVienId) {
    $last = latest_attempt($conn, (int)$exam['id'], $sinhVienId);
    if ($last && $last['trang_thai'] === 'dang_lam') return $last;
    $countStmt = $conn->prepare("SELECT COUNT(*) FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = ? AND sinh_vien_id = ?");
    $countStmt->execute([(int)$exam['id'], $sinhVienId]);
    if ((int)$countStmt->fetchColumn() >= (int)$exam['so_lan_thi_toi_da']) respond('error', 'Bạn đã hết số lần làm bài kiểm tra này');
    $stmt = $conn->prepare("INSERT INTO ket_qua_kiem_tra (sinh_vien_id, bai_kiem_tra_id, thoi_gian_bat_dau, trang_thai) VALUES (?, ?, NOW(), 'dang_lam')");
    $stmt->execute([$sinhVienId, (int)$exam['id']]);
    return latest_attempt($conn, (int)$exam['id'], $sinhVienId);
}
function question_payload(PDO $conn, array $exam, bool $includeCorrect = false): array {
    $orderQ = (int)$exam['xao_tron_cau_hoi'] === 1 ? 'RAND()' : 'thu_tu ASC, id ASC';
    $stmtQ = $conn->prepare("SELECT * FROM cau_hoi WHERE bai_kiem_tra_id = ? ORDER BY $orderQ");
    $stmtQ->execute([(int)$exam['id']]);
    $rows = $stmtQ->fetchAll(PDO::FETCH_ASSOC);
    $out = [];
    foreach ($rows as $q) {
        $answers = [];
        if ($q['loai'] !== 'essay') {
            $orderA = (int)$exam['xao_tron_dap_an'] === 1 ? 'RAND()' : 'thu_tu ASC, id ASC';
            $stmtA = $conn->prepare("SELECT * FROM dap_an WHERE cau_hoi_id = ? ORDER BY $orderA");
            $stmtA->execute([(int)$q['id']]);
            foreach ($stmtA->fetchAll(PDO::FETCH_ASSOC) as $a) {
                $item = [
                    'id' => (int)$a['id'],
                    'cau_hoi_id' => (int)$a['cau_hoi_id'],
                    'noi_dung' => $a['noi_dung'],
                    'thu_tu' => (int)$a['thu_tu'],
                ];
                if ($includeCorrect) $item['la_dap_an_dung'] = (int)$a['la_dap_an_dung'];
                $answers[] = $item;
            }
        }
        $out[] = [
            'id' => (int)$q['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'noi_dung' => $q['noi_dung'],
            'loai_cau_hoi' => web_type_to_mobile($q['loai']),
            'diem' => (float)$q['diem'],
            'giai_thich' => $includeCorrect ? $q['giai_thich'] : null,
            'thu_tu' => (int)$q['thu_tu'],
            'dap_an' => $answers,
        ];
    }
    return $out;
}
try {
    if ($sinhVienId <= 0) respond('error', 'ID sinh viên không hợp lệ');
    if ($action === 'bat_dau_quiz' || $action === 'lay_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, true);
        $attempt = start_attempt($conn, $exam, $sinhVienId);
        if ($action === 'bat_dau_quiz') {
            respond('success', 'Bắt đầu bài kiểm tra thành công', ['data' => [
                'bai_lam_quiz_id' => (int)$attempt['id'],
                'bai_tap_id' => (int)$exam['id'],
                'bai_kiem_tra_id' => (int)$exam['id'],
                'tieu_de' => $exam['tieu_de'],
                'thoi_gian_lam' => (int)$exam['thoi_gian_lam_bai'],
                'thoi_gian_bat_dau' => $attempt['thoi_gian_bat_dau'],
                'trang_thai' => $attempt['trang_thai'],
                'da_nop' => $attempt['trang_thai'] !== 'dang_lam',
            ]]);
        }
        if ($attempt['trang_thai'] !== 'dang_lam') respond('error', 'Bạn đã nộp bài kiểm tra này, vui lòng xem kết quả');
        respond('success', 'Lấy bài kiểm tra thành công', ['data' => [
            'id' => (int)$exam['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'tieu_de' => $exam['tieu_de'],
            'mo_ta' => $exam['mo_ta'],
            'han_nop' => $exam['thoi_gian_ket_thuc'],
            'thoi_gian_lam' => (int)$exam['thoi_gian_lam_bai'],
            'thoi_gian_bat_dau' => $attempt['thoi_gian_bat_dau'],
            'bai_lam_quiz_id' => (int)$attempt['id'],
            'cho_xem_dap_an' => (int)$exam['hien_dap_an_sau_nop'],
            'cau_hoi' => question_payload($conn, $exam, false),
        ]]);
    }
    if ($action === 'nop_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, true);
        $attempt = start_attempt($conn, $exam, $sinhVienId);
        if ($attempt['trang_thai'] !== 'dang_lam') respond('error', 'Bạn đã nộp bài kiểm tra này, không thể nộp lại');
        $answersRaw = $data['dap_an'] ?? [];
        if (!is_array($answersRaw)) respond('error', 'Dữ liệu đáp án không hợp lệ');
        $answerMap = [];
        foreach ($answersRaw as $item) {
            $qid = (int)($item['cau_hoi_id'] ?? 0);
            if ($qid <= 0) continue;
            $answerMap[$qid] = [
                'ids' => sort_int_array($item['dap_an_ids'] ?? []),
                'essay' => isset($item['dap_an_tu_luan']) ? trim((string)$item['dap_an_tu_luan']) : null,
            ];
        }
        $stmtQ = $conn->prepare("SELECT * FROM cau_hoi WHERE bai_kiem_tra_id = ? ORDER BY thu_tu ASC, id ASC");
        $stmtQ->execute([$examId]);
        $questions = $stmtQ->fetchAll(PDO::FETCH_ASSOC);
        if (!$questions) respond('error', 'Bài kiểm tra chưa có câu hỏi');
        $autoScore = 0.0; $essayScore = 0.0; $hasEssay = false; $correctCount = 0;
        $conn->beginTransaction();
        $del = $conn->prepare("DELETE FROM chi_tiet_ket_qua WHERE ket_qua_kiem_tra_id = ?");
        $del->execute([(int)$attempt['id']]);
        $ins = $conn->prepare("INSERT INTO chi_tiet_ket_qua (ket_qua_kiem_tra_id, cau_hoi_id, dap_an_id, dap_an_ids, dap_an_tu_luan, diem_dat) VALUES (?,?,?,?,?,?)");
        foreach ($questions as $q) {
            $qid = (int)$q['id'];
            $user = $answerMap[$qid] ?? ['ids' => [], 'essay' => null];
            $score = 0.0; $dapAnId = null; $dapAnIdsJson = null; $essay = null;
            if ($q['loai'] === 'essay') {
                $hasEssay = true;
                $essay = $user['essay'];
            } elseif ($q['loai'] === 'multiple_choice') {
                $selected = $user['ids'];
                $stmt = $conn->prepare("SELECT id FROM dap_an WHERE cau_hoi_id = ? AND la_dap_an_dung = 1 ORDER BY id ASC");
                $stmt->execute([$qid]);
                $correct = sort_int_array($stmt->fetchAll(PDO::FETCH_COLUMN));
                $dapAnIdsJson = json_encode($selected, JSON_UNESCAPED_UNICODE);
                if ($selected === $correct && count($selected) > 0) { $score = (float)$q['diem']; $autoScore += $score; $correctCount++; }
            } else {
                $selected = $user['ids'];
                $dapAnId = $selected[0] ?? null;
                $stmt = $conn->prepare("SELECT id FROM dap_an WHERE cau_hoi_id = ? AND la_dap_an_dung = 1 LIMIT 1");
                $stmt->execute([$qid]);
                $correct = (int)($stmt->fetchColumn() ?: 0);
                if ($dapAnId !== null && (int)$dapAnId === $correct) { $score = (float)$q['diem']; $autoScore += $score; $correctCount++; }
            }
            $ins->execute([(int)$attempt['id'], $qid, $dapAnId, $dapAnIdsJson, $essay, $score]);
        }
        $status = $hasEssay ? 'da_nop' : 'da_cham';
        $upd = $conn->prepare("UPDATE ket_qua_kiem_tra SET thoi_gian_nop_bai = NOW(), diem_trac_nghiem = ?, diem_tu_luan = ?, tong_diem = ?, trang_thai = ?, ngay_cap_nhat = NOW() WHERE id = ?");
        $upd->execute([$autoScore, $essayScore, $autoScore + $essayScore, $status, (int)$attempt['id']]);
        $conn->commit();
        respond('success', $hasEssay ? 'Nộp bài thành công, chờ giảng viên chấm tự luận' : 'Nộp bài thành công', ['data' => [
            'bai_lam_quiz_id' => (int)$attempt['id'],
            'bai_tap_id' => $examId,
            'tong_cau' => count($questions),
            'so_cau_dung' => $correctCount,
            'diem' => $autoScore,
            'trang_thai' => $status,
        ]]);
    }
    if ($action === 'ket_qua_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, false);
        $stmt = $conn->prepare("SELECT * FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = ? AND sinh_vien_id = ? AND trang_thai <> 'dang_lam' ORDER BY id DESC LIMIT 1");
        $stmt->execute([$examId, $sinhVienId]);
        $attempt = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$attempt) respond('error', 'Bạn chưa nộp bài kiểm tra này');
        $show = (int)$exam['hien_dap_an_sau_nop'] === 1;
        $detail = [];
        if ($show) {
            $qs = question_payload($conn, $exam, true);
            $stmtCT = $conn->prepare("SELECT * FROM chi_tiet_ket_qua WHERE ket_qua_kiem_tra_id = ?");
            $stmtCT->execute([(int)$attempt['id']]);
            $cts = [];
            foreach ($stmtCT->fetchAll(PDO::FETCH_ASSOC) as $ct) $cts[(int)$ct['cau_hoi_id']] = $ct;
            foreach ($qs as $q) {
                $ct = $cts[(int)$q['id']] ?? null;
                $chosen = [];
                if ($ct) {
                    if ($ct['dap_an_id'] !== null) $chosen[] = (int)$ct['dap_an_id'];
                    if (!empty($ct['dap_an_ids'])) $chosen = sort_int_array(json_decode($ct['dap_an_ids'], true) ?: []);
                }
                foreach ($q['dap_an'] as &$a) $a['duoc_chon'] = in_array((int)$a['id'], $chosen, true) ? 1 : 0;
                unset($a);
                $q['dung'] = $ct ? ((float)$ct['diem_dat'] > 0) : false;
                if ($ct && $ct['dap_an_tu_luan'] !== null) $q['dap_an_tu_luan'] = $ct['dap_an_tu_luan'];
                $detail[] = $q;
            }
        }
        $tongCau = (int)$conn->query("SELECT COUNT(*) FROM cau_hoi WHERE bai_kiem_tra_id = " . (int)$examId)->fetchColumn();
        $soDung = (int)$conn->query("SELECT COUNT(*) FROM chi_tiet_ket_qua WHERE ket_qua_kiem_tra_id = " . (int)$attempt['id'] . " AND diem_dat > 0")->fetchColumn();
        respond('success', 'Lấy kết quả bài kiểm tra thành công', ['data' => [
            'bai_lam_quiz_id' => (int)$attempt['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'tieu_de' => $exam['tieu_de'],
            'tong_cau' => $tongCau,
            'so_cau_dung' => $soDung,
            'diem' => (float)$attempt['tong_diem'],
            'trang_thai' => $attempt['trang_thai'],
            'thoi_gian_bat_dau' => $attempt['thoi_gian_bat_dau'],
            'thoi_gian_nop' => $attempt['thoi_gian_nop_bai'],
            'cho_xem_dap_an' => $show ? 1 : 0,
            'chi_tiet' => $detail,
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
