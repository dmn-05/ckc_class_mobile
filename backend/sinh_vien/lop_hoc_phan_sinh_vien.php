<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data       = json_decode(file_get_contents("php://input"), true) ?? [];
$sinhVienId = (int)($data["sinh_vien_id"] ?? 0);
$tuKhoa     = trim($data["tu_khoa"] ?? "");
$trangThai  = trim($data["trang_thai"] ?? "");
$hocKy      = trim($data["hoc_ky"] ?? "");
$khoaHoc    = trim($data["khoa_hoc"] ?? "");

if ($sinhVienId <= 0) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "ID sinh viên không hợp lệ"], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $sql = "
        SELECT
            lhp.id,
            lhp.ma_lop_hoc_phan,
            lhp.ten_lop,
            lhp.hoc_ky,
            lhp.nam_hoc,
            lhp.khoa_hoc,
            lhp.trang_thai,
            lhp.ngay_tao,
            svlhp.trang_thai AS trang_thai_dang_ky,
            svlhp.ngay_dang_ky,
            mh.id   AS mon_hoc_id,
            mh.ma_mon,
            mh.ten_mon,
            mh.tin_chi,
            nd.ho_ten AS ten_giang_vien,
            gv.ma_giang_vien,
            (SELECT COUNT(*) FROM tai_lieu tl
             WHERE tl.lop_hoc_phan_id = lhp.id AND tl.trang_thai = 'hien_thi') AS so_tai_lieu,
            (SELECT COUNT(*) FROM bai_tap bt
             WHERE bt.lop_hoc_phan_id = lhp.id
               AND bt.trang_thai = 'dang_mo'
               AND (bt.thoi_gian_gui IS NULL OR bt.thoi_gian_gui <= NOW())) AS so_bai_tap,
            (SELECT COUNT(*) FROM thong_bao tb
             WHERE tb.lop_hoc_phan_id = lhp.id
               AND tb.trang_thai = 'hien_thi'
               AND (tb.thoi_gian_gui IS NULL OR tb.thoi_gian_gui <= NOW())) AS so_thong_bao,
            (SELECT COUNT(*) FROM bai_nop bn
             JOIN bai_tap bt2 ON bn.bai_tap_id = bt2.id
             WHERE bt2.lop_hoc_phan_id = lhp.id
               AND bn.sinh_vien_id = :sv_id2
               AND bt2.trang_thai <> 'an'
               AND (bt2.thoi_gian_gui IS NULL OR bt2.thoi_gian_gui <= NOW())) AS so_bai_da_nop
        FROM sinh_vien_lop_hoc_phan svlhp
        JOIN lop_hoc_phan lhp ON svlhp.lop_hoc_phan_id = lhp.id
        LEFT JOIN mon_hoc mh   ON lhp.mon_hoc_id = mh.id
        LEFT JOIN giang_vien gv ON lhp.giang_vien_id = gv.id
        LEFT JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
        WHERE svlhp.sinh_vien_id = :sv_id
    ";
    $params = [":sv_id" => $sinhVienId, ":sv_id2" => $sinhVienId];

    if ($tuKhoa !== "") {
        $sql .= " AND (lhp.ten_lop LIKE :tk OR lhp.ma_lop_hoc_phan LIKE :tk2 OR mh.ten_mon LIKE :tk3)";
        $params[":tk"]  = "%$tuKhoa%";
        $params[":tk2"] = "%$tuKhoa%";
        $params[":tk3"] = "%$tuKhoa%";
    }
    if ($trangThai !== "") { $sql .= " AND svlhp.trang_thai = :tt"; $params[":tt"] = $trangThai; }
    if ($hocKy !== "")     { $sql .= " AND lhp.hoc_ky = :hk";       $params[":hk"] = $hocKy; }
    if ($khoaHoc !== "")   { $sql .= " AND lhp.khoa_hoc = :kh";     $params[":kh"] = $khoaHoc; }

    $sql .= " ORDER BY svlhp.ngay_dang_ky DESC";

    $stmt = $conn->prepare($sql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v, in_array($k, [":sv_id", ":sv_id2"]) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $result = array_map(fn($r) => [
        "id"                  => (int)$r["id"],
        "ma_lop_hoc_phan"     => $r["ma_lop_hoc_phan"],
        "ten_lop"             => $r["ten_lop"],
        "hoc_ky"              => $r["hoc_ky"],
        "nam_hoc"             => $r["nam_hoc"],
        "khoa_hoc"            => $r["khoa_hoc"],
        "trang_thai"          => $r["trang_thai"],
        "ngay_tao"            => $r["ngay_tao"],
        "trang_thai_dang_ky"  => $r["trang_thai_dang_ky"],
        "ngay_dang_ky"        => $r["ngay_dang_ky"],
        "mon_hoc_id"          => $r["mon_hoc_id"] !== null ? (int)$r["mon_hoc_id"] : null,
        "ma_mon"              => $r["ma_mon"],
        "ten_mon"             => $r["ten_mon"],
        "tin_chi"             => $r["tin_chi"] !== null ? (int)$r["tin_chi"] : null,
        "ten_giang_vien"      => $r["ten_giang_vien"],
        "ma_giang_vien"       => $r["ma_giang_vien"],
        "so_tai_lieu"         => (int)$r["so_tai_lieu"],
        "so_bai_tap"          => (int)$r["so_bai_tap"],
        "so_thong_bao"        => (int)$r["so_thong_bao"],
        "so_bai_da_nop"       => (int)$r["so_bai_da_nop"],
    ], $rows);

    echo json_encode(["status" => "success", "message" => "Lấy danh sách lớp học phần thành công", "data" => $result], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Lỗi server", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}
?>