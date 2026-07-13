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

$maBoMon = "";
$tenBoMon = "";
$khoaId = 0;
$trangThai = "dang_hoat_dong";

if (is_array($data)) {
    $maBoMon = strtoupper(trim($data["ma_bo_mon"] ?? ""));
    $tenBoMon = trim($data["ten_bo_mon"] ?? "");
    $khoaId = (int) ($data["khoa_id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "dang_hoat_dong");
} else {
    $maBoMon = strtoupper(trim($_POST["ma_bo_mon"] ?? ""));
    $tenBoMon = trim($_POST["ten_bo_mon"] ?? "");
    $khoaId = (int) ($_POST["khoa_id"] ?? 0);
    $trangThai = trim($_POST["trang_thai"] ?? "dang_hoat_dong");
}

$trangThaiHopLe = ["dang_hoat_dong", "ngung_hoat_dong"];

if ($maBoMon === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Mã bộ môn không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($tenBoMon === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Tên bộ môn không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($khoaId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Vui lòng chọn khoa"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái bộ môn không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkKhoaSql = "SELECT id, trang_thai 
                     FROM khoa 
                     WHERE id = :khoa_id 
                     LIMIT 1";

    $checkKhoaStmt = $conn->prepare($checkKhoaSql);
    $checkKhoaStmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $checkKhoaStmt->execute();

    $khoa = $checkKhoaStmt->fetch(PDO::FETCH_ASSOC);

    if (!$khoa) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy khoa đã chọn"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($khoa["trang_thai"] !== "dang_hoat_dong") {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Không thể thêm bộ môn vào khoa đã ngừng hoạt động"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkDuplicateSql = "SELECT id 
                          FROM bo_mon 
                          WHERE ma_bo_mon = :ma_bo_mon 
                          LIMIT 1";

    $checkDuplicateStmt = $conn->prepare($checkDuplicateSql);
    $checkDuplicateStmt->bindValue(":ma_bo_mon", $maBoMon, PDO::PARAM_STR);
    $checkDuplicateStmt->execute();

    if ($checkDuplicateStmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Mã bộ môn đã tồn tại"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "INSERT INTO bo_mon (ma_bo_mon, ten_bo_mon, khoa_id, trang_thai)
            VALUES (:ma_bo_mon, :ten_bo_mon, :khoa_id, :trang_thai)";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ma_bo_mon", $maBoMon, PDO::PARAM_STR);
    $stmt->bindValue(":ten_bo_mon", $tenBoMon, PDO::PARAM_STR);
    $stmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    $newId = (int) $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Thêm bộ môn thành công",
        "data" => [
            "id" => $newId,
            "ma_bo_mon" => $maBoMon,
            "ten_bo_mon" => $tenBoMon,
            "khoa_id" => $khoaId,
            "trang_thai" => $trangThai
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi thêm bộ môn",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>