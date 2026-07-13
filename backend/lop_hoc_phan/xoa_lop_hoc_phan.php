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
        "message" => "ID lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT id, ma_lop_hoc_phan, ten_lop, trang_thai
                 FROM lop_hoc_phan
                 WHERE id = :id
                 LIMIT 1";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $lopHocPhan = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lopHocPhan) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy lớp học phần cần khóa"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($lopHocPhan["trang_thai"] === "da_khoa") {
        echo json_encode([
            "status" => "success",
            "message" => "Lớp học phần đã ở trạng thái đã khóa",
            "data" => [
                "id" => (int) $lopHocPhan["id"],
                "ma_lop_hoc_phan" => $lopHocPhan["ma_lop_hoc_phan"],
                "ten_lop" => $lopHocPhan["ten_lop"],
                "trang_thai" => $lopHocPhan["trang_thai"]
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE lop_hoc_phan
            SET trang_thai = 'da_khoa'
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đã khóa lớp học phần thành công",
        "data" => [
            "id" => (int) $lopHocPhan["id"],
            "ma_lop_hoc_phan" => $lopHocPhan["ma_lop_hoc_phan"],
            "ten_lop" => $lopHocPhan["ten_lop"],
            "trang_thai" => "da_khoa"
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi khóa lớp học phần",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>