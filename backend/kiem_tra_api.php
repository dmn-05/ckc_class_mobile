<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error',
        'message' => 'Chỉ hỗ trợ phương thức GET',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . '/ket_noi.php';

try {
    $info = $conn->query(
        "SELECT DATABASE() AS database_name, NOW() AS database_time"
    )->fetch(PDO::FETCH_ASSOC);

    $counts = [];
    foreach (['nguoi_dung', 'lop_hoc_phan', 'bai_tap', 'thong_bao'] as $table) {
        $stmt = $conn->prepare(
            'SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES '
            . 'WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?'
        );
        $stmt->execute([$table]);

        if ((int)$stmt->fetchColumn() > 0) {
            $counts[$table] = (int)$conn->query(
                "SELECT COUNT(*) FROM `{$table}`"
            )->fetchColumn();
        }
    }

    echo json_encode([
        'status' => 'success',
        'message' => 'Backend và cơ sở dữ liệu đang hoạt động',
        'data' => [
            'database_connected' => true,
            'database_time' => $info['database_time'] ?? null,
            'server_time' => date('Y-m-d H:i:s'),
            'record_counts' => $counts,
        ],
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Backend chạy nhưng truy vấn kiểm tra cơ sở dữ liệu thất bại',
    ], JSON_UNESCAPED_UNICODE);
}
