<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../ket_noi.php';
require_once __DIR__ . '/_nhap_excel_helper.php';

function ckc_history_date($value): ?string {
    $raw = ckc_clean($value);
    if ($raw === '') return null;

    $date = DateTime::createFromFormat('!Y-m-d', $raw);
    $errors = DateTime::getLastErrors();
    if (!$date) return null;
    if (is_array($errors)
        && (($errors['warning_count'] ?? 0) > 0 || ($errors['error_count'] ?? 0) > 0)) {
        return null;
    }

    return $date->format('Y-m-d');
}

try {
    $input = ckc_json_input();
    if (empty($input)) {
        $input = array_merge($_GET, $_POST);
    }

    $tuKhoa = ckc_clean($input['tu_khoa'] ?? '');
    $loaiNhap = ckc_clean($input['loai_nhap'] ?? '');
    $tuNgayRaw = ckc_clean($input['tu_ngay'] ?? '');
    $denNgayRaw = ckc_clean($input['den_ngay'] ?? '');
    $page = max(1, (int)($input['page'] ?? 1));
    $limit = (int)($input['limit'] ?? 20);
    $limit = max(5, min(100, $limit));

    if ($loaiNhap !== '' && preg_match('/^[a-z0-9_]+$/', $loaiNhap) !== 1) {
        ckc_json_response('error', 'Loại nhập không hợp lệ', null, 400);
    }

    $tuNgay = ckc_history_date($tuNgayRaw);
    $denNgay = ckc_history_date($denNgayRaw);

    if ($tuNgayRaw !== '' && $tuNgay === null) {
        ckc_json_response('error', 'Từ ngày không hợp lệ. Định dạng đúng: YYYY-MM-DD', null, 400);
    }

    if ($denNgayRaw !== '' && $denNgay === null) {
        ckc_json_response('error', 'Đến ngày không hợp lệ. Định dạng đúng: YYYY-MM-DD', null, 400);
    }

    if ($tuNgay !== null && $denNgay !== null && $tuNgay > $denNgay) {
        ckc_json_response('error', 'Từ ngày không được lớn hơn đến ngày', null, 400);
    }

    // Lịch sử chỉ hiển thị các đợt đã nhập thật thành công.
    $conditions = ["d.trang_thai = 'da_nhap'"];
    $params = [];

    if ($tuKhoa !== '') {
        $conditions[] = 'd.ten_file LIKE :tu_khoa';
        $params[':tu_khoa'] = '%' . $tuKhoa . '%';
    }

    if ($loaiNhap !== '') {
        $conditions[] = 'd.loai_nhap = :loai_nhap';
        $params[':loai_nhap'] = $loaiNhap;
    }

    if ($tuNgay !== null) {
        $conditions[] = 'd.ngay_tao >= :tu_ngay';
        $params[':tu_ngay'] = $tuNgay . ' 00:00:00';
    }

    if ($denNgay !== null) {
        $conditions[] = 'd.ngay_tao <= :den_ngay';
        $params[':den_ngay'] = $denNgay . ' 23:59:59';
    }

    $where = empty($conditions) ? '' : ' WHERE ' . implode(' AND ', $conditions);

    $countSql = 'SELECT COUNT(*) FROM nhap_excel_dot d' . $where;
    $countStmt = $conn->prepare($countSql);
    foreach ($params as $key => $value) {
        $countStmt->bindValue($key, $value);
    }
    $countStmt->execute();
    $total = (int)$countStmt->fetchColumn();

    $totalPages = max(1, (int)ceil($total / $limit));
    if ($page > $totalPages) $page = $totalPages;
    $offset = ($page - 1) * $limit;

    $sql = "SELECT
                d.id,
                d.loai_nhap,
                d.ten_file,
                d.nguoi_nhap_id,
                nd.ho_ten AS ten_nguoi_nhap,
                d.tong_dong,
                d.so_hop_le,
                d.so_loi,
                d.so_canh_bao,
                d.trang_thai,
                d.ngay_tao,
                d.ngay_cap_nhat
            FROM nhap_excel_dot d
            LEFT JOIN nguoi_dung nd ON nd.id = d.nguoi_nhap_id
            {$where}
            ORDER BY d.ngay_tao DESC, d.id DESC
            LIMIT :limit OFFSET :offset";

    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();

    ckc_json_response('success', 'Lấy lịch sử nhập Excel thành công', [
        'items' => $stmt->fetchAll(PDO::FETCH_ASSOC),
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'total_pages' => $totalPages,
        ],
        'filters' => [
            'tu_khoa' => $tuKhoa,
            'loai_nhap' => $loaiNhap,
            'tu_ngay' => $tuNgay,
            'den_ngay' => $denNgay,
        ],
    ]);
} catch (Throwable $e) {
    ckc_json_response(
        'error',
        'Lỗi lấy lịch sử nhập Excel',
        ['detail' => $e->getMessage()],
        500
    );
}
