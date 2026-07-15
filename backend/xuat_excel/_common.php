<?php

declare(strict_types=1);

function xuat_excel_cors_json(): void
{
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Content-Type: application/json; charset=UTF-8');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

function xuat_excel_json_input(): array
{
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    return is_array($data) ? $data : [];
}

function xuat_excel_response(string $status, string $message, mixed $data = null, int $httpCode = 200): void
{
    http_response_code($httpCode);
    $result = ['status' => $status, 'message' => $message];
    if ($data !== null) {
        $result['data'] = $data;
    }
    echo json_encode($result, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function xuat_excel_types(): array
{
    return [
        'giang_vien' => [
            'label' => 'Giảng viên',
            'title' => 'DANH SÁCH GIẢNG VIÊN',
            'description' => 'Xuất hồ sơ giảng viên theo khoa, bộ môn, trạng thái và từ khóa.',
            'filters' => ['tu_khoa', 'khoa_id', 'bo_mon_id', 'trang_thai'],
            'default_columns' => [
                'ma_giang_vien', 'ho_ten', 'email', 'ngay_sinh', 'gioi_tinh',
                'so_dien_thoai', 'ma_bo_mon', 'ten_bo_mon', 'ma_khoa', 'ten_khoa',
                'trang_thai_giang_vien', 'trang_thai_tai_khoan'
            ],
            'columns' => [
                'ma_giang_vien' => ['label' => 'Mã giảng viên', 'width' => 18],
                'ho_ten' => ['label' => 'Họ tên', 'width' => 24],
                'email' => ['label' => 'Email', 'width' => 28],
                'ngay_sinh' => ['label' => 'Ngày sinh', 'width' => 14],
                'gioi_tinh' => ['label' => 'Giới tính', 'width' => 12],
                'so_dien_thoai' => ['label' => 'Số điện thoại', 'width' => 16],
                'cccd' => ['label' => 'CCCD', 'width' => 18],
                'dia_chi' => ['label' => 'Địa chỉ', 'width' => 34],
                'ma_bo_mon' => ['label' => 'Mã bộ môn', 'width' => 16],
                'ten_bo_mon' => ['label' => 'Tên bộ môn', 'width' => 28],
                'ma_khoa' => ['label' => 'Mã khoa', 'width' => 14],
                'ten_khoa' => ['label' => 'Tên khoa', 'width' => 26],
                'trang_thai_giang_vien' => ['label' => 'Trạng thái giảng viên', 'width' => 22],
                'trang_thai_tai_khoan' => ['label' => 'Trạng thái tài khoản', 'width' => 22],
                'ngay_tao' => ['label' => 'Ngày tạo', 'width' => 20],
            ],
        ],
        'sinh_vien' => [
            'label' => 'Sinh viên',
            'title' => 'DANH SÁCH SINH VIÊN',
            'description' => 'Xuất toàn bộ sinh viên hoặc theo lớp, khoa, khóa học và trạng thái.',
            'filters' => ['tu_khoa', 'khoa_id', 'lop_id', 'khoa_hoc', 'trang_thai'],
            'default_columns' => [
                'ma_sinh_vien', 'ho_ten', 'email', 'ngay_sinh', 'gioi_tinh',
                'so_dien_thoai', 'ma_lop', 'ten_lop', 'ma_khoa', 'ten_khoa',
                'khoa_hoc', 'trang_thai_sinh_vien', 'trang_thai_tai_khoan'
            ],
            'columns' => [
                'ma_sinh_vien' => ['label' => 'Mã sinh viên', 'width' => 18],
                'ho_ten' => ['label' => 'Họ tên', 'width' => 24],
                'email' => ['label' => 'Email', 'width' => 28],
                'ngay_sinh' => ['label' => 'Ngày sinh', 'width' => 14],
                'gioi_tinh' => ['label' => 'Giới tính', 'width' => 12],
                'so_dien_thoai' => ['label' => 'Số điện thoại', 'width' => 16],
                'cccd' => ['label' => 'CCCD', 'width' => 18],
                'dia_chi' => ['label' => 'Địa chỉ', 'width' => 34],
                'ma_lop' => ['label' => 'Mã lớp', 'width' => 16],
                'ten_lop' => ['label' => 'Tên lớp', 'width' => 24],
                'ma_khoa' => ['label' => 'Mã khoa', 'width' => 14],
                'ten_khoa' => ['label' => 'Tên khoa', 'width' => 26],
                'khoa_hoc' => ['label' => 'Khóa học', 'width' => 14],
                'trang_thai_sinh_vien' => ['label' => 'Trạng thái sinh viên', 'width' => 22],
                'trang_thai_tai_khoan' => ['label' => 'Trạng thái tài khoản', 'width' => 22],
                'ngay_tao' => ['label' => 'Ngày tạo', 'width' => 20],
            ],
        ],
        'lop_hanh_chinh' => [
            'label' => 'Lớp hành chính',
            'title' => 'DANH SÁCH LỚP HÀNH CHÍNH',
            'description' => 'Xuất danh sách lớp hành chính theo khoa, năm nhập học và trạng thái.',
            'filters' => ['tu_khoa', 'khoa_id', 'nam_nhap_hoc', 'trang_thai'],
            'default_columns' => [
                'ma_lop', 'ten_lop', 'ma_khoa', 'ten_khoa', 'nam_nhap_hoc',
                'so_luong_sinh_vien', 'trang_thai', 'ngay_tao'
            ],
            'columns' => [
                'ma_lop' => ['label' => 'Mã lớp', 'width' => 18],
                'ten_lop' => ['label' => 'Tên lớp', 'width' => 26],
                'ma_khoa' => ['label' => 'Mã khoa', 'width' => 14],
                'ten_khoa' => ['label' => 'Tên khoa', 'width' => 28],
                'nam_nhap_hoc' => ['label' => 'Năm nhập học', 'width' => 16],
                'so_luong_sinh_vien' => ['label' => 'Số sinh viên', 'width' => 16],
                'trang_thai' => ['label' => 'Trạng thái', 'width' => 18],
                'ngay_tao' => ['label' => 'Ngày tạo', 'width' => 20],
            ],
        ],
        'sinh_vien_lop_hanh_chinh' => [
            'label' => 'Sinh viên lớp hành chính',
            'title' => 'DANH SÁCH SINH VIÊN LỚP HÀNH CHÍNH',
            'description' => 'Chọn một lớp hành chính và xuất danh sách sinh viên thuộc lớp.',
            'filters' => ['lop_id', 'tu_khoa', 'trang_thai'],
            'required_filters' => ['lop_id'],
            'default_columns' => [
                'ma_sinh_vien', 'ho_ten', 'email', 'ngay_sinh', 'gioi_tinh',
                'so_dien_thoai', 'trang_thai_sinh_vien', 'trang_thai_tai_khoan'
            ],
            'columns' => [
                'ma_sinh_vien' => ['label' => 'Mã sinh viên', 'width' => 18],
                'ho_ten' => ['label' => 'Họ tên', 'width' => 24],
                'email' => ['label' => 'Email', 'width' => 28],
                'ngay_sinh' => ['label' => 'Ngày sinh', 'width' => 14],
                'gioi_tinh' => ['label' => 'Giới tính', 'width' => 12],
                'so_dien_thoai' => ['label' => 'Số điện thoại', 'width' => 16],
                'cccd' => ['label' => 'CCCD', 'width' => 18],
                'dia_chi' => ['label' => 'Địa chỉ', 'width' => 34],
                'trang_thai_sinh_vien' => ['label' => 'Trạng thái sinh viên', 'width' => 22],
                'trang_thai_tai_khoan' => ['label' => 'Trạng thái tài khoản', 'width' => 22],
                'ngay_tao' => ['label' => 'Ngày tạo', 'width' => 20],
            ],
        ],
        'lop_hoc_phan' => [
            'label' => 'Lớp học phần',
            'title' => 'DANH SÁCH LỚP HỌC PHẦN',
            'description' => 'Xuất lớp học phần theo môn, giảng viên, năm học, học kỳ và trạng thái.',
            'filters' => ['tu_khoa', 'mon_hoc_id', 'giang_vien_id', 'khoa_id', 'nam_hoc', 'hoc_ky', 'trang_thai'],
            'default_columns' => [
                'ma_lop_hoc_phan', 'ten_lop_hoc_phan', 'ma_mon', 'ten_mon',
                'ma_giang_vien', 'ten_giang_vien', 'ma_khoa', 'ten_khoa',
                'nam_hoc', 'hoc_ky', 'si_so_hien_tai', 'si_so_toi_da', 'trang_thai'
            ],
            'columns' => [
                'ma_lop_hoc_phan' => ['label' => 'Mã lớp học phần', 'width' => 30],
                'ten_lop_hoc_phan' => ['label' => 'Tên lớp học phần', 'width' => 34],
                'ma_mon' => ['label' => 'Mã môn học', 'width' => 16],
                'ten_mon' => ['label' => 'Tên môn học', 'width' => 28],
                'ma_giang_vien' => ['label' => 'Mã giảng viên', 'width' => 18],
                'ten_giang_vien' => ['label' => 'Giảng viên phụ trách', 'width' => 26],
                'ma_khoa' => ['label' => 'Mã khoa', 'width' => 14],
                'ten_khoa' => ['label' => 'Tên khoa', 'width' => 26],
                'hoc_ky' => ['label' => 'Học kỳ', 'width' => 12],
                'nam_hoc' => ['label' => 'Năm học', 'width' => 14],
                'si_so_hien_tai' => ['label' => 'Sĩ số hiện tại', 'width' => 16],
                'si_so_toi_da' => ['label' => 'Sĩ số tối đa', 'width' => 14],
                'trang_thai' => ['label' => 'Trạng thái', 'width' => 18],
                'ngay_tao' => ['label' => 'Ngày tạo', 'width' => 20],
            ],
        ],
        'sinh_vien_lop_hoc_phan' => [
            'label' => 'Sinh viên lớp học phần',
            'title' => 'DANH SÁCH SINH VIÊN LỚP HỌC PHẦN',
            'description' => 'Chọn một lớp học phần và xuất danh sách sinh viên đã đăng ký.',
            'filters' => ['lop_hoc_phan_id', 'tu_khoa', 'trang_thai'],
            'required_filters' => ['lop_hoc_phan_id'],
            'default_columns' => [
                'ma_sinh_vien', 'ho_ten', 'email', 'ma_lop', 'ten_lop',
                'ma_khoa', 'ten_khoa', 'khoa_hoc', 'trang_thai_lop_hoc_phan', 'ngay_dang_ky'
            ],
            'columns' => [
                'ma_sinh_vien' => ['label' => 'Mã sinh viên', 'width' => 18],
                'ho_ten' => ['label' => 'Họ tên', 'width' => 24],
                'email' => ['label' => 'Email', 'width' => 28],
                'ma_lop' => ['label' => 'Mã lớp hành chính', 'width' => 20],
                'ten_lop' => ['label' => 'Tên lớp hành chính', 'width' => 26],
                'ma_khoa' => ['label' => 'Mã khoa', 'width' => 14],
                'ten_khoa' => ['label' => 'Tên khoa', 'width' => 26],
                'khoa_hoc' => ['label' => 'Khóa học', 'width' => 14],
                'trang_thai_lop_hoc_phan' => ['label' => 'Trạng thái trong lớp học phần', 'width' => 28],
                'ngay_dang_ky' => ['label' => 'Ngày đăng ký', 'width' => 20],
            ],
        ],
    ];
}

function xuat_excel_validate_request(array $data): array
{
    $types = xuat_excel_types();
    $type = trim((string)($data['loai_xuat'] ?? ''));
    if (!isset($types[$type])) {
        throw new InvalidArgumentException('Loại dữ liệu xuất không hợp lệ');
    }

    $scope = trim((string)($data['pham_vi'] ?? 'theo_bo_loc'));
    if (!in_array($scope, ['toan_bo', 'theo_bo_loc', 'da_chon'], true)) {
        throw new InvalidArgumentException('Phạm vi xuất không hợp lệ');
    }

    $filters = is_array($data['bo_loc'] ?? null) ? $data['bo_loc'] : [];
    $selectedIds = array_values(array_unique(array_filter(array_map('intval', (array)($data['selected_ids'] ?? [])), fn($id) => $id > 0)));

    if ($scope === 'da_chon' && count($selectedIds) === 0) {
        throw new InvalidArgumentException('Chưa chọn dữ liệu để xuất');
    }

    foreach (($types[$type]['required_filters'] ?? []) as $key) {
        if ((int)($filters[$key] ?? 0) <= 0) {
            throw new InvalidArgumentException('Vui lòng chọn đối tượng bắt buộc trước khi xuất');
        }
    }

    $availableColumns = array_keys($types[$type]['columns']);
    $columns = array_values(array_unique(array_filter(
        array_map('strval', (array)($data['cot_xuat'] ?? [])),
        fn($column) => in_array($column, $availableColumns, true)
    )));

    if (count($columns) === 0) {
        $columns = $types[$type]['default_columns'];
    }

    return [$type, $types[$type], $scope, $filters, $selectedIds, $columns];
}

function xuat_excel_add_like(array &$where, array &$params, string $value, array $expressions, string $prefix): void
{
    $value = trim($value);
    if ($value === '') return;

    $parts = [];
    foreach ($expressions as $index => $expression) {
        $key = ':' . $prefix . '_' . $index;
        $parts[] = $expression . ' LIKE ' . $key;
        $params[$key] = '%' . $value . '%';
    }
    $where[] = '(' . implode(' OR ', $parts) . ')';
}

function xuat_excel_add_int_filter(array &$where, array &$params, mixed $value, string $expression, string $key): void
{
    $number = (int)$value;
    if ($number <= 0) return;
    $placeholder = ':' . $key;
    $where[] = $expression . ' = ' . $placeholder;
    $params[$placeholder] = $number;
}

function xuat_excel_add_string_filter(array &$where, array &$params, mixed $value, string $expression, string $key): void
{
    $text = trim((string)$value);
    if ($text === '') return;
    $placeholder = ':' . $key;
    $where[] = $expression . ' = ' . $placeholder;
    $params[$placeholder] = $text;
}

function xuat_excel_add_selected_ids(array &$where, array &$params, array $selectedIds, string $expression): void
{
    if (count($selectedIds) === 0) return;
    $holders = [];
    foreach ($selectedIds as $index => $id) {
        $key = ':selected_' . $index;
        $holders[] = $key;
        $params[$key] = $id;
    }
    $where[] = $expression . ' IN (' . implode(',', $holders) . ')';
}

function xuat_excel_query_parts(string $type, string $scope, array $filters, array $selectedIds): array
{
    $where = ['1 = 1'];
    $params = [];
    $select = '';
    $from = '';
    $order = '';
    $idExpression = '';

    switch ($type) {
        case 'giang_vien':
            $select = "gv.id, gv.ma_giang_vien, nd.ho_ten, nd.email, gv.ngay_sinh,
                gv.gioi_tinh, gv.so_dien_thoai, gv.cccd, gv.dia_chi,
                bm.ma_bo_mon, bm.ten_bo_mon, k.ma_khoa, k.ten_khoa,
                gv.trang_thai AS trang_thai_giang_vien,
                nd.trang_thai AS trang_thai_tai_khoan, gv.ngay_tao";
            $from = "FROM giang_vien gv
                INNER JOIN nguoi_dung nd ON nd.id = gv.nguoi_dung_id
                LEFT JOIN bo_mon bm ON bm.id = gv.bo_mon_id
                LEFT JOIN khoa k ON k.id = bm.khoa_id";
            $idExpression = 'gv.id';
            $order = 'ORDER BY gv.ma_giang_vien ASC';
            if ($scope !== 'toan_bo') {
                xuat_excel_add_like($where, $params, (string)($filters['tu_khoa'] ?? ''), ['gv.ma_giang_vien', 'nd.ho_ten', 'nd.email', 'bm.ten_bo_mon', 'k.ten_khoa'], 'gv_keyword');
                xuat_excel_add_int_filter($where, $params, $filters['khoa_id'] ?? 0, 'k.id', 'gv_khoa_id');
                xuat_excel_add_int_filter($where, $params, $filters['bo_mon_id'] ?? 0, 'bm.id', 'gv_bo_mon_id');
                xuat_excel_add_string_filter($where, $params, $filters['trang_thai'] ?? '', 'gv.trang_thai', 'gv_trang_thai');
            }
            break;

        case 'sinh_vien':
        case 'sinh_vien_lop_hanh_chinh':
            $select = "sv.id, sv.ma_sinh_vien, nd.ho_ten, nd.email, sv.ngay_sinh,
                sv.gioi_tinh, sv.so_dien_thoai, sv.cccd, sv.dia_chi,
                l.ma_lop, l.ten_lop, k.ma_khoa, k.ten_khoa,
                sv.khoa_hoc AS khoa_hoc,
                sv.trang_thai AS trang_thai_sinh_vien,
                nd.trang_thai AS trang_thai_tai_khoan, sv.ngay_tao";
            $from = "FROM sinh_vien sv
                INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                INNER JOIN lop l ON l.id = sv.lop_id
                INNER JOIN khoa k ON k.id = sv.khoa_id";
            $idExpression = 'sv.id';
            $order = 'ORDER BY sv.ma_sinh_vien ASC';

            if ($type === 'sinh_vien_lop_hanh_chinh') {
                xuat_excel_add_int_filter($where, $params, $filters['lop_id'] ?? 0, 'sv.lop_id', 'sv_lop_bat_buoc');
            }
            if ($scope !== 'toan_bo') {
                xuat_excel_add_like($where, $params, (string)($filters['tu_khoa'] ?? ''), ['sv.ma_sinh_vien', 'nd.ho_ten', 'nd.email', 'l.ma_lop', 'l.ten_lop'], 'sv_keyword');
                if ($type === 'sinh_vien') {
                    xuat_excel_add_int_filter($where, $params, $filters['khoa_id'] ?? 0, 'sv.khoa_id', 'sv_khoa_id');
                    xuat_excel_add_int_filter($where, $params, $filters['lop_id'] ?? 0, 'sv.lop_id', 'sv_lop_id');
                    xuat_excel_add_string_filter($where, $params, $filters['khoa_hoc'] ?? '', 'sv.khoa_hoc', 'sv_khoa_hoc');
                }
                xuat_excel_add_string_filter($where, $params, $filters['trang_thai'] ?? '', 'sv.trang_thai', 'sv_trang_thai');
            }
            break;

        case 'lop_hanh_chinh':
            $select = "l.id, l.ma_lop, l.ten_lop, k.ma_khoa, k.ten_khoa, l.nam_nhap_hoc,
                (SELECT COUNT(*) FROM sinh_vien sv WHERE sv.lop_id = l.id) AS so_luong_sinh_vien,
                l.trang_thai, l.ngay_tao";
            $from = "FROM lop l INNER JOIN khoa k ON k.id = l.khoa_id";
            $idExpression = 'l.id';
            $order = 'ORDER BY l.ma_lop ASC';
            if ($scope !== 'toan_bo') {
                xuat_excel_add_like($where, $params, (string)($filters['tu_khoa'] ?? ''), ['l.ma_lop', 'l.ten_lop', 'k.ma_khoa', 'k.ten_khoa'], 'lop_keyword');
                xuat_excel_add_int_filter($where, $params, $filters['khoa_id'] ?? 0, 'l.khoa_id', 'lop_khoa_id');
                xuat_excel_add_int_filter($where, $params, $filters['nam_nhap_hoc'] ?? 0, 'l.nam_nhap_hoc', 'lop_nam_nhap_hoc');
                xuat_excel_add_string_filter($where, $params, $filters['trang_thai'] ?? '', 'l.trang_thai', 'lop_trang_thai');
            }
            break;

        case 'lop_hoc_phan':
            $select = "lhp.id, lhp.ma_lop_hoc_phan, lhp.ten_lop AS ten_lop_hoc_phan,
                mh.ma_mon, mh.ten_mon, gv.ma_giang_vien, nd.ho_ten AS ten_giang_vien,
                k.ma_khoa, k.ten_khoa, lhp.hoc_ky, lhp.nam_hoc,
                (SELECT COUNT(*) FROM sinh_vien_lop_hoc_phan svlhp
                    WHERE svlhp.lop_hoc_phan_id = lhp.id AND svlhp.trang_thai = 'dang_hoc') AS si_so_hien_tai,
                lhp.si_so_toi_da, lhp.trang_thai, lhp.ngay_tao";
            $from = "FROM lop_hoc_phan lhp
                LEFT JOIN mon_hoc mh ON mh.id = lhp.mon_hoc_id
                LEFT JOIN giang_vien gv ON gv.id = lhp.giang_vien_id
                LEFT JOIN nguoi_dung nd ON nd.id = gv.nguoi_dung_id
                LEFT JOIN bo_mon bm ON bm.id = mh.bo_mon_id
                LEFT JOIN khoa k ON k.id = mh.khoa_id";
            $idExpression = 'lhp.id';
            $order = 'ORDER BY lhp.id DESC';
            if ($scope !== 'toan_bo') {
                xuat_excel_add_like($where, $params, (string)($filters['tu_khoa'] ?? ''), ['lhp.ma_lop_hoc_phan', 'lhp.ten_lop', 'mh.ma_mon', 'mh.ten_mon', 'gv.ma_giang_vien', 'nd.ho_ten'], 'lhp_keyword');
                xuat_excel_add_int_filter($where, $params, $filters['mon_hoc_id'] ?? 0, 'lhp.mon_hoc_id', 'lhp_mon_hoc_id');
                xuat_excel_add_int_filter($where, $params, $filters['giang_vien_id'] ?? 0, 'lhp.giang_vien_id', 'lhp_giang_vien_id');
                xuat_excel_add_int_filter($where, $params, $filters['khoa_id'] ?? 0, 'mh.khoa_id', 'lhp_khoa_id');
                xuat_excel_add_string_filter($where, $params, $filters['nam_hoc'] ?? '', 'lhp.nam_hoc', 'lhp_nam_hoc');
                xuat_excel_add_string_filter($where, $params, $filters['hoc_ky'] ?? '', 'lhp.hoc_ky', 'lhp_hoc_ky');
                xuat_excel_add_string_filter($where, $params, $filters['trang_thai'] ?? '', 'lhp.trang_thai', 'lhp_trang_thai');
            }
            break;

        case 'sinh_vien_lop_hoc_phan':
            $select = "svlhp.id, sv.ma_sinh_vien, nd.ho_ten, nd.email,
                l.ma_lop, l.ten_lop, k.ma_khoa, k.ten_khoa,
                sv.khoa_hoc AS khoa_hoc,
                svlhp.trang_thai AS trang_thai_lop_hoc_phan, svlhp.ngay_dang_ky";
            $from = "FROM sinh_vien_lop_hoc_phan svlhp
                INNER JOIN sinh_vien sv ON sv.id = svlhp.sinh_vien_id
                INNER JOIN nguoi_dung nd ON nd.id = sv.nguoi_dung_id
                INNER JOIN lop l ON l.id = sv.lop_id
                INNER JOIN khoa k ON k.id = sv.khoa_id";
            $idExpression = 'svlhp.id';
            $order = 'ORDER BY sv.ma_sinh_vien ASC';
            xuat_excel_add_int_filter($where, $params, $filters['lop_hoc_phan_id'] ?? 0, 'svlhp.lop_hoc_phan_id', 'svlhp_bat_buoc');
            if ($scope !== 'toan_bo') {
                xuat_excel_add_like($where, $params, (string)($filters['tu_khoa'] ?? ''), ['sv.ma_sinh_vien', 'nd.ho_ten', 'nd.email', 'l.ma_lop', 'l.ten_lop'], 'svlhp_keyword');
                xuat_excel_add_string_filter($where, $params, $filters['trang_thai'] ?? '', 'svlhp.trang_thai', 'svlhp_trang_thai');
            }
            break;

        default:
            throw new InvalidArgumentException('Loại dữ liệu xuất không được hỗ trợ');
    }

    if ($scope === 'da_chon') {
        xuat_excel_add_selected_ids($where, $params, $selectedIds, $idExpression);
    }

    return [
        'select' => $select,
        'from_where' => $from . ' WHERE ' . implode(' AND ', $where),
        'order' => $order,
        'params' => $params,
    ];
}

function xuat_excel_bind_and_execute(PDOStatement $stmt, array $params): void
{
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->execute();
}

function xuat_excel_count(PDO $conn, array $parts): int
{
    $stmt = $conn->prepare('SELECT COUNT(*) ' . $parts['from_where']);
    xuat_excel_bind_and_execute($stmt, $parts['params']);
    return (int)$stmt->fetchColumn();
}

function xuat_excel_fetch(PDO $conn, array $parts, ?int $limit = null): array
{
    $sql = 'SELECT ' . $parts['select'] . ' ' . $parts['from_where'] . ' ' . $parts['order'];
    if ($limit !== null) {
        $sql .= ' LIMIT ' . max(1, $limit);
    }
    $stmt = $conn->prepare($sql);
    xuat_excel_bind_and_execute($stmt, $parts['params']);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function xuat_excel_format_value(string $key, mixed $value): mixed
{
    if ($value === null) return '';

    $maps = [
        'gioi_tinh' => ['nam' => 'Nam', 'nu' => 'Nữ', 'khac' => 'Khác'],
        'trang_thai_giang_vien' => ['dang_day' => 'Đang dạy', 'ngung_day' => 'Ngừng dạy'],
        'trang_thai_sinh_vien' => ['dang_hoc' => 'Đang học', 'tam_nghi' => 'Tạm nghỉ', 'da_tot_nghiep' => 'Đã tốt nghiệp'],
        'trang_thai_tai_khoan' => ['dang_hoat_dong' => 'Đang hoạt động', 'bi_khoa' => 'Bị khóa'],
        'trang_thai_lop_hoc_phan' => ['dang_hoc' => 'Đang học', 'da_huy' => 'Đã hủy', 'hoan_thanh' => 'Hoàn thành'],
        'trang_thai' => [
            'dang_hoc' => 'Đang học', 'da_tot_nghiep' => 'Đã tốt nghiệp', 'tam_khoa' => 'Tạm khóa',
            'dang_mo' => 'Đang mở', 'da_khoa' => 'Đã khóa', 'da_ket_thuc' => 'Đã kết thúc'
        ],
    ];

    if (isset($maps[$key][(string)$value])) {
        return $maps[$key][(string)$value];
    }

    if (in_array($key, ['ngay_sinh'], true) && $value !== '') {
        $time = strtotime((string)$value);
        return $time ? date('d/m/Y', $time) : (string)$value;
    }

    if (in_array($key, ['ngay_tao', 'ngay_dang_ky'], true) && $value !== '') {
        $time = strtotime((string)$value);
        return $time ? date('d/m/Y H:i', $time) : (string)$value;
    }

    if (in_array($key, ['so_luong_sinh_vien', 'si_so_hien_tai', 'si_so_toi_da'], true)) {
        return (int)$value;
    }

    return (string)$value;
}

function xuat_excel_project_rows(array $rows, array $columns): array
{
    $result = [];
    $stt = 1;
    foreach ($rows as $row) {
        $item = [$stt++];
        foreach ($columns as $column) {
            $item[] = xuat_excel_format_value($column, $row[$column] ?? '');
        }
        $result[] = $item;
    }
    return $result;
}

function xuat_excel_metadata(PDO $conn, string $type, array $filters, string $scope, int $count): array
{
    $metadata = [
        'Loại dữ liệu' => xuat_excel_types()[$type]['label'],
        'Phạm vi xuất' => match ($scope) {
            'toan_bo' => 'Toàn bộ dữ liệu',
            'da_chon' => 'Các bản ghi đã chọn',
            default => 'Theo bộ lọc hiện tại',
        },
        'Số bản ghi' => (string)$count,
        'Ngày xuất' => date('d/m/Y H:i'),
    ];

    if ($type === 'sinh_vien_lop_hanh_chinh' && (int)($filters['lop_id'] ?? 0) > 0) {
        $stmt = $conn->prepare("SELECT l.ma_lop, l.ten_lop, l.nam_nhap_hoc, k.ma_khoa, k.ten_khoa
            FROM lop l INNER JOIN khoa k ON k.id = l.khoa_id WHERE l.id = :id LIMIT 1");
        $stmt->execute([':id' => (int)$filters['lop_id']]);
        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $metadata['Lớp hành chính'] = $row['ma_lop'] . ' - ' . $row['ten_lop'];
            $metadata['Khoa'] = $row['ma_khoa'] . ' - ' . $row['ten_khoa'];
            $metadata['Năm nhập học'] = (string)$row['nam_nhap_hoc'];
        }
    }

    if ($type === 'sinh_vien_lop_hoc_phan' && (int)($filters['lop_hoc_phan_id'] ?? 0) > 0) {
        $stmt = $conn->prepare("SELECT lhp.ma_lop_hoc_phan, lhp.ten_lop, lhp.nam_hoc, lhp.hoc_ky,
                mh.ma_mon, mh.ten_mon, gv.ma_giang_vien, nd.ho_ten AS ten_giang_vien
            FROM lop_hoc_phan lhp
            LEFT JOIN mon_hoc mh ON mh.id = lhp.mon_hoc_id
            LEFT JOIN giang_vien gv ON gv.id = lhp.giang_vien_id
            LEFT JOIN nguoi_dung nd ON nd.id = gv.nguoi_dung_id
            WHERE lhp.id = :id LIMIT 1");
        $stmt->execute([':id' => (int)$filters['lop_hoc_phan_id']]);
        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $metadata['Lớp học phần'] = $row['ma_lop_hoc_phan'] . ' - ' . $row['ten_lop'];
            $metadata['Môn học'] = trim(($row['ma_mon'] ?? '') . ' - ' . ($row['ten_mon'] ?? ''), ' -');
            $metadata['Giảng viên'] = trim(($row['ma_giang_vien'] ?? '') . ' - ' . ($row['ten_giang_vien'] ?? ''), ' -');
            $metadata['Năm học / Học kỳ'] = trim(($row['nam_hoc'] ?? '') . ' / ' . ($row['hoc_ky'] ?? ''), ' /');
        }
    }

    return $metadata;
}

function xuat_excel_safe_filename(string $text): string
{
    $text = function_exists('mb_strtolower') ? mb_strtolower(trim($text), 'UTF-8') : strtolower(trim($text));
    $replacements = [
        'à'=>'a','á'=>'a','ạ'=>'a','ả'=>'a','ã'=>'a','â'=>'a','ầ'=>'a','ấ'=>'a','ậ'=>'a','ẩ'=>'a','ẫ'=>'a','ă'=>'a','ằ'=>'a','ắ'=>'a','ặ'=>'a','ẳ'=>'a','ẵ'=>'a',
        'è'=>'e','é'=>'e','ẹ'=>'e','ẻ'=>'e','ẽ'=>'e','ê'=>'e','ề'=>'e','ế'=>'e','ệ'=>'e','ể'=>'e','ễ'=>'e',
        'ì'=>'i','í'=>'i','ị'=>'i','ỉ'=>'i','ĩ'=>'i','ò'=>'o','ó'=>'o','ọ'=>'o','ỏ'=>'o','õ'=>'o','ô'=>'o','ồ'=>'o','ố'=>'o','ộ'=>'o','ổ'=>'o','ỗ'=>'o','ơ'=>'o','ờ'=>'o','ớ'=>'o','ợ'=>'o','ở'=>'o','ỡ'=>'o',
        'ù'=>'u','ú'=>'u','ụ'=>'u','ủ'=>'u','ũ'=>'u','ư'=>'u','ừ'=>'u','ứ'=>'u','ự'=>'u','ử'=>'u','ữ'=>'u','ỳ'=>'y','ý'=>'y','ỵ'=>'y','ỷ'=>'y','ỹ'=>'y','đ'=>'d'
    ];
    $text = strtr($text, $replacements);
    $text = preg_replace('/[^a-z0-9]+/', '_', $text) ?: 'du_lieu';
    return trim($text, '_');
}

function xuat_excel_cleanup(string $directory, int $maxAgeSeconds = 86400): void
{
    if (!is_dir($directory)) return;
    $now = time();
    foreach (glob($directory . '/*.xlsx') ?: [] as $file) {
        if (is_file($file) && $now - filemtime($file) > $maxAgeSeconds) {
            @unlink($file);
        }
    }
}
