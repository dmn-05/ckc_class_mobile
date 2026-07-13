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
        "message" => "ID sinh viên lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkSql = "SELECT
                    svlhp.id,
                    svlhp.sinh_vien_id,
                    svlhp.lop_hoc_phan_id,
                    svlhp.trang_thai,
                    sv.ma_sinh_vien,
                    nd.ho_ten,
                    lhp.ten_lop
                 FROM sinh_vien_lop_hoc_phan svlhp
                 INNER JOIN sinh_vien sv ON svlhp.sinh_vien_id = sv.id
                 INNER JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
                 INNER JOIN lop_hoc_phan lhp ON svlhp.lop_hoc_phan_id = lhp.id
                 WHERE svlhp.id = :id
                 LIMIT 1";

    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bindValue(":id", $id, PDO::PARAM_INT);
    $checkStmt->execute();

    $dangKy = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$dangKy) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy sinh viên trong lớp học phần"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($dangKy["trang_thai"] === "da_huy") {
        echo json_encode([
            "status" => "success",
            "message" => "Sinh viên đã được xóa khỏi lớp học phần trước đó",
            "data" => [
                "id" => (int) $dangKy["id"],
                "sinh_vien_id" => (int) $dangKy["sinh_vien_id"],
                "lop_hoc_phan_id" => (int) $dangKy["lop_hoc_phan_id"],
                "trang_thai" => "da_huy"
            ]
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "UPDATE sinh_vien_lop_hoc_phan
            SET trang_thai = 'da_huy'
            WHERE id = :id";

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Đã xóa sinh viên khỏi lớp học phần",
        "data" => [
            "id" => (int) $dangKy["id"],
            "sinh_vien_id" => (int) $dangKy["sinh_vien_id"],
            "lop_hoc_phan_id" => (int) $dangKy["lop_hoc_phan_id"],
            "trang_thai" => "da_huy",
            "ma_sinh_vien" => $dangKy["ma_sinh_vien"],
            "ho_ten" => $dangKy["ho_ten"]
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi xóa sinh viên khỏi lớp học phần",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
