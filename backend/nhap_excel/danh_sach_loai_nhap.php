<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit(); }
require_once __DIR__ . '/_nhap_excel_helper.php';
$configs = ckc_loai_nhap_configs();
$data = [];
foreach ($configs as $ma => $cfg) {
    $data[] = ['ma' => $ma, 'ten' => $cfg['ten'], 'template' => $cfg['template'], 'can_dich' => $cfg['can_dich'] ?? false, 'key_dich' => $cfg['key_dich'] ?? null];
}
ckc_json_response('success', 'Danh sách loại nhập Excel', $data);
?>
