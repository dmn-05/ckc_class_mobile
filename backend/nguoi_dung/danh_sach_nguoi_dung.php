<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

$tuKhoa = "";
$vaiTroId = 0;
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $vaiTroId = (int) ($data["vai_tro_id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $vaiTroId = (int) ($_POST["vai_tro_id"] ?? ($_GET["vai_tro_id"] ?? 0));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "dang_hoat_dong", "bi_khoa"];

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái người dùng không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                nd.id,
                nd.ho_ten,
                nd.email,
                nd.vai_tro_id,
                nd.trang_thai,
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
                gv.bo_mon_id AS gv_bo_mon_id,
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
                sv.khoa_id AS sv_khoa_id,
                sv.trang_thai AS trang_thai_sinh_vien,
                sv.ngay_tao AS ngay_tao_sinh_vien,
                sv.ngay_cap_nhat AS ngay_cap_nhat_sinh_vien,

                l.ma_lop,
                l.ten_lop,

                k_sv.ma_khoa AS ma_khoa_sinh_vien,
                k_sv.ten_khoa AS ten_khoa_sinh_vien

            FROM nguoi_dung nd
            LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id

            LEFT JOIN giang_vien gv ON gv.nguoi_dung_id = nd.id
            LEFT JOIN bo_mon bm ON gv.bo_mon_id = bm.id
            LEFT JOIN khoa k_gv ON bm.khoa_id = k_gv.id

            LEFT JOIN sinh_vien sv ON sv.nguoi_dung_id = nd.id
            LEFT JOIN lop l ON sv.lop_id = l.id
            LEFT JOIN khoa k_sv ON sv.khoa_id = k_sv.id

            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            nd.ho_ten LIKE :tu_khoa_ho_ten
            OR nd.email LIKE :tu_khoa_email
            OR vt.ten_vai_tro LIKE :tu_khoa_vai_tro
            OR gv.ma_giang_vien LIKE :tu_khoa_ma_gv
            OR sv.ma_sinh_vien LIKE :tu_khoa_ma_sv
            OR bm.ten_bo_mon LIKE :tu_khoa_bo_mon
            OR l.ten_lop LIKE :tu_khoa_lop
        )";

        $params[":tu_khoa_ho_ten"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_email"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_vai_tro"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_gv"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_sv"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_bo_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_lop"] = "%" . $tuKhoa . "%";
    }

    if ($vaiTroId > 0) {
        $sql .= " AND nd.vai_tro_id = :vai_tro_id";
        $params[":vai_tro_id"] = $vaiTroId;
    }

    if ($trangThai !== "") {
        $sql .= " AND nd.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " ORDER BY nd.id DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        if ($key === ":vai_tro_id") {
            $stmt->bindValue($key, $value, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $value, PDO::PARAM_STR);
        }
    }

    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $data = array_map(function ($row) {
        return [
            "id" => (int) $row["id"],
            "ho_ten" => $row["ho_ten"],
            "email" => $row["email"],
            "vai_tro_id" => (int) $row["vai_tro_id"],
            "ten_vai_tro" => $row["ten_vai_tro"],
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"],

            "giang_vien_id" => $row["giang_vien_id"] !== null ? (int) $row["giang_vien_id"] : null,
            "ma_giang_vien" => $row["ma_giang_vien"],
            "trang_thai_giang_vien" => $row["trang_thai_giang_vien"],
            "ngay_tao_giang_vien" => $row["ngay_tao_giang_vien"],
            "ngay_cap_nhat_giang_vien" => $row["ngay_cap_nhat_giang_vien"],

            "sinh_vien_id" => $row["sinh_vien_id"] !== null ? (int) $row["sinh_vien_id"] : null,
            "ma_sinh_vien" => $row["ma_sinh_vien"],
            "trang_thai_sinh_vien" => $row["trang_thai_sinh_vien"],
            "ngay_tao_sinh_vien" => $row["ngay_tao_sinh_vien"],
            "ngay_cap_nhat_sinh_vien" => $row["ngay_cap_nhat_sinh_vien"],

            "ngay_sinh" => $row["gv_ngay_sinh"] ?? $row["sv_ngay_sinh"],
            "gioi_tinh" => $row["gv_gioi_tinh"] ?? $row["sv_gioi_tinh"],
            "so_dien_thoai" => $row["gv_so_dien_thoai"] ?? $row["sv_so_dien_thoai"],
            "cccd" => $row["gv_cccd"] ?? $row["sv_cccd"],
            "dia_chi" => $row["gv_dia_chi"] ?? $row["sv_dia_chi"],

            "bo_mon_id" => $row["gv_bo_mon_id"] !== null ? (int) $row["gv_bo_mon_id"] : null,
            "ma_bo_mon" => $row["ma_bo_mon"],
            "ten_bo_mon" => $row["ten_bo_mon"],
            "khoa_giang_vien_id" => $row["khoa_giang_vien_id"] !== null ? (int) $row["khoa_giang_vien_id"] : null,
            "ma_khoa_giang_vien" => $row["ma_khoa_giang_vien"],
            "ten_khoa_giang_vien" => $row["ten_khoa_giang_vien"],

            "lop_id" => $row["lop_id"] !== null ? (int) $row["lop_id"] : null,
            "ma_lop" => $row["ma_lop"],
            "ten_lop" => $row["ten_lop"],
            "khoa_sinh_vien_id" => $row["sv_khoa_id"] !== null ? (int) $row["sv_khoa_id"] : null,
            "ma_khoa_sinh_vien" => $row["ma_khoa_sinh_vien"],
            "ten_khoa_sinh_vien" => $row["ten_khoa_sinh_vien"],

            "vai_tro" => [
                "id" => (int) $row["vai_tro_id"],
                "ten_vai_tro" => $row["ten_vai_tro"]
            ]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách người dùng thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách người dùng",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>