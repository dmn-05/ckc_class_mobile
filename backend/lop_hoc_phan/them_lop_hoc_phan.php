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

function tenHocKyNgan(string $hocKy): string
{
    return match ($hocKy) {
        "HK1" => "Học kỳ 1",
        "HK2" => "Học kỳ 2",
        "HK3" => "Học kỳ 3",
        "HK4" => "Học kỳ 4",
        "HK5" => "Học kỳ 5",
        "HK6" => "Học kỳ 6",
        default => $hocKy,
    };
}

function taoTenLopHocPhan(?array $lopHanhChinh, array $monHoc, string $hocKy, string $namHoc): string
{
    if ($lopHanhChinh !== null) {
        return trim(($lopHanhChinh["ten_lop"] ?? "") . " - " . ($monHoc["ten_mon"] ?? ""));
    }

    return trim("HKP " . tenHocKyNgan($hocKy) . " " . $namHoc);
}

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);
if (!is_array($data)) {
    $data = $_POST;
}

$monHocId = (int) ($data["mon_hoc_id"] ?? 0);
$giangVienId = (int) ($data["giang_vien_id"] ?? 0);
$hocKy = trim($data["hoc_ky"] ?? "HK1");
$khoaHoc = trim($data["khoa_hoc"] ?? "");
$lopId = (int) ($data["lop_id"] ?? 0); // 0 = Học kỳ phụ
$siSoToiDa = isset($data["si_so_toi_da"]) && $data["si_so_toi_da"] !== ""
    ? (int) $data["si_so_toi_da"]
    : null;
$trangThai = trim($data["trang_thai"] ?? "dang_mo");

$hocKyHopLe = ["HK1", "HK2", "HK3", "HK4", "HK5", "HK6"];
$trangThaiHopLe = ["dang_mo", "da_khoa", "da_ket_thuc"];

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

if ($siSoToiDa !== null && ($siSoToiDa <= 0 || $siSoToiDa > 500)) {
    traLoiLoi(400, "Sĩ số tối đa phải từ 1 đến 500");
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    traLoiLoi(400, "Trạng thái lớp học phần không hợp lệ");
}

try {
    $checkMonSql = "SELECT id, ma_mon, ten_mon, trang_thai 
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

    $lopHanhChinh = null;
    if ($lopId > 0) {
        $checkLopSql = "SELECT id, ma_lop, ten_lop, khoa_id, khoa_hoc, trang_thai
                        FROM lop
                        WHERE id = :lop_id
                        LIMIT 1";
        $checkLopStmt = $conn->prepare($checkLopSql);
        $checkLopStmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
        $checkLopStmt->execute();
        $lopHanhChinh = $checkLopStmt->fetch(PDO::FETCH_ASSOC);

        if (!$lopHanhChinh) {
            traLoiLoi(404, "Không tìm thấy lớp hành chính đã chọn");
        }

        if ($lopHanhChinh["trang_thai"] !== "dang_hoc") {
            traLoiLoi(400, "Chỉ có thể thêm sinh viên từ lớp hành chính đang học");
        }

        $khoaHocCuaLop = trim($lopHanhChinh["khoa_hoc"] ?? "");
        if ($khoaHocCuaLop === "" || !hopLeKhoaHoc($khoaHocCuaLop)) {
            traLoiLoi(400, "Lớp hành chính đã chọn chưa có khóa học hợp lệ");
        }

        // Khi chọn lớp hành chính, khóa học của lớp học phần luôn đồng bộ theo lớp hành chính.
        $khoaHoc = $khoaHocCuaLop;
    }

    $namHoc = tinhNamHocTheoKhoaHocVaHocKy($khoaHoc, $hocKy);
    $tenLop = taoTenLopHocPhan($lopHanhChinh, $monHoc, $hocKy, $namHoc);
    $maLopHocPhan = $tenLop;

    if ($maLopHocPhan === "" || $tenLop === "") {
        traLoiLoi(400, "Không thể tự động tạo tên lớp học phần");
    }

    $checkDuplicateSql = "SELECT id 
                          FROM lop_hoc_phan 
                          WHERE ma_lop_hoc_phan = :ma_lop_hoc_phan 
                          LIMIT 1";

    $checkDuplicateStmt = $conn->prepare($checkDuplicateSql);
    $checkDuplicateStmt->bindValue(":ma_lop_hoc_phan", $maLopHocPhan, PDO::PARAM_STR);
    $checkDuplicateStmt->execute();

    if ($checkDuplicateStmt->fetch()) {
        traLoiLoi(409, "Lớp học phần đã tồn tại: " . $maLopHocPhan);
    }

    $conn->beginTransaction();

    $sql = "INSERT INTO lop_hoc_phan (
                ma_lop_hoc_phan,
                ten_lop,
                mon_hoc_id,
                giang_vien_id,
                hoc_ky,
                nam_hoc,
                khoa_hoc,
                si_so_toi_da,
                trang_thai
            )
            VALUES (
                :ma_lop_hoc_phan,
                :ten_lop,
                :mon_hoc_id,
                :giang_vien_id,
                :hoc_ky,
                :nam_hoc,
                :khoa_hoc,
                :si_so_toi_da,
                :trang_thai
            )";

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
    $stmt->execute();

    $newId = (int) $conn->lastInsertId();

    if (db_has_table($conn, 'giang_vien_lop_hoc_phan')) {
        $stmtMap = $conn->prepare("INSERT IGNORE INTO giang_vien_lop_hoc_phan (lop_hoc_phan_id, giang_vien_id, vai_tro, ngay_tao, ngay_cap_nhat) VALUES (?, ?, 'chinh', NOW(), NOW())");
        $stmtMap->execute([$newId, $giangVienId]);
    }

    $soSinhVienDaThem = 0;

    if ($lopId > 0) {
        $insertSinhVienSql = "INSERT INTO sinh_vien_lop_hoc_phan (
                                  sinh_vien_id,
                                  lop_hoc_phan_id,
                                  trang_thai
                              )
                              SELECT
                                  sv.id,
                                  :lop_hoc_phan_id,
                                  'dang_hoc'
                              FROM sinh_vien sv
                              INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                              WHERE sv.lop_id = :lop_id
                                AND sv.trang_thai = 'dang_hoc'
                                AND nd.trang_thai = 'dang_hoat_dong'";

        $insertSinhVienStmt = $conn->prepare($insertSinhVienSql);
        $insertSinhVienStmt->bindValue(":lop_hoc_phan_id", $newId, PDO::PARAM_INT);
        $insertSinhVienStmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
        $insertSinhVienStmt->execute();
        $soSinhVienDaThem = $insertSinhVienStmt->rowCount();
    }

    $conn->commit();

    $message = $lopId > 0
        ? "Thêm lớp học phần thành công và đã thêm {$soSinhVienDaThem} sinh viên từ lớp hành chính"
        : "Thêm lớp học phần học kỳ phụ thành công";

    echo json_encode([
        "status" => "success",
        "message" => $message,
        "data" => [
            "id" => $newId,
            "ma_lop_hoc_phan" => $maLopHocPhan,
            "ten_lop" => $tenLop,
            "mon_hoc_id" => $monHocId,
            "giang_vien_id" => $giangVienId,
            "hoc_ky" => $hocKy,
            "nam_hoc" => $namHoc,
            "khoa_hoc" => $khoaHoc,
            "lop_id_nguon" => $lopId,
            "so_sinh_vien_da_them" => $soSinhVienDaThem,
            "si_so_toi_da" => $siSoToiDa,
            "trang_thai" => $trangThai
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    traLoiLoi(500, "Lỗi server khi thêm lớp học phần", $e->getMessage());
}
?>
