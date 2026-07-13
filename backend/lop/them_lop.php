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

$maLop = "";
$tenLop = "";
$khoaId = 0;
$khoaHoc = "";
$trangThai = "dang_hoc";

if (is_array($data)) {
    $maLop = strtoupper(trim($data["ma_lop"] ?? ""));
    $tenLop = trim($data["ten_lop"] ?? "");
    $khoaId = (int) ($data["khoa_id"] ?? 0);
    $khoaHoc = trim($data["khoa_hoc"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "dang_hoc");
} else {
    $maLop = strtoupper(trim($_POST["ma_lop"] ?? ""));
    $tenLop = trim($_POST["ten_lop"] ?? "");
    $khoaId = (int) ($_POST["khoa_id"] ?? 0);
    $khoaHoc = trim($_POST["khoa_hoc"] ?? "");
    $trangThai = trim($_POST["trang_thai"] ?? "dang_hoc");
}

function response_json(int $httpCode, array $payload): void {
    http_response_code($httpCode);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function validate_khoa_hoc(string $khoaHoc): void {
    if (!preg_match('/^[0-9]{4}-[0-9]{4}$/', $khoaHoc)) {
        response_json(400, [
            "status" => "error",
            "message" => "Khóa học không hợp lệ. Ví dụ đúng: 2024-2027"
        ]);
    }

    [$start, $end] = array_map('intval', explode('-', $khoaHoc));
    $namHienTai = (int) date("Y");

    if ($start < 2000 || $start > $namHienTai + 1) {
        response_json(400, [
            "status" => "error",
            "message" => "Năm bắt đầu khóa học không hợp lệ"
        ]);
    }

    if ($end - $start !== 3) {
        response_json(400, [
            "status" => "error",
            "message" => "Khóa học phải kéo dài đúng 3 năm. Ví dụ: 2024-2027"
        ]);
    }
}

$trangThaiHopLe = ["dang_hoc", "da_tot_nghiep", "tam_khoa"];

if ($maLop === "") response_json(400, ["status" => "error", "message" => "Mã lớp không được để trống"]);
if ($tenLop === "") response_json(400, ["status" => "error", "message" => "Tên lớp không được để trống"]);
if ($khoaId <= 0) response_json(400, ["status" => "error", "message" => "Vui lòng chọn khoa"]);
if ($khoaHoc === "") response_json(400, ["status" => "error", "message" => "Vui lòng chọn khóa học"]);

validate_khoa_hoc($khoaHoc);

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    response_json(400, ["status" => "error", "message" => "Trạng thái lớp không hợp lệ"]);
}

try {
    $checkKhoaSql = "SELECT id, trang_thai FROM khoa WHERE id = :khoa_id LIMIT 1";
    $checkKhoaStmt = $conn->prepare($checkKhoaSql);
    $checkKhoaStmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $checkKhoaStmt->execute();
    $khoa = $checkKhoaStmt->fetch(PDO::FETCH_ASSOC);

    if (!$khoa) response_json(404, ["status" => "error", "message" => "Không tìm thấy khoa đã chọn"]);

    if ($khoa["trang_thai"] !== "dang_hoat_dong") {
        response_json(400, ["status" => "error", "message" => "Không thể thêm lớp vào khoa đã ngừng hoạt động"]);
    }

    $checkDuplicateSql = "SELECT id FROM lop WHERE ma_lop = :ma_lop LIMIT 1";
    $checkDuplicateStmt = $conn->prepare($checkDuplicateSql);
    $checkDuplicateStmt->bindValue(":ma_lop", $maLop, PDO::PARAM_STR);
    $checkDuplicateStmt->execute();

    if ($checkDuplicateStmt->fetch()) {
        response_json(409, ["status" => "error", "message" => "Mã lớp đã tồn tại"]);
    }

    $sql = "INSERT INTO lop (
                ma_lop,
                ten_lop,
                khoa_id,
                khoa_hoc,
                trang_thai
            )
            VALUES (
                :ma_lop,
                :ten_lop,
                :khoa_id,
                :khoa_hoc,
                :trang_thai
            )";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ma_lop", $maLop, PDO::PARAM_STR);
    $stmt->bindValue(":ten_lop", $tenLop, PDO::PARAM_STR);
    $stmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $stmt->bindValue(":khoa_hoc", $khoaHoc, PDO::PARAM_STR);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    $newId = (int) $conn->lastInsertId();

    echo json_encode([
        "status" => "success",
        "message" => "Thêm lớp thành công",
        "data" => [
            "id" => $newId,
            "ma_lop" => $maLop,
            "ten_lop" => $tenLop,
            "khoa_id" => $khoaId,
            "khoa_hoc" => $khoaHoc,
            "trang_thai" => $trangThai
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi thêm lớp",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
