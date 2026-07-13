<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit();
}

require_once __DIR__ . '/../ket_noi.php';
require_once __DIR__ . '/_nhap_excel_helper.php';

$data = ckc_json_input();
$loai = ckc_clean($data['loai_nhap'] ?? '');
$rows = $data['rows'] ?? [];
$target = is_array($data['doi_tuong_dich'] ?? null)
    ? $data['doi_tuong_dich']
    : [];

$configs = ckc_loai_nhap_configs();

if (!isset($configs[$loai])) {
    ckc_json_response('error', 'Loại nhập Excel không hợp lệ', null, 400);
}

if (!is_array($rows) || count($rows) === 0) {
    ckc_json_response(
        'error',
        'File Excel chưa có dữ liệu để kiểm tra',
        null,
        400
    );
}

try {
    $ketQua = [];
    $seen = [];
    $tong = 0;
    $hopLe = 0;
    $loi = 0;
    $canhBao = 0;

    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }

        $line = (int)($row['_dong_excel'] ?? ($tong + 4));
        unset($row['_dong_excel']);

        $res = ckc_validate_row(
            $conn,
            $loai,
            $line,
            $row,
            $seen,
            $target
        );

        $ketQua[] = $res;
        $tong++;

        if ($res['trang_thai'] === 'loi') {
            $loi++;
        } elseif ($res['trang_thai'] === 'canh_bao') {
            $canhBao++;
        } else {
            $hopLe++;
        }
    }

    /*
     * Không tạo nhap_excel_dot và nhap_excel_dong ở bước kiểm tra.
     * Kết quả chỉ được trả về Flutter để xem trước.
     * Chỉ khi người dùng xác nhận nhập thật thì backend mới ghi lịch sử.
     */
    ckc_json_response('success', 'Kiểm tra dữ liệu Excel thành công', [
        'dot_nhap_id' => 0,
        'tong_dong' => $tong,
        'so_hop_le' => $hopLe,
        'so_loi' => $loi,
        'so_canh_bao' => $canhBao,
        'co_the_xac_nhan' => $loi === 0 && $tong > 0,
        'ket_qua_dong' => $ketQua,
    ]);
} catch (Throwable $e) {
    ckc_json_response(
        'error',
        'Lỗi kiểm tra Excel: ' . $e->getMessage(),
        null,
        500
    );
}
