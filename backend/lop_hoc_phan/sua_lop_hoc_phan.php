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

function traLoiLoi(int $code, string $message, ?string $detail = null): void
{
    http_response_code($code);

    $response = [
        "status" => "error",
        "message" => $message
    ];

    if ($detail !== null) {
        $response["detail"] = $detail;
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}


function db_has_table(PDO $conn, string $table): bool
{
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $stmt->execute([$db, $table]);
    return (int)$stmt->fetchColumn() > 0;
}

function hopLeKhoaHoc(string $khoaHoc): bool
{
    if (!preg_match('/^[0-9]{4}-[0-9]{4}$/', $khoaHoc)) {
        return false;
    }

    $namBatDau = (int) substr($khoaHoc, 0, 4);
    $namKetThuc = (int) substr($khoaHoc, 5, 4);

    return $namKetThuc - $namBatDau === 3;
}

function tinhNamHocTheoKhoaHocVaHocKy(string $khoaHoc, string $hocKy): string
{
    $namBatDau = (int) substr($khoaHoc, 0, 4);

    $offset = match ($hocKy) {
        "HK1", "HK2" => 0,
        "HK3", "HK4" => 1,
        "HK5", "HK6" => 2,
        default => 0,
    };

    $nam1 = $namBatDau + $offset;
    $nam2 = $nam1 + 1;

    return $nam1 . "-" . $nam2;
}

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

$id = 0;
$maLopHocPhan = "";
$tenLop = "";
$monHocId = 0;
$giangVienId = 0;
$hocKy = "HK1";
$namHoc = "";
$khoaHoc = "";
$siSoToiDa = null;
$trangThai = "dang_mo";

if (is_array($data)) {
    $id = (int) ($data["id"] ?? 0);
    $maLopHocPhan = trim($data["ma_lop_hoc_phan"] ?? "");
    $tenLop = trim($data["ten_lop"] ?? "");
    $monHocId = (int) ($data["mon_hoc_id"] ?? 0);
    $giangVienId = (int) ($data["giang_vien_id"] ?? 0);
    $hocKy = trim($data["hoc_ky"] ?? "HK1");
    $namHoc = trim($data["nam_hoc"] ?? "");
    $khoaHoc = trim($data["khoa_hoc"] ?? "");
    $siSoToiDa = isset($data["si_so_toi_da"]) && $data["si_so_toi_da"] !== ""
        ? (int) $data["si_so_toi_da"]
        : null;
    $trangThai = trim($data["trang_thai"] ?? "dang_mo");
} else {
    $id = (int) ($_POST["id"] ?? 0);
    $maLopHocPhan = trim($_POST["ma_lop_hoc_phan"] ?? "");
    $tenLop = trim($_POST["ten_lop"] ?? "");
    $monHocId = (int) ($_POST["mon_hoc_id"] ?? 0);
    $giangVienId = (int) ($_POST["giang_vien_id"] ?? 0);
    $hocKy = trim($_POST["hoc_ky"] ?? "HK1");
    $namHoc = trim($_POST["nam_hoc"] ?? "");
    $khoaHoc = trim($_POST["khoa_hoc"] ?? "");
    $siSoToiDa = isset($_POST["si_so_toi_da"]) && $_POST["si_so_toi_da"] !== ""
        ? (int) $_POST["si_so_toi_da"]
        : null;
    $trangThai = trim($_POST["trang_thai"] ?? "dang_mo");
}

$hocKyHopLe = ["HK1", "HK2", "HK3", "HK4", "HK5", "HK6"];
$trangThaiHopLe = ["dang_mo", "da_khoa", "da_ket_thuc"];

if ($id <= 0) {
    traLoiLoi(400, "ID lớp học phần không hợp lệ");
}

if ($maLopHocPhan === "") {
    traLoiLoi(400, "Mã lớp học phần không được để trống");
}

if ($tenLop === "") {
    traLoiLoi(400, "Tên lớp học phần không được để trống");
}

if ($monHocId <= 0) {
    traLoiLoi(400, "Vui lòng chọn môn học");
}

if ($giangVienId <= 0) {
    traLoiLoi(400, "Vui lòng chọn giảng viên");
}

if (!in_array($hocKy, $hocKyHopLe, true)) {
    traLoiLoi(400, "Học kỳ không hợp lệ");
}

if ($khoaHoc === "") {
    traLoiLoi(400, "Vui lòng chọn khóa học");
}

if (!hopLeKhoaHoc($khoaHoc)) {
    traLoiLoi(400, "Khóa học không hợp lệ. Ví dụ đúng: 2024-2027");
}

$namHoc = tinhNamHocTheoKhoaHocVaHocKy($khoaHoc, $hocKy);

if ($siSoToiDa !== null && ($siSoToiDa <= 0 || $siSoToiDa > 500)) {
    traLoiLoi(400, "Sĩ số tối đa phải từ 1 đến 500");
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    traLoiLoi(400, "Trạng thái lớp học phần không hợp lệ");
}

try {
    $checkExistSql = "SELECT id
                      FROM lop_hoc_phan
                      WHERE id = :id
                      LIMIT 1";

    $checkExistStmt = $conn->prepare($checkExistSql);
    $checkExistStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkExistStmt->execute();

    if (!$checkExistStmt->fetch(PDO::FETCH_ASSOC)) {
        traLoiLoi(404, "Không tìm thấy lớp học phần cần sửa");
    }

    $checkMonSql = "SELECT id, trang_thai 
                    FROM mon_hoc 
                    WHERE id = :mon_hoc_id 
                    LIMIT 1";

    $checkMonStmt = $conn->prepare($checkMonSql);
    $checkMonStmt->bindValue(":mon_hoc_id", $monHocId, PDO::PARAM_INT);
    $checkMonStmt->execute();

    $monHoc = $checkMonStmt->fetch(PDO::FETCH_ASSOC);

    if (!$monHoc) {
        traLoiLoi(404, "Không tìm thấy môn học đã chọn");
    }

    if ($monHoc["trang_thai"] !== "dang_mo") {
        traLoiLoi(400, "Không thể mở lớp học phần cho môn học đã ngừng sử dụng");
    }

    $checkGiangVienSql = "SELECT 
                            gv.id,
                            gv.trang_thai,
                            nd.trang_thai AS trang_thai_tai_khoan
                          FROM giang_vien gv
                          INNER JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
                          WHERE gv.id = :giang_vien_id
                          LIMIT 1";

    $checkGiangVienStmt = $conn->prepare($checkGiangVienSql);
    $checkGiangVienStmt->bindValue(":giang_vien_id", $giangVienId, PDO::PARAM_INT);
    $checkGiangVienStmt->execute();

    $giangVien = $checkGiangVienStmt->fetch(PDO::FETCH_ASSOC);

    if (!$giangVien) {
        traLoiLoi(404, "Không tìm thấy giảng viên đã chọn");
    }

    if ($giangVien["trang_thai"] !== "dang_day") {
        traLoiLoi(400, "Giảng viên đã ngừng dạy");
    }

    if ($giangVien["trang_thai_tai_khoan"] !== "dang_hoat_dong") {
        traLoiLoi(400, "Tài khoản giảng viên đang bị khóa");
    }

    $checkDuplicateSql = "SELECT id 
                          FROM lop_hoc_phan 
                          WHERE ma_lop_hoc_phan = :ma_lop_hoc_phan
                            AND id <> :id
                          LIMIT 1";

    $checkDuplicateStmt = $conn->prepare($checkDuplicateSql);
    $checkDuplicateStmt->bindValue(":ma_lop_hoc_phan", $maLopHocPhan, PDO::PARAM_STR);
    $checkDuplicateStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkDuplicateStmt->execute();

    if ($checkDuplicateStmt->fetch(PDO::FETCH_ASSOC)) {
        traLoiLoi(409, "Mã lớp học phần đã tồn tại");
    }

    $conn->beginTransaction();

    $sql = "UPDATE lop_hoc_phan
            SET ma_lop_hoc_phan = :ma_lop_hoc_phan,
                ten_lop = :ten_lop,
                mon_hoc_id = :mon_hoc_id,
                giang_vien_id = :giang_vien_id,
                hoc_ky = :hoc_ky,
                nam_hoc = :nam_hoc,
                khoa_hoc = :khoa_hoc,
                si_so_toi_da = :si_so_toi_da,
                trang_thai = :trang_thai
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ma_lop_hoc_phan", $maLopHocPhan, PDO::PARAM_STR);
    $stmt->bindValue(":ten_lop", $tenLop, PDO::PARAM_STR);
    $stmt->bindValue(":mon_hoc_id", $monHocId, PDO::PARAM_INT);
    $stmt->bindValue(":giang_vien_id", $giangVienId, PDO::PARAM_INT);
    $stmt->bindValue(":hoc_ky", $hocKy, PDO::PARAM_STR);
    $stmt->bindValue(":nam_hoc", $namHoc, PDO::PARAM_STR);
    $stmt->bindValue(":khoa_hoc", $khoaHoc, PDO::PARAM_STR);

    if ($siSoToiDa === null) {
        $stmt->bindValue(":si_so_toi_da", null, PDO::PARAM_NULL);
    } else {
        $stmt->bindValue(":si_so_toi_da", $siSoToiDa, PDO::PARAM_INT);
    }

    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    if (db_has_table($conn, 'giang_vien_lop_hoc_phan')) {
        $conn->prepare("DELETE FROM giang_vien_lop_hoc_phan WHERE lop_hoc_phan_id = ? AND vai_tro = 'chinh'")->execute([$id]);
        $stmtMap = $conn->prepare("INSERT IGNORE INTO giang_vien_lop_hoc_phan (lop_hoc_phan_id, giang_vien_id, vai_tro, ngay_tao, ngay_cap_nhat) VALUES (?, ?, 'chinh', NOW(), NOW())");
        $stmtMap->execute([$id, $giangVienId]);
    }

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Cập nhật lớp học phần thành công",
        "data" => [
            "id" => $id,
            "ma_lop_hoc_phan" => $maLopHocPhan,
            "ten_lop" => $tenLop,
            "mon_hoc_id" => $monHocId,
            "giang_vien_id" => $giangVienId,
            "hoc_ky" => $hocKy,
            "nam_hoc" => $namHoc,
            "khoa_hoc" => $khoaHoc,
            "si_so_toi_da" => $siSoToiDa,
            "trang_thai" => $trangThai
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    traLoiLoi(500, "Lỗi server khi cập nhật lớp học phần", $e->getMessage());
}
?>
