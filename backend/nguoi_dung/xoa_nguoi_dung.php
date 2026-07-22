<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Chỉ hỗ trợ phương thức POST'], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . '/../ket_noi.php';

function ckc_status_reply(int $code, string $status, string $message, ?array $data = null): void
{
    http_response_code($code);
    $result = ['status' => $status, 'message' => $message];
    if ($data !== null) {
        $result['data'] = $data;
    }
    echo json_encode($result, JSON_UNESCAPED_UNICODE);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}

$id = (int)($input['id'] ?? 0);
$trangThaiMoi = trim((string)($input['trang_thai'] ?? 'bi_khoa'));

if ($id <= 0) {
    ckc_status_reply(400, 'error', 'ID người dùng không hợp lệ');
}
if (!in_array($trangThaiMoi, ['dang_hoat_dong', 'bi_khoa'], true)) {
    ckc_status_reply(400, 'error', 'Trạng thái tài khoản không hợp lệ');
}
if ($id === 1 && $trangThaiMoi === 'bi_khoa') {
    ckc_status_reply(400, 'error', 'Không thể khóa tài khoản quản trị chính');
}

try {
    $stmt = $conn->prepare('SELECT id, ho_ten, trang_thai FROM nguoi_dung WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$user) {
        ckc_status_reply(404, 'error', 'Người dùng không tồn tại');
    }

    if ((string)$user['trang_thai'] === $trangThaiMoi) {
        $message = $trangThaiMoi === 'bi_khoa'
            ? 'Tài khoản đã ở trạng thái bị khóa'
            : 'Tài khoản đã ở trạng thái đang hoạt động';
        ckc_status_reply(200, 'success', $message, [
            'id' => $id,
            'trang_thai' => $trangThaiMoi,
        ]);
    }

    $stmt = $conn->prepare('UPDATE nguoi_dung SET trang_thai = :trang_thai WHERE id = :id');
    $stmt->execute([':trang_thai' => $trangThaiMoi, ':id' => $id]);

    $message = $trangThaiMoi === 'bi_khoa'
        ? 'Khóa tài khoản thành công'
        : 'Mở khóa tài khoản thành công';

    ckc_status_reply(200, 'success', $message, [
        'id' => $id,
        'ho_ten' => $user['ho_ten'],
        'trang_thai' => $trangThaiMoi,
    ]);
} catch (PDOException $e) {
    ckc_status_reply(500, 'error', 'Lỗi CSDL khi cập nhật trạng thái tài khoản', [
        'detail' => $e->getMessage(),
    ]);
} catch (Throwable $e) {
    ckc_status_reply(500, 'error', 'Lỗi server khi cập nhật trạng thái tài khoản', [
        'detail' => $e->getMessage(),
    ]);
}
