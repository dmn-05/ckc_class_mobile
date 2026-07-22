<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit(); }
require_once __DIR__ . '/../ket_noi.php';
require_once __DIR__ . '/_nhap_excel_helper.php';

function ckc_insert_user(PDO $conn, array $r, int $vaiTroId, string $trangThai): int {
    if ($vaiTroId <= 0) {
        throw new Exception('Vai trò người dùng không tồn tại');
    }
    if (!in_array($trangThai, ['dang_hoat_dong', 'bi_khoa'], true)) {
        $trangThai = 'dang_hoat_dong';
    }
    $matKhauHash = password_hash((string)$r['mat_khau'], PASSWORD_DEFAULT);
    if ($matKhauHash === false) {
        throw new Exception('Không thể mã hóa mật khẩu người dùng');
    }
    $stmt = $conn->prepare("INSERT INTO nguoi_dung (ho_ten,email,mat_khau,vai_tro_id,trang_thai) VALUES (:ten,:email,:mk,:role,:tt)");
    $stmt->execute([
        ':ten' => $r['ho_ten'],
        ':email' => $r['email'],
        ':mk' => $matKhauHash,
        ':role' => $vaiTroId,
        ':tt' => $trangThai,
    ]);
    return (int)$conn->lastInsertId();
}
function ckc_confirm_one(PDO $conn, string $loai, array $r, string $action): string {
    if ($action === 'bo_qua') return 'bo_qua';
    switch($loai){
        case 'khoa':
            $stmt=$conn->prepare("INSERT INTO khoa (ma_khoa,ten_khoa,trang_thai) VALUES (:ma,:ten,:tt)"); $stmt->execute([':ma'=>$r['ma_khoa'],':ten'=>$r['ten_khoa'],':tt'=>$r['trang_thai']]); return 'them_moi';
        case 'bo_mon':
            $stmt=$conn->prepare("INSERT INTO bo_mon (ma_bo_mon,ten_bo_mon,khoa_id,trang_thai) VALUES (:ma,:ten,:khoa,:tt)"); $stmt->execute([':ma'=>$r['ma_bo_mon'],':ten'=>$r['ten_bo_mon'],':khoa'=>$r['khoa_id'],':tt'=>$r['trang_thai']]); return 'them_moi';
        case 'mon_hoc':
            $stmt=$conn->prepare("INSERT INTO mon_hoc (ma_mon,ten_mon,tin_chi,khoa_id,bo_mon_id,trang_thai) VALUES (:ma,:ten,:tin,:khoa,:bm,:tt)"); $stmt->execute([':ma'=>$r['ma_mon'],':ten'=>$r['ten_mon'],':tin'=>$r['tin_chi'],':khoa'=>$r['khoa_id'],':bm'=>$r['bo_mon_id'],':tt'=>$r['trang_thai']]); return 'them_moi';
        case 'lop_hanh_chinh':
            $namNhapHoc = ckc_nam_nhap_hoc_normalize($r['nam_nhap_hoc'] ?? null);
            if ($namNhapHoc === null) {
                throw new Exception('Năm nhập học không hợp lệ');
            }

            $cols = ['ma_lop', 'ten_lop', 'khoa_id', 'trang_thai'];
            $vals = [':ma', ':ten', ':khoa', ':tt'];
            $params = [
                ':ma' => $r['ma_lop'],
                ':ten' => $r['ten_lop'],
                ':khoa' => $r['khoa_id'],
                ':tt' => $r['trang_thai'],
            ];

            $coCotNamNhapHoc = ckc_column_exists($conn, 'lop', 'nam_nhap_hoc');
            $coCotKhoaHoc = ckc_column_exists($conn, 'lop', 'khoa_hoc');
            if (!$coCotNamNhapHoc && !$coCotKhoaHoc) {
                throw new Exception('Bảng lop chưa có cột nam_nhap_hoc hoặc khoa_hoc');
            }
            if ($coCotNamNhapHoc) {
                $cols[] = 'nam_nhap_hoc';
                $vals[] = ':nam_nhap_hoc';
                $params[':nam_nhap_hoc'] = $namNhapHoc;
            }
            if ($coCotKhoaHoc) {
                $cols[] = 'khoa_hoc';
                $vals[] = ':khoa_hoc';
                $params[':khoa_hoc'] = $namNhapHoc . '-' . ($namNhapHoc + 3);
            }

            $sql = 'INSERT INTO lop (' . implode(',', $cols) . ') VALUES (' . implode(',', $vals) . ')';
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            return 'them_moi';
        case 'sinh_vien':
        case 'sinh_vien_theo_lop':
            $lopId = (int)($r['lop_id'] ?? 0);
            $namExpr = ckc_lop_nam_expr($conn);
            $lop = ckc_one(
                $conn,
                "SELECT id, khoa_id, {$namExpr} AS nam_nhap_hoc, trang_thai
                 FROM lop
                 WHERE id = :id
                 LIMIT 1",
                [':id' => $lopId]
            );
            if (!$lop) {
                throw new Exception('Lớp hành chính của sinh viên không còn tồn tại');
            }
            if ($lop['trang_thai'] !== 'dang_hoc') {
                throw new Exception('Lớp hành chính không còn ở trạng thái Đang học');
            }

            $uid = ckc_insert_user(
                $conn,
                $r,
                ckc_role_id($conn, 'sinh_vien'),
                'dang_hoat_dong'
            );

            $cols = [
                'nguoi_dung_id', 'ma_sinh_vien', 'ngay_sinh', 'gioi_tinh',
                'so_dien_thoai', 'cccd', 'dia_chi', 'lop_id', 'khoa_id', 'trang_thai'
            ];
            $vals = [
                ':uid', ':ma', ':ngay', ':gt', ':sdt', ':cccd', ':dc',
                ':lop', ':khoa', ':tt'
            ];
            $params = [
                ':uid' => $uid,
                ':ma' => $r['ma_sinh_vien'],
                ':ngay' => $r['ngay_sinh'] ?: null,
                ':gt' => $r['gioi_tinh'] ?: null,
                ':sdt' => $r['so_dien_thoai'] ?: null,
                ':cccd' => $r['cccd'] ?: null,
                ':dc' => $r['dia_chi'] ?: null,
                ':lop' => (int)$lop['id'],
                ':khoa' => (int)$lop['khoa_id'],
                ':tt' => $r['trang_thai_sinh_vien'] ?? 'dang_hoc',
            ];

            if (ckc_column_exists($conn, 'sinh_vien', 'khoa_hoc')) {
                $cols[] = 'khoa_hoc';
                $vals[] = ':khoa_hoc';
                $params[':khoa_hoc'] = ckc_lop_khoa_hoc($conn, (int)$lop['id']);
            }

            $stmt = $conn->prepare(
                "INSERT INTO sinh_vien (" . implode(',', $cols) . ") VALUES (" . implode(',', $vals) . ")"
            );
            $stmt->execute($params);
            return 'them_moi';
        case 'giang_vien':
            $uid=ckc_insert_user($conn,$r,ckc_role_id($conn,'giang_vien'),$r['trang_thai_tai_khoan']);
            $stmt=$conn->prepare("INSERT INTO giang_vien (nguoi_dung_id,ma_giang_vien,ngay_sinh,gioi_tinh,so_dien_thoai,cccd,dia_chi,bo_mon_id,trang_thai) VALUES (:uid,:ma,:ngay,:gt,:sdt,:cccd,:dc,:bm,:tt)"); $stmt->execute([':uid'=>$uid,':ma'=>$r['ma_giang_vien'],':ngay'=>$r['ngay_sinh'] ?: null,':gt'=>$r['gioi_tinh'] ?: null,':sdt'=>$r['so_dien_thoai'] ?: null,':cccd'=>$r['cccd'] ?: null,':dc'=>$r['dia_chi'] ?: null,':bm'=>$r['bo_mon_id'],':tt'=>$r['trang_thai_giang_vien']]); return 'them_moi';
        case 'lop_hoc_phan':
            $stmt=$conn->prepare("INSERT INTO lop_hoc_phan (ma_lop_hoc_phan,ten_lop,mon_hoc_id,giang_vien_id,hoc_ky,nam_hoc,si_so_toi_da,trang_thai) VALUES (:ma,:ten,:mon,:gv,:hk,:nam,:siso,:tt)");
            $stmt->execute([':ma'=>$r['ma_lop_hoc_phan'],':ten'=>$r['ten_lop'],':mon'=>$r['mon_hoc_id'],':gv'=>$r['giang_vien_id'],':hk'=>$r['hoc_ky'],':nam'=>$r['nam_hoc'],':siso'=>$r['si_so_toi_da'] ?: null,':tt'=>$r['trang_thai']]);
            return 'them_moi';
    }
    throw new Exception('Loại nhập không được hỗ trợ');
}
$data = ckc_json_input();
$loai = ckc_clean($data['loai_nhap'] ?? '');
$tenFile = ckc_clean($data['ten_file'] ?? '');
$nguoiNhapId = (int)($data['nguoi_nhap_id'] ?? 1);
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
        'Không có dữ liệu Excel để xác nhận nhập',
        null,
        400
    );
}

try {
    $conn->beginTransaction();

    /*
     * Luôn kiểm tra lại dữ liệu ngay trước khi ghi CSDL.
     * Điều này tránh dữ liệu bị thay đổi giữa bước xem trước và xác nhận.
     */
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

    if ($tong <= 0) {
        throw new Exception('File Excel không có dòng dữ liệu hợp lệ để xử lý');
    }

    if ($loi > 0) {
        throw new Exception(
            'Dữ liệu đã thay đổi hoặc vẫn còn ' . $loi .
            ' dòng lỗi. Vui lòng kiểm tra lại trước khi nhập.'
        );
    }

    $them = 0;
    $boQua = 0;
    $kich = 0;

    foreach ($ketQua as $line) {
        if ($line['trang_thai'] === 'loi') {
            continue;
        }

        $r = $line['du_lieu'] ?? null;
        if (!is_array($r)) {
            continue;
        }

        $res = ckc_confirm_one(
            $conn,
            $loai,
            $r,
            $line['hanh_dong'] ?? 'them_moi'
        );

        if ($res === 'them_moi') {
            $them++;
        } elseif ($res === 'kich_hoat_lai') {
            $kich++;
        } else {
            $boQua++;
        }
    }

    /*
     * Chỉ tạo lịch sử sau khi toàn bộ dữ liệu nghiệp vụ đã xử lý thành công.
     * Không còn bản ghi cho_xac_nhan trong CSDL.
     */
    $stmt = $conn->prepare(
        "INSERT INTO nhap_excel_dot
            (loai_nhap, ten_file, nguoi_nhap_id, tong_dong,
             so_hop_le, so_loi, so_canh_bao, trang_thai)
         VALUES
            (:loai, :file, :uid, :tong, :hop, 0, :cb, 'da_nhap')"
    );
    $stmt->execute([
        ':loai' => $loai,
        ':file' => $tenFile,
        ':uid' => $nguoiNhapId > 0 ? $nguoiNhapId : null,
        ':tong' => $tong,
        ':hop' => $hopLe,
        ':cb' => $canhBao,
    ]);

    $dotId = (int)$conn->lastInsertId();

    $stmtDong = $conn->prepare(
        "INSERT INTO nhap_excel_dong
            (dot_nhap_id, so_dong, du_lieu_json,
             trang_thai, hanh_dong, thong_bao)
         VALUES
            (:dot, :dong, :json, :tt, :hd, :tb)"
    );

    foreach ($ketQua as $line) {
        $stmtDong->execute([
            ':dot' => $dotId,
            ':dong' => (int)($line['so_dong'] ?? 0),
            ':json' => json_encode(
                $line['du_lieu'] ?? [],
                JSON_UNESCAPED_UNICODE
            ),
            ':tt' => $line['trang_thai'] ?? 'hop_le',
            ':hd' => $line['hanh_dong'] ?? 'them_moi',
            ':tb' => $line['thong_bao'] ?? '',
        ]);
    }

    $conn->commit();

    ckc_json_response('success', 'Nhập dữ liệu Excel thành công', [
        'dot_nhap_id' => $dotId,
        'da_them_moi' => $them,
        'da_kich_hoat_lai' => $kich,
        'bo_qua' => $boQua,
    ]);
} catch (Throwable $e) {
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }

    ckc_json_response(
        'error',
        'Lỗi nhập thật: ' . $e->getMessage(),
        null,
        500
    );
}
?>
