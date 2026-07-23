<?php
require_once __DIR__ . '/_nhap_excel_helper.php';

$loai = trim($_GET['loai_nhap'] ?? '');
$configs = ckc_loai_nhap_configs();

if ($loai === '' || !isset($configs[$loai])) {
    http_response_code(400);
    echo 'Loại nhập Excel không hợp lệ';
    exit();
}

$fileName = $configs[$loai]['template'];
$path = __DIR__ . '/mau_excel/' . $fileName;

if (!is_file($path)) {
    http_response_code(404);
    echo 'Không tìm thấy file mẫu';
    exit();
}

// Không cho trình duyệt dùng lại file mẫu cũ sau khi backend đã cập nhật.
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
header('Expires: 0');

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="' . basename($fileName) . '"');
header('Content-Length: ' . filesize($path));
header('Last-Modified: ' . gmdate('D, d M Y H:i:s', filemtime($path)) . ' GMT');
header('ETag: "' . md5_file($path) . '"');

readfile($path);
exit();
?>
