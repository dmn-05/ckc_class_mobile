<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . '/../upload/cloudinary_helper.php';

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(['status' => $status, 'message' => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $files = ckc_collect_uploads(['file', 'files', 'files[]']);
    if (empty($files)) respond('error', 'Vui lòng chọn file bài tập');

    $file = $files[0];
    $up = ckc_upload_to_cloudinary($file, 'assignments');

    respond('success', 'Upload file bài tập thành công', [
        'duong_dan_file' => $up['secure_url'],
        'file_url' => $up['secure_url'],
        'file_name' => $up['original_filename'],
        'data' => [
            'ten_file_goc' => $up['original_filename'],
            'duong_dan_file' => $up['secure_url'],
            'secure_url' => $up['secure_url'],
            'public_id' => $up['public_id'],
            'loai_file' => $up['format'],
            'kich_thuoc' => $up['bytes'],
        ],
    ]);
} catch (Throwable $e) {
    // Trả JSON lỗi với HTTP 200 để Flutter không bị DioException bad response
    // và có thể hiển thị đúng nguyên nhân: thiếu cấu hình Cloudinary, thiếu curl, file quá lớn...
    respond('error', $e->getMessage());
}
?>
