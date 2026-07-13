<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../ket_noi.php';
require_once __DIR__ . '/_nhap_excel_helper.php';

try {
    $input = ckc_json_input();
    if (empty($input)) {
        $input = array_merge($_GET, $_POST);
    }

    $id = (int)($input['dot_nhap_id'] ?? 0);
    if ($id <= 0) {
        ckc_json_response('error', 'ID đợt nhập không hợp lệ', null, 400);
    }

    $dot = ckc_one(
        $conn,
        "SELECT
            d.*,
            nd.ho_ten AS ten_nguoi_nhap
         FROM nhap_excel_dot d
         LEFT JOIN nguoi_dung nd ON nd.id = d.nguoi_nhap_id
         WHERE d.id = :id
           AND d.trang_thai = 'da_nhap'
         LIMIT 1",
        [':id' => $id]
    );

    if (!$dot) {
        ckc_json_response('error', 'Không tìm thấy đợt nhập Excel', null, 404);
    }

    $stmt = $conn->prepare(
        'SELECT id, dot_nhap_id, so_dong, du_lieu_json, trang_thai, hanh_dong, thong_bao, ngay_tao
         FROM nhap_excel_dong
         WHERE dot_nhap_id = :id
         ORDER BY so_dong ASC, id ASC'
    );
    $stmt->execute([':id' => $id]);

    $rows = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $decoded = json_decode((string)($row['du_lieu_json'] ?? ''), true);
        $row['du_lieu'] = is_array($decoded) ? $decoded : [];
        unset($row['du_lieu_json']);
        $rows[] = $row;
    }

    ckc_json_response('success', 'Lấy chi tiết lịch sử nhập Excel thành công', [
        'dot' => $dot,
        'dong' => $rows,
    ]);
} catch (Throwable $e) {
    ckc_json_response(
        'error',
        'Lỗi lấy chi tiết nhập Excel',
        ['detail' => $e->getMessage()],
        500
    );
}
