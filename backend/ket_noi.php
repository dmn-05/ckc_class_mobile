<?php
date_default_timezone_set('Asia/Ho_Chi_Minh');

function env_value(string $name): ?string {
    $value = getenv($name);
    if ($value === false) {
        return null;
    }

    $value = trim((string)$value);
    return $value === '' ? null : $value;
}

$mysqlUrl = env_value('MYSQL_URL');
$urlConfig = [];

if ($mysqlUrl !== null) {
    $parsed = parse_url($mysqlUrl);

    if (is_array($parsed)) {
        $urlConfig = [
            'host' => isset($parsed['host']) ? urldecode((string)$parsed['host']) : null,
            'port' => isset($parsed['port']) ? (string)$parsed['port'] : null,
            'name' => isset($parsed['path'])
                ? ltrim(urldecode((string)$parsed['path']), '/')
                : null,
            'user' => isset($parsed['user']) ? urldecode((string)$parsed['user']) : null,
            'pass' => isset($parsed['pass']) ? urldecode((string)$parsed['pass']) : null,
        ];
    }
}

$host = env_value('MYSQLHOST')
    ?? env_value('DB_HOST')
    ?? ($urlConfig['host'] ?? null)
    ?? 'localhost';

$port = env_value('MYSQLPORT')
    ?? env_value('DB_PORT')
    ?? ($urlConfig['port'] ?? null)
    ?? '3306';

$dbname = env_value('MYSQLDATABASE')
    ?? env_value('DB_NAME')
    ?? ($urlConfig['name'] ?? null)
    ?? 'ckc_class_web_mobile';

$username = env_value('MYSQLUSER')
    ?? env_value('DB_USER')
    ?? ($urlConfig['user'] ?? null)
    ?? 'root';

$envPassword = getenv('MYSQLPASSWORD');
if ($envPassword === false) {
    $envPassword = getenv('DB_PASSWORD');
}
$password = $envPassword !== false
    ? (string)$envPassword
    : (string)($urlConfig['pass'] ?? '');

try {
    $conn = new PDO(
        "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );

    $conn->exec("SET time_zone = '+07:00'");
    $conn->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");

} catch (PDOException $e) {
    http_response_code(500);
    header("Content-Type: application/json; charset=UTF-8");

    $response = [
        "status"  => "error",
        "message" => "Không kết nối được cơ sở dữ liệu",
    ];

    $debug = strtolower((string)(env_value('APP_DEBUG') ?? ''));
    if (in_array($debug, ['1', 'true', 'yes', 'on'], true)) {
        $response["detail"] = $e->getMessage();
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}
?>
