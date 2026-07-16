<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once __DIR__ . '/cloudinary_helper.php';

$cfg = ckc_cloudinary_config();
echo json_encode([
    'status' => ckc_cloudinary_ready() && function_exists('curl_init') ? 'success' : 'error',
    'cloudinary_ready' => ckc_cloudinary_ready(),
    'curl_enabled' => function_exists('curl_init'),
    'curlfile_enabled' => class_exists('CURLFile'),
    'config_source' => $cfg['source'] ?? 'none',
    'cloud_name_set' => $cfg['cloud_name'] !== '',
    'api_key_set' => $cfg['api_key'] !== '',
    'api_secret_set' => $cfg['api_secret'] !== '',
    'upload_max_filesize' => ini_get('upload_max_filesize'),
    'post_max_size' => ini_get('post_max_size'),
    'message' => ckc_cloudinary_ready()
        ? (function_exists('curl_init') ? 'Cloudinary và curl đã sẵn sàng' : 'Cloudinary đã cấu hình nhưng PHP chưa bật curl')
        : ckc_cloudinary_config_message(),
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
