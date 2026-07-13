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
        "message" => "ID môn học không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT id, ma_mon, ten_mon, tin_chi, trang_thai
                 FROM mon_hoc
                 WHERE id = :id
                 LIMIT 1";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $monHoc = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$monHoc) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy môn học cần ngừng sử dụng"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($monHoc["trang_thai"] === "ngung_su_dung") {
        echo json_encode([
            "status" => "success",
            "message" => "Môn học đã ở trạng thái ngừng sử dụng",
            "data" => [
                "id" => (int) $monHoc["id"],
                "ma_mon" => $monHoc["ma_mon"],
                "ten_mon" => $monHoc["ten_mon"],
                "tin_chi" => (int) $monHoc["tin_chi"],
                "trang_thai" => $monHoc["trang_thai"]
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE mon_hoc
            SET trang_thai = 'ngung_su_dung'
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đã chuyển môn học sang trạng thái ngừng sử dụng",
        "data" => [
            "id" => (int) $monHoc["id"],
            "ma_mon" => $monHoc["ma_mon"],
            "ten_mon" => $monHoc["ten_mon"],
            "tin_chi" => (int) $monHoc["tin_chi"],
            "trang_thai" => "ngung_su_dung"
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi chuyển trạng thái môn học",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>