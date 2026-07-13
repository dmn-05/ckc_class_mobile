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

$lopHocPhanId = 0;
$tuKhoa = "";
$trangThai = "";

if (is_array($data)) {
    $lopHocPhanId = (int) ($data["lop_hoc_phan_id"] ?? 0);
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $lopHocPhanId = (int) ($_POST["lop_hoc_phan_id"] ?? ($_GET["lop_hoc_phan_id"] ?? 0));
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "dang_hoc", "da_huy", "hoan_thanh"];

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp học phần không hợp lệ"
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
    $checkLopSql = "SELECT id, ma_lop_hoc_phan, ten_lop
                    FROM lop_hoc_phan
                    WHERE id = :lop_hoc_phan_id
                    LIMIT 1";

    $checkLopStmt = $conn->prepare($checkLopSql);
    $checkLopStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $checkLopStmt->execute();

    $lopHocPhan = $checkLopStmt->fetch(PDO::FETCH_ASSOC);

    if (!$lopHocPhan) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy lớp học phần"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "SELECT
                svlhp.id,
                svlhp.sinh_vien_id,
                svlhp.lop_hoc_phan_id,
                svlhp.trang_thai,
                svlhp.ngay_dang_ky,

                sv.ma_sinh_vien,
                sv.ngay_sinh,
                sv.gioi_tinh,
                sv.so_dien_thoai,
                sv.cccd,
                sv.dia_chi,
                sv.lop_id,
                sv.khoa_id,
                sv.trang_thai AS trang_thai_sinh_vien,

                nd.ho_ten,
                nd.email,
                nd.trang_thai AS trang_thai_tai_khoan,

                l.ma_lop,
                l.ten_lop AS ten_lop_hanh_chinh,

                k.ma_khoa,
                k.ten_khoa
            FROM sinh_vien_lop_hoc_phan svlhp
            INNER JOIN sinh_vien sv ON svlhp.sinh_vien_id = sv.id
            INNER JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
            LEFT JOIN lop l ON sv.lop_id = l.id
            LEFT JOIN khoa k ON sv.khoa_id = k.id
            WHERE svlhp.lop_hoc_phan_id = :lop_hoc_phan_id";

    $params = [":lop_hoc_phan_id" => $lopHocPhanId];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            sv.ma_sinh_vien LIKE :tu_khoa_ma_sv
            OR nd.ho_ten LIKE :tu_khoa_ho_ten
            OR nd.email LIKE :tu_khoa_email
            OR l.ma_lop LIKE :tu_khoa_ma_lop
            OR l.ten_lop LIKE :tu_khoa_ten_lop
            OR k.ma_khoa LIKE :tu_khoa_ma_khoa
            OR k.ten_khoa LIKE :tu_khoa_ten_khoa
            OR svlhp.trang_thai LIKE :tu_khoa_trang_thai
        )";

        $keyword = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_sv"] = $keyword;
        $params[":tu_khoa_ho_ten"] = $keyword;
        $params[":tu_khoa_email"] = $keyword;
        $params[":tu_khoa_ma_lop"] = $keyword;
        $params[":tu_khoa_ten_lop"] = $keyword;
        $params[":tu_khoa_ma_khoa"] = $keyword;
        $params[":tu_khoa_ten_khoa"] = $keyword;
        $params[":tu_khoa_trang_thai"] = $keyword;
    }

    if ($trangThai !== "") {
        $sql .= " AND svlhp.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " ORDER BY
                CASE svlhp.trang_thai
                    WHEN 'dang_hoc' THEN 1
                    WHEN 'hoan_thanh' THEN 2
                    WHEN 'da_huy' THEN 3
                    ELSE 4
                END,
                sv.ma_sinh_vien ASC,
                nd.ho_ten ASC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        if ($key === ":lop_hoc_phan_id") {
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
            "sinh_vien_id" => (int) $row["sinh_vien_id"],
            "lop_hoc_phan_id" => (int) $row["lop_hoc_phan_id"],
            "trang_thai" => $row["trang_thai"],
            "ngay_dang_ky" => $row["ngay_dang_ky"],

            "ma_sinh_vien" => $row["ma_sinh_vien"],
            "ho_ten" => $row["ho_ten"],
            "email" => $row["email"],
            "ngay_sinh" => $row["ngay_sinh"],
            "gioi_tinh" => $row["gioi_tinh"],
            "so_dien_thoai" => $row["so_dien_thoai"],
            "cccd" => $row["cccd"],
            "dia_chi" => $row["dia_chi"],
            "trang_thai_sinh_vien" => $row["trang_thai_sinh_vien"],
            "trang_thai_tai_khoan" => $row["trang_thai_tai_khoan"],

            "lop_id" => $row["lop_id"] !== null ? (int) $row["lop_id"] : null,
            "ma_lop" => $row["ma_lop"],
            "ten_lop_hanh_chinh" => $row["ten_lop_hanh_chinh"],

            "khoa_id" => $row["khoa_id"] !== null ? (int) $row["khoa_id"] : null,
            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách sinh viên lớp học phần thành công",
        "lop_hoc_phan" => [
            "id" => (int) $lopHocPhan["id"],
            "ma_lop_hoc_phan" => $lopHocPhan["ma_lop_hoc_phan"],
            "ten_lop" => $lopHocPhan["ten_lop"]
        ],
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách sinh viên lớp học phần",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
