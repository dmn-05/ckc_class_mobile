<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim($data["action"] ?? "lay");

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function clean_str($value) {
    $s = trim((string)($value ?? ""));
    return $s === "" ? null : $s;
}

function profile(PDO $conn, int $id) {
    $stmt = $conn->prepare(" 
        SELECT
            nd.id,
            nd.ho_ten,
            nd.email,
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
            gv.ngay_tao AS ngay_tao_giang_vien,
            gv.ngay_cap_nhat AS ngay_cap_nhat_giang_vien,
            bm.ma_bo_mon,
            bm.ten_bo_mon,
            k_gv.id AS khoa_giang_vien_id,
            k_gv.ma_khoa AS ma_khoa_giang_vien,
            k_gv.ten_khoa AS ten_khoa_giang_vien,
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
            sv.ngay_tao AS ngay_tao_sinh_vien,
            sv.ngay_cap_nhat AS ngay_cap_nhat_sinh_vien,
            l.ma_lop,
            l.ten_lop,
            k_sv.ma_khoa AS ma_khoa_sinh_vien,
            k_sv.ten_khoa AS ten_khoa_sinh_vien
        FROM nguoi_dung nd
        LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
        LEFT JOIN giang_vien gv ON gv.nguoi_dung_id = nd.id AND gv.deleted_at IS NULL
        LEFT JOIN bo_mon bm ON gv.bo_mon_id = bm.id AND bm.deleted_at IS NULL
        LEFT JOIN khoa k_gv ON bm.khoa_id = k_gv.id AND k_gv.deleted_at IS NULL
        LEFT JOIN sinh_vien sv ON sv.nguoi_dung_id = nd.id AND sv.deleted_at IS NULL
        LEFT JOIN lop l ON sv.lop_id = l.id AND l.deleted_at IS NULL
        LEFT JOIN khoa k_sv ON sv.khoa_id = k_sv.id AND k_sv.deleted_at IS NULL
        WHERE nd.id = ?
        LIMIT 1
    ");
    $stmt->execute([$id]);
    $r = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$r) return null;

    return [
        "id" => (int)$r["id"],
        "ho_ten" => $r["ho_ten"],
        "email" => $r["email"],
        "vai_tro_id" => (int)$r["vai_tro_id"],
        "ten_vai_tro" => $r["ten_vai_tro"],
        "trang_thai" => $r["trang_thai"],
        "avatar" => $r["avatar"],
        "ngay_tao" => $r["ngay_tao"],
        "ngay_cap_nhat" => $r["ngay_cap_nhat"],
        "giang_vien_id" => $r["giang_vien_id"] !== null ? (int)$r["giang_vien_id"] : null,
        "ma_giang_vien" => $r["ma_giang_vien"],
        "trang_thai_giang_vien" => $r["trang_thai_giang_vien"],
        "ngay_tao_giang_vien" => $r["ngay_tao_giang_vien"],
        "ngay_cap_nhat_giang_vien" => $r["ngay_cap_nhat_giang_vien"],
        "sinh_vien_id" => $r["sinh_vien_id"] !== null ? (int)$r["sinh_vien_id"] : null,
        "ma_sinh_vien" => $r["ma_sinh_vien"],
        "trang_thai_sinh_vien" => $r["trang_thai_sinh_vien"],
        "ngay_tao_sinh_vien" => $r["ngay_tao_sinh_vien"],
        "ngay_cap_nhat_sinh_vien" => $r["ngay_cap_nhat_sinh_vien"],
        "ngay_sinh" => $r["gv_ngay_sinh"] ?? $r["sv_ngay_sinh"],
        "gioi_tinh" => $r["gv_gioi_tinh"] ?? $r["sv_gioi_tinh"],
        "so_dien_thoai" => $r["gv_so_dien_thoai"] ?? $r["sv_so_dien_thoai"],
        "cccd" => $r["gv_cccd"] ?? $r["sv_cccd"],
        "dia_chi" => $r["gv_dia_chi"] ?? $r["sv_dia_chi"],
        "bo_mon_id" => $r["bo_mon_id"] !== null ? (int)$r["bo_mon_id"] : null,
        "ma_bo_mon" => $r["ma_bo_mon"],
        "ten_bo_mon" => $r["ten_bo_mon"],
        "khoa_giang_vien_id" => $r["khoa_giang_vien_id"] !== null ? (int)$r["khoa_giang_vien_id"] : null,
        "ma_khoa_giang_vien" => $r["ma_khoa_giang_vien"],
        "ten_khoa_giang_vien" => $r["ten_khoa_giang_vien"],
        "lop_id" => $r["lop_id"] !== null ? (int)$r["lop_id"] : null,
        "ma_lop" => $r["ma_lop"],
        "ten_lop" => $r["ten_lop"],
        "khoa_sinh_vien_id" => $r["khoa_sinh_vien_id"] !== null ? (int)$r["khoa_sinh_vien_id"] : null,
        "ma_khoa_sinh_vien" => $r["ma_khoa_sinh_vien"],
        "ten_khoa_sinh_vien" => $r["ten_khoa_sinh_vien"],
    ];
}

try {
    $id = (int)($data["id"] ?? $data["nguoi_dung_id"] ?? 0);
    if ($id <= 0) respond("error", "ID người dùng không hợp lệ");

    if ($action === "lay") {
        $info = profile($conn, $id);
        if (!$info) respond("error", "Không tìm thấy người dùng");
        respond("success", "Lấy hồ sơ thành công", ["data" => $info]);
    }

    if ($action === "cap_nhat_avatar") {
        $avatar = clean_str($data["avatar"] ?? "");
        if (!$avatar) respond("error", "Thiếu đường dẫn ảnh đại diện");
        if (!filter_var($avatar, FILTER_VALIDATE_URL)) respond("error", "Đường dẫn ảnh đại diện không hợp lệ");

        $stmt = $conn->prepare("UPDATE nguoi_dung SET avatar = ?, ngay_cap_nhat = NOW() WHERE id = ?");
        $stmt->execute([$avatar, $id]);

        $info = profile($conn, $id);
        if (!$info) respond("error", "Không tìm thấy người dùng sau khi cập nhật avatar");
        respond("success", "Cập nhật ảnh đại diện thành công", ["data" => $info]);
    }


    if ($action === "doi_mat_khau") {
        $matKhauHienTai = trim((string)($data["mat_khau_hien_tai"] ?? ""));
        $matKhauMoi = trim((string)($data["mat_khau_moi"] ?? ""));
        $nhapLai = trim((string)($data["nhap_lai_mat_khau_moi"] ?? $data["xac_nhan_mat_khau_moi"] ?? ""));

        if ($matKhauHienTai === "") respond("error", "Vui lòng nhập mật khẩu hiện tại");
        if ($matKhauMoi === "") respond("error", "Vui lòng nhập mật khẩu mới");
        if (strlen($matKhauMoi) < 6) respond("error", "Mật khẩu mới phải có ít nhất 6 ký tự");
        if ($matKhauMoi !== $nhapLai) respond("error", "Nhập lại mật khẩu mới không khớp");
        if ($matKhauMoi === $matKhauHienTai) respond("error", "Mật khẩu mới không được trùng mật khẩu hiện tại");

        $stmt = $conn->prepare("SELECT mat_khau, trang_thai FROM nguoi_dung WHERE id = ? LIMIT 1");
        $stmt->execute([$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) respond("error", "Không tìm thấy người dùng");
        if (($row["trang_thai"] ?? "") !== "dang_hoat_dong") respond("error", "Tài khoản đang bị khóa");

        $matKhauDb = trim((string)($row["mat_khau"] ?? ""));
        $dung = hash_equals($matKhauDb, $matKhauHienTai);
        if (!$dung && password_get_info($matKhauDb)["algoName"] !== "unknown") {
            $dung = password_verify($matKhauHienTai, $matKhauDb);
        }
        if (!$dung) respond("error", "Mật khẩu hiện tại không đúng");

        // Giữ tương thích với dang_nhap.php hiện tại: lưu mật khẩu thường.
        // Nếu sau này chuẩn hóa bảo mật, có thể đổi thành password_hash($matKhauMoi, PASSWORD_DEFAULT).
        $up = $conn->prepare("UPDATE nguoi_dung SET mat_khau = ?, ngay_cap_nhat = NOW() WHERE id = ?");
        $up->execute([$matKhauMoi, $id]);

        respond("success", "Đổi mật khẩu thành công. Vui lòng đăng nhập lại.");
    }

    if ($action === "cap_nhat") {
        respond("error", "Thông tin cá nhân chỉ được xem, không cho phép tự chỉnh sửa trên Mobile. Bạn chỉ có thể cập nhật ảnh đại diện.");
    }

    respond("error", "Hành động không hợp lệ");
} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server khi xử lý hồ sơ", ["detail" => $e->getMessage()]);
}
?>
