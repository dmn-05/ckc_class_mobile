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
$lopHocPhanId = 0;
$monHocId = 0;
$nguoiTaoId = 0;
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
    $monHocId = (int)($data["mon_hoc_id"] ?? 0);
    $nguoiTaoId = (int)($data["nguoi_tao_id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $lopHocPhanId = (int)($_POST["lop_hoc_phan_id"] ?? ($_GET["lop_hoc_phan_id"] ?? 0));
    $monHocId = (int)($_POST["mon_hoc_id"] ?? ($_GET["mon_hoc_id"] ?? 0));
    $nguoiTaoId = (int)($_POST["nguoi_tao_id"] ?? ($_GET["nguoi_tao_id"] ?? 0));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "hien_thi", "an"];
if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái tài liệu không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT
                tl.id,
                tl.tieu_de,
                tl.mo_ta,
                tl.duong_dan_file,
                tl.lop_hoc_phan_id,
                tl.nguoi_tao_id,
                tl.trang_thai,
                tl.ngay_tao,
                tl.ngay_cap_nhat,

                lhp.ma_lop_hoc_phan,
                lhp.ten_lop AS ten_lop_hoc_phan,
                lhp.hoc_ky,
                lhp.nam_hoc,
                lhp.trang_thai AS trang_thai_lop_hoc_phan,

                mh.id AS mon_hoc_id,
                mh.ma_mon,
                mh.ten_mon,

                bm.id AS bo_mon_id,
                bm.ma_bo_mon,
                bm.ten_bo_mon,

                k.id AS khoa_id,
                k.ma_khoa,
                k.ten_khoa,

                nd.ho_ten AS ten_nguoi_tao,
                nd.email AS email_nguoi_tao
            FROM tai_lieu tl
            LEFT JOIN lop_hoc_phan lhp ON tl.lop_hoc_phan_id = lhp.id
            LEFT JOIN mon_hoc mh ON lhp.mon_hoc_id = mh.id
            LEFT JOIN bo_mon bm ON mh.bo_mon_id = bm.id
            LEFT JOIN khoa k ON mh.khoa_id = k.id
            LEFT JOIN nguoi_dung nd ON tl.nguoi_tao_id = nd.id
            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            tl.tieu_de LIKE :tu_khoa
            OR tl.mo_ta LIKE :tu_khoa
            OR tl.duong_dan_file LIKE :tu_khoa
            OR lhp.ma_lop_hoc_phan LIKE :tu_khoa
            OR lhp.ten_lop LIKE :tu_khoa
            OR mh.ma_mon LIKE :tu_khoa
            OR mh.ten_mon LIKE :tu_khoa
            OR nd.ho_ten LIKE :tu_khoa
        )";
        $params[":tu_khoa"] = "%" . $tuKhoa . "%";
    }

    if ($lopHocPhanId > 0) {
        $sql .= " AND tl.lop_hoc_phan_id = :lop_hoc_phan_id";
        $params[":lop_hoc_phan_id"] = $lopHocPhanId;
    }

    if ($monHocId > 0) {
        $sql .= " AND mh.id = :mon_hoc_id";
        $params[":mon_hoc_id"] = $monHocId;
    }

    if ($nguoiTaoId > 0) {
        $sql .= " AND tl.nguoi_tao_id = :nguoi_tao_id";
        $params[":nguoi_tao_id"] = $nguoiTaoId;
    }

    if ($trangThai !== "") {
        $sql .= " AND tl.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " ORDER BY tl.ngay_tao DESC, tl.id DESC";

    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $type = is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR;
        $stmt->bindValue($key, $value, $type);
    }
    $stmt->execute();

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách tài liệu thành công",
        "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách tài liệu",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
