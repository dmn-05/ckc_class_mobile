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
        "message" => "ID khoa không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT id, ma_khoa, ten_khoa, trang_thai
                 FROM khoa
                 WHERE id = :id
                 LIMIT 1";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $khoa = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$khoa) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy khoa cần ngừng hoạt động"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($khoa["trang_thai"] === "ngung_hoat_dong") {
        echo json_encode([
            "status" => "success",
            "message" => "Khoa đã ở trạng thái ngừng hoạt động",
            "data" => [
                "id" => (int) $khoa["id"],
                "ma_khoa" => $khoa["ma_khoa"],
                "ten_khoa" => $khoa["ten_khoa"],
                "trang_thai" => $khoa["trang_thai"]
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE khoa
            SET trang_thai = 'ngung_hoat_dong'
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    $getSql = "SELECT id, ma_khoa, ten_khoa, trang_thai, ngay_tao, ngay_cap_nhat
               FROM khoa
               WHERE id = :id
               LIMIT 1";

    $getStmt = $conn->prepare($getSql);
    $getStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $getStmt->execute();

    $khoaMoi = $getStmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "message" => "Đã chuyển khoa sang trạng thái ngừng hoạt động",
        "data" => [
            "id" => (int) $khoaMoi["id"],
            "ma_khoa" => $khoaMoi["ma_khoa"],
            "ten_khoa" => $khoaMoi["ten_khoa"],
            "trang_thai" => $khoaMoi["trang_thai"],
            "ngay_tao" => $khoaMoi["ngay_tao"],
            "ngay_cap_nhat" => $khoaMoi["ngay_cap_nhat"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi chuyển trạng thái khoa",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>