<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

function respond($status, $message, $extra = [], $code = 200) {
    http_response_code($code);
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function db_has_table(PDO $conn, string $table): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $stmt->execute([$db, $table]);
    return (int)$stmt->fetchColumn() > 0;
}

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) $data = $_POST;

$giangVienId = (int)($data["giang_vien_id"] ?? 0);
$maLopHocPhan = strtoupper(trim($data["ma_lop_hoc_phan"] ?? ""));
$tenLop = trim($data["ten_lop"] ?? "");
$monHocId = (int)($data["mon_hoc_id"] ?? 0);
$hocKy = trim($data["hoc_ky"] ?? "HK1");
$namHoc = trim($data["nam_hoc"] ?? "");
$siSoToiDaRaw = trim((string)($data["si_so_toi_da"] ?? ""));
$trangThai = trim($data["trang_thai"] ?? "dang_mo");

$hocKyHopLe = ["HK1", "HK2", "HK3", "HK4", "HK5", "HK6"];
$trangThaiHopLe = ["dang_mo", "da_khoa", "da_ket_thuc"];

if ($giangVienId <= 0) respond("error", "ID giảng viên không hợp lệ", [], 400);
if ($maLopHocPhan === "") respond("error", "Mã lớp học phần không được để trống", [], 400);
if ($tenLop === "") respond("error", "Tên lớp học phần không được để trống", [], 400);
if ($monHocId <= 0) respond("error", "Vui lòng chọn môn học", [], 400);
if (!in_array($hocKy, $hocKyHopLe, true)) respond("error", "Học kỳ không hợp lệ", [], 400);
if (!preg_match('/^(\d{4})-(\d{4})$/', $namHoc, $namMatch) || ((int)$namMatch[2] - (int)$namMatch[1]) !== 1) {
    respond("error", "Năm học phải có dạng YYYY-YYYY và hai năm liên tiếp", [], 400);
}
if (!in_array($trangThai, $trangThaiHopLe, true)) respond("error", "Trạng thái không hợp lệ", [], 400);

$siSoToiDa = null;
if ($siSoToiDaRaw !== "") {
    $siSoToiDa = (int)$siSoToiDaRaw;
    if ($siSoToiDa <= 0) respond("error", "Sĩ số tối đa phải lớn hơn 0", [], 400);
}

try {
    $stmt = $conn->prepare("SELECT id FROM giang_vien WHERE id = ? AND trang_thai = 'dang_day' LIMIT 1");
    $stmt->execute([$giangVienId]);
    if (!$stmt->fetch(PDO::FETCH_ASSOC)) respond("error", "Giảng viên không tồn tại hoặc đã ngừng dạy", [], 404);

    $stmt = $conn->prepare("SELECT id FROM mon_hoc WHERE id = ? AND trang_thai = 'dang_mo' LIMIT 1");
    $stmt->execute([$monHocId]);
    if (!$stmt->fetch(PDO::FETCH_ASSOC)) respond("error", "Môn học không tồn tại hoặc đã ngừng sử dụng", [], 404);

    $stmt = $conn->prepare("SELECT id FROM lop_hoc_phan WHERE ma_lop_hoc_phan = ? LIMIT 1");
    $stmt->execute([$maLopHocPhan]);
    if ($stmt->fetch(PDO::FETCH_ASSOC)) respond("error", "Mã lớp học phần đã tồn tại", [], 409);

    $conn->beginTransaction();
    $stmt = $conn->prepare("
        INSERT INTO lop_hoc_phan
        (ma_lop_hoc_phan, ten_lop, mon_hoc_id, giang_vien_id, hoc_ky, nam_hoc, si_so_toi_da, trang_thai)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([$maLopHocPhan, $tenLop, $monHocId, $giangVienId, $hocKy, $namHoc, $siSoToiDa, $trangThai]);
    $lopHocPhanId = (int)$conn->lastInsertId();

    if (db_has_table($conn, 'giang_vien_lop_hoc_phan')) {
        $stmtMap = $conn->prepare("INSERT IGNORE INTO giang_vien_lop_hoc_phan (lop_hoc_phan_id, giang_vien_id, vai_tro, ngay_tao, ngay_cap_nhat) VALUES (?, ?, 'chinh', NOW(), NOW())");
        $stmtMap->execute([$lopHocPhanId, $giangVienId]);
    }
    $conn->commit();

    respond("success", "Tạo lớp học phần thành công", ["data" => [
        "id" => $lopHocPhanId,
        "ma_lop_hoc_phan" => $maLopHocPhan,
        "ten_lop" => $tenLop,
        "mon_hoc_id" => $monHocId,
        "giang_vien_id" => $giangVienId,
        "hoc_ky" => $hocKy,
        "nam_hoc" => $namHoc,
        "si_so_toi_da" => $siSoToiDa,
        "trang_thai" => $trangThai,
    ]]);
} catch (PDOException $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    respond("error", "Lỗi server khi tạo lớp học phần", ["detail" => $e->getMessage()], 500);
}
?>
