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

$maKhoa = "";
$tenKhoa = "";
$trangThai = "dang_hoat_dong";

if (is_array($data)) {
    $maKhoa = strtoupper(trim($data["ma_khoa"] ?? ""));
    $tenKhoa = trim($data["ten_khoa"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "dang_hoat_dong");
} else {
    $maKhoa = strtoupper(trim($_POST["ma_khoa"] ?? ""));
    $tenKhoa = trim($_POST["ten_khoa"] ?? "");
    $trangThai = trim($_POST["trang_thai"] ?? "dang_hoat_dong");
}

$trangThaiHopLe = ["dang_hoat_dong", "ngung_hoat_dong"];

if ($maKhoa === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Mã khoa không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($tenKhoa === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Tên khoa không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái khoa không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT id FROM khoa WHERE ma_khoa = :ma_khoa LIMIT 1";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":ma_khoa", $maKhoa, PDO::PARAM_STR);
    $checkStmt->execute();

    if ($checkStmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Mã khoa đã tồn tại"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "INSERT INTO khoa (ma_khoa, ten_khoa, trang_thai)
            VALUES (:ma_khoa, :ten_khoa, :trang_thai)";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ma_khoa", $maKhoa, PDO::PARAM_STR);
    $stmt->bindValue(":ten_khoa", $tenKhoa, PDO::PARAM_STR);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    $newId = (int) $conn->lastInsertId();

    $getSql = "SELECT id, ma_khoa, ten_khoa, trang_thai, ngay_tao, ngay_cap_nhat
               FROM khoa
               WHERE id = :id
               LIMIT 1";

    $getStmt = $conn->prepare($getSql);
    $getStmt->bindValue(":id", $newId, PDO::PARAM_INT);
    $getStmt->execute();

    $khoa = $getStmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "message" => "Thêm khoa thành công",
        "data" => [
            "id" => (int) $khoa["id"],
            "ma_khoa" => $khoa["ma_khoa"],
            "ten_khoa" => $khoa["ten_khoa"],
            "trang_thai" => $khoa["trang_thai"],
            "ngay_tao" => $khoa["ngay_tao"],
            "ngay_cap_nhat" => $khoa["ngay_cap_nhat"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi thêm khoa",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>