<?php
function ckc_json_input(): array {
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') return [];
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function ckc_json_response(string $status, string $message, $data = null, int $code = 200): void {
    http_response_code($code);
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode(
        ['status' => $status, 'message' => $message, 'data' => $data],
        JSON_UNESCAPED_UNICODE
    );
    exit();
}

function ckc_clean($value): string {
    if ($value === null) return '';
    $text = trim((string)$value);
    $text = preg_replace('/\s+/u', ' ', $text);
    return $text ?? '';
}

function ckc_upper($value): string {
    return mb_strtoupper(ckc_clean($value), 'UTF-8');
}

function ckc_lower($value): string {
    return mb_strtolower(ckc_clean($value), 'UTF-8');
}

function ckc_len(string $value): int {
    return mb_strlen($value, 'UTF-8');
}

function ckc_email_ok(string $email): bool {
    return $email !== '' && filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function ckc_code_ok(string $value): bool {
    if ($value === '') return false;
    return preg_match('/^[\p{L}\p{N}._\-\/ ]+$/u', $value) === 1;
}

function ckc_phone_normalize($value): string {
    $raw = ckc_clean($value);
    if ($raw === '') return '';
    $prefix = str_starts_with($raw, '+') ? '+' : '';
    $digits = preg_replace('/\D+/', '', $raw);
    return $prefix . ($digits ?? '');
}

function ckc_phone_ok(string $value): bool {
    if ($value === '') return true;
    return preg_match('/^\+?\d{9,15}$/', $value) === 1;
}

function ckc_cccd_normalize($value): string {
    return preg_replace('/\D+/', '', ckc_clean($value)) ?? '';
}

function ckc_cccd_ok(string $value): bool {
    if ($value === '') return true;
    return preg_match('/^\d{12}$/', $value) === 1;
}

function ckc_one(PDO $conn, string $sql, array $params = []) {
    $stmt = $conn->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function ckc_column_exists(PDO $conn, string $table, string $column): bool {
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)
        || !preg_match('/^[a-zA-Z0-9_]+$/', $column)) {
        return false;
    }

    $stmt = $conn->prepare(
        "SELECT COUNT(*)
         FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE()
           AND TABLE_NAME = :table_name
           AND COLUMN_NAME = :column_name"
    );
    $stmt->execute([
        ':table_name' => $table,
        ':column_name' => $column,
    ]);

    return (int)$stmt->fetchColumn() > 0;
}

function ckc_role_id(PDO $conn, string $roleName): int {
    $row = ckc_one(
        $conn,
        'SELECT id FROM vai_tro WHERE ten_vai_tro = :role LIMIT 1',
        [':role' => $roleName]
    );
    return $row ? (int)$row['id'] : 0;
}

function ckc_map_value($value, array $map, string $default = ''): string {
    $normalized = ckc_lower($value);
    if ($normalized === '') return $default;
    return $map[$normalized] ?? ckc_clean($value);
}

function ckc_status_khoa($value): string {
    return ckc_map_value($value, [
        'đang hoạt động' => 'dang_hoat_dong',
        'dang hoat dong' => 'dang_hoat_dong',
        'dang_hoat_dong' => 'dang_hoat_dong',
        'ngừng hoạt động' => 'ngung_hoat_dong',
        'ngung hoat dong' => 'ngung_hoat_dong',
        'ngung_hoat_dong' => 'ngung_hoat_dong',
    ], 'dang_hoat_dong');
}

function ckc_status_lop($value): string {
    return ckc_map_value($value, [
        'đang học' => 'dang_hoc',
        'dang hoc' => 'dang_hoc',
        'dang_hoc' => 'dang_hoc',
        'đã tốt nghiệp' => 'da_tot_nghiep',
        'da tot nghiep' => 'da_tot_nghiep',
        'da_tot_nghiep' => 'da_tot_nghiep',
        'tạm khóa' => 'tam_khoa',
        'tam khoa' => 'tam_khoa',
        'tam_khoa' => 'tam_khoa',
    ], 'dang_hoc');
}

function ckc_status_sv($value): string {
    return ckc_map_value($value, [
        'đang học' => 'dang_hoc',
        'dang hoc' => 'dang_hoc',
        'dang_hoc' => 'dang_hoc',
        'tạm nghỉ' => 'tam_nghi',
        'tam nghi' => 'tam_nghi',
        'tam_nghi' => 'tam_nghi',
        'đã tốt nghiệp' => 'da_tot_nghiep',
        'da tot nghiep' => 'da_tot_nghiep',
        'da_tot_nghiep' => 'da_tot_nghiep',
    ], 'dang_hoc');
}

function ckc_status_gv($value): string {
    return ckc_map_value($value, [
        'đang dạy' => 'dang_day',
        'dang day' => 'dang_day',
        'dang_day' => 'dang_day',
        'ngừng dạy' => 'ngung_day',
        'ngung day' => 'ngung_day',
        'ngung_day' => 'ngung_day',
    ], 'dang_day');
}

function ckc_status_tk($value): string {
    return ckc_map_value($value, [
        'đang hoạt động' => 'dang_hoat_dong',
        'dang hoat dong' => 'dang_hoat_dong',
        'dang_hoat_dong' => 'dang_hoat_dong',
        'bị khóa' => 'bi_khoa',
        'bi khoa' => 'bi_khoa',
        'bi_khoa' => 'bi_khoa',
    ], 'dang_hoat_dong');
}

function ckc_status_mon($value): string {
    return ckc_map_value($value, [
        'đang mở' => 'dang_mo',
        'dang mo' => 'dang_mo',
        'dang_mo' => 'dang_mo',
        'ngừng sử dụng' => 'ngung_su_dung',
        'ngung su dung' => 'ngung_su_dung',
        'ngung_su_dung' => 'ngung_su_dung',
    ], 'dang_mo');
}

function ckc_status_lhp($value): string {
    return ckc_map_value($value, [
        'đang mở' => 'dang_mo',
        'dang mo' => 'dang_mo',
        'dang_mo' => 'dang_mo',
        'đã khóa' => 'da_khoa',
        'da khoa' => 'da_khoa',
        'da_khoa' => 'da_khoa',
        'đã kết thúc' => 'da_ket_thuc',
        'da ket thuc' => 'da_ket_thuc',
        'da_ket_thuc' => 'da_ket_thuc',
    ], 'dang_mo');
}

function ckc_gioi_tinh($value): ?string {
    $mapped = ckc_map_value($value, [
        'nam' => 'nam',
        'nữ' => 'nu',
        'nu' => 'nu',
        'khác' => 'khac',
        'khac' => 'khac',
    ], '');
    return $mapped === '' ? null : $mapped;
}

function ckc_date($value): ?string {
    $raw = ckc_clean($value);
    if ($raw === '') return null;

    $date = null;
    if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $raw)) {
        $date = DateTime::createFromFormat('!Y-m-d', $raw);
    } elseif (preg_match('/^\d{2}\/\d{2}\/\d{4}$/', $raw)) {
        $date = DateTime::createFromFormat('!d/m/Y', $raw);
    }

    if (!$date) return null;
    $errors = DateTime::getLastErrors();
    if (is_array($errors)
        && (($errors['warning_count'] ?? 0) > 0 || ($errors['error_count'] ?? 0) > 0)) {
        return null;
    }
    return $date->format('Y-m-d');
}

function ckc_birth_date_ok(?string $date, int $minAge = 14, int $maxAge = 100): bool {
    if ($date === null) return true;
    $birth = new DateTimeImmutable($date);
    $today = new DateTimeImmutable('today');
    if ($birth > $today) return false;
    $age = $birth->diff($today)->y;
    return $age >= $minAge && $age <= $maxAge;
}

function ckc_khoa_hoc_ok(string $value): bool {
    if (!preg_match('/^\d{4}-\d{4}$/', $value)) return false;
    $start = (int)substr($value, 0, 4);
    $end = (int)substr($value, 5, 4);
    return $start >= 2000 && $end - $start === 3;
}

function ckc_nam_bat_dau_khoa(string $value): ?int {
    return ckc_khoa_hoc_ok($value) ? (int)substr($value, 0, 4) : null;
}

function ckc_nam_nhap_hoc_ok($value): bool {
    if (!preg_match('/^\d{4}$/', trim((string)$value))) return false;
    $year = (int)$value;
    return $year >= 2000 && $year <= ((int)date('Y') + 5);
}

function ckc_nam_hoc_ok(string $value): bool {
    if (!preg_match('/^(\d{4})-(\d{4})$/', trim($value), $m)) return false;
    $start = (int)$m[1];
    $end = (int)$m[2];
    return $start >= 2000 && $end === $start + 1;
}

function ckc_lop_khoa_hoc(PDO $conn, int $lopId): ?string {
    $row = ckc_one(
        $conn,
        'SELECT nam_nhap_hoc FROM lop WHERE id = :id LIMIT 1',
        [':id' => $lopId]
    );
    if (!$row || !ckc_nam_nhap_hoc_ok($row['nam_nhap_hoc'] ?? null)) return null;
    $start = (int)$row['nam_nhap_hoc'];
    return $start . '-' . ($start + 3);
}

function ckc_loai_nhap_configs(): array {
    return [
        'khoa' => ['ten' => 'Khoa', 'template' => 'mau_nhap_khoa.xlsx', 'can_dich' => false],
        'bo_mon' => ['ten' => 'Bộ môn', 'template' => 'mau_nhap_bo_mon.xlsx', 'can_dich' => false],
        'mon_hoc' => ['ten' => 'Môn học', 'template' => 'mau_nhap_mon_hoc.xlsx', 'can_dich' => false],
        'lop_hanh_chinh' => ['ten' => 'Lớp hành chính', 'template' => 'mau_nhap_lop_hanh_chinh.xlsx', 'can_dich' => false],
        'sinh_vien' => ['ten' => 'Sinh viên', 'template' => 'mau_nhap_sinh_vien.xlsx', 'can_dich' => false],
        'sinh_vien_theo_lop' => [
            'ten' => 'Sinh viên theo lớp hành chính',
            'template' => 'mau_nhap_sinh_vien_theo_lop.xlsx',
            'can_dich' => true,
            'key_dich' => 'ma_lop',
        ],
        'giang_vien' => ['ten' => 'Giảng viên', 'template' => 'mau_nhap_giang_vien.xlsx', 'can_dich' => false],
        'lop_hoc_phan' => ['ten' => 'Lớp học phần', 'template' => 'mau_nhap_lop_hoc_phan.xlsx', 'can_dich' => false],
    ];
}

function ckc_result(
    int $line,
    array $row,
    string $status,
    string $action,
    array $messages
): array {
    return [
        'so_dong' => $line,
        'du_lieu' => $row,
        'trang_thai' => $status,
        'hanh_dong' => $action,
        'thong_bao' => implode('; ', array_values(array_unique(array_filter($messages)))),
    ];
}

function ckc_mark_seen(array &$seen, string $group, string $value, string $message, array &$messages): void {
    if ($value === '') return;
    if (isset($seen[$group][$value])) $messages[] = $message;
    $seen[$group][$value] = true;
}

function ckc_require_max(
    string $value,
    string $label,
    int $max,
    array &$messages,
    bool $required = true
): void {
    if ($required && $value === '') {
        $messages[] = 'Thiếu ' . $label;
        return;
    }
    if ($value !== '' && ckc_len($value) > $max) {
        $messages[] = $label . ' vượt quá ' . $max . ' ký tự';
    }
}

function ckc_validate_row(
    PDO $conn,
    string $loai,
    int $line,
    array $row,
    array &$seen,
    array $target
): array {
    $messages = [];
    $status = 'hop_le';
    $action = 'them_moi';

    switch ($loai) {
        case 'khoa':
            $row['ma_khoa'] = ckc_upper($row['ma_khoa'] ?? '');
            $row['ten_khoa'] = ckc_clean($row['ten_khoa'] ?? '');
            $row['trang_thai'] = ckc_status_khoa($row['trang_thai'] ?? '');

            ckc_require_max($row['ma_khoa'], 'mã khoa', 20, $messages);
            ckc_require_max($row['ten_khoa'], 'tên khoa', 100, $messages);
            if ($row['ma_khoa'] !== '' && !ckc_code_ok($row['ma_khoa'])) {
                $messages[] = 'Mã khoa chứa ký tự không hợp lệ';
            }
            if (!in_array($row['trang_thai'], ['dang_hoat_dong', 'ngung_hoat_dong'], true)) {
                $messages[] = 'Trạng thái khoa không hợp lệ';
            }
            ckc_mark_seen($seen, 'khoa', $row['ma_khoa'], 'Mã khoa bị trùng trong file', $messages);

            if ($row['ma_khoa'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM khoa WHERE ma_khoa = :ma LIMIT 1',
                [':ma' => $row['ma_khoa']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã khoa đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'bo_mon':
            $row['ma_bo_mon'] = ckc_upper($row['ma_bo_mon'] ?? '');
            $row['ten_bo_mon'] = ckc_clean($row['ten_bo_mon'] ?? '');
            $row['ma_khoa'] = ckc_upper($row['ma_khoa'] ?? '');
            $row['trang_thai'] = ckc_status_khoa($row['trang_thai'] ?? '');

            ckc_require_max($row['ma_bo_mon'], 'mã bộ môn', 20, $messages);
            ckc_require_max($row['ten_bo_mon'], 'tên bộ môn', 100, $messages);
            ckc_require_max($row['ma_khoa'], 'mã khoa', 20, $messages);
            if (!in_array($row['trang_thai'], ['dang_hoat_dong', 'ngung_hoat_dong'], true)) {
                $messages[] = 'Trạng thái bộ môn không hợp lệ';
            }

            $khoa = $row['ma_khoa'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, trang_thai FROM khoa WHERE ma_khoa = :ma LIMIT 1',
                [':ma' => $row['ma_khoa']]
            );
            if (!$khoa) {
                $messages[] = 'Mã khoa không tồn tại';
            } else {
                $row['khoa_id'] = (int)$khoa['id'];
                if ($khoa['trang_thai'] !== 'dang_hoat_dong') {
                    $messages[] = 'Khoa đang ngừng hoạt động';
                }
            }

            ckc_mark_seen($seen, 'bo_mon', $row['ma_bo_mon'], 'Mã bộ môn bị trùng trong file', $messages);
            if ($row['ma_bo_mon'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM bo_mon WHERE ma_bo_mon = :ma LIMIT 1',
                [':ma' => $row['ma_bo_mon']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã bộ môn đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'mon_hoc':
            $row['ma_mon'] = ckc_upper($row['ma_mon'] ?? '');
            $row['ten_mon'] = ckc_clean($row['ten_mon'] ?? '');
            $tinChiRaw = ckc_clean($row['tin_chi'] ?? '');
            $row['tin_chi'] = preg_match('/^\d+$/', $tinChiRaw) ? (int)$tinChiRaw : 0;
            $row['ma_khoa'] = ckc_upper($row['ma_khoa'] ?? '');
            $row['ma_bo_mon'] = ckc_upper($row['ma_bo_mon'] ?? '');
            $row['trang_thai'] = ckc_status_mon($row['trang_thai'] ?? '');

            ckc_require_max($row['ma_mon'], 'mã môn học', 20, $messages);
            ckc_require_max($row['ten_mon'], 'tên môn học', 100, $messages);
            ckc_require_max($row['ma_khoa'], 'mã khoa', 20, $messages);
            ckc_require_max($row['ma_bo_mon'], 'mã bộ môn', 20, $messages);
            if (!preg_match('/^\d+$/', $tinChiRaw) || $row['tin_chi'] < 1 || $row['tin_chi'] > 10) {
                $messages[] = 'Số tín chỉ phải là số nguyên từ 1 đến 10';
            }
            if (!in_array($row['trang_thai'], ['dang_mo', 'ngung_su_dung'], true)) {
                $messages[] = 'Trạng thái môn học không hợp lệ';
            }

            $khoa = $row['ma_khoa'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, trang_thai FROM khoa WHERE ma_khoa = :ma LIMIT 1',
                [':ma' => $row['ma_khoa']]
            );
            if (!$khoa) {
                $messages[] = 'Mã khoa không tồn tại';
            } else {
                $row['khoa_id'] = (int)$khoa['id'];
                if ($khoa['trang_thai'] !== 'dang_hoat_dong') {
                    $messages[] = 'Khoa đang ngừng hoạt động';
                }
            }

            $boMon = $row['ma_bo_mon'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, khoa_id, trang_thai FROM bo_mon WHERE ma_bo_mon = :ma LIMIT 1',
                [':ma' => $row['ma_bo_mon']]
            );
            if (!$boMon) {
                $messages[] = 'Mã bộ môn không tồn tại';
            } else {
                $row['bo_mon_id'] = (int)$boMon['id'];
                if ($boMon['trang_thai'] !== 'dang_hoat_dong') {
                    $messages[] = 'Bộ môn đang ngừng hoạt động';
                }
                if (isset($row['khoa_id']) && (int)$boMon['khoa_id'] !== (int)$row['khoa_id']) {
                    $messages[] = 'Bộ môn không thuộc khoa đã nhập';
                }
            }

            ckc_mark_seen($seen, 'mon_hoc', $row['ma_mon'], 'Mã môn học bị trùng trong file', $messages);
            if ($row['ma_mon'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM mon_hoc WHERE ma_mon = :ma LIMIT 1',
                [':ma' => $row['ma_mon']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã môn học đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'lop_hanh_chinh':
            $row['ma_lop'] = ckc_upper($row['ma_lop'] ?? '');
            $row['ten_lop'] = ckc_clean($row['ten_lop'] ?? '');
            $row['ma_khoa'] = ckc_upper($row['ma_khoa'] ?? '');
            $row['nam_nhap_hoc'] = ckc_clean($row['nam_nhap_hoc'] ?? '');
            $row['trang_thai'] = ckc_status_lop($row['trang_thai'] ?? '');

            ckc_require_max($row['ma_lop'], 'mã lớp', 20, $messages);
            ckc_require_max($row['ten_lop'], 'tên lớp', 100, $messages);
            ckc_require_max($row['ma_khoa'], 'mã khoa', 20, $messages);
            if (!ckc_nam_nhap_hoc_ok($row['nam_nhap_hoc'])) {
                $messages[] = 'Năm nhập học phải gồm 4 chữ số hợp lệ, ví dụ 2026';
            }
            if (!in_array($row['trang_thai'], ['dang_hoc', 'da_tot_nghiep', 'tam_khoa'], true)) {
                $messages[] = 'Trạng thái lớp không hợp lệ';
            }

            $khoa = $row['ma_khoa'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, trang_thai FROM khoa WHERE ma_khoa = :ma LIMIT 1',
                [':ma' => $row['ma_khoa']]
            );
            if (!$khoa) {
                $messages[] = 'Mã khoa không tồn tại';
            } else {
                $row['khoa_id'] = (int)$khoa['id'];
                if ($khoa['trang_thai'] !== 'dang_hoat_dong') {
                    $messages[] = 'Khoa đang ngừng hoạt động';
                }
            }

            ckc_mark_seen($seen, 'lop', $row['ma_lop'], 'Mã lớp bị trùng trong file', $messages);
            if ($row['ma_lop'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM lop WHERE ma_lop = :ma LIMIT 1',
                [':ma' => $row['ma_lop']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã lớp đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'sinh_vien_theo_lop':
            $maLopDich = ckc_upper($target['ma_lop'] ?? '');
            if ($maLopDich === '') {
                $messages[] = 'Chưa chọn mã lớp hành chính đích';
            } else {
                $lop = ckc_one(
                    $conn,
                    "SELECT l.id, l.ma_lop, l.khoa_id, l.nam_nhap_hoc,
                            l.trang_thai, k.ma_khoa, k.trang_thai AS trang_thai_khoa
                     FROM lop l
                     INNER JOIN khoa k ON k.id = l.khoa_id
                     WHERE l.ma_lop = :ma
                     LIMIT 1",
                    [':ma' => $maLopDich]
                );
                if (!$lop) {
                    $messages[] = 'Lớp hành chính đích không tồn tại';
                } else {
                    $row['ma_lop'] = $lop['ma_lop'];
                    $row['lop_id'] = (int)$lop['id'];
                    $row['khoa_id'] = (int)$lop['khoa_id'];
                    $row['ma_khoa'] = $lop['ma_khoa'];
                    $row['khoa_hoc'] = ckc_lop_khoa_hoc($conn, (int)$lop['id']);
                    if ($lop['trang_thai'] !== 'dang_hoc') {
                        $messages[] = 'Lớp hành chính đích không ở trạng thái Đang học';
                    }
                    if ($lop['trang_thai_khoa'] !== 'dang_hoat_dong') {
                        $messages[] = 'Khoa của lớp đang ngừng hoạt động';
                    }
                    if (!ckc_khoa_hoc_ok((string)$row['khoa_hoc'])) {
                        $messages[] = 'Lớp chưa có khóa học hợp lệ';
                    }
                }
            }
            // Tiếp tục dùng chung logic sinh viên.

        case 'sinh_vien':
            $row['ma_sinh_vien'] = ckc_upper($row['ma_sinh_vien'] ?? '');
            $row['ho_ten'] = ckc_clean($row['ho_ten'] ?? '');
            $row['email'] = ckc_lower($row['email'] ?? '');
            $row['mat_khau'] = ckc_clean($row['mat_khau'] ?? '');
            $ngaySinhRaw = ckc_clean($row['ngay_sinh'] ?? '');
            $row['ngay_sinh'] = ckc_date($ngaySinhRaw);
            $gioiTinhRaw = ckc_clean($row['gioi_tinh'] ?? '');
            $row['gioi_tinh'] = ckc_gioi_tinh($gioiTinhRaw);
            $row['so_dien_thoai'] = ckc_phone_normalize($row['so_dien_thoai'] ?? '');
            $row['cccd'] = ckc_cccd_normalize($row['cccd'] ?? '');
            $row['dia_chi'] = ckc_clean($row['dia_chi'] ?? '');
            $row['trang_thai_sinh_vien'] = ckc_status_sv($row['trang_thai_sinh_vien'] ?? '');
            $row['trang_thai_tai_khoan'] = 'dang_hoat_dong';

            ckc_require_max($row['ma_sinh_vien'], 'mã sinh viên', 20, $messages);
            ckc_require_max($row['ho_ten'], 'họ tên', 100, $messages);
            ckc_require_max($row['email'], 'email', 100, $messages);
            ckc_require_max($row['mat_khau'], 'mật khẩu', 255, $messages);
            ckc_require_max($row['so_dien_thoai'], 'số điện thoại', 20, $messages, false);
            ckc_require_max($row['cccd'], 'CCCD', 20, $messages, false);
            if ($row['dia_chi'] !== '' && ckc_len($row['dia_chi']) > 1000) {
                $messages[] = 'Địa chỉ vượt quá 1000 ký tự';
            }
            if ($row['ma_sinh_vien'] !== '' && !ckc_code_ok($row['ma_sinh_vien'])) {
                $messages[] = 'Mã sinh viên chứa ký tự không hợp lệ';
            }
            if (!ckc_email_ok($row['email'])) {
                $messages[] = 'Email không hợp lệ';
            }
            if ($row['mat_khau'] !== '' && ckc_len($row['mat_khau']) < 6) {
                $messages[] = 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            if ($ngaySinhRaw !== '' && $row['ngay_sinh'] === null) {
                $messages[] = 'Ngày sinh không hợp lệ, dùng định dạng dd/MM/yyyy';
            } elseif (!ckc_birth_date_ok($row['ngay_sinh'])) {
                $messages[] = 'Tuổi sinh viên phải từ 14 đến 100';
            }
            if ($gioiTinhRaw !== '' && $row['gioi_tinh'] === null) {
                $messages[] = 'Giới tính chỉ nhận Nam, Nữ hoặc Khác';
            }
            if (!ckc_phone_ok($row['so_dien_thoai'])) {
                $messages[] = 'Số điện thoại phải có từ 9 đến 15 chữ số';
            }
            if (!ckc_cccd_ok($row['cccd'])) {
                $messages[] = 'CCCD phải gồm đúng 12 chữ số';
            }
            if (!in_array($row['trang_thai_sinh_vien'], ['dang_hoc', 'tam_nghi', 'da_tot_nghiep'], true)) {
                $messages[] = 'Trạng thái sinh viên không hợp lệ';
            }
            if (ckc_role_id($conn, 'sinh_vien') <= 0) {
                $messages[] = 'Hệ thống chưa có vai trò sinh_vien';
            }

            if (!isset($row['lop_id'])) {
                $row['ma_lop'] = ckc_upper($row['ma_lop'] ?? '');
                ckc_require_max($row['ma_lop'], 'mã lớp', 20, $messages);

                $lop = $row['ma_lop'] === '' ? null : ckc_one(
                    $conn,
                    "SELECT l.id, l.ma_lop, l.khoa_id, l.nam_nhap_hoc,
                            l.trang_thai, k.ma_khoa, k.trang_thai AS trang_thai_khoa
                     FROM lop l
                     INNER JOIN khoa k ON k.id = l.khoa_id
                     WHERE l.ma_lop = :ma
                     LIMIT 1",
                    [':ma' => $row['ma_lop']]
                );
                if (!$lop) {
                    $messages[] = 'Mã lớp không tồn tại';
                } else {
                    $row['lop_id'] = (int)$lop['id'];
                    $row['khoa_id'] = (int)$lop['khoa_id'];
                    $row['ma_khoa'] = $lop['ma_khoa'];
                    $row['khoa_hoc'] = ckc_lop_khoa_hoc($conn, (int)$lop['id']);
                    if ($lop['trang_thai'] !== 'dang_hoc') {
                        $messages[] = 'Lớp không ở trạng thái Đang học';
                    }
                    if ($lop['trang_thai_khoa'] !== 'dang_hoat_dong') {
                        $messages[] = 'Khoa của lớp đang ngừng hoạt động';
                    }
                    if (!ckc_khoa_hoc_ok((string)$row['khoa_hoc'])) {
                        $messages[] = 'Lớp chưa có khóa học hợp lệ';
                    }
                }
            }

            ckc_mark_seen($seen, 'email', $row['email'], 'Email bị trùng trong file', $messages);
            ckc_mark_seen($seen, 'mssv', $row['ma_sinh_vien'], 'Mã sinh viên bị trùng trong file', $messages);
            if ($row['cccd'] !== '') {
                ckc_mark_seen($seen, 'cccd', $row['cccd'], 'CCCD bị trùng trong file', $messages);
            }

            if ($row['email'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM nguoi_dung WHERE email = :email LIMIT 1',
                [':email' => $row['email']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Email đã tồn tại, sẽ bỏ qua';
            }
            if ($row['ma_sinh_vien'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM sinh_vien WHERE ma_sinh_vien = :ma LIMIT 1',
                [':ma' => $row['ma_sinh_vien']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã sinh viên đã tồn tại, sẽ bỏ qua';
            }
            if ($row['cccd'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM sinh_vien WHERE cccd = :cccd LIMIT 1',
                [':cccd' => $row['cccd']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'CCCD sinh viên đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'giang_vien':
            $row['ma_giang_vien'] = ckc_upper($row['ma_giang_vien'] ?? '');
            $row['ho_ten'] = ckc_clean($row['ho_ten'] ?? '');
            $row['email'] = ckc_lower($row['email'] ?? '');
            $row['mat_khau'] = ckc_clean($row['mat_khau'] ?? '');
            $row['ma_bo_mon'] = ckc_upper($row['ma_bo_mon'] ?? '');
            $ngaySinhRaw = ckc_clean($row['ngay_sinh'] ?? '');
            $row['ngay_sinh'] = ckc_date($ngaySinhRaw);
            $gioiTinhRaw = ckc_clean($row['gioi_tinh'] ?? '');
            $row['gioi_tinh'] = ckc_gioi_tinh($gioiTinhRaw);
            $row['so_dien_thoai'] = ckc_phone_normalize($row['so_dien_thoai'] ?? '');
            $row['cccd'] = ckc_cccd_normalize($row['cccd'] ?? '');
            $row['dia_chi'] = ckc_clean($row['dia_chi'] ?? '');
            $row['trang_thai_giang_vien'] = ckc_status_gv($row['trang_thai_giang_vien'] ?? '');
            $row['trang_thai_tai_khoan'] = ckc_status_tk($row['trang_thai_tai_khoan'] ?? '');

            ckc_require_max($row['ma_giang_vien'], 'mã giảng viên', 20, $messages);
            ckc_require_max($row['ho_ten'], 'họ tên', 100, $messages);
            ckc_require_max($row['email'], 'email', 100, $messages);
            ckc_require_max($row['mat_khau'], 'mật khẩu', 255, $messages);
            ckc_require_max($row['ma_bo_mon'], 'mã bộ môn', 20, $messages);
            if (!ckc_email_ok($row['email'])) $messages[] = 'Email không hợp lệ';
            if ($row['mat_khau'] !== '' && ckc_len($row['mat_khau']) < 6) {
                $messages[] = 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            if ($ngaySinhRaw !== '' && $row['ngay_sinh'] === null) {
                $messages[] = 'Ngày sinh không hợp lệ, dùng định dạng dd/MM/yyyy';
            } elseif (!ckc_birth_date_ok($row['ngay_sinh'], 18, 100)) {
                $messages[] = 'Tuổi giảng viên phải từ 18 đến 100';
            }
            if ($gioiTinhRaw !== '' && $row['gioi_tinh'] === null) {
                $messages[] = 'Giới tính chỉ nhận Nam, Nữ hoặc Khác';
            }
            if (!ckc_phone_ok($row['so_dien_thoai'])) {
                $messages[] = 'Số điện thoại phải có từ 9 đến 15 chữ số';
            }
            if (!ckc_cccd_ok($row['cccd'])) {
                $messages[] = 'CCCD phải gồm đúng 12 chữ số';
            }
            if (!in_array($row['trang_thai_giang_vien'], ['dang_day', 'ngung_day'], true)) {
                $messages[] = 'Trạng thái giảng viên không hợp lệ';
            }
            if (!in_array($row['trang_thai_tai_khoan'], ['dang_hoat_dong', 'bi_khoa'], true)) {
                $messages[] = 'Trạng thái tài khoản không hợp lệ';
            }
            if (ckc_role_id($conn, 'giang_vien') <= 0) {
                $messages[] = 'Hệ thống chưa có vai trò giang_vien';
            }

            $boMon = $row['ma_bo_mon'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, trang_thai FROM bo_mon WHERE ma_bo_mon = :ma LIMIT 1',
                [':ma' => $row['ma_bo_mon']]
            );
            if (!$boMon) {
                $messages[] = 'Mã bộ môn không tồn tại';
            } else {
                $row['bo_mon_id'] = (int)$boMon['id'];
                if ($boMon['trang_thai'] !== 'dang_hoat_dong') {
                    $messages[] = 'Bộ môn đang ngừng hoạt động';
                }
            }

            ckc_mark_seen($seen, 'email', $row['email'], 'Email bị trùng trong file', $messages);
            ckc_mark_seen($seen, 'gv', $row['ma_giang_vien'], 'Mã giảng viên bị trùng trong file', $messages);
            if ($row['cccd'] !== '') {
                ckc_mark_seen($seen, 'cccd_gv', $row['cccd'], 'CCCD bị trùng trong file', $messages);
            }

            if ($row['email'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM nguoi_dung WHERE email = :email LIMIT 1',
                [':email' => $row['email']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Email đã tồn tại, sẽ bỏ qua';
            }
            if ($row['ma_giang_vien'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM giang_vien WHERE ma_giang_vien = :ma LIMIT 1',
                [':ma' => $row['ma_giang_vien']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã giảng viên đã tồn tại, sẽ bỏ qua';
            }
            break;

        case 'lop_hoc_phan':
            $row['ma_lop_hoc_phan'] = ckc_clean($row['ma_lop_hoc_phan'] ?? '');
            $row['ten_lop'] = ckc_clean($row['ten_lop'] ?? '');
            $row['ma_mon'] = ckc_upper($row['ma_mon'] ?? '');
            $row['ma_giang_vien'] = ckc_upper($row['ma_giang_vien'] ?? '');
            $row['nam_hoc'] = ckc_clean($row['nam_hoc'] ?? '');
            $row['hoc_ky'] = ckc_upper($row['hoc_ky'] ?? '');
            $siSoRaw = ckc_clean($row['si_so_toi_da'] ?? '');
            $row['si_so_toi_da'] = preg_match('/^\d+$/', $siSoRaw) ? (int)$siSoRaw : 0;
            $row['trang_thai'] = ckc_status_lhp($row['trang_thai'] ?? '');

            ckc_require_max($row['ma_lop_hoc_phan'], 'mã lớp học phần', 150, $messages);
            ckc_require_max($row['ten_lop'], 'tên lớp học phần', 150, $messages);
            ckc_require_max($row['ma_mon'], 'mã môn học', 20, $messages);
            ckc_require_max($row['ma_giang_vien'], 'mã giảng viên', 20, $messages);
            if (!ckc_nam_hoc_ok($row['nam_hoc'])) {
                $messages[] = 'Năm học phải đúng dạng hai năm liên tiếp, ví dụ 2026-2027';
            }
            if (!in_array($row['hoc_ky'], ['HK1', 'HK2', 'HK3', 'HK4', 'HK5', 'HK6'], true)) {
                $messages[] = 'Học kỳ chỉ nhận HK1 đến HK6';
            }
            if (!preg_match('/^\d+$/', $siSoRaw)
                || $row['si_so_toi_da'] < 1
                || $row['si_so_toi_da'] > 500) {
                $messages[] = 'Sĩ số tối đa phải là số nguyên từ 1 đến 500';
            }
            if (!in_array($row['trang_thai'], ['dang_mo', 'da_khoa', 'da_ket_thuc'], true)) {
                $messages[] = 'Trạng thái lớp học phần không hợp lệ';
            }

            $mon = $row['ma_mon'] === '' ? null : ckc_one(
                $conn,
                'SELECT id, trang_thai FROM mon_hoc WHERE ma_mon = :ma LIMIT 1',
                [':ma' => $row['ma_mon']]
            );
            if (!$mon) {
                $messages[] = 'Mã môn học không tồn tại';
            } else {
                $row['mon_hoc_id'] = (int)$mon['id'];
                if ($mon['trang_thai'] !== 'dang_mo') {
                    $messages[] = 'Môn học đang ngừng sử dụng';
                }
            }

            $giangVien = $row['ma_giang_vien'] === '' ? null : ckc_one(
                $conn,
                "SELECT gv.id, gv.trang_thai, nd.trang_thai AS trang_thai_tai_khoan
                 FROM giang_vien gv
                 INNER JOIN nguoi_dung nd ON nd.id = gv.nguoi_dung_id
                 WHERE gv.ma_giang_vien = :ma
                 LIMIT 1",
                [':ma' => $row['ma_giang_vien']]
            );
            if (!$giangVien) {
                $messages[] = 'Mã giảng viên không tồn tại';
            } else {
                $row['giang_vien_id'] = (int)$giangVien['id'];
                if ($giangVien['trang_thai'] !== 'dang_day') {
                    $messages[] = 'Giảng viên đang ngừng dạy';
                }
                if ($giangVien['trang_thai_tai_khoan'] !== 'dang_hoat_dong') {
                    $messages[] = 'Tài khoản giảng viên đang bị khóa';
                }
            }

            ckc_mark_seen(
                $seen,
                'lhp_ma',
                ckc_lower($row['ma_lop_hoc_phan']),
                'Mã lớp học phần bị trùng trong file',
                $messages
            );
            ckc_mark_seen(
                $seen,
                'lhp_ten',
                ckc_lower($row['ten_lop'] . '|' . $row['nam_hoc'] . '|' . $row['hoc_ky']),
                'Tên lớp học phần bị trùng trong cùng năm học và học kỳ trong file',
                $messages
            );

            if ($row['ma_lop_hoc_phan'] !== '' && ckc_one(
                $conn,
                'SELECT id FROM lop_hoc_phan WHERE ma_lop_hoc_phan = :ma LIMIT 1',
                [':ma' => $row['ma_lop_hoc_phan']]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Mã lớp học phần đã tồn tại, sẽ bỏ qua';
            } elseif ($row['ten_lop'] !== '' && ckc_one(
                $conn,
                "SELECT id FROM lop_hoc_phan
                 WHERE ten_lop = :ten
                   AND nam_hoc = :nam_hoc
                   AND hoc_ky = :hoc_ky
                 LIMIT 1",
                [
                    ':ten' => $row['ten_lop'],
                    ':nam_hoc' => $row['nam_hoc'],
                    ':hoc_ky' => $row['hoc_ky'],
                ]
            )) {
                $status = 'canh_bao';
                $action = 'bo_qua';
                $messages[] = 'Tên lớp học phần đã tồn tại trong cùng năm học và học kỳ, sẽ bỏ qua';
            }
            break;

        default:
            $messages[] = 'Loại nhập không được hỗ trợ';
    }

    if (!empty($messages)) {
        $hasError = false;
        foreach ($messages as $message) {
            if (mb_strpos($message, 'sẽ bỏ qua') === false) {
                $hasError = true;
                break;
            }
        }
        if ($hasError) $status = 'loi';
    }

    return ckc_result($line, $row, $status, $action, $messages);
}
?>
