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

try {
    $cards = [];

    $queries = [
        "khoa" => "SELECT COUNT(*) FROM khoa",
        "bo_mon" => "SELECT COUNT(*) FROM bo_mon",
        "mon_hoc" => "SELECT COUNT(*) FROM mon_hoc",
        "lop" => "SELECT COUNT(*) FROM lop",
        "lop_hoc_phan" => "SELECT COUNT(*) FROM lop_hoc_phan",
        "nguoi_dung" => "SELECT COUNT(*) FROM nguoi_dung",
        "giang_vien" => "SELECT COUNT(*) FROM giang_vien",
        "sinh_vien" => "SELECT COUNT(*) FROM sinh_vien",
        "tai_lieu" => "SELECT COUNT(*) FROM tai_lieu",
        "bai_tap" => "SELECT COUNT(*) FROM bai_tap",
        "bai_nop" => "SELECT COUNT(*) FROM bai_nop",
        "binh_luan" => "SELECT COUNT(*) FROM binh_luan"
    ];

    foreach ($queries as $key => $sql) {
        $cards[$key] = (int)$conn->query($sql)->fetchColumn();
    }

    $stmt = $conn->query("SELECT trang_thai, COUNT(*) AS so_luong FROM nguoi_dung GROUP BY trang_thai");
    $nguoiDungTheoTrangThai = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt = $conn->query("SELECT trang_thai, COUNT(*) AS so_luong FROM tai_lieu GROUP BY trang_thai");
    $taiLieuTheoTrangThai = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt = $conn->query("SELECT trang_thai, COUNT(*) AS so_luong FROM bai_nop GROUP BY trang_thai");
    $baiNopTheoTrangThai = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt = $conn->query("SELECT 
            lhp.id,
            lhp.ma_lop_hoc_phan,
            lhp.ten_lop,
            lhp.hoc_ky,
            lhp.nam_hoc,
            lhp.trang_thai,
            mh.ma_mon,
            mh.ten_mon,
            gv.ma_giang_vien,
            ndgv.ho_ten AS ten_giang_vien,
            COUNT(DISTINCT CASE WHEN svlhp.trang_thai = 'dang_hoc' THEN svlhp.sinh_vien_id END) AS so_sinh_vien_dang_hoc,
            COUNT(DISTINCT tl.id) AS so_tai_lieu,
            COUNT(DISTINCT bt.id) AS so_bai_tap,
            COUNT(DISTINCT bn.id) AS so_bai_nop,
            COUNT(DISTINCT CASE WHEN bn.trang_thai = 'da_cham' THEN bn.id END) AS so_bai_da_cham,
            COUNT(DISTINCT CASE WHEN bn.trang_thai = 'nop_muon' THEN bn.id END) AS so_bai_nop_muon,
            ROUND(AVG(CASE WHEN bn.diem IS NOT NULL THEN bn.diem END), 2) AS diem_trung_binh
        FROM lop_hoc_phan lhp
        LEFT JOIN mon_hoc mh ON lhp.mon_hoc_id = mh.id
        LEFT JOIN giang_vien gv ON lhp.giang_vien_id = gv.id
        LEFT JOIN nguoi_dung ndgv ON gv.nguoi_dung_id = ndgv.id
        LEFT JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = lhp.id
        LEFT JOIN tai_lieu tl ON tl.lop_hoc_phan_id = lhp.id AND tl.trang_thai = 'hien_thi'
        LEFT JOIN bai_tap bt ON bt.lop_hoc_phan_id = lhp.id
        LEFT JOIN bai_nop bn ON bn.bai_tap_id = bt.id
        GROUP BY lhp.id
        ORDER BY lhp.ngay_tao DESC, lhp.id DESC");
    $baoCaoLopHocPhan = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt = $conn->query("SELECT
            mh.id AS mon_hoc_id,
            mh.ma_mon,
            mh.ten_mon,
            COUNT(DISTINCT lhp.id) AS so_lop_hoc_phan,
            COUNT(DISTINCT svlhp.sinh_vien_id) AS so_sinh_vien_tham_gia,
            COUNT(DISTINCT tl.id) AS so_tai_lieu,
            COUNT(DISTINCT bt.id) AS so_bai_tap,
            ROUND(AVG(CASE WHEN bn.diem IS NOT NULL THEN bn.diem END), 2) AS diem_trung_binh
        FROM mon_hoc mh
        LEFT JOIN lop_hoc_phan lhp ON lhp.mon_hoc_id = mh.id
        LEFT JOIN sinh_vien_lop_hoc_phan svlhp ON svlhp.lop_hoc_phan_id = lhp.id AND svlhp.trang_thai = 'dang_hoc'
        LEFT JOIN tai_lieu tl ON tl.lop_hoc_phan_id = lhp.id AND tl.trang_thai = 'hien_thi'
        LEFT JOIN bai_tap bt ON bt.lop_hoc_phan_id = lhp.id
        LEFT JOIN bai_nop bn ON bn.bai_tap_id = bt.id
        GROUP BY mh.id
        ORDER BY mh.ma_mon ASC");
    $baoCaoMonHoc = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "message" => "Lấy báo cáo thống kê thành công",
        "data" => [
            "tong_quan" => $cards,
            "nguoi_dung_theo_trang_thai" => $nguoiDungTheoTrangThai,
            "tai_lieu_theo_trang_thai" => $taiLieuTheoTrangThai,
            "bai_nop_theo_trang_thai" => $baiNopTheoTrangThai,
            "bao_cao_lop_hoc_phan" => $baoCaoLopHocPhan,
            "bao_cao_mon_hoc" => $baoCaoMonHoc
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Lỗi server khi lấy báo cáo thống kê",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
