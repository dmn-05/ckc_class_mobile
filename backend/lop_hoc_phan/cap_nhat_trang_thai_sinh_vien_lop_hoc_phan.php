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
$trangThai = "";

if (is_array($data)) {
    $id = (int) ($data["id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $id = (int) ($_POST["id"] ?? 0);
    $trangThai = trim($_POST["trang_thai"] ?? "");
}

$trangThaiHopLe = ["dang_hoc", "da_huy", "hoan_thanh"];

if ($id <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID sinh viên lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái sinh viên trong lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $conn->beginTransaction();

    $checkSql = "SELECT
                    svlhp.id,
                    svlhp.sinh_vien_id,
                    svlhp.lop_hoc_phan_id,
                    svlhp.trang_thai,
                    sv.ma_sinh_vien,
                    nd.ho_ten,
                    lhp.si_so_toi_da
                 FROM sinh_vien_lop_hoc_phan svlhp
                 INNER JOIN sinh_vien sv ON svlhp.sinh_vien_id = sv.id
                 INNER JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
                 INNER JOIN lop_hoc_phan lhp ON svlhp.lop_hoc_phan_id = lhp.id
                 WHERE svlhp.id = :id
                 LIMIT 1
                 FOR UPDATE";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $dangKy = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$dangKy) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy sinh viên trong lớp học phần"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($trangThai === "dang_hoc" && $dangKy["trang_thai"] !== "dang_hoc") {
        $countSql = "SELECT COUNT(*) AS so_luong
                     FROM sinh_vien_lop_hoc_phan
                     WHERE lop_hoc_phan_id = :lop_hoc_phan_id
                       AND trang_thai = 'dang_hoc'";

        $countStmt = $conn->prepare($countSql);
        $countStmt->bindValue(":lop_hoc_phan_id", (int) $dangKy["lop_hoc_phan_id"], PDO::PARAM_INT);
        $countStmt->execute();

        $soLuongDangHoc = (int) $countStmt->fetchColumn();
        $siSoToiDa = $dangKy["si_so_toi_da"] !== null ? (int) $dangKy["si_so_toi_da"] : null;

        if ($siSoToiDa !== null && $soLuongDangHoc >= $siSoToiDa) {
            $conn->rollBack();
            http_response_code(400);
            echo json_encode([
                "status" => "error",
                "message" => "Lớp học phần đã đủ sĩ số tối đa"
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }

    $sql = "UPDATE sinh_vien_lop_hoc_phan
            SET trang_thai = :trang_thai
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    $conn->commit();

    echo json_encode([
        "status" => "success",
        "message" => "Cập nhật trạng thái sinh viên thành công",
        "data" => [
            "id" => (int) $dangKy["id"],
            "sinh_vien_id" => (int) $dangKy["sinh_vien_id"],
            "lop_hoc_phan_id" => (int) $dangKy["lop_hoc_phan_id"],
            "trang_thai" => $trangThai,
            "ma_sinh_vien" => $dangKy["ma_sinh_vien"],
            "ho_ten" => $dangKy["ho_ten"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi cập nhật trạng thái sinh viên",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
