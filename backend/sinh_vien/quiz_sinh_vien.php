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
    $stmt = $conn->prepare("SELECT bkt.*,
            svlhp.trang_thai AS trang_thai_dang_ky,
            CASE WHEN bkt.thoi_gian_bat_dau IS NOT NULL AND bkt.thoi_gian_bat_dau > NOW() THEN 1 ELSE 0 END AS chua_den_gio,
            CASE WHEN bkt.thoi_gian_ket_thuc IS NOT NULL AND bkt.thoi_gian_ket_thuc < NOW() THEN 1 ELSE 0 END AS da_het_han
        FROM bai_kiem_tra bkt
        JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = bkt.lop_hoc_phan_id
        WHERE bkt.id = ? AND svlhp.sinh_vien_id = ? AND svlhp.trang_thai <> 'da_huy'
        LIMIT 1");
    $stmt->execute([$examId, $sinhVienId]);
    $exam = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$exam) respond('error', 'Bạn không có quyền làm bài kiểm tra này hoặc bài không tồn tại');
    if ($checkOpen) {
        if (($exam['trang_thai_dang_ky'] ?? '') !== 'dang_hoc') respond('error', 'Bạn không còn ở trạng thái đang học trong lớp này');
        if ($exam['trang_thai'] !== 'hien_thi') respond('error', 'Bài kiểm tra chưa được mở hoặc đã bị ẩn');
        if ((int)$exam['chua_den_gio'] === 1) respond('error', 'Bài kiểm tra chưa đến thời gian làm');
        if ((int)$exam['da_het_han'] === 1) respond('error', 'Bài kiểm tra đã hết hạn');
    }
    return $exam;
}
function latest_attempt(PDO $conn, int $examId, int $sinhVienId) {
    $stmt = $conn->prepare("SELECT * FROM ket_qua_kiem_tra WHERE bai_kiem_tra_id = ? AND sinh_vien_id = ? ORDER BY id DESC LIMIT 1");
    $stmt->execute([$examId, $sinhVienId]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}
function attempt_time_info(PDO $conn, array $attempt, array $exam): array {
    $stmt = $conn->prepare("SELECT
            GREATEST(0, TIMESTAMPDIFF(SECOND, thoi_gian_bat_dau, NOW())) AS da_dung_giay,
            CASE
                WHEN ? IS NULL THEN NULL
                ELSE TIMESTAMPDIFF(SECOND, NOW(), ?)
            END AS con_lai_den_han
        FROM ket_qua_kiem_tra
        WHERE id = ?
        LIMIT 1");
    $hanKetThuc = !empty($exam['thoi_gian_ket_thuc']) ? $exam['thoi_gian_ket_thuc'] : null;
    $stmt->execute([$hanKetThuc, $hanKetThuc, (int)$attempt['id']]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

    $durationSeconds = max(1, (int)$exam['thoi_gian_lam_bai']) * 60;
    $remaining = $durationSeconds - max(0, (int)($row['da_dung_giay'] ?? 0));
    if ($row['con_lai_den_han'] !== null) {
        $remaining = min($remaining, (int)$row['con_lai_den_han']);
    }

    return [
        'da_dung_giay' => max(0, (int)($row['da_dung_giay'] ?? 0)),
        'con_lai_giay' => max(0, $remaining),
        'con_lai_thuc_te' => $remaining,
    ];
}
function attempt_is_expired(PDO $conn, array $attempt, array $exam): bool {
    // Cho phép trễ tối đa 15 giây do độ trễ mạng, nhưng thời gian được tính hoàn toàn ở server.
    $graceSeconds = 15;
    $timeInfo = attempt_time_info($conn, $attempt, $exam);
    return (int)$timeInfo['con_lai_thuc_te'] < -$graceSeconds;
}
function finalize_expired_attempt(PDO $conn, int $attemptId): void {
    $stmt = $conn->prepare("UPDATE ket_qua_kiem_tra
        SET thoi_gian_nop_bai = COALESCE(thoi_gian_nop_bai, NOW()),
            diem_trac_nghiem = 0,
            diem_tu_luan = 0,
            tong_diem = 0,
            trang_thai = 'da_cham',
            ngay_cap_nhat = NOW()
        WHERE id = ? AND trang_thai = 'dang_lam'");
    $stmt->execute([$attemptId]);
}
function require_active_attempt(PDO $conn, array $exam, int $sinhVienId): array {
    $attempt = latest_attempt($conn, (int)$exam['id'], $sinhVienId);
    if (!$attempt) respond('error', 'Bạn chưa bắt đầu bài kiểm tra. Vui lòng nhấn Bắt đầu làm quiz');
    if ($attempt['trang_thai'] !== 'dang_lam') respond('error', 'Bạn đã nộp bài kiểm tra này, vui lòng xem kết quả');
    if (attempt_is_expired($conn, $attempt, $exam)) {
        finalize_expired_attempt($conn, (int)$attempt['id']);
        respond('error', 'Đã hết thời gian làm bài. Bài làm đã được hệ thống kết thúc');
    }
    return $attempt;
}
function start_attempt(PDO $conn, array $exam, int $sinhVienId) {
    $last = latest_attempt($conn, (int)$exam['id'], $sinhVienId);
    if ($last && $last['trang_thai'] === 'dang_lam') {
        if (!attempt_is_expired($conn, $last, $exam)) return $last;
        finalize_expired_attempt($conn, (int)$last['id']);
    }
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
    if (in_array($action, ['bat_dau_quiz', 'nop_quiz'], true)) {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_quiz($conn, (int)($data['bai_tap_id'] ?? 0)));
    }

    if ($sinhVienId <= 0) respond('error', 'ID sinh viên không hợp lệ');
    if ($action === 'bat_dau_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, true);
        $attempt = start_attempt($conn, $exam, $sinhVienId);
        respond('success', 'Bắt đầu bài kiểm tra thành công', ['data' => [
            'bai_lam_quiz_id' => (int)$attempt['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'tieu_de' => $exam['tieu_de'],
            'thoi_gian_lam' => (int)$exam['thoi_gian_lam_bai'],
            'thoi_gian_bat_dau' => $attempt['thoi_gian_bat_dau'],
            'thoi_gian_con_lai_giay' => attempt_time_info($conn, $attempt, $exam)['con_lai_giay'],
            'trang_thai' => $attempt['trang_thai'],
            'da_nop' => false,
        ]]);
    }
    if ($action === 'lay_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, false);
        if ($exam['trang_thai'] !== 'hien_thi') respond('error', 'Bài kiểm tra chưa được mở hoặc đã bị ẩn');
        $attempt = require_active_attempt($conn, $exam, $sinhVienId);
        $timeInfo = attempt_time_info($conn, $attempt, $exam);
        respond('success', 'Lấy bài kiểm tra thành công', ['data' => [
            'id' => (int)$exam['id'],
            'bai_tap_id' => (int)$exam['id'],
            'bai_kiem_tra_id' => (int)$exam['id'],
            'tieu_de' => $exam['tieu_de'],
            'mo_ta' => $exam['mo_ta'],
            'han_nop' => $exam['thoi_gian_ket_thuc'],
            'thoi_gian_lam' => (int)$exam['thoi_gian_lam_bai'],
            'thoi_gian_bat_dau' => $attempt['thoi_gian_bat_dau'],
            'thoi_gian_con_lai_giay' => (int)$timeInfo['con_lai_giay'],
            'bai_lam_quiz_id' => (int)$attempt['id'],
            'cho_xem_dap_an' => (int)$exam['hien_dap_an_sau_nop'],
            'cau_hoi' => question_payload($conn, $exam, false),
        ]]);
    }
    if ($action === 'nop_quiz') {
        $examId = int_val($data, 'bai_tap_id');
        if ($examId <= 0) respond('error', 'ID bài kiểm tra không hợp lệ');
        $exam = lay_exam_va_quyen($conn, $examId, $sinhVienId, false);
        if ($exam['trang_thai'] !== 'hien_thi') respond('error', 'Bài kiểm tra chưa được mở hoặc đã bị ẩn');
        $attempt = require_active_attempt($conn, $exam, $sinhVienId);
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
