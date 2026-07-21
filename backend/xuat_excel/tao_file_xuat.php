<?php
require_once __DIR__ . '/_common.php';

// Gửi CORS trước khi nạp writer. Nếu writer lỗi cú pháp/runtime,
// Flutter Web vẫn đọc được nội dung lỗi thay vì nhận response = null.
xuat_excel_cors_json();

ini_set('display_errors', '0');
error_reporting(E_ALL);

// Chuyển warning/notice thành exception để trả JSON rõ ràng.
set_error_handler(function ($severity, $message, $file, $line) {
    if (!(error_reporting() & $severity)) {
        return false;
    }

    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Bắt cả lỗi nghiêm trọng để tránh Flutter Web chỉ báo "Không thể kết nối server".
register_shutdown_function(function () {
    $error = error_get_last();
    if ($error === null) {
        return;
    }

    $fatalTypes = [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR];
    if (!in_array($error['type'], $fatalTypes, true)) {
        return;
    }

    if (!headers_sent()) {
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        header('Access-Control-Allow-Origin: *');
    }

    echo json_encode([
        'status' => 'error',
        'message' => 'Backend gặp lỗi nghiêm trọng khi tạo file Excel',
        'data' => [
            'detail' => $error['message'],
            'file' => basename($error['file']),
            'line' => $error['line'],
        ],
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
});

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    xuat_excel_response('error', 'Chỉ hỗ trợ phương thức POST', null, 405);
}

try {
    // Nạp trong try để ParseError/Error có thể được trả về dưới dạng JSON.
    require_once __DIR__ . '/_simple_xlsx_writer.php';
    require_once __DIR__ . '/../ket_noi.php';

    if (!class_exists('ZipArchive')) {
        throw new RuntimeException(
            'PHP chưa bật ZipArchive. Hãy bật extension=zip trong php.ini và restart Apache.'
        );
    }

    $data = xuat_excel_json_input();
    [$type, $config, $scope, $filters, $selectedIds, $columns] =
        xuat_excel_validate_request($data);

    $namNhapHocExpr = xuat_excel_nam_nhap_hoc_expression($conn, 'l');
    $parts = xuat_excel_query_parts($type, $scope, $filters, $selectedIds, $namNhapHocExpr);
    $count = xuat_excel_count($conn, $parts);

    if ($count <= 0) {
        throw new InvalidArgumentException('Không có dữ liệu phù hợp để xuất');
    }

    if ($count > 20000) {
        throw new InvalidArgumentException(
            'Số bản ghi vượt quá 20.000. Hãy dùng bộ lọc để thu hẹp dữ liệu trước khi xuất'
        );
    }

    $rawRows = xuat_excel_fetch($conn, $parts);

    $headers = ['STT'];
    $widths = [8];
    foreach ($columns as $column) {
        $headers[] = $config['columns'][$column]['label'];
        $widths[] = $config['columns'][$column]['width'] ?? 18;
    }

    $rows = xuat_excel_project_rows($rawRows, $columns);
    $metadata = xuat_excel_metadata($conn, $type, $filters, $scope, $count);

    $directory = __DIR__ . '/uploads';
    if (!is_dir($directory)) {
        if (!mkdir($directory, 0775, true) && !is_dir($directory)) {
            throw new RuntimeException('Không thể tạo thư mục lưu file xuất');
        }
    }

    if (!is_writable($directory)) {
        throw new RuntimeException(
            'Thư mục backend/xuat_excel/uploads không có quyền ghi'
        );
    }

    xuat_excel_cleanup($directory);

    $token = bin2hex(random_bytes(16));
    $requestedFileName = trim((string)($data['ten_file'] ?? ''));

    if ($requestedFileName !== '') {
        // Bỏ đuôi .xlsx nếu người dùng đã nhập. Không dùng regex để tránh
        // lỗi PCRE Unknown modifier trên một số bản PHP/XAMPP.
        if (strtolower(substr($requestedFileName, -5)) === '.xlsx') {
            $requestedFileName = substr($requestedFileName, 0, -5);
        }

        // Loại các ký tự Windows không cho phép trong tên file.
        $requestedFileName = str_replace(
            ['<', '>', ':', '"', '/', '\\', '|', '?', '*'],
            ' ',
            $requestedFileName
        );

        // Loại ký tự điều khiển và chuẩn hóa khoảng trắng.
        $requestedFileName = preg_replace(
            '~[\x00-\x1F\x7F]+~',
            ' ',
            $requestedFileName
        ) ?? '';
        $requestedFileName = preg_replace(
            '~\s+~u',
            ' ',
            trim($requestedFileName)
        ) ?? '';

        if ($requestedFileName === '') {
            throw new InvalidArgumentException('Tên file không hợp lệ');
        }

        if (function_exists('mb_substr')) {
            $requestedFileName = mb_substr($requestedFileName, 0, 120, 'UTF-8');
        } else {
            $requestedFileName = substr($requestedFileName, 0, 120);
        }

        $downloadName = $requestedFileName . '.xlsx';
    } else {
        $downloadName = xuat_excel_safe_filename($config['label']) .
            '_' . date('Ymd_His') . '.xlsx';
    }

    $storedName = $token . '.xlsx';
    $path = $directory . '/' . $storedName;

    SimpleXlsxWriter::write(
        $path,
        $config['title'],
        $metadata,
        $headers,
        $rows,
        $widths,
        'Dữ liệu'
    );

    if (!is_file($path) || filesize($path) <= 0) {
        throw new RuntimeException('File Excel được tạo nhưng không có dữ liệu');
    }

    xuat_excel_response('success', 'Tạo file Excel thành công', [
        'file_name' => $downloadName,
        'download_path' => '/xuat_excel/tai_file_xuat.php?token=' .
            urlencode($token) . '&name=' . urlencode($downloadName),
        'tong_dong' => $count,
    ]);
} catch (InvalidArgumentException $e) {
    xuat_excel_response('error', $e->getMessage(), null, 400);
} catch (Throwable $e) {
    error_log(
        '[CKC XUAT EXCEL] ' . $e->getMessage() .
        ' tại ' . $e->getFile() . ':' . $e->getLine()
    );

    xuat_excel_response('error', 'Không thể tạo file Excel', [
        'detail' => $e->getMessage(),
        'file' => basename($e->getFile()),
        'line' => $e->getLine(),
        'php_version' => PHP_VERSION,
        'ziparchive' => class_exists('ZipArchive'),
    ], 500);
}
