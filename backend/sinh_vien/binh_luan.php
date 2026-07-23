<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim((string)($data["action"] ?? ""));
$nguoiDungId = (int)($data["nguoi_dung_id"] ?? 0);

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

/** Bình luận của bảng tin luôn gắn trực tiếp bằng binh_luan.bai_viet_id. */
function lay_bai_viet(PDO $conn, int $baiVietId): array {
    if ($baiVietId <= 0) {
        throw new RuntimeException('ID bài viết không hợp lệ');
    }

    $stmt = $conn->prepare("SELECT id, lop_hoc_phan_id, trang_thai FROM bai_viet WHERE id=? LIMIT 1");
    $stmt->execute([$baiVietId]);
    $baiViet = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$baiViet) {
        throw new RuntimeException('Bài viết không tồn tại');
    }
    if (($baiViet['trang_thai'] ?? 'hien_thi') === 'an') {
        throw new RuntimeException('Bài viết đã bị ẩn');
    }

    return $baiViet;
}

function map_binh_luan(array $r): array {
    return [
        "id" => (int)$r["id"],
        "noi_dung" => $r["noi_dung"],
        "nguoi_dung_id" => (int)$r["nguoi_dung_id"],
        "ten_nguoi_dung" => $r["ten_nguoi_dung"],
        "ten_vai_tro" => $r["ten_vai_tro"],
        "ngay_tao" => $r["ngay_tao"],
        "ngay_cap_nhat" => $r["ngay_cap_nhat"],
    ];
}

try {
    if ($action === 'dang') {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        $baiViet = lay_bai_viet($conn, $baiVietId);
        ckc_require_lhp_mutable($conn, (int)$baiViet['lop_hoc_phan_id']);
    } elseif (in_array($action, ['sua', 'xoa'], true)) {
        ckc_require_lhp_mutable(
            $conn,
            ckc_lhp_id_from_binh_luan($conn, (int)($data['binh_luan_id'] ?? 0))
        );
    }

    if ($action === 'danh_sach') {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        lay_bai_viet($conn, $baiVietId);

        $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.trang_thai,
                   bl.ngay_tao, bl.ngay_cap_nhat, bl.nguoi_dung_id,
                   nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
            FROM binh_luan bl
            JOIN nguoi_dung nd ON nd.id = bl.nguoi_dung_id
            LEFT JOIN vai_tro vt ON vt.id = nd.vai_tro_id
            WHERE bl.bai_viet_id = ?
              AND bl.trang_thai = 'hien_thi'
            ORDER BY bl.ngay_tao ASC, bl.id ASC");
        $stmt->execute([$baiVietId]);

        respond('success', 'Lấy bình luận bài viết thành công', [
            'data' => array_map('map_binh_luan', $stmt->fetchAll(PDO::FETCH_ASSOC)),
        ]);
    }

    if ($action === 'dang') {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        $baiViet = lay_bai_viet($conn, $baiVietId);
        $lopHocPhanId = (int)$baiViet['lop_hoc_phan_id'];
        $noiDung = trim((string)($data['noi_dung'] ?? ''));

        if ($nguoiDungId <= 0) respond('error', 'ID người dùng không hợp lệ');
        if ($noiDung === '') respond('error', 'Nội dung bình luận không được trống');
        if (mb_strlen($noiDung) > 2000) {
            respond('error', 'Nội dung quá dài (tối đa 2000 ký tự)');
        }

        $stmt = $conn->prepare("INSERT INTO binh_luan
            (noi_dung, nguoi_dung_id, lop_hoc_phan_id, bai_viet_id, trang_thai)
            VALUES (?, ?, ?, ?, 'hien_thi')");
        $stmt->execute([$noiDung, $nguoiDungId, $lopHocPhanId, $baiVietId]);
        $newId = (int)$conn->lastInsertId();

        $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.nguoi_dung_id,
                   bl.ngay_tao, bl.ngay_cap_nhat,
                   nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
            FROM binh_luan bl
            JOIN nguoi_dung nd ON nd.id = bl.nguoi_dung_id
            LEFT JOIN vai_tro vt ON vt.id = nd.vai_tro_id
            WHERE bl.id = ?");
        $stmt->execute([$newId]);

        respond('success', 'Đăng bình luận bài viết thành công', [
            'data' => map_binh_luan($stmt->fetch(PDO::FETCH_ASSOC)),
        ]);
    }

    if ($action === "sua") {
        $binhLuanId = (int)($data["binh_luan_id"] ?? 0);
        $noiDung = trim((string)($data["noi_dung"] ?? ""));
        if ($binhLuanId <= 0) respond("error", "ID bình luận không hợp lệ");
        if ($nguoiDungId <= 0) respond("error", "ID người dùng không hợp lệ");
        if ($noiDung === "") respond("error", "Nội dung không được trống");
        if (mb_strlen($noiDung) > 2000) respond("error", "Nội dung quá dài (tối đa 2000 ký tự)");

        $chk = $conn->prepare("SELECT nguoi_dung_id FROM binh_luan WHERE id = ?");
        $chk->execute([$binhLuanId]);
        $bl = $chk->fetch(PDO::FETCH_ASSOC);
        if (!$bl) respond("error", "Bình luận không tồn tại");
        if ((int)$bl["nguoi_dung_id"] !== $nguoiDungId) respond("error", "Bạn không có quyền sửa bình luận này");

        $conn->prepare("UPDATE binh_luan SET noi_dung=?, ngay_cap_nhat=NOW() WHERE id=?")
            ->execute([$noiDung, $binhLuanId]);
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

        $conn->prepare("UPDATE binh_luan SET trang_thai='an', ngay_cap_nhat=NOW() WHERE id=?")
            ->execute([$binhLuanId]);
        respond("success", "Xóa bình luận thành công");
    }

    http_response_code(400);
    respond("error", "Hành động không hợp lệ");
} catch (Throwable $e) {
    http_response_code(500);
    respond("error", "Lỗi server: " . $e->getMessage());
}
?>
