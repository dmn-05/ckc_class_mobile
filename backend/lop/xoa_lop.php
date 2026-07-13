<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode([
        "status" => "error",
        "message" => "Chỉ hỗ trợ phương thức POST"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

$id = 0;

if (is_array($data)) {
    $id = (int) ($data["id"] ?? 0);
} else {
    $id = (int) ($_POST["id"] ?? 0);
}

if ($id <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT id, ma_lop, ten_lop, trang_thai
                 FROM lop
                 WHERE id = :id
                 LIMIT 1";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $lop = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lop) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy lớp cần tạm khóa"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($lop["trang_thai"] === "tam_khoa") {
        echo json_encode([
            "status" => "success",
            "message" => "Lớp đã ở trạng thái tạm khóa",
            "data" => [
                "id" => (int) $lop["id"],
                "ma_lop" => $lop["ma_lop"],
                "ten_lop" => $lop["ten_lop"],
                "trang_thai" => $lop["trang_thai"]
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE lop
            SET trang_thai = 'tam_khoa'
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đã chuyển lớp sang trạng thái tạm khóa",
        "data" => [
            "id" => (int) $lop["id"],
            "ma_lop" => $lop["ma_lop"],
            "ten_lop" => $lop["ten_lop"],
            "trang_thai" => "tam_khoa"
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi tạm khóa lớp",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>