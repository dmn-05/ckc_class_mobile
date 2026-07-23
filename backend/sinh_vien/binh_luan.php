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

/**
 * Bản vá cũ từng thêm binh_luan.thong_bao_id. CSDL chuẩn Ckc_host dùng
 * binh_luan.bai_viet_id, nên chỉ chuyển dữ liệu cũ về bai_viet_id rồi bỏ qua
 * hoàn toàn thong_bao_id trong các thao tác mới.
 */
function migrate_legacy_thong_bao_comments(PDO $conn): void {
    $db = (string)$conn->query("SELECT DATABASE()")->fetchColumn();
    $stmt = $conn->prepare("SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA=? AND TABLE_NAME='binh_luan' AND COLUMN_NAME='thong_bao_id'");
    $stmt->execute([$db]);
    if ((int)$stmt->fetchColumn() === 0) return;

    $conn->exec("UPDATE binh_luan bl
        JOIN thong_bao tb ON tb.id = bl.thong_bao_id
        SET bl.bai_viet_id = tb.bai_viet_id,
            bl.lop_hoc_phan_id = COALESCE(bl.lop_hoc_phan_id, tb.lop_hoc_phan_id)
        WHERE bl.thong_bao_id IS NOT NULL
          AND tb.bai_viet_id IS NOT NULL
          AND (bl.bai_viet_id IS NULL OR bl.bai_viet_id = 0)");
}

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
    migrate_legacy_thong_bao_comments($conn);

    if ($action === 'dang') {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);

        if ($baiVietId > 0) {
            $baiViet = lay_bai_viet($conn, $baiVietId);
            $lopHocPhanId = (int)$baiViet['lop_hoc_phan_id'];
        }

        ckc_require_lhp_mutable($conn, $lopHocPhanId);
    } elseif (in_array($action, ['sua', 'xoa'], true)) {
        ckc_require_lhp_mutable(
            $conn,
            ckc_lhp_id_from_binh_luan($conn, (int)($data['binh_luan_id'] ?? 0))
        );
    }

    if ($action === "danh_sach") {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);

        if ($baiVietId > 0) {
            lay_bai_viet($conn, $baiVietId);
            $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.trang_thai, bl.ngay_tao, bl.ngay_cap_nhat,
                       bl.nguoi_dung_id, nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
                FROM binh_luan bl
                JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
                LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
                WHERE bl.bai_viet_id = ?
                  AND bl.trang_thai = 'hien_thi'
                ORDER BY bl.ngay_tao ASC, bl.id ASC");
            $stmt->execute([$baiVietId]);
        } else {
            if ($lopHocPhanId <= 0) respond("error", "ID lớp học phần không hợp lệ");
            $stmt = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.trang_thai, bl.ngay_tao, bl.ngay_cap_nhat,
                       bl.nguoi_dung_id, nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
                FROM binh_luan bl
                JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
                LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
                WHERE bl.lop_hoc_phan_id = ?
                  AND bl.bai_viet_id IS NULL
                  AND bl.trang_thai = 'hien_thi'
                ORDER BY bl.ngay_tao ASC, bl.id ASC");
            $stmt->execute([$lopHocPhanId]);
        }

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        respond("success", "Lấy bình luận thành công", [
            "data" => array_map('map_binh_luan', $rows),
        ]);
    }

    if ($action === "dang") {
        $baiVietId = (int)($data['bai_viet_id'] ?? 0);
        $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);
        $noiDung = trim((string)($data["noi_dung"] ?? ""));

        if ($nguoiDungId <= 0) respond("error", "ID người dùng không hợp lệ");
        if ($noiDung === "") respond("error", "Nội dung bình luận không được trống");
        if (mb_strlen($noiDung) > 2000) respond("error", "Nội dung quá dài (tối đa 2000 ký tự)");

        if ($baiVietId > 0) {
            $baiViet = lay_bai_viet($conn, $baiVietId);
            $lopHocPhanId = (int)$baiViet['lop_hoc_phan_id'];
        } elseif ($lopHocPhanId <= 0) {
            respond("error", "Phải truyền bai_viet_id hoặc lop_hoc_phan_id");
        }

        $stmt = $conn->prepare("INSERT INTO binh_luan
            (noi_dung, nguoi_dung_id, lop_hoc_phan_id, bai_viet_id, trang_thai)
            VALUES (?, ?, ?, ?, 'hien_thi')");
        $stmt->execute([
            $noiDung,
            $nguoiDungId,
            $lopHocPhanId,
            $baiVietId > 0 ? $baiVietId : null,
        ]);
        $newId = (int)$conn->lastInsertId();

        $stmt2 = $conn->prepare("SELECT bl.id, bl.noi_dung, bl.nguoi_dung_id, bl.ngay_tao, bl.ngay_cap_nhat,
                    nd.ho_ten AS ten_nguoi_dung, vt.ten_vai_tro
            FROM binh_luan bl
            JOIN nguoi_dung nd ON bl.nguoi_dung_id = nd.id
            LEFT JOIN vai_tro vt ON nd.vai_tro_id = vt.id
            WHERE bl.id = ?");
        $stmt2->execute([$newId]);
        $bl = $stmt2->fetch(PDO::FETCH_ASSOC);

        respond("success", "Đăng bình luận thành công", ["data" => map_binh_luan($bl)]);
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
