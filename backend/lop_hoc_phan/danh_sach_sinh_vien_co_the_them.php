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

if (is_array($data)) {
    $lopHocPhanId = (int) ($data["lop_hoc_phan_id"] ?? 0);
    $tuKhoa = trim($data["tu_khoa"] ?? "");
} else {
    $lopHocPhanId = (int) ($_POST["lop_hoc_phan_id"] ?? ($_GET["lop_hoc_phan_id"] ?? 0));
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
}

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $checkLopSql = "SELECT id
                    FROM lop_hoc_phan
                    WHERE id = :lop_hoc_phan_id
                    LIMIT 1";

    $checkLopStmt = $conn->prepare($checkLopSql);
    $checkLopStmt->bindValue(":lop_hoc_phan_id", $lopHocPhanId, PDO::PARAM_INT);
    $checkLopStmt->execute();

    if (!$checkLopStmt->fetch()) {
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy lớp học phần"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $sql = "SELECT
                sv.id AS sinh_vien_id,
                sv.ma_sinh_vien,
                sv.trang_thai AS trang_thai_sinh_vien,
                nd.ho_ten,
                nd.email,
                nd.trang_thai AS trang_thai_tai_khoan,
                l.ma_lop,
                l.ten_lop AS ten_lop_hanh_chinh,
                k.ma_khoa,
                k.ten_khoa,
                svlhp.id AS dang_ky_id,
                svlhp.trang_thai AS trang_thai_dang_ky
            FROM sinh_vien sv
            INNER JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
            LEFT JOIN lop l ON sv.lop_id = l.id
            LEFT JOIN khoa k ON sv.khoa_id = k.id
            LEFT JOIN sinh_vien_lop_hoc_phan svlhp
                ON svlhp.sinh_vien_id = sv.id
                AND svlhp.lop_hoc_phan_id = :lop_hoc_phan_id
            WHERE nd.trang_thai = 'dang_hoat_dong'
              AND sv.trang_thai = 'dang_hoc'
              AND (svlhp.id IS NULL OR svlhp.trang_thai = 'da_huy')";

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
        )";

        $keyword = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_sv"] = $keyword;
        $params[":tu_khoa_ho_ten"] = $keyword;
        $params[":tu_khoa_email"] = $keyword;
        $params[":tu_khoa_ma_lop"] = $keyword;
        $params[":tu_khoa_ten_lop"] = $keyword;
        $params[":tu_khoa_ma_khoa"] = $keyword;
        $params[":tu_khoa_ten_khoa"] = $keyword;
    }

    $sql .= " ORDER BY sv.ma_sinh_vien ASC, nd.ho_ten ASC";

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
            "sinh_vien_id" => (int) $row["sinh_vien_id"],
            "ma_sinh_vien" => $row["ma_sinh_vien"],
            "ho_ten" => $row["ho_ten"],
            "email" => $row["email"],
            "trang_thai_sinh_vien" => $row["trang_thai_sinh_vien"],
            "trang_thai_tai_khoan" => $row["trang_thai_tai_khoan"],
            "ma_lop" => $row["ma_lop"],
            "ten_lop_hanh_chinh" => $row["ten_lop_hanh_chinh"],
            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"],
            "dang_ky_id" => $row["dang_ky_id"] !== null ? (int) $row["dang_ky_id"] : null,
            "trang_thai_dang_ky" => $row["trang_thai_dang_ky"]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách sinh viên có thể thêm thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách sinh viên có thể thêm",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
