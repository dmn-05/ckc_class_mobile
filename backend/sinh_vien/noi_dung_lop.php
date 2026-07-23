<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";

$data = json_decode(file_get_contents("php://input"), true) ?? [];
$action = trim((string)($data["action"] ?? ""));
$lopHocPhanId = (int)($data["lop_hoc_phan_id"] ?? 0);
$tuKhoa = trim((string)($data["tu_khoa"] ?? ""));

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function lay_files_bai_viet_sv(PDO $conn, int $baiVietId): array {
    $stmt = $conn->prepare("SELECT tt.id, tt.ten_file, tt.ten_file_luu, tt.duong_dan,
               tt.loai_file, tt.kich_thuoc, tt.ngay_tao
        FROM tep_tin_bai_viet tbv
        JOIN tep_tin tt ON tt.id = tbv.tep_tin_id
        WHERE tbv.bai_viet_id = ?
          AND COALESCE(tt.trang_thai, 'dang_su_dung') <> 'da_xoa'
        ORDER BY tbv.id ASC");
    $stmt->execute([$baiVietId]);

    return array_map(static fn(array $r): array => [
        'id' => (int)$r['id'],
        'ten_file' => $r['ten_file'],
        'ten_file_goc' => $r['ten_file'],
        'duong_dan' => $r['duong_dan'],
        'duong_dan_file' => $r['duong_dan'],
        'loai_file' => $r['loai_file'],
        'kich_thuoc' => (int)$r['kich_thuoc'],
        'ngay_tao' => $r['ngay_tao'],
    ], $stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($lopHocPhanId <= 0) {
    http_response_code(400);
    respond('error', 'ID lớp học phần không hợp lệ');
}

try {
    if ($action === 'tai_lieu') {
        $sql = "SELECT tl.*, nd.ho_ten AS ten_nguoi_tao
                FROM tai_lieu tl
                LEFT JOIN nguoi_dung nd ON tl.nguoi_tao_id = nd.id
                WHERE tl.lop_hoc_phan_id = :lhp
                  AND tl.trang_thai = 'hien_thi'";
        if ($tuKhoa !== '') $sql .= " AND tl.tieu_de LIKE :tu_khoa";
        $sql .= " ORDER BY tl.ngay_tao DESC";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':lhp', $lopHocPhanId, PDO::PARAM_INT);
        if ($tuKhoa !== '') $stmt->bindValue(':tu_khoa', "%$tuKhoa%", PDO::PARAM_STR);
        $stmt->execute();

        $result = array_map(static fn(array $r): array => [
            'id' => (int)$r['id'],
            'bai_viet_id' => isset($r['bai_viet_id']) && $r['bai_viet_id'] !== null
                ? (int)$r['bai_viet_id']
                : null,
            'tieu_de' => $r['tieu_de'],
            'mo_ta' => $r['mo_ta'],
            'duong_dan_file' => $r['duong_dan_file'],
            'ten_nguoi_tao' => $r['ten_nguoi_tao'],
            'ngay_tao' => $r['ngay_tao'],
            'ngay_cap_nhat' => $r['ngay_cap_nhat'],
        ], $stmt->fetchAll(PDO::FETCH_ASSOC));

        respond('success', 'Lấy danh sách tài liệu thành công', ['data' => $result]);
    }

    if ($action === 'bai_viet') {
        $sql = "SELECT bv.*, nd.ho_ten AS ten_nguoi_tao,
                       nd.avatar AS avatar_nguoi_tao,
                       vt.ten_vai_tro,
                       cd.ten_chu_de,
                       bt.loai_bai_tap,
                       bt.huong_dan AS huong_dan_bai_tap,
                       bt.mo_ta AS mo_ta_bai_tap,
                       bt.so_file_toi_da,
                       bt.dung_luong_toi_da_mb,
                       (SELECT COUNT(*) FROM binh_luan bl
                        WHERE bl.bai_viet_id = bv.id
                          AND bl.trang_thai = 'hien_thi') AS so_binh_luan
                FROM bai_viet bv
                LEFT JOIN nguoi_dung nd ON nd.id = bv.nguoi_tao_id
                LEFT JOIN vai_tro vt ON vt.id = nd.vai_tro_id
                LEFT JOIN chu_de cd ON cd.id = bv.chu_de_id
                LEFT JOIN bai_tap bt ON bt.id = bv.bai_tap_id
                WHERE bv.lop_hoc_phan_id = :lhp
                  AND bv.trang_thai = 'hien_thi'";
        if ($tuKhoa !== '') {
            $sql .= " AND (bv.tieu_de LIKE :tk_tieu_de OR bv.noi_dung LIKE :tk_noi_dung)";
        }
        $sql .= " ORDER BY bv.ngay_tao DESC, bv.id DESC";

        $stmt = $conn->prepare($sql);
        $stmt->bindValue(':lhp', $lopHocPhanId, PDO::PARAM_INT);
        if ($tuKhoa !== '') {
            $stmt->bindValue(':tk_tieu_de', "%$tuKhoa%", PDO::PARAM_STR);
            $stmt->bindValue(':tk_noi_dung', "%$tuKhoa%", PDO::PARAM_STR);
        }
        $stmt->execute();

        $result = [];
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $r) {
            $baiVietId = (int)$r['id'];
            $result[] = [
                'id' => $baiVietId,
                'bai_viet_id' => $baiVietId,
                'tieu_de' => $r['tieu_de'],
                'noi_dung' => $r['noi_dung'],
                'hinh_anh' => $r['hinh_anh'],
                'external_url' => $r['external_url'],
                'lop_hoc_phan_id' => (int)$r['lop_hoc_phan_id'],
                'chu_de_id' => $r['chu_de_id'] !== null ? (int)$r['chu_de_id'] : null,
                'ten_chu_de' => $r['ten_chu_de'],
                'bai_tap_id' => $r['bai_tap_id'] !== null ? (int)$r['bai_tap_id'] : null,
                'nguoi_tao_id' => (int)$r['nguoi_tao_id'],
                'ten_nguoi_tao' => $r['ten_nguoi_tao'],
                'avatar_nguoi_tao' => $r['avatar_nguoi_tao'],
                'ten_vai_tro' => $r['ten_vai_tro'],
                'loai_bai_viet' => $r['loai_bai_viet'],
                'loai_tai_nguyen' => $r['loai_tai_nguyen'],
                'trang_thai' => $r['trang_thai'],
                'ngay_tao' => $r['ngay_tao'],
                'ngay_cap_nhat' => $r['ngay_cap_nhat'],
                'diem_toi_da' => $r['diem_toi_da'] !== null ? (float)$r['diem_toi_da'] : null,
                'han_nop' => $r['han_nop'],
                'cho_phep_nop_tre' => (int)$r['cho_phep_nop_tre'],
                'tyle_phat_tre' => (int)$r['tyle_phat_tre'],
                'luot_xem' => (int)$r['luot_xem'],
                'loai_bai_tap' => $r['loai_bai_tap'],
                'huong_dan_bai_tap' => $r['huong_dan_bai_tap'],
                'mo_ta_bai_tap' => $r['mo_ta_bai_tap'],
                'so_file_toi_da' => $r['so_file_toi_da'] !== null ? (int)$r['so_file_toi_da'] : null,
                'dung_luong_toi_da_mb' => $r['dung_luong_toi_da_mb'] !== null ? (int)$r['dung_luong_toi_da_mb'] : null,
                'so_binh_luan' => (int)$r['so_binh_luan'],
                'files' => lay_files_bai_viet_sv($conn, $baiVietId),
            ];
        }

        respond('success', 'Lấy danh sách bài viết thành công', ['data' => $result]);
    }

    http_response_code(400);
    respond('error', "Hành động không hợp lệ. Dùng 'tai_lieu' hoặc 'bai_viet'");
} catch (Throwable $e) {
    http_response_code(500);
    respond('error', 'Lỗi server: ' . $e->getMessage());
}
?>
