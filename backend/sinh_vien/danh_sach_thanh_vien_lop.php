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
$lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "ID lớp học phần không hợp lệ"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    // Lấy giảng viên của lớp học phần
    $stmtGV = $conn->prepare("
        SELECT
            gv.id AS giang_vien_id,
            gv.ma_giang_vien,
            nd.ho_ten,
            nd.email
        FROM lop_hoc_phan lhp
        LEFT JOIN giang_vien gv ON lhp.giang_vien_id = gv.id
        LEFT JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
        WHERE lhp.id = ?
        LIMIT 1
    ");
    $stmtGV->execute([$lopHocPhanId]);
    $giangVien = $stmtGV->fetch(PDO::FETCH_ASSOC);

    // Lấy sinh viên tham gia lớp học phần
    $stmtSV = $conn->prepare("
        SELECT
            sv.id AS sinh_vien_id,
            sv.ma_sinh_vien,
            nd.ho_ten,
            nd.email,
            svlhp.trang_thai,
            svlhp.ngay_dang_ky
        FROM sinh_vien_lop_hoc_phan svlhp
        JOIN sinh_vien sv ON svlhp.sinh_vien_id = sv.id
        JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
        WHERE svlhp.lop_hoc_phan_id = ?
          AND svlhp.trang_thai <> 'da_huy'
        ORDER BY nd.ho_ten ASC
    ");
    $stmtSV->execute([$lopHocPhanId]);
    $sinhViens = $stmtSV->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy danh sách thành viên thành công",
        "data" => [
            "giang_vien" => $giangVien ? [
                "id" => (int)$giangVien["giang_vien_id"],
                "ma_giang_vien" => $giangVien["ma_giang_vien"],
                "ho_ten" => $giangVien["ho_ten"],
                "email" => $giangVien["email"],
            ] : null,
            "sinh_vien" => array_map(function ($r) {
                return [
                    "id" => (int)$r["sinh_vien_id"],
                    "ma_sinh_vien" => $r["ma_sinh_vien"],
                    "ho_ten" => $r["ho_ten"],
                    "email" => $r["email"],
                    "trang_thai" => $r["trang_thai"],
                    "ngay_dang_ky" => $r["ngay_dang_ky"],
                ];
            }, $sinhViens)
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>