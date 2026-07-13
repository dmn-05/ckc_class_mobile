<?php
// Thiết lập múi giờ PHP trước khi xử lý thời gian
date_default_timezone_set('Asia/Ho_Chi_Minh');

function ckc_env(array $keys, string $default = ''): string
{
    foreach ($keys as $key) {
        $value = getenv($key);
        if ($value !== false && $value !== '') {
            return (string) $value;
        }

        if (isset($_ENV[$key]) && $_ENV[$key] !== '') {
            return (string) $_ENV[$key];
        }
    }

    return $default;
}

// Thông tin kết nối CSDL. Khi deploy Railway, ưu tiên biến MYSQL* của MySQL service.
$host = ckc_env(['DB_HOST', 'MYSQLHOST'], 'localhost');
$port = ckc_env(['DB_PORT', 'MYSQLPORT'], '3306');
$dbname = ckc_env(['DB_DATABASE', 'MYSQLDATABASE'], 'ckc_class_web_mobile');
$username = ckc_env(['DB_USERNAME', 'MYSQLUSER'], 'root');
$password = ckc_env(['DB_PASSWORD', 'MYSQLPASSWORD'], '');

$databaseUrl = ckc_env(['MYSQL_URL', 'DATABASE_URL']);
if ($databaseUrl !== '') {
    $parts = parse_url($databaseUrl);
    if ($parts !== false) {
        $host = isset($parts['host']) ? rawurldecode((string) $parts['host']) : $host;
        $port = isset($parts['port']) ? (string) $parts['port'] : $port;
        $username = isset($parts['user']) ? rawurldecode((string) $parts['user']) : $username;
        $password = isset($parts['pass']) ? rawurldecode((string) $parts['pass']) : $password;
        $pathDb = trim((string) ($parts['path'] ?? ''), '/');
        $dbname = $pathDb !== '' ? rawurldecode($pathDb) : $dbname;
    }
}

$dsn = "mysql:host={$host};dbname={$dbname};charset=utf8mb4";
if ($port !== '') {
    $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";
}

try {
    $conn = new PDO(
        $dsn,
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

    $payload = [
        "status"  => "error",
        "message" => "Không kết nối được cơ sở dữ liệu",
    ];

    if (filter_var(ckc_env(['APP_DEBUG'], 'false'), FILTER_VALIDATE_BOOLEAN)) {
        $payload["detail"] = $e->getMessage();
    }

    echo json_encode($payload, JSON_UNESCAPED_UNICODE);

    exit();
}
?>
