<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit();
}

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    echo json_encode([
        "status" => "error",
        "message" => "Chỉ hỗ trợ phương thức POST",
        "method" => $_SERVER["REQUEST_METHOD"],
        "file" => __FILE__
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/ket_noi.php";

$email = trim($_POST["email"] ?? "");
$password = trim($_POST["password"] ?? "");

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (is_array($data)) {
    $email = trim($data["email"] ?? $email);
    $password = trim($data["password"] ?? $password);
}

if ($email === "" || $password === "") {
    echo json_encode([
        "status" => "error",
        "message" => "Thiếu email hoặc mật khẩu"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$sql = "
    SELECT 
        nd.id,
        nd.ho_ten,
        nd.email,
        nd.mat_khau,
        nd.vai_tro_id,
        nd.trang_thai,
        nd.avatar,
        nd.ngay_tao,
        nd.ngay_cap_nhat,
        vt.ten_vai_tro,
        gv.id AS giang_vien_id,
        gv.ma_giang_vien,
        gv.ngay_sinh AS gv_ngay_sinh,
        gv.gioi_tinh AS gv_gioi_tinh,
        gv.so_dien_thoai AS gv_so_dien_thoai,
        gv.cccd AS gv_cccd,
        gv.dia_chi AS gv_dia_chi,
        gv.bo_mon_id,
        gv.trang_thai AS trang_thai_giang_vien,
        bm.ma_bo_mon,
        bm.ten_bo_mon,
        sv.id AS sinh_vien_id,
        sv.ma_sinh_vien,
        sv.ngay_sinh AS sv_ngay_sinh,
        sv.gioi_tinh AS sv_gioi_tinh,
        sv.so_dien_thoai AS sv_so_dien_thoai,
        sv.cccd AS sv_cccd,
        sv.dia_chi AS sv_dia_chi,
        sv.lop_id,
        sv.khoa_id AS khoa_sinh_vien_id,
        sv.trang_thai AS trang_thai_sinh_vien,
        l.ma_lop,
        l.ten_lop,
        k.ma_khoa AS ma_khoa_sinh_vien,
        k.ten_khoa AS ten_khoa_sinh_vien
    FROM nguoi_dung nd
    LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
    LEFT JOIN giang_vien gv ON gv.nguoi_dung_id = nd.id AND gv.deleted_at IS NULL
    LEFT JOIN bo_mon bm ON gv.bo_mon_id = bm.id
    LEFT JOIN sinh_vien sv ON sv.nguoi_dung_id = nd.id AND sv.deleted_at IS NULL
    LEFT JOIN lop l ON sv.lop_id = l.id
    LEFT JOIN khoa k ON sv.khoa_id = k.id
    WHERE nd.email = :email
    LIMIT 1
";

$stmt = $conn->prepare($sql);
$stmt->bindValue(":email", $email);
$stmt->execute();

$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode([
        "status" => "error",
        "message" => "Email không tồn tại"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$matKhauDb = trim($user["mat_khau"] ?? "");
$thongTinMaHoa = password_get_info($matKhauDb);
$laMatKhauDangThuong = $thongTinMaHoa["algoName"] === "unknown";
$matKhauDung = false;

// Tạm hỗ trợ dữ liệu cũ đang lưu mật khẩu thường để người dùng vẫn đăng nhập được.
if ($laMatKhauDangThuong && hash_equals($matKhauDb, $password)) {
    $matKhauDung = true;
}

if (!$laMatKhauDangThuong) {
    $matKhauDung = password_verify($password, $matKhauDb);
}

if (!$matKhauDung) {
    echo json_encode([
        "status" => "error",
        "message" => "Sai mật khẩu"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (($user["trang_thai"] ?? "") === "bi_khoa") {
    echo json_encode([
        "status" => "error",
        "message" => "Tài khoản này đã bị khóa, vui lòng liên hệ Khoa."
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Tự động chuyển mật khẩu cũ dạng thường sang password_hash sau lần đăng nhập đúng.
if ($laMatKhauDangThuong) {
    $matKhauHash = password_hash($password, PASSWORD_DEFAULT);
    if ($matKhauHash !== false) {
        $up = $conn->prepare("UPDATE nguoi_dung SET mat_khau = :mat_khau, ngay_cap_nhat = NOW() WHERE id = :id");
        $up->execute([":mat_khau" => $matKhauHash, ":id" => (int)$user["id"]]);
    }
}

echo json_encode([
    "status" => "success",
    "message" => "Đăng nhập thành công",
    "user" => [
        "id" => (int)$user["id"],
        "ho_ten" => $user["ho_ten"],
        "email" => $user["email"],
        "vai_tro_id" => (int)$user["vai_tro_id"],
        "ten_vai_tro" => $user["ten_vai_tro"],
        "trang_thai" => $user["trang_thai"],
        "avatar" => $user["avatar"],
        "ngay_tao" => $user["ngay_tao"],
        "ngay_cap_nhat" => $user["ngay_cap_nhat"],
        "giang_vien_id" => $user["giang_vien_id"] !== null ? (int)$user["giang_vien_id"] : null,
        "ma_giang_vien" => $user["ma_giang_vien"],
        "sinh_vien_id" => $user["sinh_vien_id"] !== null ? (int)$user["sinh_vien_id"] : null,
        "ma_sinh_vien" => $user["ma_sinh_vien"],
        "ngay_sinh" => $user["gv_ngay_sinh"] ?? $user["sv_ngay_sinh"],
        "gioi_tinh" => $user["gv_gioi_tinh"] ?? $user["sv_gioi_tinh"],
        "so_dien_thoai" => $user["gv_so_dien_thoai"] ?? $user["sv_so_dien_thoai"],
        "cccd" => $user["gv_cccd"] ?? $user["sv_cccd"],
        "dia_chi" => $user["gv_dia_chi"] ?? $user["sv_dia_chi"],
        "bo_mon_id" => $user["bo_mon_id"] !== null ? (int)$user["bo_mon_id"] : null,
        "ma_bo_mon" => $user["ma_bo_mon"],
        "ten_bo_mon" => $user["ten_bo_mon"],
        "lop_id" => $user["lop_id"] !== null ? (int)$user["lop_id"] : null,
        "ma_lop" => $user["ma_lop"],
        "ten_lop" => $user["ten_lop"],
        "khoa_sinh_vien_id" => $user["khoa_sinh_vien_id"] !== null ? (int)$user["khoa_sinh_vien_id"] : null,
        "ma_khoa_sinh_vien" => $user["ma_khoa_sinh_vien"],
        "ten_khoa_sinh_vien" => $user["ten_khoa_sinh_vien"],
        "trang_thai_giang_vien" => $user["trang_thai_giang_vien"],
        "trang_thai_sinh_vien" => $user["trang_thai_sinh_vien"]
    ]
], JSON_UNESCAPED_UNICODE);
?>