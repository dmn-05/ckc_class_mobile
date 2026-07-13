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
$maMon = "";
$tenMon = "";
$tinChi = 3;
$khoaId = 0;
$boMonId = 0;
$trangThai = "dang_mo";

if (is_array($data)) {
    $id = (int) ($data["id"] ?? 0);
    $maMon = strtoupper(trim($data["ma_mon"] ?? ""));
    $tenMon = trim($data["ten_mon"] ?? "");
    $tinChi = (int) ($data["tin_chi"] ?? 3);
    $khoaId = (int) ($data["khoa_id"] ?? 0);
    $boMonId = (int) ($data["bo_mon_id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "dang_mo");
} else {
    $id = (int) ($_POST["id"] ?? 0);
    $maMon = strtoupper(trim($_POST["ma_mon"] ?? ""));
    $tenMon = trim($_POST["ten_mon"] ?? "");
    $tinChi = (int) ($_POST["tin_chi"] ?? 3);
    $khoaId = (int) ($_POST["khoa_id"] ?? 0);
    $boMonId = (int) ($_POST["bo_mon_id"] ?? 0);
    $trangThai = trim($_POST["trang_thai"] ?? "dang_mo");
}

$trangThaiHopLe = ["dang_mo", "ngung_su_dung"];

if ($id <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID môn học không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($maMon === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Mã môn học không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($tenMon === "") {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Tên môn học không được để trống"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($tinChi <= 0 || $tinChi > 10) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Số tín chỉ phải từ 1 đến 10"
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

if ($boMonId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Vui lòng chọn bộ môn"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái môn học không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkExistSql = "SELECT id 
                      FROM mon_hoc 
                      WHERE id = :id 
                      LIMIT 1";

    $checkExistStmt = $conn->prepare($checkExistSql);
    $checkExistStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkExistStmt->execute();

    if (!$checkExistStmt->fetch()) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy môn học cần sửa"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

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
            "message" => "Khoa không tồn tại"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($khoa["trang_thai"] !== "dang_hoat_dong") {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Không thể chuyển môn học vào khoa đã ngừng hoạt động"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkBoMonSql = "SELECT id, trang_thai 
                      FROM bo_mon 
                      WHERE id = :bo_mon_id AND khoa_id = :khoa_id 
                      LIMIT 1";

    $checkBoMonStmt = $conn->prepare($checkBoMonSql);
    $checkBoMonStmt->bindValue(":bo_mon_id", $boMonId, PDO::PARAM_INT);
    $checkBoMonStmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $checkBoMonStmt->execute();

    $boMon = $checkBoMonStmt->fetch(PDO::FETCH_ASSOC);

    if (!$boMon) {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Bộ môn không thuộc khoa đã chọn"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($boMon["trang_thai"] !== "dang_hoat_dong") {
        http_response_code(400);
        echo json_encode([
            "status" => "error",
            "message" => "Không thể chuyển môn học vào bộ môn đã ngừng hoạt động"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkMaSql = "SELECT id 
                   FROM mon_hoc 
                   WHERE ma_mon = :ma_mon AND id <> :id 
                   LIMIT 1";

    $checkMaStmt = $conn->prepare($checkMaSql);
    $checkMaStmt->bindValue(":ma_mon", $maMon, PDO::PARAM_STR);
    $checkMaStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkMaStmt->execute();

    if ($checkMaStmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Mã môn học đã tồn tại"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $checkTenSql = "SELECT id 
                    FROM mon_hoc 
                    WHERE ten_mon = :ten_mon 
                    AND bo_mon_id = :bo_mon_id 
                    AND id <> :id
                    LIMIT 1";

    $checkTenStmt = $conn->prepare($checkTenSql);
    $checkTenStmt->bindValue(":ten_mon", $tenMon, PDO::PARAM_STR);
    $checkTenStmt->bindValue(":bo_mon_id", $boMonId, PDO::PARAM_INT);
    $checkTenStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkTenStmt->execute();

    if ($checkTenStmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            "status" => "error",
            "message" => "Tên môn học đã tồn tại trong bộ môn đã chọn"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE mon_hoc
            SET ma_mon = :ma_mon,
                ten_mon = :ten_mon,
                tin_chi = :tin_chi,
                khoa_id = :khoa_id,
                bo_mon_id = :bo_mon_id,
                trang_thai = :trang_thai
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ma_mon", $maMon, PDO::PARAM_STR);
    $stmt->bindValue(":ten_mon", $tenMon, PDO::PARAM_STR);
    $stmt->bindValue(":tin_chi", $tinChi, PDO::PARAM_INT);
    $stmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
    $stmt->bindValue(":bo_mon_id", $boMonId, PDO::PARAM_INT);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Cập nhật môn học thành công",
        "data" => [
            "id" => $id,
            "ma_mon" => $maMon,
            "ten_mon" => $tenMon,
            "tin_chi" => $tinChi,
            "khoa_id" => $khoaId,
            "bo_mon_id" => $boMonId,
            "trang_thai" => $trangThai
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi cập nhật môn học",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>