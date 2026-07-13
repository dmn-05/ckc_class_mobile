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
$khoaId = 0;
$khoaHoc = "";
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $khoaId = (int) ($data["khoa_id"] ?? 0);
    $khoaHoc = trim($data["khoa_hoc"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $khoaId = (int) ($_POST["khoa_id"] ?? ($_GET["khoa_id"] ?? 0));
    $khoaHoc = trim($_POST["khoa_hoc"] ?? ($_GET["khoa_hoc"] ?? ""));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "dang_hoc", "da_tot_nghiep", "tam_khoa"];

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái lớp không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if ($khoaHoc !== "" && !preg_match('/^[0-9]{4}-[0-9]{4}$/', $khoaHoc)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Khóa học không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                l.id,
                l.ma_lop,
                l.ten_lop,
                l.khoa_id,
                l.khoa_hoc,
                l.trang_thai,
                l.ngay_tao,
                l.ngay_cap_nhat,

                k.ma_khoa,
                k.ten_khoa,
                k.trang_thai AS trang_thai_khoa,
                k.ngay_tao AS ngay_tao_khoa,
                k.ngay_cap_nhat AS ngay_cap_nhat_khoa,

                COUNT(sv.id) AS so_luong_sinh_vien
            FROM lop l
            LEFT JOIN khoa k ON l.khoa_id = k.id
            LEFT JOIN sinh_vien sv ON sv.lop_id = l.id
            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            l.ma_lop LIKE :tu_khoa_ma_lop
            OR l.ten_lop LIKE :tu_khoa_ten_lop
            OR l.khoa_hoc LIKE :tu_khoa_khoa_hoc
            OR k.ma_khoa LIKE :tu_khoa_ma_khoa
            OR k.ten_khoa LIKE :tu_khoa_ten_khoa
        )";

        $params[":tu_khoa_ma_lop"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_lop"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_khoa_hoc"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_khoa"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_khoa"] = "%" . $tuKhoa . "%";
    }

    if ($khoaId > 0) {
        $sql .= " AND l.khoa_id = :khoa_id";
        $params[":khoa_id"] = $khoaId;
    }

    if ($khoaHoc !== "") {
        $sql .= " AND l.khoa_hoc = :khoa_hoc";
        $params[":khoa_hoc"] = $khoaHoc;
    }

    if ($trangThai !== "") {
        $sql .= " AND l.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " GROUP BY 
                l.id,
                l.ma_lop,
                l.ten_lop,
                l.khoa_id,
                l.khoa_hoc,
                l.trang_thai,
                l.ngay_tao,
                l.ngay_cap_nhat,
                k.ma_khoa,
                k.ten_khoa,
                k.trang_thai,
                k.ngay_tao,
                k.ngay_cap_nhat
              ORDER BY l.id DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        if ($key === ":khoa_id") {
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
            "ma_lop" => $row["ma_lop"],
            "ten_lop" => $row["ten_lop"],
            "khoa_id" => (int) $row["khoa_id"],
            "khoa_hoc" => $row["khoa_hoc"],
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"],
            "so_luong_sinh_vien" => (int) $row["so_luong_sinh_vien"],

            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"],

            "khoa" => [
                "id" => (int) $row["khoa_id"],
                "ma_khoa" => $row["ma_khoa"],
                "ten_khoa" => $row["ten_khoa"],
                "trang_thai" => $row["trang_thai_khoa"],
                "ngay_tao" => $row["ngay_tao_khoa"],
                "ngay_cap_nhat" => $row["ngay_cap_nhat_khoa"]
            ]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách lớp thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách lớp",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
