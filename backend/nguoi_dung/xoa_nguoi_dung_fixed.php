<?php
// File này là khóa tài khoản (xóa mềm), không xóa cứng khỏi CSDL.
// Không nên DELETE nguoi_dung vì bảng này đang được khóa ngoại bởi sinh_vien, giang_vien, binh_luan...
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) $data = $_POST;

$id = (int)($data["id"] ?? 0);

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID người dùng không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT id, ho_ten, email, trang_thai FROM nguoi_dung WHERE id = :id LIMIT 1");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();
    $nguoiDung = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$nguoiDung) {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy người dùng cần khóa"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($nguoiDung["trang_thai"] === "bi_khoa") {
        echo json_encode([
            "status" => "success",
            "message" => "Người dùng đã ở trạng thái bị khóa",
            "data" => [
                "id" => (int)$nguoiDung["id"],
                "ho_ten" => $nguoiDung["ho_ten"],
                "email" => $nguoiDung["email"],
                "trang_thai" => $nguoiDung["trang_thai"]
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // Khóa mềm tài khoản.
    $stmt = $conn->prepare("UPDATE nguoi_dung SET trang_thai = 'bi_khoa' WHERE id = :id");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đã khóa người dùng thành công",
        "data" => [
            "id" => (int)$nguoiDung["id"],
            "ho_ten" => $nguoiDung["ho_ten"],
            "email" => $nguoiDung["email"],
            "trang_thai" => "bi_khoa"
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi khóa người dùng",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
