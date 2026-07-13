<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];

$id = (int)($data["id"] ?? 0);
$hoTen = trim($data["ho_ten"] ?? "");

if ($id <= 0) {
    echo json_encode(["status" => "error", "message" => "ID người dùng không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($hoTen === "") {
    echo json_encode(["status" => "error", "message" => "Họ tên không được để trống"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE nguoi_dung SET ho_ten = :ho_ten WHERE id = :id");
    $stmt->bindValue(":ho_ten", $hoTen, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đổi tên thành công",
        "data" => [
            "id" => $id,
            "ho_ten" => $hoTen
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi đổi tên",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>