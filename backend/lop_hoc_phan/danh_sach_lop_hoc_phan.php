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

function traLoiLoi(int $code, string $message, ?string $detail = null): void
{
    http_response_code($code);

    $response = [
        "status" => "error",
        "message" => $message
    ];

    if ($detail !== null) {
        $response["detail"] = $detail;
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit();
}

function hopLeNamHoc(string $namHoc): bool
{
    if (!preg_match('/^[0-9]{4}-[0-9]{4}$/', $namHoc)) return false;
    $a = (int)substr($namHoc, 0, 4);
    $b = (int)substr($namHoc, 5, 4);
    return $a >= 2000 && $a <= (int)date("Y") + 2 && $b - $a === 1;
}

$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

$tuKhoa = "";
$monHocId = 0;
$giangVienId = 0;
$hocKy = "";
$namHoc = "";
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $monHocId = (int) ($data["mon_hoc_id"] ?? 0);
    $giangVienId = (int) ($data["giang_vien_id"] ?? 0);
    $hocKy = trim($data["hoc_ky"] ?? "");
    $namHoc = trim($data["nam_hoc"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $monHocId = (int) ($_POST["mon_hoc_id"] ?? ($_GET["mon_hoc_id"] ?? 0));
    $giangVienId = (int) ($_POST["giang_vien_id"] ?? ($_GET["giang_vien_id"] ?? 0));
    $hocKy = trim($_POST["hoc_ky"] ?? ($_GET["hoc_ky"] ?? ""));
    $namHoc = trim($_POST["nam_hoc"] ?? ($_GET["nam_hoc"] ?? ""));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$hocKyHopLe = ["", "HK1", "HK2", "HK3", "HK4", "HK5", "HK6"];
$trangThaiHopLe = ["", "dang_mo", "da_khoa", "da_ket_thuc"];

if (!in_array($hocKy, $hocKyHopLe, true)) {
    traLoiLoi(400, "Học kỳ không hợp lệ");
}

if ($namHoc !== "" && !hopLeNamHoc($namHoc)) {
    traLoiLoi(400, "Năm học không hợp lệ. Ví dụ đúng: 2025-2026");
}

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    traLoiLoi(400, "Trạng thái lớp học phần không hợp lệ");
}

try {
    $sql = "SELECT 
                lhp.id,
                lhp.ma_lop_hoc_phan,
                lhp.ten_lop,
                lhp.mon_hoc_id,
                lhp.giang_vien_id,
                lhp.hoc_ky,
                lhp.nam_hoc,
                lhp.si_so_toi_da,
                lhp.trang_thai,
                lhp.ngay_tao,
                lhp.ngay_cap_nhat,

                mh.ma_mon,
                mh.ten_mon,
                mh.tin_chi,
                mh.khoa_id AS mon_khoa_id,
                mh.bo_mon_id AS mon_bo_mon_id,
                mh.trang_thai AS trang_thai_mon_hoc,

                bm.ma_bo_mon,
                bm.ten_bo_mon,

                k.id AS khoa_id,
                k.ma_khoa,
                k.ten_khoa,

                gv.ma_giang_vien,
                gv.trang_thai AS trang_thai_giang_vien,

                nd.ho_ten AS ten_giang_vien,
                nd.email AS email_giang_vien,
                nd.trang_thai AS trang_thai_tai_khoan_gv,

                COUNT(svlhp.id) AS tong_so_sinh_vien,
                COALESCE(SUM(CASE WHEN svlhp.trang_thai = 'dang_hoc' THEN 1 ELSE 0 END), 0) AS so_sinh_vien_dang_hoc

            FROM lop_hoc_phan lhp
            LEFT JOIN mon_hoc mh ON lhp.mon_hoc_id = mh.id
            LEFT JOIN bo_mon bm ON mh.bo_mon_id = bm.id
            LEFT JOIN khoa k ON mh.khoa_id = k.id
            LEFT JOIN giang_vien gv ON lhp.giang_vien_id = gv.id
            LEFT JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
            LEFT JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = lhp.id
            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            lhp.ma_lop_hoc_phan LIKE :tu_khoa_ma_lhp
            OR lhp.ten_lop LIKE :tu_khoa_ten_lop
            OR lhp.nam_hoc LIKE :tu_khoa_nam_hoc
            OR mh.ma_mon LIKE :tu_khoa_ma_mon
            OR mh.ten_mon LIKE :tu_khoa_ten_mon
            OR nd.ho_ten LIKE :tu_khoa_gv
            OR gv.ma_giang_vien LIKE :tu_khoa_ma_gv
            OR bm.ten_bo_mon LIKE :tu_khoa_bo_mon
            OR k.ten_khoa LIKE :tu_khoa_khoa
        )";

        $params[":tu_khoa_ma_lhp"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_lop"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_nam_hoc"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_gv"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_gv"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_bo_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_khoa"] = "%" . $tuKhoa . "%";
    }

    if ($monHocId > 0) {
        $sql .= " AND lhp.mon_hoc_id = :mon_hoc_id";
        $params[":mon_hoc_id"] = $monHocId;
    }

    if ($giangVienId > 0) {
        $sql .= " AND lhp.giang_vien_id = :giang_vien_id";
        $params[":giang_vien_id"] = $giangVienId;
    }

    if ($namHoc !== "") {
        $sql .= " AND lhp.nam_hoc = :nam_hoc";
        $params[":nam_hoc"] = $namHoc;
    }

    if ($hocKy !== "") {
        $sql .= " AND lhp.hoc_ky = :hoc_ky";
        $params[":hoc_ky"] = $hocKy;
    }


    if ($trangThai !== "") {
        $sql .= " AND lhp.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " GROUP BY 
                lhp.id,
                lhp.ma_lop_hoc_phan,
                lhp.ten_lop,
                lhp.mon_hoc_id,
                lhp.giang_vien_id,
                lhp.hoc_ky,
                lhp.nam_hoc,
                lhp.si_so_toi_da,
                lhp.trang_thai,
                lhp.ngay_tao,
                lhp.ngay_cap_nhat,
                mh.ma_mon,
                mh.ten_mon,
                mh.tin_chi,
                mh.khoa_id,
                mh.bo_mon_id,
                mh.trang_thai,
                bm.ma_bo_mon,
                bm.ten_bo_mon,
                k.id,
                k.ma_khoa,
                k.ten_khoa,
                gv.ma_giang_vien,
                gv.trang_thai,
                nd.ho_ten,
                nd.email,
                nd.trang_thai
              ORDER BY lhp.id DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        if ($key === ":mon_hoc_id" || $key === ":giang_vien_id") {
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
            "ma_lop_hoc_phan" => $row["ma_lop_hoc_phan"],
            "ten_lop" => $row["ten_lop"],
            "mon_hoc_id" => $row["mon_hoc_id"] !== null ? (int) $row["mon_hoc_id"] : null,
            "giang_vien_id" => $row["giang_vien_id"] !== null ? (int) $row["giang_vien_id"] : null,
            "hoc_ky" => $row["hoc_ky"],
            "nam_hoc" => $row["nam_hoc"],
            "si_so_toi_da" => $row["si_so_toi_da"] !== null ? (int) $row["si_so_toi_da"] : null,
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"],

            "tong_so_sinh_vien" => (int) $row["tong_so_sinh_vien"],
            "so_sinh_vien_dang_hoc" => (int) $row["so_sinh_vien_dang_hoc"],

            "ma_mon" => $row["ma_mon"],
            "ten_mon" => $row["ten_mon"],
            "tin_chi" => $row["tin_chi"] !== null ? (int) $row["tin_chi"] : null,
            "trang_thai_mon_hoc" => $row["trang_thai_mon_hoc"],

            "ma_bo_mon" => $row["ma_bo_mon"],
            "ten_bo_mon" => $row["ten_bo_mon"],

            "khoa_id" => $row["khoa_id"] !== null ? (int) $row["khoa_id"] : null,
            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"],

            "ma_giang_vien" => $row["ma_giang_vien"],
            "ten_giang_vien" => $row["ten_giang_vien"],
            "email_giang_vien" => $row["email_giang_vien"],
            "trang_thai_giang_vien" => $row["trang_thai_giang_vien"],
            "trang_thai_tai_khoan_gv" => $row["trang_thai_tai_khoan_gv"]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách lớp học phần thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    traLoiLoi(500, "Lỗi server khi lấy danh sách lớp học phần", $e->getMessage());
}
?>
    