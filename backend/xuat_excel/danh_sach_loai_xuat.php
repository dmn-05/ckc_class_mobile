<?php
require_once __DIR__ . '/_common.php';
xuat_excel_cors_json();

$items = [];
foreach (xuat_excel_types() as $key => $config) {
    $columns = [];
    foreach ($config['columns'] as $columnKey => $columnConfig) {
        $columns[] = [
            'key' => $columnKey,
            'label' => $columnConfig['label'],
            'mac_dinh' => in_array($columnKey, $config['default_columns'], true),
        ];
    }
    $items[] = [
        'key' => $key,
        'label' => $config['label'],
        'description' => $config['description'],
        'filters' => $config['filters'],
        'required_filters' => $config['required_filters'] ?? [],
        'columns' => $columns,
    ];
}

xuat_excel_response('success', 'Lấy danh sách loại xuất thành công', $items);
