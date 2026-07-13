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
$trangThai = "";

if (is_array($data)) {
    $tuKhoa = trim($data["tu_khoa"] ?? "");
    $trangThai = trim($data["trang_thai"] ?? "");
} else {
    $tuKhoa = trim($_POST["tu_khoa"] ?? ($_GET["tu_khoa"] ?? ""));
    $trangThai = trim($_POST["trang_thai"] ?? ($_GET["trang_thai"] ?? ""));
}

$trangThaiHopLe = ["", "dang_hoat_dong", "ngung_hoat_dong"];

if (!in_array($trangThai, $trangThaiHopLe, true)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Trạng thái khoa không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                id,
                ma_khoa,
                ten_khoa,
                trang_thai,
                ngay_tao,
                ngay_cap_nhat
            FROM khoa
            WHERE 1 = 1";

    $params = [];

    if ($tuKhoa !== "") {
        $sql .= " AND (
            ma_khoa LIKE :tu_khoa_ma 
            OR ten_khoa LIKE :tu_khoa_ten
        )";

        $params[":tu_khoa_ma"] = "%" . $tuKhoa . "%";
        $params[":tu_khoa_ten"] = "%" . $tuKhoa . "%";
    }

    if ($trangThai !== "") {
        $sql .= " AND trang_thai = :trang_thai";
        $params[":trang_thai"] = $trangThai;
    }

    $sql .= " ORDER BY id DESC";

    $stmt = $conn->prepare($sql);

    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value, PDO::PARAM_STR);
    }

    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $data = array_map(function ($row) {
        return [
            "id" => (int) $row["id"],
            "ma_khoa" => $row["ma_khoa"],
            "ten_khoa" => $row["ten_khoa"],
            "trang_thai" => $row["trang_thai"],
            "ngay_tao" => $row["ngay_tao"],
            "ngay_cap_nhat" => $row["ngay_cap_nhat"]
        ];
    }, $rows);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách khoa thành công",
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy danh sách khoa",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>