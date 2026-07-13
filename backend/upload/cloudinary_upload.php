<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . '/cloudinary_helper.php';

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(['status' => $status, 'message' => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $folder = trim($_POST['folder'] ?? 'files');
    $allowedFolders = ['assignments', 'submissions', 'files', 'avatars', 'posts'];
    if (!in_array($folder, $allowedFolders, true)) {
        respond('error', 'Folder upload không hợp lệ');
    }

    $files = ckc_collect_uploads(['files', 'files[]', 'file']);
    if (empty($files)) respond('error', 'Vui lòng chọn file để upload');

    $data = [];
    foreach ($files as $f) {
        $up = ckc_upload_to_cloudinary($f, $folder);
        $data[] = [
            'ten_file_goc' => $up['original_filename'],
            'duong_dan_file' => $up['secure_url'],
            'secure_url' => $up['secure_url'],
            'public_id' => $up['public_id'],
            'loai_file' => $up['format'],
            'kich_thuoc' => $up['bytes'],
        ];
    }

    respond('success', 'Upload Cloudinary thành công', [
        'data' => count($data) === 1 ? $data[0] : $data,
        'files' => $data,
        'duong_dan_file' => $data[0]['duong_dan_file'] ?? '',
    ]);
} catch (Throwable $e) {
    // Trả JSON lỗi với HTTP 200 để Flutter không bị DioException bad response
    // và có thể hiển thị đúng nguyên nhân: thiếu cấu hình Cloudinary, thiếu curl, file quá lớn...
    respond('error', $e->getMessage());
}
?>
