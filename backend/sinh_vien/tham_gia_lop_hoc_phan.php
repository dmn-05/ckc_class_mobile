<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }
if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["status" => "error", "message" => "Chỉ hỗ trợ phương thức POST"], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . "/../ket_noi.php";

function respond($status, $message, $extra = [], $code = 200) {
    http_response_code($code);
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

$data = json_decode(file_get_contents("php://input"), true);
if (!is_array($data)) $data = $_POST;

$sinhVienId = (int)($data["sinh_vien_id"] ?? 0);
$maLopHocPhan = strtoupper(trim($data["ma_lop_hoc_phan"] ?? ""));

if ($sinhVienId <= 0) respond("error", "ID sinh viên không hợp lệ", [], 400);
if ($maLopHocPhan === "") respond("error", "Vui lòng nhập mã lớp học phần", [], 400);

try {
    $stmt = $conn->prepare("SELECT id FROM sinh_vien WHERE id = ? AND trang_thai = 'dang_hoc' LIMIT 1");
    $stmt->execute([$sinhVienId]);
    if (!$stmt->fetch(PDO::FETCH_ASSOC)) respond("error", "Sinh viên không tồn tại hoặc không còn học", [], 404);

    $stmt = $conn->prepare("\n        SELECT lhp.id, lhp.ma_lop_hoc_phan, lhp.ten_lop, lhp.trang_thai, lhp.si_so_toi_da,\n               mh.ten_mon, mh.ma_mon, nd.ho_ten AS ten_giang_vien,\n               (SELECT COUNT(*) FROM sinh_vien_lop_hoc_phan svlhp\n                WHERE svlhp.lop_hoc_phan_id = lhp.id AND svlhp.trang_thai = 'dang_hoc') AS so_sinh_vien\n        FROM lop_hoc_phan lhp\n        LEFT JOIN mon_hoc mh ON lhp.mon_hoc_id = mh.id\n        LEFT JOIN giang_vien gv ON lhp.giang_vien_id = gv.id\n        LEFT JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id\n        WHERE lhp.ma_lop_hoc_phan = ?\n        LIMIT 1\n    ");
    $stmt->execute([$maLopHocPhan]);
    $lop = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$lop) respond("error", "Không tìm thấy lớp học phần với mã này", [], 404);
    if ($lop["trang_thai"] !== "dang_mo") respond("error", "Lớp học phần không còn mở để tham gia", [], 400);

    $siSoToiDa = $lop["si_so_toi_da"] !== null ? (int)$lop["si_so_toi_da"] : null;
    $soSinhVien = (int)$lop["so_sinh_vien"];
    if ($siSoToiDa !== null && $soSinhVien >= $siSoToiDa) {
        respond("error", "Lớp học phần đã đủ sĩ số", [], 400);
    }

    $lopHocPhanId = (int)$lop["id"];
    $stmt = $conn->prepare("SELECT id, trang_thai FROM sinh_vien_lop_hoc_phan WHERE sinh_vien_id = ? AND lop_hoc_phan_id = ? LIMIT 1");
    $stmt->execute([$sinhVienId, $lopHocPhanId]);
    $dangKyCu = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($dangKyCu) {
        if ($dangKyCu["trang_thai"] === "dang_hoc") {
            respond("error", "Bạn đã tham gia lớp học phần này", [], 409);
        }
        $stmt = $conn->prepare("UPDATE sinh_vien_lop_hoc_phan SET trang_thai = 'dang_hoc', ngay_dang_ky = CURRENT_TIMESTAMP WHERE id = ?");
        $stmt->execute([(int)$dangKyCu["id"]]);
        $dangKyId = (int)$dangKyCu["id"];
    } else {
        $stmt = $conn->prepare("INSERT INTO sinh_vien_lop_hoc_phan (sinh_vien_id, lop_hoc_phan_id, trang_thai) VALUES (?, ?, 'dang_hoc')");
        $stmt->execute([$sinhVienId, $lopHocPhanId]);
        $dangKyId = (int)$conn->lastInsertId();
    }

    respond("success", "Tham gia lớp học phần thành công", ["data" => [
        "dang_ky_id" => $dangKyId,
        "lop_hoc_phan_id" => $lopHocPhanId,
        "ma_lop_hoc_phan" => $lop["ma_lop_hoc_phan"],
        "ten_lop" => $lop["ten_lop"],
        "ma_mon" => $lop["ma_mon"],
        "ten_mon" => $lop["ten_mon"],
        "ten_giang_vien" => $lop["ten_giang_vien"],
    ]]);
} catch (PDOException $e) {
    respond("error", "Lỗi server khi tham gia lớp học phần", ["detail" => $e->getMessage()], 500);
}
?>
