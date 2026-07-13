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
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) {
    $data = $_POST;
}

$id = (int)($data["id"] ?? 0);
$tieuDe = trim($data["tieu_de"] ?? "");
$moTa = trim($data["mo_ta"] ?? "");
$duongDanFile = trim($data["duong_dan_file"] ?? "");
$lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
$trangThai = trim($data["trang_thai"] ?? "hien_thi");

$trangThaiHopLe = ["hien_thi", "an"];

if ($id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID tài liệu không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}
if ($tieuDe === "") {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Tiêu đề tài liệu không được để trống"], JSON_UNESCAPED_UNICODE);
    exit();
}
if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Vui lòng chọn lớp học phần"], JSON_UNESCAPED_UNICODE);
    exit();
}
if ($duongDanFile === "") {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Đường dẫn file không được để trống"], JSON_UNESCAPED_UNICODE);
    exit();
}
if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Trạng thái tài liệu không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->prepare("SELECT id FROM tai_lieu WHERE id = :id LIMIT 1");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetch(PDO::FETCH_ASSOC)) {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy tài liệu"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $stmt = $conn->prepare("SELECT id FROM lop_hoc_phan WHERE id = :id LIMIT 1");
    $stmt->bindValue(":id", $lopHocPhanId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetch(PDO::FETCH_ASSOC)) {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy lớp học phần"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $stmt = $conn->prepare("UPDATE tai_lieu
        SET tieu_de = :tieu_de,
            mo_ta = :mo_ta,
            duong_dan_file = :duong_dan_file,
            lop_hoc_phan_id = :lop_hoc_phan_id,
            trang_thai = :trang_thai
        WHERE id = :id");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->bindValue(":tieu_de", $tieuDe, PDO::PARAM_STR);
    $stmt->bindValue(":mo_ta", $moTa === "" ? null : $moTa, $moTa === "" ? PDO::PARAM_NULL : PDO::PARAM_STR);
    $stmt->bindValue(":duong_dan_file", $duongDanFile, PDO::PARAM_STR);
    $stmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    echo json_encode(["status" => "success", "message" => "Cập nhật tài liệu thành công"], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi cập nhật tài liệu",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
