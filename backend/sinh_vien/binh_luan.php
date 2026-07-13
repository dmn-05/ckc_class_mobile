<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim($data["action"] ?? "");
$nguoiDungId = (int)($data["nguoi_dung_id"] ?? 0);

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function ensure_thong_bao_schema_bl(PDO $conn) {
    $db = $conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=? AND TABLE_NAME='thong_bao' AND COLUMN_NAME='bai_viet_id'");
    $stmt->execute([$db]);
    if ((int)$stmt->fetchColumn() === 0) {
        $conn->exec("ALTER TABLE thong_bao ADD COLUMN bai_viet_id INT NULL AFTER nguoi_tao_id");
        try { $conn->exec("ALTER TABLE thong_bao ADD INDEX idx_thong_bao_bai_viet (bai_viet_id)"); } catch (Throwable $e) {}
    }
}

function tao_bai_viet_cho_thong_bao(PDO $conn, int $thongBaoId): array {
    $stmt = $conn->prepare("SELECT * FROM thong_bao WHERE id=?");
    $stmt->execute([$thongBaoId]);
    $tb = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$tb) throw new RuntimeException('Thông báo không tồn tại');
    if (!empty($tb['bai_viet_id'])) return ['bai_viet_id' => (int)$tb['bai_viet_id'], 'lop_hoc_phan_id' => (int)$tb['lop_hoc_phan_id']];

    $stmt = $conn->prepare("INSERT INTO bai_viet
        (tieu_de, noi_dung, lop_hoc_phan_id, nguoi_tao_id, loai_bai_viet, loai_tai_nguyen, trang_thai)
        VALUES (?, ?, ?, ?, 'thong_bao', 'document', ?)");
    $stmt->execute([$tb['tieu_de'], $tb['noi_dung'], (int)$tb['lop_hoc_phan_id'], (int)$tb['nguoi_tao_id'], $tb['trang_thai']]);
    $baiVietId = (int)$conn->lastInsertId();
    $conn->prepare("UPDATE thong_bao SET bai_viet_id=? WHERE id=?")->execute([$baiVietId, $thongBaoId]);
    return ['bai_viet_id' => $baiVietId, 'lop_hoc_phan_id' => (int)$tb['lop_hoc_phan_id']];
}

function resolve_target(PDO $conn, array $data): array {
    ensure_thong_bao_schema_bl($conn);
    $thongBaoId = (int)($data['thong_bao_id'] ?? 0);
    $baiVietId = (int)($data['bai_viet_id'] ?? 0);
    $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);

    if ($thongBaoId > 0) {
        $r = tao_bai_viet_cho_thong_bao($conn, $thongBaoId);
        return ['mode' => 'thong_bao', 'bai_viet_id' => $r['bai_viet_id'], 'lop_hoc_phan_id' => $r['lop_hoc_phan_id']];
    }

    if ($baiVietId > 0) {
        $stmt = $conn->prepare("SELECT lop_hoc_phan_id FROM bai_viet WHERE id=?");
        $stmt->execute([$baiVietId]);
        $lhp = $stmt->fetchColumn();
        return ['mode' => 'bai_viet', 'bai_viet_id' => $baiVietId, 'lop_hoc_phan_id' => $lhp ? (int)$lhp : $lopHocPhanId];
    }

    return ['mode' => 'lop', 'bai_viet_id' => null, 'lop_hoc_phan_id' => $lopHocPhanId];
}

try {
    if ($action === "danh_sach") {
        $target = resolve_target($conn, $data);
        if ($target['mode'] === 'lop') {
            if ($target['lop_hoc_phan_id'] <= 0) respond("error", "ID lớp học phần không hợp lệ");
            $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.trang_thai, bl.ngay_tao, bl.ngay_cap_nhat,
                       bl.nguoi_dung_id, nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
                FROM binh_luan bl
                JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
                LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
                WHERE bl.lop_hoc_phan_id = ? AND bl.bai_viet_id IS NULL AND bl.trang_thai = 'hien_thi'
                ORDER BY bl.ngay_tao ASC");
            $stmt->execute([$target['lop_hoc_phan_id']]);
        } else {
            $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.trang_thai, bl.ngay_tao, bl.ngay_cap_nhat,
                       bl.nguoi_dung_id, nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
                FROM binh_luan bl
                JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
                LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
                WHERE bl.bai_viet_id = ? AND bl.trang_thai = 'hien_thi'
                ORDER BY bl.ngay_tao ASC");
            $stmt->execute([$target['bai_viet_id']]);
        }
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $result = array_map(fn($r) => [
            "id" => (int)$r["id"],
            "noi_dung" => $r["noi_dung"],
            "nguoi_dung_id" => (int)$r["nguoi_dung_id"],
            "ten_nguoi_dung" => $r["ten_nguoi_dung"],
            "ten_vai_tro" => $r["ten_vai_tro"],
            "ngay_tao" => $r["ngay_tao"],
            "ngay_cap_nhat" => $r["ngay_cap_nhat"],
        ], $rows);
        respond("success", "Lấy bình luận thành công", ["data" => $result]);
    }

    if ($action === "dang") {
        $target = resolve_target($conn, $data);
        $noiDung = trim($data["noi_dung"] ?? "");
        if ($nguoiDungId <= 0) respond("error", "ID người dùng không hợp lệ");
        if ($noiDung === "") respond("error", "Nội dung bình luận không được trống");
        if (mb_strlen($noiDung) > 2000) respond("error", "Nội dung quá dài (tối đa 2000 ký tự)");
        if ($target['mode'] === 'lop' && $target['lop_hoc_phan_id'] <= 0) respond("error", "ID lớp học phần không hợp lệ");

        $stmt = $conn->prepare("INSERT INTO binh_luan (noi_dung, nguoi_dung_id, lop_hoc_phan_id, bai_viet_id, trang_thai) VALUES (?,?,?,?, 'hien_thi')");
        $stmt->execute([$noiDung, $nguoiDungId, $target['lop_hoc_phan_id'] ?: null, $target['bai_viet_id']]);
        $newId = (int)$conn->lastInsertId();

        $stmt2 = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.nguoi_dung_id, bl.ngay_tao, nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
            FROM binh_luan bl
            JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
            LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
            WHERE bl.id = ?");
        $stmt2->execute([$newId]);
        $bl = $stmt2->fetch(PDO::FETCH_ASSOC);
        respond("success", "Đăng bình luận thành công", ["data" => [
            "id" => (int)$bl["id"],
            "noi_dung" => $bl["noi_dung"],
            "nguoi_dung_id" => (int)$bl["nguoi_dung_id"],
            "ten_nguoi_dung" => $bl["ten_nguoi_dung"],
            "ten_vai_tro" => $bl["ten_vai_tro"],
            "ngay_tao" => $bl["ngay_tao"],
            "ngay_cap_nhat" => $bl["ngay_tao"],
        ]]);
    }

    if ($action === "sua") {
        $binhLuanId = (int)($data["binh_luan_id"] ?? 0);
        $noiDung = trim($data["noi_dung"] ?? "");
        if ($binhLuanId <= 0) respond("error", "ID bình luận không hợp lệ");
        if ($nguoiDungId <= 0) respond("error", "ID người dùng không hợp lệ");
        if ($noiDung === "") respond("error", "Nội dung không được trống");
        $chk = $conn->prepare("SELECT nguoi_dung_id FROM binh_luan WHERE id = ?");
        $chk->execute([$binhLuanId]);
        $bl = $chk->fetch(PDO::FETCH_ASSOC);
        if (!$bl) respond("error", "Bình luận không tồn tại");
        if ((int)$bl["nguoi_dung_id"] !== $nguoiDungId) respond("error", "Bạn không có quyền sửa bình luận này");
        $conn->prepare("UPDATE binh_luan SET noi_dung=?, ngay_cap_nhat=NOW() WHERE id=?")->execute([$noiDung, $binhLuanId]);
        respond("success", "Cập nhật bình luận thành công");
    }

    if ($action === "xoa") {
        $binhLuanId = (int)($data["binh_luan_id"] ?? 0);
        if ($binhLuanId <= 0) respond("error", "ID bình luận không hợp lệ");
        if ($nguoiDungId <= 0) respond("error", "ID người dùng không hợp lệ");
        $chk = $conn->prepare("SELECT nguoi_dung_id FROM binh_luan WHERE id = ?");
        $chk->execute([$binhLuanId]);
        $bl = $chk->fetch(PDO::FETCH_ASSOC);
        if (!$bl) respond("error", "Bình luận không tồn tại");
        if ((int)$bl["nguoi_dung_id"] !== $nguoiDungId) respond("error", "Bạn không có quyền xóa bình luận này");
        $conn->prepare("UPDATE binh_luan SET trang_thai='an' WHERE id=?")->execute([$binhLuanId]);
        respond("success", "Xóa bình luận thành công");
    }

    http_response_code(400);
    respond("error", "Hành động không hợp lệ");
} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
