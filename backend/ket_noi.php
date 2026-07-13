<?php
// Thiết lập múi giờ PHP trước khi xử lý thời gian
date_default_timezone_set('Asia/Ho_Chi_Minh');

// Thông tin kết nối CSDL
$host = "localhost";
$dbname = "ckc_class_web_mobile";
$username = "root";
$password = "";

try {
    $conn = new PDO(
        "mysql:host={$host};dbname={$dbname};charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );

    // Thiết lập múi giờ cho MySQL/MariaDB
    // Dùng +07:00 để tránh lỗi khi MySQL chưa cài timezone name Asia/Ho_Chi_Minh
    $conn->exec("SET time_zone = '+07:00'");
    $conn->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");

} catch (PDOException $e) {
    http_response_code(500);
    header("Content-Type: application/json; charset=UTF-8");

    echo json_encode([
        "status"  => "error",
        "message" => "Không kết nối được cơ sở dữ liệu",
        "detail"  => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);

    exit();
}
?>