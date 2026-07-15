<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
$tuKhoa       = trim($data["tu_khoa"] ?? "");

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID lớp học phần không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "SELECT 
                sv.id AS sinh_vien_id,
                sv.ma_sinh_vien,
                nd.ho_ten,
                nd.email,
                sv.gioi_tinh,
                sv.so_dien_thoai,
                l.ma_lop,
                l.ten_lop,
                svlhp.id AS dang_ky_id,
                svlhp.trang_thai AS trang_thai_dang_ky,
                svlhp.ngay_dang_ky,
                (SELECT COUNT(*) FROM bai_nop bn 
                 JOIN bai_tap bt ON bn.bai_tap_id = bt.id 
                 WHERE bn.sinh_vien_id = sv.id AND bt.lop_hoc_phan_id = :lop_id2) AS so_bai_da_nop,
                (SELECT ROUND(AVG(bn2.diem), 2) FROM bai_nop bn2
                 JOIN bai_tap bt2 ON bn2.bai_tap_id = bt2.id
                 WHERE bn2.sinh_vien_id = sv.id AND bt2.lop_hoc_phan_id = :lop_id3 AND bn2.diem IS NOT NULL) AS diem_trung_binh
            FROM sinh_vien_lop_hoc_phan svlhp
            JOIN sinh_vien sv ON svlhp.sinh_vien_id = sv.id
            JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
            LEFT JOIN lop l ON sv.lop_id = l.id
            WHERE svlhp.lop_hoc_phan_id = :lop_id
              AND svlhp.trang_thai <> 'da_huy'";

    $params = [":lop_id" => $lopHocPhanId, ":lop_id2" => $lopHocPhanId, ":lop_id3" => $lopHocPhanId];

    if ($tuKhoa !== "") {
        $sql .= " AND (nd.ho_ten LIKE :tu_khoa OR sv.ma_sinh_vien LIKE :tu_khoa2 OR nd.email LIKE :tu_khoa3)";
        $params[":tu_khoa"]  = "%$tuKhoa%";
        $params[":tu_khoa2"] = "%$tuKhoa%";
        $params[":tu_khoa3"] = "%$tuKhoa%";
    }

    $sql .= " ORDER BY nd.ho_ten ASC";

    $stmt = $conn->prepare($sql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v, in_array($k, [":lop_id", ":lop_id2", ":lop_id3"]) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $result = array_map(fn($r) => [
        "sinh_vien_id"       => (int)$r["sinh_vien_id"],
        "ma_sinh_vien"       => $r["ma_sinh_vien"],
        "ho_ten"             => $r["ho_ten"],
        "email"              => $r["email"],
        "gioi_tinh"          => $r["gioi_tinh"],
        "so_dien_thoai"      => $r["so_dien_thoai"],
        "ma_lop"             => $r["ma_lop"],
        "ten_lop"            => $r["ten_lop"],
        "dang_ky_id"         => (int)$r["dang_ky_id"],
        "trang_thai_dang_ky" => $r["trang_thai_dang_ky"],
        "ngay_dang_ky"       => $r["ngay_dang_ky"],
        "so_bai_da_nop"      => (int)$r["so_bai_da_nop"],
        "diem_trung_binh"    => $r["diem_trung_binh"] !== null ? (float)$r["diem_trung_binh"] : null,
    ], $rows);

    echo json_encode(["status" => "success", "message" => "Lấy danh sách sinh viên thành công", "data" => $result], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Lỗi server", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>