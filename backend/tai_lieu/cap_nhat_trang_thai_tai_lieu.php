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
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) {
    $data = $_POST;
}

$id = (int)($data["id"] ?? 0);
$trangThai = trim($data["trang_thai"] ?? "");

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID tài liệu không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}
if (!in_array($trangThai, ["hien_thi", "an"], true)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Trạng thái tài liệu không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->prepare("UPDATE tai_lieu SET trang_thai = :trang_thai WHERE id = :id");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    if ($stmt->rowCount() === 0) {
        // Có thể tài liệu đã ở đúng trạng thái, vẫn kiểm tra tồn tại để trả đúng thông báo.
        $check = $conn->prepare("SELECT id FROM tai_lieu WHERE id = :id LIMIT 1");
        $check->bindValue(":id", $id, PDO::PARAM_INT);
        $check->execute();
        if (!$check->fetch(PDO::FETCH_ASSOC)) {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Không tìm thấy tài liệu"], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }

    echo json_encode([
        "status" => "success",
        "message" => $trangThai === "hien_thi" ? "Đã hiển thị tài liệu" : "Đã ẩn tài liệu"
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi cập nhật trạng thái tài liệu",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
