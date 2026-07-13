<?php
require_once __DIR__ . '/_common.php';
xuat_excel_cors_json();
require_once __DIR__ . '/../ket_noi.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    xuat_excel_response('error', 'Chỉ hỗ trợ phương thức POST', null, 405);
}

try {
    $data = xuat_excel_json_input();
    [$type, $config, $scope, $filters, $selectedIds, $columns] = xuat_excel_validate_request($data);
    $parts = xuat_excel_query_parts($type, $scope, $filters, $selectedIds);
    $count = xuat_excel_count($conn, $parts);
    $sampleRaw = xuat_excel_fetch($conn, $parts, 5);

    $sample = [];
    foreach ($sampleRaw as $row) {
        $item = [];
        foreach ($columns as $column) {
            $item[$column] = xuat_excel_format_value($column, $row[$column] ?? '');
        }
        $sample[] = $item;
    }

    $columnInfo = [];
    foreach ($columns as $column) {
        $columnInfo[] = ['key' => $column, 'label' => $config['columns'][$column]['label']];
    }

    xuat_excel_response('success', 'Xem trước dữ liệu xuất thành công', [
        'tong_dong' => $count,
        'so_cot' => count($columns) + 1,
        'columns' => $columnInfo,
        'sample' => $sample,
        'metadata' => xuat_excel_metadata($conn, $type, $filters, $scope, $count),
    ]);
} catch (InvalidArgumentException $e) {
    xuat_excel_response('error', $e->getMessage(), null, 400);
} catch (Throwable $e) {
    xuat_excel_response('error', 'Không thể xem trước dữ liệu xuất', ['detail' => $e->getMessage()], 500);
}
