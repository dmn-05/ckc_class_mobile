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
$boMonId = 0;
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $khoaId = (int) ($data["khoa_id"] ?? 0);
    $boMonId = (int) ($data["bo_mon_id"] ?? 0);
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $khoaId = (int) ($_POST["khoa_id"] ?? ($_GET["khoa_id"] ?? 0));
    $boMonId = (int) ($_POST["bo_mon_id"] ?? ($_GET["bo_mon_id"] ?? 0));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "dang_mo", "ngung_su_dung"];

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái môn học không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                mh.id,
                mh.ma_mon,
                mh.ten_mon,
                mh.tin_chi,
                mh.khoa_id,
                mh.bo_mon_id,
                mh.trang_thai,
                mh.ngay_tao,
                mh.ngay_cap_nhat,

                k.ma_khoa,
                k.ten_khoa,
                k.trang_thai AS trang_thai_khoa,
                k.ngay_tao AS ngay_tao_khoa,
                k.ngay_cap_nhat AS ngay_cap_nhat_khoa,

                bm.ma_bo_mon,
                bm.ten_bo_mon,
                bm.trang_thai AS trang_thai_bo_mon,
                bm.ngay_tao AS ngay_tao_bo_mon,
                bm.ngay_cap_nhat AS ngay_cap_nhat_bo_mon
            FROM mon_hoc mh
            LEFT JOIN khoa k ON mh.khoa_id = k.id
            LEFT JOIN bo_mon bm ON mh.bo_mon_id = bm.id
            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            mh.ma_mon LIKE :tu_khoa_ma_mon
            OR mh.ten_mon LIKE :tu_khoa_ten_mon
            OR k.ma_khoa LIKE :tu_khoa_ma_khoa
            OR k.ten_khoa LIKE :tu_khoa_ten_khoa
            OR bm.ma_bo_mon LIKE :tu_khoa_ma_bo_mon
            OR bm.ten_bo_mon LIKE :tu_khoa_ten_bo_mon
        )";

        $params[":tu_khoa_ma_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_khoa"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_khoa"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ma_bo_mon"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten_bo_mon"] = "%" . $tuKhoa . "%";
    }

    if ($khoaId > 0) {
        $sql .= " AND mh.khoa_id = :khoa_id";
        $params[":khoa_id"] = $khoaId;
    }

    if ($boMonId > 0) {
        $sql .= " AND mh.bo_mon_id = :bo_mon_id";
        $params[":bo_mon_id"] = $boMonId;
    }

    if ($trangThai !== "") {
        $sql .= " AND mh.trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " ORDER BY mh.id DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        if ($key === ":khoa_id" || $key === ":bo_mon_id") {
            $stmt->bindValue($key, $value, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $value, PDO::PARAM_STR);
        }
    }

    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $data = array_map(function ($row) {
        $khoa = null;
        $boMon = null;

        if (!empty($row["khoa_id"])) {
            $khoa = [
                "id" => (int) $row["khoa_id"],
                "ma_khoa" => $row["ma_khoa"],
                "ten_khoa" => $row["ten_khoa"],
                "trang_thai" => $row["trang_thai_khoa"],
                "ngay_tao" => $row["ngay_tao_khoa"],
                "ngay_cap_nhat" => $row["ngay_cap_nhat_khoa"]
            ];
        }

        if (!empty($row["bo_mon_id"])) {
            $boMon = [
                "id" => (int) $row["bo_mon_id"],
                "ma_bo_mon" => $row["ma_bo_mon"],
                "ten_bo_mon" => $row["ten_bo_mon"],
                "khoa_id" => (int) $row["khoa_id"],
                "trang_thai" => $row["trang_thai_bo_mon"],
                "ngay_tao" => $row["ngay_tao_bo_mon"],
                "ngay_cap_nhat" => $row["ngay_cap_nhat_bo_mon"],
                "khoa" => $khoa
            ];
        }

        return [
            "id" => (int) $row["id"],
            "ma_mon" => $row["ma_mon"],
            "ten_mon" => $row["ten_mon"],
            "tin_chi" => (int) $row["tin_chi"],
            "khoa_id" => (int) $row["khoa_id"],
            "bo_mon_id" => (int) $row["bo_mon_id"],
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"],

            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"],
            "ma_bo_mon" => $row["ma_bo_mon"],
            "ten_bo_mon" => $row["ten_bo_mon"],

            "khoa" => $khoa,
            "bo_mon" => $boMon
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách môn học thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách môn học",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>