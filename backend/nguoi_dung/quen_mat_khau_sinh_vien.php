<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
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

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function normalize_text($value) {
    return trim((string)($value ?? ""));
}

try {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!is_array($data)) {
        $data = $_POST;
    }

    $maSinhVien = normalize_text($data["ma_sinh_vien"] ?? $data["mssv"] ?? "");
    $email = strtolower(normalize_text($data["email"] ?? $data["gmail"] ?? ""));
    $cccd = preg_replace('/\D+/', '', normalize_text($data["cccd"] ?? ""));

    if ($maSinhVien === "") respond("error", "Vui lòng nhập mã sinh viên");
    if ($email === "" || !filter_var($email, FILTER_VALIDATE_EMAIL)) respond("error", "Email không hợp lệ");
    if (!preg_match('/^\d{12}$/', $cccd)) respond("error", "CCCD phải gồm đúng 12 chữ số");

    $stmt = $conn->prepare(" 
        SELECT
            sv.id AS sinh_vien_id,
            sv.ma_sinh_vien,
            sv.cccd,
            sv.deleted_at,
            nd.id AS nguoi_dung_id,
            nd.email,
            nd.trang_thai
        FROM sinh_vien sv
        INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
        WHERE LOWER(sv.ma_sinh_vien) = LOWER(:ma_sinh_vien)
          AND LOWER(nd.email) = :email
          AND sv.cccd = :cccd
          AND sv.deleted_at IS NULL
        LIMIT 1
    ");
    $stmt->execute([
        ":ma_sinh_vien" => $maSinhVien,
        ":email" => $email,
        ":cccd" => $cccd,
    ]);

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        respond("error", "Thông tin mã sinh viên, email hoặc CCCD không đúng");
    }

    if (($row["trang_thai"] ?? "") !== "dang_hoat_dong") {
        respond("error", "Tài khoản đang bị khóa, không thể đặt lại mật khẩu");
    }

    // Theo yêu cầu: mật khẩu mới được đặt lại bằng đúng số CCCD.
    // Hệ thống hiện vẫn hỗ trợ mật khẩu thường trong dang_nhap.php.
    $up = $conn->prepare("UPDATE nguoi_dung SET mat_khau = ?, ngay_cap_nhat = NOW() WHERE id = ?");
    $up->execute([$cccd, (int)$row["nguoi_dung_id"]]);

    respond("success", "Đặt lại mật khẩu thành công. Mật khẩu mới là số CCCD của bạn.");
} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server khi đặt lại mật khẩu", ["detail" => $e->getMessage()]);
}
?>
