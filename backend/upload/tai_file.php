<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

function fail_download($message, $code = 400) {
    http_response_code($code);
    header('Content-Type: text/plain; charset=UTF-8');
    echo $message;
    exit();
}

function b64url_decode_str($value) {
    $value = strtr((string)$value, '-_', '+/');
    $pad = strlen($value) % 4;
    if ($pad) $value .= str_repeat('=', 4 - $pad);
    $decoded = base64_decode($value, true);
    return $decoded === false ? '' : $decoded;
}

function safe_filename($name) {
    $name = basename(str_replace('\\', '/', (string)$name));
    $name = preg_replace('/[\r\n\t\x00-\x1F\x7F]+/u', '', $name);
    $name = trim($name);
    return $name !== '' ? $name : 'file_tai_ve';
}

$url = b64url_decode_str($_GET['u'] ?? '');
$filename = safe_filename(b64url_decode_str($_GET['f'] ?? ''));

if ($url === '') fail_download('Thiếu đường dẫn file');

$parts = parse_url($url);
if (!$parts) fail_download('Đường dẫn file không hợp lệ');

$path = $parts['path'] ?? '';
$host = strtolower($parts['host'] ?? '');
$scheme = strtolower($parts['scheme'] ?? '');

header('Content-Type: application/octet-stream');
header("Content-Disposition: attachment; filename=\"" . addslashes($filename) . "\"; filename*=UTF-8''" . rawurlencode($filename));
header('X-Content-Type-Options: nosniff');

// Cho phép tải file Cloudinary hoặc file local trong backend/uploads.
if ($scheme === 'http' || $scheme === 'https') {
    $isCloudinary = str_ends_with($host, 'cloudinary.com') || $host === 'res.cloudinary.com';
    $isLocalBackend = in_array($host, ['localhost', '127.0.0.1', '10.0.2.2'], true) && str_starts_with($path, '/backend/');
    if (!$isCloudinary && !$isLocalBackend) {
        fail_download('Host file không được phép tải qua proxy', 403);
    }

    if (!function_exists('curl_init')) fail_download('Server chưa bật curl', 500);
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_RETURNTRANSFER => false,
        CURLOPT_CONNECTTIMEOUT => 20,
        CURLOPT_TIMEOUT => 180,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false,
        CURLOPT_HEADERFUNCTION => function($curl, $header) { return strlen($header); },
        CURLOPT_WRITEFUNCTION => function($curl, $data) { echo $data; return strlen($data); },
    ]);
    $ok = curl_exec($ch);
    $http = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);
    if ($ok === false || $http >= 400) {
        // Có thể header đã gửi một phần; chỉ ghi thêm thông báo ngắn.
        echo "\nKhông tải được file: " . ($err ?: ('HTTP ' . $http));
    }
    exit();
}

// Đường dẫn tương đối local, ví dụ uploads/abc.pdf hoặc /uploads/abc.pdf
$relative = ltrim(str_replace('\\', '/', $url), '/');
$relative = preg_replace('#^backend/#', '', $relative);
if (!str_starts_with($relative, 'uploads/')) {
    fail_download('Chỉ cho phép tải file trong thư mục uploads hoặc Cloudinary', 403);
}
$full = realpath(__DIR__ . '/../' . $relative);
$base = realpath(__DIR__ . '/../uploads');
if (!$full || !$base || !str_starts_with($full, $base) || !is_file($full)) {
    fail_download('Không tìm thấy file local', 404);
}
readfile($full);
exit();
?>
