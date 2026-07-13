<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$nguoiDungId = (int)($data["nguoi_dung_id"] ?? 0);

if ($nguoiDungId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID người dùng không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->prepare("
        SELECT
            sv.id AS sinh_vien_id,
            sv.nguoi_dung_id,
            sv.ma_sinh_vien,
            nd.ho_ten,
            nd.email
        FROM sinh_vien sv
        JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
        WHERE sv.nguoi_dung_id = ?
        LIMIT 1
    ");
    $stmt->execute([$nguoiDungId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy sinh viên theo tài khoản này"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode([
        "status" => "success",
        "message" => "Lấy thông tin sinh viên thành công",
        "data" => [
            "sinh_vien_id" => (int)$row["sinh_vien_id"],
            "nguoi_dung_id" => (int)$row["nguoi_dung_id"],
            "ma_sinh_vien" => $row["ma_sinh_vien"],
            "ho_ten" => $row["ho_ten"],
            "email" => $row["email"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>