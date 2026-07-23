<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { http_response_code(200); exit(); }

require_once __DIR__ . "/../ket_noi.php";
require_once __DIR__ . "/../_lop_hoc_phan_guard.php";
require_once __DIR__ . "/../upload/cloudinary_helper.php";

$rawInput = file_get_contents("php://input");
$jsonData = json_decode($rawInput, true);
$data = is_array($jsonData) ? $jsonData : $_POST;
$action = trim((string)($data["action"] ?? ""));

function respond($status, $message, $extra = []) {
    echo json_encode(array_merge(["status" => $status, "message" => $message], $extra), JSON_UNESCAPED_UNICODE);
    exit();
}

function lay_files_bai_viet(PDO $conn, int $baiVietId): array {
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

function luu_files_bai_viet(PDO $conn, int $baiVietId, int $nguoiTaoId, array $files): array {
    $stmt = $conn->prepare("SELECT COUNT(*)
        FROM tep_tin_bai_viet tbv
        JOIN tep_tin tt ON tt.id = tbv.tep_tin_id
        WHERE tbv.bai_viet_id = ?
          AND COALESCE(tt.trang_thai, 'dang_su_dung') <> 'da_xoa'");
    $stmt->execute([$baiVietId]);
    $soFileHienTai = (int)$stmt->fetchColumn();

    if ($soFileHienTai + count($files) > 10) {
        throw new RuntimeException('Mỗi bài viết chỉ được đính kèm tối đa 10 file');
    }

    $saved = [];
    foreach ($files as $file) {
        if ((int)($file['size'] ?? 0) > 50 * 1024 * 1024) {
            throw new RuntimeException('File ' . ($file['name'] ?? '') . ' vượt quá 50MB');
        }

        $up = ckc_upload_to_cloudinary($file, 'posts');
        $tenFile = trim((string)($file['name'] ?? ''));
        if ($tenFile === '') $tenFile = trim((string)($up['original_filename'] ?? 'file'));
        if ($tenFile === '') $tenFile = 'file';

        $loaiFile = $up['format'] ?: strtolower(pathinfo($tenFile, PATHINFO_EXTENSION));
        $kichThuoc = (float)($up['bytes'] ?? ($file['size'] ?? 0));
        $url = (string)$up['secure_url'];

        $stmt = $conn->prepare("INSERT INTO tep_tin
            (ten_file, ten_file_luu, duong_dan, loai_file, kich_thuoc, nguoi_tao_id, trang_thai)
            VALUES (?, ?, ?, ?, ?, ?, 'dang_su_dung')");
        $stmt->execute([
            $tenFile,
            $up['public_id'] ?? null,
            $url,
            $loaiFile,
            $kichThuoc,
            $nguoiTaoId,
        ]);
        $tepTinId = (int)$conn->lastInsertId();

        $stmt = $conn->prepare("INSERT INTO tep_tin_bai_viet (tep_tin_id, bai_viet_id, ngay_tao)
            VALUES (?, ?, NOW())");
        $stmt->execute([$tepTinId, $baiVietId]);

        $saved[] = [
            'id' => $tepTinId,
            'ten_file' => $tenFile,
            'duong_dan' => $url,
            'duong_dan_file' => $url,
            'loai_file' => $loaiFile,
            'kich_thuoc' => (int)$kichThuoc,
        ];
    }

    return $saved;
}

function parse_tep_tin_ids($raw): array {
    if (is_array($raw)) {
        $values = $raw;
    } else {
        $decoded = json_decode((string)$raw, true);
        $values = is_array($decoded) ? $decoded : explode(',', (string)$raw);
    }

    return array_values(array_unique(array_filter(
        array_map('intval', $values),
        static fn(int $value): bool => $value > 0
    )));
}

function xoa_files_bai_viet(PDO $conn, int $baiVietId, array $tepTinIds): void {
    if (empty($tepTinIds)) return;

    $placeholders = implode(',', array_fill(0, count($tepTinIds), '?'));
    $stmt = $conn->prepare("DELETE FROM tep_tin_bai_viet
        WHERE bai_viet_id = ? AND tep_tin_id IN ($placeholders)");
    $stmt->execute(array_merge([$baiVietId], $tepTinIds));

    $stmt = $conn->prepare("UPDATE tep_tin SET trang_thai = 'da_xoa'
        WHERE id IN ($placeholders)");
    $stmt->execute($tepTinIds);
}

function map_bai_viet(PDO $conn, array $r): array {
    $id = (int)$r['id'];
    return [
        'id' => $id,
        'bai_viet_id' => $id,
        'tieu_de' => $r['tieu_de'],
        'noi_dung' => $r['noi_dung'],
        'hinh_anh' => $r['hinh_anh'],
        'external_url' => $r['external_url'],
        'lop_hoc_phan_id' => (int)$r['lop_hoc_phan_id'],
        'chu_de_id' => $r['chu_de_id'] !== null ? (int)$r['chu_de_id'] : null,
        'bai_tap_id' => $r['bai_tap_id'] !== null ? (int)$r['bai_tap_id'] : null,
        'nguoi_tao_id' => (int)$r['nguoi_tao_id'],
        'ten_nguoi_tao' => $r['ten_nguoi_tao'],
        'avatar_nguoi_tao' => $r['avatar_nguoi_tao'],
        'ten_vai_tro' => $r['ten_vai_tro'] ?? null,
        'ten_chu_de' => $r['ten_chu_de'] ?? null,
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
        'loai_bai_tap' => $r['loai_bai_tap'] ?? null,
        'huong_dan_bai_tap' => $r['huong_dan_bai_tap'] ?? null,
        'mo_ta_bai_tap' => $r['mo_ta_bai_tap'] ?? null,
        'so_file_toi_da' => isset($r['so_file_toi_da']) && $r['so_file_toi_da'] !== null
            ? (int)$r['so_file_toi_da']
            : null,
        'dung_luong_toi_da_mb' => isset($r['dung_luong_toi_da_mb']) && $r['dung_luong_toi_da_mb'] !== null
            ? (int)$r['dung_luong_toi_da_mb']
            : null,
        'so_binh_luan' => (int)$r['so_binh_luan'],
        'files' => lay_files_bai_viet($conn, $id),
        // Giữ khóa cũ ở mức phản hồi để app cũ không lỗi, nhưng không đọc bảng thong_bao.
        'thoi_gian_gui' => null,
        'trang_thai_gui' => 'da_dang',
    ];
}

try {
    if ($action === 'them') {
        ckc_require_lhp_mutable($conn, (int)($data['lop_hoc_phan_id'] ?? 0));
    } elseif (in_array($action, ['sua', 'xoa'], true)) {
        ckc_require_lhp_mutable($conn, ckc_lhp_id_from_bai_viet($conn, (int)($data['id'] ?? 0)));
    }

    switch ($action) {
        case 'danh_sach': {
            $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);
            $trangThai = trim((string)($data['trang_thai'] ?? ''));
            if ($lopHocPhanId <= 0) respond('error', 'ID lớp học phần không hợp lệ');

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
                      AND bv.loai_bai_viet IN ('bai_viet', 'thong_bao')";
            $params = [':lhp' => $lopHocPhanId];

            if ($trangThai !== '') {
                $sql .= " AND bv.trang_thai = :trang_thai";
                $params[':trang_thai'] = $trangThai;
            }

            $sql .= " ORDER BY bv.ngay_tao DESC, bv.id DESC";
            $stmt = $conn->prepare($sql);
            foreach ($params as $key => $value) {
                $stmt->bindValue($key, $value, $key === ':lhp' ? PDO::PARAM_INT : PDO::PARAM_STR);
            }
            $stmt->execute();

            $result = [];
            foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
                $result[] = map_bai_viet($conn, $row);
            }

            respond('success', 'Lấy danh sách bài viết thành công', ['data' => $result]);
        }

        case 'them': {
            $tieuDe = trim((string)($data['tieu_de'] ?? ''));
            $noiDung = trim((string)($data['noi_dung'] ?? ''));
            $lopHocPhanId = (int)($data['lop_hoc_phan_id'] ?? 0);
            $nguoiTaoId = (int)($data['nguoi_tao_id'] ?? 0);
            $trangThai = trim((string)($data['trang_thai'] ?? 'hien_thi'));

            if ($tieuDe === '') respond('error', 'Tiêu đề không được để trống');
            if ($lopHocPhanId <= 0) respond('error', 'ID lớp học phần không hợp lệ');
            if ($nguoiTaoId <= 0) respond('error', 'ID người tạo không hợp lệ');
            if (!in_array($trangThai, ['hien_thi', 'an'], true)) $trangThai = 'hien_thi';

            $conn->beginTransaction();
            $stmt = $conn->prepare("INSERT INTO bai_viet
                (tieu_de, noi_dung, lop_hoc_phan_id, nguoi_tao_id,
                 loai_bai_viet, loai_tai_nguyen, trang_thai)
                VALUES (?, ?, ?, ?, 'bai_viet', 'document', ?)");
            $stmt->execute([
                $tieuDe,
                $noiDung !== '' ? $noiDung : null,
                $lopHocPhanId,
                $nguoiTaoId,
                $trangThai,
            ]);
            $baiVietId = (int)$conn->lastInsertId();

            $files = ckc_collect_uploads(['file', 'files', 'files[]']);
            $savedFiles = empty($files)
                ? []
                : luu_files_bai_viet($conn, $baiVietId, $nguoiTaoId, $files);

            $conn->commit();
            respond('success', 'Đăng bài viết thành công', [
                'id' => $baiVietId,
                'bai_viet_id' => $baiVietId,
                'files' => $savedFiles,
            ]);
        }

        case 'sua': {
            $id = (int)($data['id'] ?? 0);
            $tieuDe = trim((string)($data['tieu_de'] ?? ''));
            $noiDung = trim((string)($data['noi_dung'] ?? ''));
            $trangThai = trim((string)($data['trang_thai'] ?? 'hien_thi'));
            $nguoiTaoId = (int)($data['nguoi_tao_id'] ?? 0);

            if ($id <= 0) respond('error', 'ID bài viết không hợp lệ');
            if ($tieuDe === '') respond('error', 'Tiêu đề không được để trống');
            if (!in_array($trangThai, ['hien_thi', 'an'], true)) $trangThai = 'hien_thi';

            $conn->beginTransaction();
            $stmt = $conn->prepare("UPDATE bai_viet
                SET tieu_de = ?, noi_dung = ?, loai_bai_viet = 'bai_viet',
                    trang_thai = ?, ngay_cap_nhat = NOW()
                WHERE id = ?");
            $stmt->execute([
                $tieuDe,
                $noiDung !== '' ? $noiDung : null,
                $trangThai,
                $id,
            ]);
            if ($stmt->rowCount() === 0) {
                $check = $conn->prepare("SELECT COUNT(*) FROM bai_viet WHERE id = ?");
                $check->execute([$id]);
                if ((int)$check->fetchColumn() === 0) {
                    throw new RuntimeException('Bài viết không tồn tại');
                }
            }

            $tepTinXoa = parse_tep_tin_ids($data['xoa_tep_tin_ids'] ?? []);
            xoa_files_bai_viet($conn, $id, $tepTinXoa);

            $files = ckc_collect_uploads(['file', 'files', 'files[]']);
            $savedFiles = empty($files)
                ? []
                : luu_files_bai_viet($conn, $id, $nguoiTaoId, $files);

            $conn->commit();
            respond('success', 'Cập nhật bài viết thành công', [
                'id' => $id,
                'bai_viet_id' => $id,
                'files' => $savedFiles,
            ]);
        }

        case 'xoa': {
            $id = (int)($data['id'] ?? 0);
            if ($id <= 0) respond('error', 'ID bài viết không hợp lệ');

            $stmt = $conn->prepare("UPDATE bai_viet
                SET trang_thai = 'an', ngay_cap_nhat = NOW()
                WHERE id = ?");
            $stmt->execute([$id]);
            respond('success', 'Xóa bài viết thành công');
        }

        default:
            http_response_code(400);
            respond('error', 'Hành động không hợp lệ');
    }
} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    respond('error', 'Lỗi server: ' . $e->getMessage());
}
?>
