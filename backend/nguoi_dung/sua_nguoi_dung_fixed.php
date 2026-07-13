<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

function respond($status, $message, $data = null, $code = 200) {
    http_response_code($code);
    $res = ["status" => $status, "message" => $message];
    if ($data !== null) $res["data"] = $data;
    echo json_encode($res, JSON_UNESCAPED_UNICODE);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) $data = $_POST;

$id = (int)($data["id"] ?? 0);
$hoTen = trim($data["ho_ten"] ?? "");
$email = strtolower(trim($data["email"] ?? ""));
$matKhau = trim($data["mat_khau"] ?? "");
$vaiTroId = (int)($data["vai_tro_id"] ?? 0);
$trangThai = trim($data["trang_thai"] ?? "dang_hoat_dong");

// Dữ liệu sinh viên: lớp ở đây là lớp hành chính, không phải lớp học phần tham gia bằng mã.
$maSinhVien = trim($data["ma_sinh_vien"] ?? "");
$lopId = (int)($data["lop_id"] ?? 0);
$khoaId = (int)($data["khoa_id"] ?? 0);

// Dữ liệu giảng viên.
$maGiangVien = trim($data["ma_giang_vien"] ?? "");
$boMonId = (int)($data["bo_mon_id"] ?? 0);

$trangThaiHopLe = ["dang_hoat_dong", "bi_khoa"];

if ($id <= 0) respond("error", "ID người dùng không hợp lệ", null, 400);
if ($hoTen === "") respond("error", "Họ tên không được để trống", null, 400);
if ($email === "") respond("error", "Email không được để trống", null, 400);
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) respond("error", "Email không hợp lệ", null, 400);
if ($matKhau !== "" && strlen($matKhau) < 6) respond("error", "Mật khẩu mới phải có ít nhất 6 ký tự", null, 400);
if ($vaiTroId <= 0) respond("error", "Vui lòng chọn vai trò", null, 400);
if (!in_array($trangThai, $trangThaiHopLe, true)) respond("error", "Trạng thái người dùng không hợp lệ", null, 400);

// Vì CSDL đang để sinh_vien.lop_id và sinh_vien.khoa_id NOT NULL nên sinh viên bắt buộc nhập 2 ID này.
if ($vaiTroId === 3) {
    if ($lopId <= 0) respond("error", "Vui lòng nhập ID lớp hành chính cho sinh viên", null, 400);
    if ($khoaId <= 0) respond("error", "Vui lòng nhập ID khoa cho sinh viên", null, 400);
}

try {
    $stmt = $conn->prepare("SELECT id FROM nguoi_dung WHERE id = :id LIMIT 1");
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetch()) respond("error", "Không tìm thấy người dùng cần sửa", null, 404);

    $stmt = $conn->prepare("SELECT id FROM vai_tro WHERE id = :id LIMIT 1");
    $stmt->bindValue(":id", $vaiTroId, PDO::PARAM_INT);
    $stmt->execute();
    if (!$stmt->fetch()) respond("error", "Vai trò không tồn tại", null, 404);

    $stmt = $conn->prepare("SELECT id FROM nguoi_dung WHERE email = :email AND id <> :id LIMIT 1");
    $stmt->bindValue(":email", $email, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    $stmt->execute();
    if ($stmt->fetch()) respond("error", "Email đã tồn tại", null, 409);

    if ($vaiTroId === 3) {
        $stmt = $conn->prepare("SELECT id FROM lop WHERE id = :id LIMIT 1");
        $stmt->bindValue(":id", $lopId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) respond("error", "Lớp hành chính không tồn tại", null, 404);

        $stmt = $conn->prepare("SELECT id FROM khoa WHERE id = :id LIMIT 1");
        $stmt->bindValue(":id", $khoaId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) respond("error", "Khoa không tồn tại", null, 404);
    }

    if ($vaiTroId === 2 && $boMonId > 0) {
        $stmt = $conn->prepare("SELECT id FROM bo_mon WHERE id = :id LIMIT 1");
        $stmt->bindValue(":id", $boMonId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) respond("error", "Bộ môn không tồn tại", null, 404);
    }

    $conn->beginTransaction();

    if ($matKhau !== "") {
        $sql = "UPDATE nguoi_dung SET ho_ten = :ho_ten, email = :email, mat_khau = :mat_khau, vai_tro_id = :vai_tro_id, trang_thai = :trang_thai WHERE id = :id";
    } else {
        $sql = "UPDATE nguoi_dung SET ho_ten = :ho_ten, email = :email, vai_tro_id = :vai_tro_id, trang_thai = :trang_thai WHERE id = :id";
    }

    $stmt = $conn->prepare($sql);
    $stmt->bindValue(":ho_ten", $hoTen, PDO::PARAM_STR);
    $stmt->bindValue(":email", $email, PDO::PARAM_STR);
    $stmt->bindValue(":vai_tro_id", $vaiTroId, PDO::PARAM_INT);
    $stmt->bindValue(":trang_thai", $trangThai, PDO::PARAM_STR);
    $stmt->bindValue(":id", $id, PDO::PARAM_INT);
    if ($matKhau !== "") $stmt->bindValue(":mat_khau", $matKhau, PDO::PARAM_STR);
    $stmt->execute();

    $extra = [];

    if ($vaiTroId === 3) {
        if ($maSinhVien === "") $maSinhVien = "SV" . str_pad($id, 3, "0", STR_PAD_LEFT);

        $stmt = $conn->prepare("SELECT id FROM sinh_vien WHERE nguoi_dung_id = :nguoi_dung_id LIMIT 1");
        $stmt->bindValue(":nguoi_dung_id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $sv = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sv) {
            $svId = (int)$sv["id"];
            $stmt = $conn->prepare("UPDATE sinh_vien SET ma_sinh_vien = :ma_sinh_vien, lop_id = :lop_id, khoa_id = :khoa_id, trang_thai = 'dang_hoc' WHERE id = :id");
            $stmt->bindValue(":id", $svId, PDO::PARAM_INT);
        } else {
            $stmt = $conn->prepare("INSERT INTO sinh_vien (nguoi_dung_id, ma_sinh_vien, lop_id, khoa_id, trang_thai) VALUES (:nguoi_dung_id, :ma_sinh_vien, :lop_id, :khoa_id, 'dang_hoc')");
            $stmt->bindValue(":nguoi_dung_id", $id, PDO::PARAM_INT);
        }
        $stmt->bindValue(":ma_sinh_vien", $maSinhVien, PDO::PARAM_STR);
        $stmt->bindValue(":lop_id", $lopId, PDO::PARAM_INT);
        $stmt->bindValue(":khoa_id", $khoaId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$sv) $svId = (int)$conn->lastInsertId();

        $extra["sinh_vien_id"] = $svId;
        $extra["ma_sinh_vien"] = $maSinhVien;
        $extra["lop_id"] = $lopId;
        $extra["khoa_id"] = $khoaId;
    }

    if ($vaiTroId === 2) {
        if ($maGiangVien === "") $maGiangVien = "GV" . str_pad($id, 3, "0", STR_PAD_LEFT);

        $stmt = $conn->prepare("SELECT id FROM giang_vien WHERE nguoi_dung_id = :nguoi_dung_id LIMIT 1");
        $stmt->bindValue(":nguoi_dung_id", $id, PDO::PARAM_INT);
        $stmt->execute();
        $gv = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($gv) {
            $gvId = (int)$gv["id"];
            $stmt = $conn->prepare("UPDATE giang_vien SET ma_giang_vien = :ma_giang_vien, bo_mon_id = :bo_mon_id, trang_thai = 'dang_day' WHERE id = :id");
            $stmt->bindValue(":id", $gvId, PDO::PARAM_INT);
        } else {
            $stmt = $conn->prepare("INSERT INTO giang_vien (nguoi_dung_id, ma_giang_vien, bo_mon_id, trang_thai) VALUES (:nguoi_dung_id, :ma_giang_vien, :bo_mon_id, 'dang_day')");
            $stmt->bindValue(":nguoi_dung_id", $id, PDO::PARAM_INT);
        }
        $stmt->bindValue(":ma_giang_vien", $maGiangVien, PDO::PARAM_STR);
        if ($boMonId > 0) $stmt->bindValue(":bo_mon_id", $boMonId, PDO::PARAM_INT);
        else $stmt->bindValue(":bo_mon_id", null, PDO::PARAM_NULL);
        $stmt->execute();
        if (!$gv) $gvId = (int)$conn->lastInsertId();

        $extra["giang_vien_id"] = $gvId;
        $extra["ma_giang_vien"] = $maGiangVien;
        $extra["bo_mon_id"] = $boMonId > 0 ? $boMonId : null;
    }

    $conn->commit();

    respond("success", "Cập nhật người dùng thành công", array_merge([
        "id" => $id,
        "ho_ten" => $hoTen,
        "email" => $email,
        "vai_tro_id" => $vaiTroId,
        "trang_thai" => $trangThai
    ], $extra));
} catch (Exception $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    respond("error", "Lỗi server khi cập nhật người dùng", ["detail" => $e->getMessage()], 500);
}
?>
