<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

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

function ckc_user_reply(int $code, string $status, string $message, ?array $data = null): void
{
    http_response_code($code);
    $result = ['status' => $status, 'message' => $message];
    if ($data !== null) {
        $result['data'] = $data;
    }
    echo json_encode($result, JSON_UNESCAPED_UNICODE);
    exit();
}

function ckc_user_column_exists(PDO $conn, string $table, string $column): bool
{
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table) || !preg_match('/^[A-Za-z0-9_]+$/', $column)) {
        return false;
    }
    $stmt = $conn->prepare(
        'SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table_name AND COLUMN_NAME = :column_name'
    );
    $stmt->execute([':table_name' => $table, ':column_name' => $column]);
    return (int)$stmt->fetchColumn() > 0;
}

function ckc_user_lop_nam_expr(PDO $conn): string
{
    if (ckc_user_column_exists($conn, 'lop', 'nam_nhap_hoc')) {
        return 'nam_nhap_hoc';
    }
    if (ckc_user_column_exists($conn, 'lop', 'khoa_hoc')) {
        return "CASE
            WHEN khoa_hoc REGEXP '^[0-9]{4}' THEN CAST(SUBSTRING(khoa_hoc, 1, 4) AS UNSIGNED)
            WHEN khoa_hoc REGEXP '^[Kk][0-9]{2}' THEN 2000 + CAST(SUBSTRING(khoa_hoc, 2, 2) AS UNSIGNED)
            ELSE NULL
        END";
    }
    return 'NULL';
}

$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}

$id = (int)($input['id'] ?? 0);
$hoTen = trim((string)($input['ho_ten'] ?? ''));
$email = strtolower(trim((string)($input['email'] ?? '')));
$matKhau = trim((string)($input['mat_khau'] ?? ''));
$vaiTroId = (int)($input['vai_tro_id'] ?? 0);
$trangThai = trim((string)($input['trang_thai'] ?? 'dang_hoat_dong'));
$maSinhVien = trim((string)($input['ma_sinh_vien'] ?? ''));
$lopId = (int)($input['lop_id'] ?? 0);
$khoaId = (int)($input['khoa_id'] ?? 0);
$maGiangVien = trim((string)($input['ma_giang_vien'] ?? ''));
$boMonId = (int)($input['bo_mon_id'] ?? 0);

if ($id <= 0) {
    ckc_user_reply(400, 'error', 'ID người dùng không hợp lệ');
}
if ($hoTen === '') {
    ckc_user_reply(400, 'error', 'Họ tên không được để trống');
}
if ($email === '' || filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
    ckc_user_reply(400, 'error', 'Email không hợp lệ');
}
if ($matKhau !== '' && strlen($matKhau) < 6) {
    ckc_user_reply(400, 'error', 'Mật khẩu mới phải có ít nhất 6 ký tự');
}
if ($vaiTroId <= 0) {
    ckc_user_reply(400, 'error', 'Vai trò không hợp lệ');
}
if (!in_array($trangThai, ['dang_hoat_dong', 'bi_khoa'], true)) {
    ckc_user_reply(400, 'error', 'Trạng thái tài khoản không hợp lệ');
}
if ($id === 1 && $trangThai === 'bi_khoa') {
    ckc_user_reply(400, 'error', 'Không thể khóa tài khoản quản trị chính');
}

try {
    $conn->beginTransaction();

    $stmt = $conn->prepare(
        'SELECT nd.id, nd.vai_tro_id, vt.ten_vai_tro
         FROM nguoi_dung nd
         LEFT JOIN vai_tro vt ON vt.id = nd.vai_tro_id
         WHERE nd.id = :id
         LIMIT 1
         FOR UPDATE'
    );
    $stmt->execute([':id' => $id]);
    $nguoiDung = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$nguoiDung) {
        $conn->rollBack();
        ckc_user_reply(404, 'error', 'Người dùng không tồn tại');
    }

    $vaiTroCu = (int)$nguoiDung['vai_tro_id'];
    $tenVaiTro = (string)($nguoiDung['ten_vai_tro'] ?? '');
    if ($vaiTroId !== $vaiTroCu) {
        $conn->rollBack();
        ckc_user_reply(
            400,
            'error',
            'Không thể đổi vai trò của tài khoản đã tạo. Hãy tạo tài khoản mới để tránh sai dữ liệu giảng viên hoặc sinh viên.'
        );
    }

    $stmt = $conn->prepare('SELECT id FROM nguoi_dung WHERE email = :email AND id <> :id LIMIT 1');
    $stmt->execute([':email' => $email, ':id' => $id]);
    if ($stmt->fetch()) {
        $conn->rollBack();
        ckc_user_reply(409, 'error', 'Email đã được sử dụng bởi tài khoản khác');
    }

    $setNguoiDung = [
        'ho_ten = :ho_ten',
        'email = :email',
        'trang_thai = :trang_thai',
    ];
    $paramsNguoiDung = [
        ':ho_ten' => $hoTen,
        ':email' => $email,
        ':trang_thai' => $trangThai,
        ':id' => $id,
    ];
    if ($matKhau !== '') {
        $hash = password_hash($matKhau, PASSWORD_DEFAULT);
        if ($hash === false) {
            throw new RuntimeException('Không thể mã hóa mật khẩu');
        }
        $setNguoiDung[] = 'mat_khau = :mat_khau';
        $paramsNguoiDung[':mat_khau'] = $hash;
    }

    $stmt = $conn->prepare('UPDATE nguoi_dung SET ' . implode(', ', $setNguoiDung) . ' WHERE id = :id');
    $stmt->execute($paramsNguoiDung);

    $profileData = [];

    if ($tenVaiTro === 'sinh_vien') {
        $stmt = $conn->prepare(
            'SELECT id, ma_sinh_vien FROM sinh_vien
             WHERE nguoi_dung_id = :nguoi_dung_id
             LIMIT 1
             FOR UPDATE'
        );
        $stmt->execute([':nguoi_dung_id' => $id]);
        $sinhVien = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$sinhVien) {
            throw new RuntimeException('Tài khoản sinh viên chưa có hồ sơ sinh viên tương ứng');
        }
        $sinhVienId = (int)$sinhVien['id'];
        if ($maSinhVien === '') {
            $maSinhVien = (string)$sinhVien['ma_sinh_vien'];
        }
        if ($lopId <= 0 || $khoaId <= 0) {
            throw new InvalidArgumentException('Vui lòng chọn khoa và lớp hành chính cho sinh viên');
        }

        $stmt = $conn->prepare(
            'SELECT id FROM sinh_vien
             WHERE ma_sinh_vien = :ma_sinh_vien AND id <> :id
             LIMIT 1'
        );
        $stmt->execute([':ma_sinh_vien' => $maSinhVien, ':id' => $sinhVienId]);
        if ($stmt->fetch()) {
            throw new InvalidArgumentException('Mã sinh viên đã được sử dụng');
        }

        $namExpr = ckc_user_lop_nam_expr($conn);
        $coDeletedAt = ckc_user_column_exists($conn, 'lop', 'deleted_at');
        $sqlLop = "SELECT id, khoa_id, {$namExpr} AS nam_nhap_hoc FROM lop WHERE id = :id";
        if ($coDeletedAt) {
            $sqlLop .= ' AND deleted_at IS NULL';
        }
        $sqlLop .= ' LIMIT 1';
        $stmt = $conn->prepare($sqlLop);
        $stmt->execute([':id' => $lopId]);
        $lop = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$lop) {
            throw new InvalidArgumentException('Lớp hành chính không tồn tại');
        }
        if ((int)$lop['khoa_id'] !== $khoaId) {
            throw new InvalidArgumentException('Lớp hành chính không thuộc khoa đã chọn');
        }

        $stmt = $conn->prepare('SELECT id FROM khoa WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $khoaId]);
        if (!$stmt->fetch()) {
            throw new InvalidArgumentException('Khoa không tồn tại');
        }

        $setSinhVien = [
            'ma_sinh_vien = :ma_sinh_vien',
            'lop_id = :lop_id',
            'khoa_id = :khoa_id',
        ];
        $paramsSinhVien = [
            ':ma_sinh_vien' => $maSinhVien,
            ':lop_id' => $lopId,
            ':khoa_id' => $khoaId,
            ':id' => $sinhVienId,
        ];
        if (ckc_user_column_exists($conn, 'sinh_vien', 'khoa_hoc')) {
            $namNhapHoc = (int)($lop['nam_nhap_hoc'] ?? 0);
            $khoaHoc = $namNhapHoc >= 2000 ? $namNhapHoc . '-' . ($namNhapHoc + 3) : null;
            $setSinhVien[] = 'khoa_hoc = :khoa_hoc';
            $paramsSinhVien[':khoa_hoc'] = $khoaHoc;
        }

        $stmt = $conn->prepare('UPDATE sinh_vien SET ' . implode(', ', $setSinhVien) . ' WHERE id = :id');
        $stmt->execute($paramsSinhVien);
        $profileData = [
            'sinh_vien_id' => $sinhVienId,
            'ma_sinh_vien' => $maSinhVien,
            'lop_id' => $lopId,
            'khoa_id' => $khoaId,
        ];
    } elseif ($tenVaiTro === 'giang_vien') {
        $stmt = $conn->prepare(
            'SELECT id, ma_giang_vien FROM giang_vien
             WHERE nguoi_dung_id = :nguoi_dung_id
             LIMIT 1
             FOR UPDATE'
        );
        $stmt->execute([':nguoi_dung_id' => $id]);
        $giangVien = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$giangVien) {
            throw new RuntimeException('Tài khoản giảng viên chưa có hồ sơ giảng viên tương ứng');
        }
        $giangVienId = (int)$giangVien['id'];
        if ($maGiangVien === '') {
            $maGiangVien = (string)$giangVien['ma_giang_vien'];
        }

        $stmt = $conn->prepare(
            'SELECT id FROM giang_vien
             WHERE ma_giang_vien = :ma_giang_vien AND id <> :id
             LIMIT 1'
        );
        $stmt->execute([':ma_giang_vien' => $maGiangVien, ':id' => $giangVienId]);
        if ($stmt->fetch()) {
            throw new InvalidArgumentException('Mã giảng viên đã được sử dụng');
        }

        if ($boMonId > 0) {
            $stmt = $conn->prepare('SELECT id FROM bo_mon WHERE id = :id LIMIT 1');
            $stmt->execute([':id' => $boMonId]);
            if (!$stmt->fetch()) {
                throw new InvalidArgumentException('Bộ môn không tồn tại');
            }
        }

        $stmt = $conn->prepare(
            'UPDATE giang_vien
             SET ma_giang_vien = :ma_giang_vien, bo_mon_id = :bo_mon_id
             WHERE id = :id'
        );
        $stmt->bindValue(':ma_giang_vien', $maGiangVien, PDO::PARAM_STR);
        if ($boMonId > 0) {
            $stmt->bindValue(':bo_mon_id', $boMonId, PDO::PARAM_INT);
        } else {
            $stmt->bindValue(':bo_mon_id', null, PDO::PARAM_NULL);
        }
        $stmt->bindValue(':id', $giangVienId, PDO::PARAM_INT);
        $stmt->execute();
        $profileData = [
            'giang_vien_id' => $giangVienId,
            'ma_giang_vien' => $maGiangVien,
            'bo_mon_id' => $boMonId > 0 ? $boMonId : null,
        ];
    } elseif ($tenVaiTro !== 'quan_tri') {
        throw new InvalidArgumentException('Vai trò người dùng chưa được hỗ trợ');
    }

    $conn->commit();
    ckc_user_reply(200, 'success', 'Cập nhật người dùng thành công', array_merge([
        'id' => $id,
        'vai_tro_id' => $vaiTroId,
        'trang_thai' => $trangThai,
    ], $profileData));
} catch (InvalidArgumentException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    ckc_user_reply(400, 'error', $e->getMessage());
} catch (PDOException $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    $message = $e->getCode() === '23000'
        ? 'Dữ liệu cập nhật bị trùng hoặc vi phạm liên kết CSDL'
        : 'Lỗi CSDL khi cập nhật người dùng';
    ckc_user_reply(500, 'error', $message, ['detail' => $e->getMessage()]);
} catch (Throwable $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    ckc_user_reply(500, 'error', 'Lỗi server khi cập nhật người dùng', ['detail' => $e->getMessage()]);
}
