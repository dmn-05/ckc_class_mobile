<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data        = json_decode(file_get_contents("php://input"), true) ?? [];
$giangVienId = (int)($data["giang_vien_id"] ?? 0);

if ($giangVienId <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID giảng viên không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

function db_has_table(PDO $conn, string $table): bool {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA=? AND TABLE_NAME=?");
    $stmt->execute([$db, $table]);
    return (int)$stmt->fetchColumn() > 0;
}

function gv_lhp_condition(bool $hasMap): string {
    if (!$hasMap) return "lhp.giang_vien_id = :gv";
    return "(lhp.giang_vien_id = :gv OR EXISTS (
        SELECT 1 FROM giang_vien_lop_hoc_phan gvlhp
        WHERE gvlhp.lop_hoc_phan_id = lhp.id AND gvlhp.giang_vien_id = :gv_map
    ))";
}

function scalar_query(PDO $conn, string $sql, int $giangVienId, bool $hasMap) {
    $stmt = $conn->prepare($sql);
    $stmt->bindValue(':gv', $giangVienId, PDO::PARAM_INT);
    if ($hasMap) $stmt->bindValue(':gv_map', $giangVienId, PDO::PARAM_INT);
    $stmt->execute();
    return $stmt->fetchColumn();
}

try {
    $hasMap = db_has_table($conn, 'giang_vien_lop_hoc_phan');
    $cond = gv_lhp_condition($hasMap);

    $tongLop = (int)scalar_query($conn, "SELECT COUNT(*) FROM lop_hoc_phan lhp WHERE $cond AND lhp.trang_thai='dang_mo'", $giangVienId, $hasMap);

    $lopDangMo = (int)scalar_query($conn, "SELECT COUNT(*) FROM lop_hoc_phan lhp WHERE $cond AND lhp.trang_thai='dang_mo'", $giangVienId, $hasMap);

    $tongSinhVien = (int)scalar_query($conn, "SELECT COUNT(DISTINCT svlhp.sinh_vien_id)
        FROM sinh_vien_lop_hoc_phan svlhp
        JOIN lop_hoc_phan lhp ON svlhp.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND svlhp.trang_thai='dang_hoc'", $giangVienId, $hasMap);

    $tongBaiTap = (int)scalar_query($conn, "SELECT COUNT(*)
        FROM bai_tap bt
        JOIN lop_hoc_phan lhp ON bt.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND COALESCE(bt.loai_bai_tap, 'nop_file') = 'nop_file' AND bt.trang_thai <> 'an'", $giangVienId, $hasMap);

    $chooCham = (int)scalar_query($conn, "SELECT COUNT(*)
        FROM bai_nop bn
        JOIN bai_tap bt ON bn.bai_tap_id=bt.id
        JOIN lop_hoc_phan lhp ON bt.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND bn.trang_thai IN ('da_nop','nop_muon')", $giangVienId, $hasMap);

    $tongTaiLieu = (int)scalar_query($conn, "SELECT COUNT(*)
        FROM tai_lieu tl
        JOIN lop_hoc_phan lhp ON tl.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND tl.trang_thai <> 'an'", $giangVienId, $hasMap);

    $tongBaiViet = (int)scalar_query($conn, "SELECT COUNT(*)
        FROM bai_viet bv
        JOIN lop_hoc_phan lhp ON bv.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND bv.trang_thai <> 'an'", $giangVienId, $hasMap);

    $binhLuanMoi = (int)scalar_query($conn, "SELECT COUNT(*)
        FROM binh_luan bl
        JOIN lop_hoc_phan lhp ON bl.lop_hoc_phan_id=lhp.id
        WHERE $cond AND lhp.trang_thai='dang_mo' AND bl.trang_thai='hien_thi' AND bl.ngay_tao >= DATE_SUB(NOW(), INTERVAL 7 DAY)", $giangVienId, $hasMap);

    $diemTrungBinh = scalar_query($conn, "SELECT ROUND(AVG(bn.diem), 2)
        FROM bai_nop bn
        JOIN bai_tap bt ON bn.bai_tap_id=bt.id
        JOIN lop_hoc_phan lhp ON bt.lop_hoc_phan_id=lhp.id
        WHERE $cond AND bn.diem IS NOT NULL", $giangVienId, $hasMap);

    echo json_encode([
        "status"  => "success",
        "message" => "Lấy thống kê thành công",
        "data"    => [
            "tong_lop_hoc_phan"  => $tongLop,
            "lop_dang_mo"        => $lopDangMo,
            "tong_sinh_vien"     => $tongSinhVien,
            "tong_bai_tap"       => $tongBaiTap,
            "cho_cham"           => $chooCham,
            "tong_tai_lieu"      => $tongTaiLieu,
            "tong_bai_viet"       => $tongBaiViet,
            "binh_luan_moi"      => $binhLuanMoi,
            "diem_trung_binh"    => $diemTrungBinh !== false && $diemTrungBinh !== null ? (float)$diemTrungBinh : null,
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Lỗi server", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>
