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

$lopHocPhanId = 0;
$sinhVienId = 0;

if (is_array($data)) {
    $lopHocPhanId = (int) ($data["lop_hoc_phan_id"] ?? 0);
    $sinhVienId = (int) ($data["sinh_vien_id"] ?? 0);
} else {
    $lopHocPhanId = (int) ($_POST["lop_hoc_phan_id"] ?? 0);
    $sinhVienId = (int) ($_POST["sinh_vien_id"] ?? 0);
}

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($sinhVienId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID sinh viên không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $conn->beginTransaction();

    $checkLopSql = "SELECT id, ma_lop_hoc_phan, ten_lop, si_so_toi_da, trang_thai
                    FROM lop_hoc_phan
                    WHERE id = :lop_hoc_phan_id
                    LIMIT 1
                    FOR UPDATE";

    $checkLopStmt = $conn->prepare($checkLopSql);
    $checkLopStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $checkLopStmt->execute();

    $lopHocPhan = $checkLopStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lopHocPhan) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy lớp học phần"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($lopHocPhan["trang_thai"] !== "dang_mo") {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Chỉ có thể thêm sinh viên vào lớp học phần đang mở"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkSinhVienSql = "SELECT
                            sv.id,
                            sv.ma_sinh_vien,
                            sv.trang_thai AS trang_thai_sinh_vien,
                            nd.ho_ten,
                            nd.trang_thai AS trang_thai_tai_khoan
                         FROM sinh_vien sv
                         INNER JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
                         WHERE sv.id = :sinh_vien_id
                         LIMIT 1";

    $checkSinhVienStmt = $conn->prepare($checkSinhVienSql);
    $checkSinhVienStmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
    $checkSinhVienStmt->execute();

    $sinhVien = $checkSinhVienStmt->fetch(PDO::FETCH_ASSOC);

    if (!$sinhVien) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy sinh viên"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($sinhVien["trang_thai_sinh_vien"] !== "dang_hoc") {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Chỉ có thể thêm sinh viên đang học"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($sinhVien["trang_thai_tai_khoan"] !== "dang_hoat_dong") {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Tài khoản sinh viên đang bị khóa"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkDangKySql = "SELECT id, trang_thai
                       FROM sinh_vien_lop_hoc_phan
                       WHERE sinh_vien_id = :sinh_vien_id
                         AND lop_hoc_phan_id = :lop_hoc_phan_id
                       LIMIT 1
                       FOR UPDATE";

    $checkDangKyStmt = $conn->prepare($checkDangKySql);
    $checkDangKyStmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
    $checkDangKyStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $checkDangKyStmt->execute();

    $dangKy = $checkDangKyStmt->fetch(PDO::FETCH_ASSOC);

    if ($dangKy && $dangKy["trang_thai"] === "dang_hoc") {
        $conn->rollBack();
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Sinh viên đã có trong lớp học phần này"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($dangKy && $dangKy["trang_thai"] === "hoan_thanh") {
        $conn->rollBack();
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Sinh viên đã hoàn thành lớp học phần này, không thể thêm lại"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $countSql = "SELECT COUNT(*) AS so_luong
                 FROM sinh_vien_lop_hoc_phan
                 WHERE lop_hoc_phan_id = :lop_hoc_phan_id
                   AND trang_thai = 'dang_hoc'";

    $countStmt = $conn->prepare($countSql);
    $countStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $countStmt->execute();

    $soLuongDangHoc = (int) $countStmt->fetchColumn();
    $siSoToiDa = $lopHocPhan["si_so_toi_da"] !== null ? (int) $lopHocPhan["si_so_toi_da"] : null;

    if ($siSoToiDa !== null && $soLuongDangHoc >= $siSoToiDa) {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Lớp học phần đã đủ sĩ số tối đa"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($dangKy) {
        $updateSql = "UPDATE sinh_vien_lop_hoc_phan
                      SET trang_thai = 'dang_hoc'
                      WHERE id = :id";

        $updateStmt = $conn->prepare($updateSql);
        $updateStmt->bindValue(":id", (int) $dangKy["id"], PDO::PARAM_INT);
        $updateStmt->execute();

        $dangKyId = (int) $dangKy["id"];
        $message = "Thêm lại sinh viên vào lớp học phần thành công";
    } else {
        $insertSql = "INSERT INTO sinh_vien_lop_hoc_phan (
                        sinh_vien_id,
                        lop_hoc_phan_id,
                        trang_thai
                      ) VALUES (
                        :sinh_vien_id,
                        :lop_hoc_phan_id,
                        'dang_hoc'
                      )";

        $insertStmt = $conn->prepare($insertSql);
        $insertStmt->bindValue(":sinh_vien_id", $sinhVienId, PDO::PARAM_INT);
        $insertStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
        $insertStmt->execute();

        $dangKyId = (int) $conn->lastInsertId();
        $message = "Thêm sinh viên vào lớp học phần thành công";
    }

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => $message,
        "data" => [
            "id" => $dangKyId,
            "sinh_vien_id" => $sinhVienId,
            "lop_hoc_phan_id" => $lopHocPhanId,
            "trang_thai" => "dang_hoc",
            "ma_sinh_vien" => $sinhVien["ma_sinh_vien"],
            "ho_ten" => $sinhVien["ho_ten"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    $code = $e->getCode();

    if ($code === "23000") {
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Sinh viên đã có trong lớp học phần này"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi thêm sinh viên vào lớp học phần",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
