<?php
header('Access-Control-Allow-Origin: *');

$token = strtolower(trim((string)($_GET['token'] ?? '')));
$name = trim((string)($_GET['name'] ?? 'du_lieu.xlsx'));

if (!preg_match('/^[a-f0-9]{32}$/', $token)) {
    http_response_code(400);
    exit('Mã tải file không hợp lệ');
}

$file = __DIR__ . '/uploads/' . $token . '.xlsx';
if (!is_file($file)) {
    http_response_code(404);
    exit('File không tồn tại hoặc đã hết hạn');
}

$name = preg_replace('/[^\pL\pN._ -]+/u', '_', $name) ?: 'du_lieu.xlsx';
if (!str_ends_with(strtolower($name), '.xlsx')) {
    $name .= '.xlsx';
}

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Length: ' . filesize($file));
header("Content-Disposition: attachment; filename*=UTF-8''" . rawurlencode($name));
header('Cache-Control: no-store, no-cache, must-revalidate');
readfile($file);
exit;
