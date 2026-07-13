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
    echo json_encode([
        "status" => "error",
        "message" => "ID người dùng không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                gv.id AS giang_vien_id,
                gv.nguoi_dung_id,
                gv.ma_giang_vien,
                nd.ho_ten,
                nd.email
            FROM giang_vien gv
            JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
            WHERE gv.nguoi_dung_id = ?
            LIMIT 1";

    $stmt = $conn->prepare($sql);
    $stmt->execute([$nguoiDungId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        echo json_encode([
            "status" => "error",
            "message" => "Tài khoản này không phải giảng viên"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode([
        "status" => "success",
        "message" => "Lấy thông tin giảng viên thành công",
        "data" => [
            "giang_vien_id" => (int)$row["giang_vien_id"],
            "nguoi_dung_id" => (int)$row["nguoi_dung_id"],
            "ma_giang_vien" => $row["ma_giang_vien"],
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