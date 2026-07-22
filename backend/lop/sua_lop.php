<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Chỉ hỗ trợ phương thức POST'], JSON_UNESCAPED_UNICODE);
    exit();
}

require_once __DIR__ . '/../ket_noi.php';

function reply_sua_lop(int $code, array $payload): void
{
    http_response_code($code);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function ckc_sua_lop_has_column(PDO $conn, string $table, string $column): bool
{
    $db = (string)$conn->query("SELECT DATABASE()")?->fetchColumn();
    $stmt = $conn->prepare(
        "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND COLUMN_NAME = ?"
    );
    $stmt->execute([$db, $table, $column]);
    return (int)$stmt->fetchColumn() > 0;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) $input = $_POST;

$id = (int)($input['id'] ?? 0);
$maLop = strtoupper(trim((string)($input['ma_lop'] ?? '')));
$tenLop = trim((string)($input['ten_lop'] ?? ''));
$khoaId = (int)($input['khoa_id'] ?? 0);
$namNhapHoc = (int)($input['nam_nhap_hoc'] ?? 0);
$trangThai = trim((string)($input['trang_thai'] ?? ''));

if ($id <= 0) reply_sua_lop(400, ['status' => 'error', 'message' => 'ID lớp không hợp lệ']);
if ($maLop === '' || $tenLop === '') reply_sua_lop(400, ['status' => 'error', 'message' => 'Mã lớp và tên lớp không được để trống']);
if ($khoaId <= 0) reply_sua_lop(400, ['status' => 'error', 'message' => 'Vui lòng chọn khoa']);

$maxYear = (int)date('Y') + 2;
if ($namNhapHoc < 2000 || $namNhapHoc > $maxYear) {
    reply_sua_lop(400, ['status' => 'error', 'message' => 'Năm nhập học không hợp lệ']);
}
if (!in_array($trangThai, ['dang_hoc', 'da_tot_nghiep', 'tam_khoa'], true)) {
    reply_sua_lop(400, ['status' => 'error', 'message' => 'Trạng thái lớp không hợp lệ']);
}

try {
    $coNamNhapHoc = ckc_sua_lop_has_column($conn, 'lop', 'nam_nhap_hoc');
    $coKhoaHoc = ckc_sua_lop_has_column($conn, 'lop', 'khoa_hoc');
    $coDeletedAt = ckc_sua_lop_has_column($conn, 'lop', 'deleted_at');

    $sqlTonTai = "SELECT id FROM lop WHERE id = :id";
    if ($coDeletedAt) $sqlTonTai .= " AND deleted_at IS NULL";
    $sqlTonTai .= " LIMIT 1";
    $stmt = $conn->prepare($sqlTonTai);
    $stmt->execute([':id' => $id]);
    if (!$stmt->fetch()) reply_sua_lop(404, ['status' => 'error', 'message' => 'Không tìm thấy lớp']);

    $stmt = $conn->prepare("SELECT id FROM khoa WHERE id = :id LIMIT 1");
    $stmt->execute([':id' => $khoaId]);
    if (!$stmt->fetch()) reply_sua_lop(404, ['status' => 'error', 'message' => 'Không tìm thấy khoa đã chọn']);

    $sqlTrung = "SELECT id FROM lop WHERE ma_lop = :ma AND id <> :id";
    if ($coDeletedAt) $sqlTrung .= " AND deleted_at IS NULL";
    $sqlTrung .= " LIMIT 1";
    $stmt = $conn->prepare($sqlTrung);
    $stmt->execute([':ma' => $maLop, ':id' => $id]);
    if ($stmt->fetch()) reply_sua_lop(409, ['status' => 'error', 'message' => 'Mã lớp đã tồn tại']);

    if (!$coNamNhapHoc && !$coKhoaHoc) {
        reply_sua_lop(500, ['status' => 'error', 'message' => 'Bảng lớp chưa có cột năm nhập học phù hợp']);
    }

    $conn->beginTransaction();

    if ($coNamNhapHoc) {
        $sql = "UPDATE lop
                SET ma_lop = :ma, ten_lop = :ten, khoa_id = :khoa,
                    nam_nhap_hoc = :nam, trang_thai = :tt, ngay_cap_nhat = NOW()
                WHERE id = :id";
        $params = [':ma' => $maLop, ':ten' => $tenLop, ':khoa' => $khoaId, ':nam' => $namNhapHoc, ':tt' => $trangThai, ':id' => $id];
    } else {
        $khoaHocTuongThich = $namNhapHoc . '-' . ($namNhapHoc + 3);
        $sql = "UPDATE lop
                SET ma_lop = :ma, ten_lop = :ten, khoa_id = :khoa,
                    khoa_hoc = :khoa_hoc, trang_thai = :tt, ngay_cap_nhat = NOW()
                WHERE id = :id";
        $params = [':ma' => $maLop, ':ten' => $tenLop, ':khoa' => $khoaId, ':khoa_hoc' => $khoaHocTuongThich, ':tt' => $trangThai, ':id' => $id];
    }

    $stmt = $conn->prepare($sql);
    $stmt->execute($params);

    // Sinh viên vẫn dùng khoa_hoc; đồng bộ khóa 3 năm theo năm nhập học của lớp.
    if (ckc_sua_lop_has_column($conn, 'sinh_vien', 'khoa_hoc')) {
        $khoaHocSinhVien = $namNhapHoc . '-' . ($namNhapHoc + 3);
        $stmt = $conn->prepare(
            "UPDATE sinh_vien
             SET khoa_id = :khoa, khoa_hoc = :khoa_hoc, ngay_cap_nhat = NOW()
             WHERE lop_id = :lop_id"
        );
        $stmt->execute([':khoa' => $khoaId, ':khoa_hoc' => $khoaHocSinhVien, ':lop_id' => $id]);
    } else {
        $stmt = $conn->prepare("UPDATE sinh_vien SET khoa_id = :khoa, ngay_cap_nhat = NOW() WHERE lop_id = :lop_id");
        $stmt->execute([':khoa' => $khoaId, ':lop_id' => $id]);
    }

    $conn->commit();

    reply_sua_lop(200, [
        'status' => 'success',
        'message' => 'Cập nhật lớp thành công',
        'data' => [
            'id' => $id,
            'ma_lop' => $maLop,
            'ten_lop' => $tenLop,
            'khoa_id' => $khoaId,
            'nam_nhap_hoc' => $namNhapHoc,
            'trang_thai' => $trangThai,
        ],
    ]);
} catch (PDOException $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    reply_sua_lop(500, ['status' => 'error', 'message' => 'Lỗi server khi cập nhật lớp', 'detail' => $e->getMessage()]);
}
