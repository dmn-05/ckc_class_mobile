<?php
/**
 * Cloudinary helper dùng chung cho backend PHP Mobile.
 *
 * Ưu tiên cấu hình theo biến môi trường giống Web:
 *   CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
 * Hoặc khai báo riêng:
 *   CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
 *
 * Nếu chạy XAMPP không đọc được biến môi trường, có thể tạo file:
 *   backend/upload/cloudinary_local.php
 * và return mảng:
 *   <?php return [
 *     'cloud_name' => 'your_cloud_name',
 *     'api_key' => 'your_api_key',
 *     'api_secret' => 'your_api_secret',
 *   ];
 */

function ckc_cloudinary_env(string $name): string
{
    $value = getenv($name);
    if ($value === false || $value === null || $value === '') {
        $value = $_ENV[$name] ?? ($_SERVER[$name] ?? '');
    }
    return trim((string)$value);
}

function ckc_cloudinary_is_placeholder(string $value): bool
{
    $normalized = strtoupper(trim($value));
    if ($normalized === '') return true;

    $normalized = trim($normalized, "<>[]{} \\t\\n\\r\\0\\x0B");
    $placeholders = [
        'API_KEY', 'YOUR_API_KEY', 'CLOUDINARY_API_KEY',
        'API_SECRET', 'YOUR_API_SECRET', 'CLOUDINARY_API_SECRET',
        'CLOUD_NAME', 'YOUR_CLOUD_NAME', 'CLOUDINARY_CLOUD_NAME',
        'CHANGE_ME', 'CHANGEME', 'REPLACE_ME', 'REPLACEME',
    ];
    if (in_array($normalized, $placeholders, true)) return true;

    return str_contains($normalized, 'YOUR_')
        || str_contains($normalized, 'REPLACE_')
        || str_contains($normalized, '<API_')
        || str_contains($normalized, '<CLOUD_');
}

function ckc_cloudinary_candidate(array $cfg, string $source): array
{
    return [
        'cloud_name' => trim((string)($cfg['cloud_name'] ?? '')),
        'api_key' => trim((string)($cfg['api_key'] ?? '')),
        'api_secret' => trim((string)($cfg['api_secret'] ?? '')),
        'source' => $source,
    ];
}

function ckc_cloudinary_candidate_valid(array $cfg): bool
{
    return !ckc_cloudinary_is_placeholder((string)($cfg['cloud_name'] ?? ''))
        && !ckc_cloudinary_is_placeholder((string)($cfg['api_key'] ?? ''))
        && !ckc_cloudinary_is_placeholder((string)($cfg['api_secret'] ?? ''));
}

function ckc_cloudinary_from_url(string $url, string $source): ?array
{
    $url = trim($url);
    if ($url === '') return null;

    $parts = parse_url($url);
    if (!$parts || !isset($parts['host'], $parts['user'], $parts['pass'])) {
        return null;
    }

    return ckc_cloudinary_candidate([
        'cloud_name' => rawurldecode((string)$parts['host']),
        'api_key' => rawurldecode((string)$parts['user']),
        'api_secret' => rawurldecode((string)$parts['pass']),
    ], $source);
}

function ckc_cloudinary_config(): array
{
    $candidates = [];

    // Railway/production: ưu tiên biến môi trường. Giá trị mẫu như
    // cloudinary://API_KEY:API_SECRET@CLOUD_NAME sẽ bị bỏ qua.
    $envUrl = ckc_cloudinary_from_url(
        ckc_cloudinary_env('CLOUDINARY_URL'),
        'CLOUDINARY_URL'
    );
    if ($envUrl !== null) $candidates[] = $envUrl;

    $candidates[] = ckc_cloudinary_candidate([
        'cloud_name' => ckc_cloudinary_env('CLOUDINARY_CLOUD_NAME'),
        'api_key' => ckc_cloudinary_env('CLOUDINARY_API_KEY'),
        'api_secret' => ckc_cloudinary_env('CLOUDINARY_API_SECRET'),
    ], 'CLOUDINARY_*');

    // XAMPP/local: chỉ dùng khi không có cấu hình môi trường hợp lệ.
    $localFile = __DIR__ . '/cloudinary_local.php';
    if (is_file($localFile)) {
        $local = require $localFile;
        if (is_array($local)) {
            $localUrl = ckc_cloudinary_from_url(
                (string)($local['cloudinary_url'] ?? ''),
                'cloudinary_local.php:cloudinary_url'
            );
            if ($localUrl !== null) $candidates[] = $localUrl;
            $candidates[] = ckc_cloudinary_candidate($local, 'cloudinary_local.php');
        }
    }

    foreach ($candidates as $candidate) {
        if (ckc_cloudinary_candidate_valid($candidate)) {
            return $candidate;
        }
    }

    return [
        'cloud_name' => '',
        'api_key' => '',
        'api_secret' => '',
        'source' => 'none',
    ];
}

function ckc_cloudinary_ready(): bool
{
    return ckc_cloudinary_candidate_valid(ckc_cloudinary_config());
}

function ckc_cloudinary_config_message(): string
{
    $url = ckc_cloudinary_env('CLOUDINARY_URL');
    if ($url !== '') {
        $candidate = ckc_cloudinary_from_url($url, 'CLOUDINARY_URL');
        if ($candidate === null || !ckc_cloudinary_candidate_valid($candidate)) {
            return 'CLOUDINARY_URL đang sai hoặc còn dùng giá trị mẫu API_KEY/API_SECRET/CLOUD_NAME.';
        }
    }

    return 'Chưa có cấu hình Cloudinary hợp lệ. Hãy đặt CLOUDINARY_URL hoặc ba biến CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET.';
}

function ckc_cloudinary_signature(array $params, string $apiSecret): string
{
    ksort($params);
    $pairs = [];
    foreach ($params as $key => $value) {
        if ($value === null || $value === '' || $key === 'file' || $key === 'resource_type' || $key === 'api_key') {
            continue;
        }
        if (is_array($value)) {
            $value = implode(',', $value);
        }
        $pairs[] = $key . '=' . $value;
    }
    return sha1(implode('&', $pairs) . $apiSecret);
}

function ckc_upload_error_message(int $code): string
{
    return match ($code) {
        UPLOAD_ERR_INI_SIZE => 'File vượt quá upload_max_filesize trong php.ini',
        UPLOAD_ERR_FORM_SIZE => 'File vượt quá MAX_FILE_SIZE của form',
        UPLOAD_ERR_PARTIAL => 'File chỉ upload được một phần',
        UPLOAD_ERR_NO_FILE => 'Chưa chọn file upload',
        UPLOAD_ERR_NO_TMP_DIR => 'Server thiếu thư mục tạm để upload file',
        UPLOAD_ERR_CANT_WRITE => 'Server không ghi được file tạm',
        UPLOAD_ERR_EXTENSION => 'Upload bị chặn bởi extension PHP',
        default => 'Upload file thất bại, mã lỗi: ' . $code,
    };
}

function ckc_upload_to_cloudinary(array $file, string $folder): array
{
    if (!ckc_cloudinary_ready()) {
        throw new RuntimeException(ckc_cloudinary_config_message());
    }

    if (!function_exists('curl_init') || !class_exists('CURLFile')) {
        throw new RuntimeException('PHP chưa bật extension curl. Hãy mở php.ini, bật extension=curl rồi restart Apache/XAMPP');
    }

    $uploadError = (int)($file['error'] ?? UPLOAD_ERR_OK);
    if ($uploadError !== UPLOAD_ERR_OK) {
        throw new RuntimeException(ckc_upload_error_message($uploadError));
    }

    if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
        throw new RuntimeException('File upload không hợp lệ hoặc đã hết hạn trong thư mục tạm');
    }

    $cfg = ckc_cloudinary_config();
    $folder = trim($folder, '/');
    if (!preg_match('/^[a-zA-Z0-9_\/-]+$/', $folder)) {
        throw new RuntimeException('Folder Cloudinary không hợp lệ');
    }

    $timestamp = time();
    $paramsToSign = [
        'folder' => $folder,
        'timestamp' => $timestamp,
    ];

    $signature = ckc_cloudinary_signature($paramsToSign, $cfg['api_secret']);
    $endpoint = 'https://api.cloudinary.com/v1_1/' . rawurlencode($cfg['cloud_name']) . '/auto/upload';

    $postFields = [
        'file' => new CURLFile($file['tmp_name'], $file['type'] ?? 'application/octet-stream', $file['name'] ?? 'upload_file'),
        'folder' => $folder,
        'timestamp' => $timestamp,
        'api_key' => $cfg['api_key'],
        'signature' => $signature,
        'resource_type' => 'auto',
    ];

    $ch = curl_init($endpoint);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $postFields,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 20,
        CURLOPT_TIMEOUT => 120,
    ]);

    $raw = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($raw === false || $curlError) {
        throw new RuntimeException('Không kết nối được Cloudinary: ' . $curlError);
    }

    $json = json_decode($raw, true);
    if ($httpCode < 200 || $httpCode >= 300 || !is_array($json) || empty($json['secure_url'])) {
        $msg = is_array($json) && isset($json['error']['message']) ? $json['error']['message'] : $raw;
        throw new RuntimeException('Cloudinary upload lỗi: ' . $msg);
    }

    return [
        'secure_url' => $json['secure_url'],
        'url' => $json['secure_url'],
        'public_id' => $json['public_id'] ?? null,
        'resource_type' => $json['resource_type'] ?? null,
        'format' => $json['format'] ?? strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION)),
        'bytes' => (int)($json['bytes'] ?? ($file['size'] ?? 0)),
        'original_filename' => $file['name'] ?? ($json['original_filename'] ?? null),
        'created_at' => $json['created_at'] ?? null,
    ];
}

function ckc_collect_uploads(array $keys = ['files', 'files[]', 'file']): array
{
    $result = [];
    foreach ($keys as $key) {
        if (!isset($_FILES[$key])) continue;
        $f = $_FILES[$key];
        if (is_array($f['name'])) {
            $count = count($f['name']);
            for ($i = 0; $i < $count; $i++) {
                if ((int)$f['error'][$i] === UPLOAD_ERR_NO_FILE) continue;
                $result[] = [
                    'name' => $f['name'][$i],
                    'type' => $f['type'][$i] ?? '',
                    'tmp_name' => $f['tmp_name'][$i],
                    'error' => (int)$f['error'][$i],
                    'size' => (int)$f['size'][$i],
                ];
            }
        } else {
            if ((int)$f['error'] === UPLOAD_ERR_NO_FILE) continue;
            $result[] = [
                'name' => $f['name'],
                'type' => $f['type'] ?? '',
                'tmp_name' => $f['tmp_name'],
                'error' => (int)$f['error'],
                'size' => (int)$f['size'],
            ];
        }
    }
    return $result;
}

function ckc_file_ext(string $name): string
{
    return strtolower(pathinfo($name, PATHINFO_EXTENSION));
}

function ckc_file_name_from_url(string $url): string
{
    $path = parse_url($url, PHP_URL_PATH) ?: $url;
    $base = basename($path);
    return $base !== '' ? $base : 'file';
}
?>
