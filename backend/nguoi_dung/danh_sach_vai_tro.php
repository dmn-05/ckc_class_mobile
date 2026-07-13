<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

try {
    $sql = "SELECT id, ten_vai_tro
            FROM vai_tro
            ORDER BY id ASC";

    $stmt = $conn->prepare($sql);
    $stmt->execute();

    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $data = array_map(function ($row) {
        return [
            "id" => (int) $row["id"],
            "ten_vai_tro" => $row["ten_vai_tro"]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách vai trò thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách vai trò",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>