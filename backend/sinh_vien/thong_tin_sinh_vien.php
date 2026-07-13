<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data      = json_decode(file_get_contents("php://input"), true) ?? [];
$sinhVienId = (int)($data["sinh_vien_id"] ?? 0);

if ($sinhVienId <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID sinh viên không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    // Thông tin cơ bản
    $stmt = $conn->prepare("
        SELECT
            sv.id AS sinh_vien_id,
            sv.ma_sinh_vien,
            sv.ngay_sinh,
            sv.gioi_tinh,
            sv.so_dien_thoai,
            sv.cccd,
            sv.dia_chi,
            sv.trang_thai AS trang_thai_sinh_vien,
            sv.ngay_tao   AS ngay_tao_sinh_vien,
            sv.ngay_cap_nhat AS ngay_cap_nhat_sinh_vien,
            nd.id         AS nguoi_dung_id,
            nd.ho_ten,
            nd.email,
            nd.trang_thai,
            nd.ngay_tao,
            nd.ngay_cap_nhat,
            l.id          AS lop_id,
            l.ma_lop,
            l.ten_lop,
            l.nam_nhap_hoc,
            k.id          AS khoa_id,
            k.ma_khoa,
            k.ten_khoa
        FROM sinh_vien sv
        JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
        LEFT JOIN lop l    ON sv.lop_id = l.id
        LEFT JOIN khoa k   ON sv.khoa_id = k.id
        WHERE sv.id = :id
        LIMIT 1
    ");
    $stmt->execute([":id" => $sinhVienId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        http_response_code(404);
        echo json_encode(["status" => "error", "message" => "Không tìm thấy sinh viên"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // Thống kê nhanh
    $stmt2 = $conn->prepare("SELECT COUNT(*) FROM sinh_vien_lop_hoc_phan WHERE sinh_vien_id = ? AND trang_thai = 'dang_hoc'");
    $stmt2->execute([$sinhVienId]);
    $soLopDangHoc = (int)$stmt2->fetchColumn();

    $stmt3 = $conn->prepare("
        SELECT COUNT(*) FROM bai_nop bn
        JOIN bai_tap bt ON bn.bai_tap_id = bt.id
        JOIN sinh_vien_lop_hoc_phan svlhp ON bt.lop_hoc_phan_id = svlhp.lop_hoc_phan_id
        WHERE bn.sinh_vien_id = ?
          AND svlhp.sinh_vien_id = ?
          AND bt.trang_thai <> 'an'
          AND (bt.thoi_gian_gui IS NULL OR bt.thoi_gian_gui <= NOW())
    ");
    $stmt3->execute([$sinhVienId, $sinhVienId]);
    $soBaiDaNop = (int)$stmt3->fetchColumn();

    $stmt4 = $conn->prepare("
        SELECT ROUND(AVG(bn.diem),2) FROM bai_nop bn
        WHERE bn.sinh_vien_id = ? AND bn.diem IS NOT NULL
    ");
    $stmt4->execute([$sinhVienId]);
    $diemTB = $stmt4->fetchColumn();

    $stmt5 = $conn->prepare("
        SELECT COUNT(*) FROM bai_tap bt
        JOIN sinh_vien_lop_hoc_phan svlhp ON bt.lop_hoc_phan_id = svlhp.lop_hoc_phan_id
        WHERE svlhp.sinh_vien_id = ?
        AND bt.trang_thai = 'dang_mo'
        AND (bt.thoi_gian_gui IS NULL OR bt.thoi_gian_gui <= NOW())
        AND (bt.han_nop IS NULL OR bt.han_nop > NOW())
        AND bt.id NOT IN (SELECT bai_tap_id FROM bai_nop WHERE sinh_vien_id = ?)
    ");
    $stmt5->execute([$sinhVienId, $sinhVienId]);
    $soBaiChuaNop = (int)$stmt5->fetchColumn();

    echo json_encode([
        "status"  => "success",
        "message" => "Lấy thông tin sinh viên thành công",
        "data"    => [
            "sinh_vien_id"           => (int)$row["sinh_vien_id"],
            "nguoi_dung_id"          => (int)$row["nguoi_dung_id"],
            "ma_sinh_vien"           => $row["ma_sinh_vien"],
            "ho_ten"                 => $row["ho_ten"],
            "email"                  => $row["email"],
            "ngay_sinh"              => $row["ngay_sinh"],
            "gioi_tinh"              => $row["gioi_tinh"],
            "so_dien_thoai"          => $row["so_dien_thoai"],
            "cccd"                   => $row["cccd"],
            "dia_chi"                => $row["dia_chi"],
            "trang_thai"             => $row["trang_thai"],
            "trang_thai_sinh_vien"   => $row["trang_thai_sinh_vien"],
            "ngay_tao"               => $row["ngay_tao"],
            "ngay_cap_nhat"          => $row["ngay_cap_nhat"],
            "ngay_tao_sinh_vien"     => $row["ngay_tao_sinh_vien"],
            "ngay_cap_nhat_sinh_vien"=> $row["ngay_cap_nhat_sinh_vien"],
            "lop_id"                 => $row["lop_id"] !== null ? (int)$row["lop_id"] : null,
            "ma_lop"                 => $row["ma_lop"],
            "ten_lop"                => $row["ten_lop"],
            "nam_nhap_hoc"           => $row["nam_nhap_hoc"] !== null ? (int)$row["nam_nhap_hoc"] : null,
            "khoa_id"                => $row["khoa_id"] !== null ? (int)$row["khoa_id"] : null,
            "ma_khoa"                => $row["ma_khoa"],
            "ten_khoa"               => $row["ten_khoa"],
            "thong_ke"               => [
                "so_lop_dang_hoc"  => $soLopDangHoc,
                "so_bai_da_nop"    => $soBaiDaNop,
                "so_bai_chua_nop"  => $soBaiChuaNop,
                "diem_trung_binh"  => $diemTB !== false ? (float)$diemTB : null,
            ],
        ]
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Lỗi server", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>