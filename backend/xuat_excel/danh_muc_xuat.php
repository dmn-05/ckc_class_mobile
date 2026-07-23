<?php
require_once __DIR__ . '/_common.php';
xuat_excel_cors_json();
require_once __DIR__ . '/../ket_noi.php';

try {
    $namNhapHocExpr = xuat_excel_nam_nhap_hoc_expression($conn, 'l');
    $khoaHocExpr = xuat_excel_khoa_hoc_expression($conn, 'sv', 'l');

    $whereKhoa = xuat_excel_column_exists($conn, 'khoa', 'deleted_at')
        ? ' WHERE deleted_at IS NULL'
        : '';
    $whereBoMon = xuat_excel_column_exists($conn, 'bo_mon', 'deleted_at')
        ? ' WHERE deleted_at IS NULL'
        : '';
    $whereLop = xuat_excel_column_exists($conn, 'lop', 'deleted_at')
        ? ' WHERE l.deleted_at IS NULL'
        : '';
    $whereMonHoc = xuat_excel_column_exists($conn, 'mon_hoc', 'deleted_at')
        ? ' WHERE deleted_at IS NULL'
        : '';
    $whereGiangVien = xuat_excel_column_exists($conn, 'giang_vien', 'deleted_at')
        ? ' WHERE gv.deleted_at IS NULL'
        : '';
    $whereSinhVien = xuat_excel_column_exists($conn, 'sinh_vien', 'deleted_at')
        ? ' WHERE sv.deleted_at IS NULL'
        : '';

    $khoa = $conn->query("SELECT id, ma_khoa, ten_khoa, trang_thai
        FROM khoa{$whereKhoa} ORDER BY ma_khoa")->fetchAll(PDO::FETCH_ASSOC);
    $boMon = $conn->query("SELECT id, ma_bo_mon, ten_bo_mon, khoa_id, trang_thai
        FROM bo_mon{$whereBoMon} ORDER BY ma_bo_mon")->fetchAll(PDO::FETCH_ASSOC);
    $lop = $conn->query("SELECT l.id, l.ma_lop, l.ten_lop, l.khoa_id,
            {$namNhapHocExpr} AS nam_nhap_hoc, l.trang_thai
        FROM lop l{$whereLop} ORDER BY l.ma_lop")->fetchAll(PDO::FETCH_ASSOC);
    $monHoc = $conn->query("SELECT id, ma_mon, ten_mon, khoa_id, bo_mon_id, trang_thai
        FROM mon_hoc{$whereMonHoc} ORDER BY ma_mon")->fetchAll(PDO::FETCH_ASSOC);
    $giangVien = $conn->query("SELECT gv.id, gv.ma_giang_vien, nd.ho_ten,
            gv.bo_mon_id, gv.trang_thai
        FROM giang_vien gv
        INNER JOIN nguoi_dung nd ON nd.id = gv.nguoi_dung_id
        {$whereGiangVien}
        ORDER BY gv.ma_giang_vien")->fetchAll(PDO::FETCH_ASSOC);
    $lopHocPhan = $conn->query("SELECT lhp.id, lhp.ma_lop_hoc_phan,
            lhp.ten_lop, lhp.nam_hoc, lhp.hoc_ky, lhp.trang_thai,
            mh.ma_mon, mh.ten_mon
        FROM lop_hoc_phan lhp
        LEFT JOIN mon_hoc mh ON mh.id = lhp.mon_hoc_id
        ORDER BY lhp.id DESC")->fetchAll(PDO::FETCH_ASSOC);
    $khoaHoc = $conn->query("SELECT DISTINCT {$khoaHocExpr} AS khoa_hoc
        FROM sinh_vien sv
        INNER JOIN lop l ON l.id = sv.lop_id
        {$whereSinhVien}
        HAVING khoa_hoc IS NOT NULL AND khoa_hoc <> ''
        ORDER BY khoa_hoc")->fetchAll(PDO::FETCH_COLUMN);
    $namWhere = $whereLop === ''
        ? " WHERE {$namNhapHocExpr} IS NOT NULL"
        : $whereLop . " AND {$namNhapHocExpr} IS NOT NULL";
    $namNhapHoc = $conn->query("SELECT DISTINCT {$namNhapHocExpr} AS nam_nhap_hoc
        FROM lop l{$namWhere}
        ORDER BY nam_nhap_hoc DESC")->fetchAll(PDO::FETCH_COLUMN);
    $namHoc = $conn->query("SELECT DISTINCT nam_hoc FROM lop_hoc_phan WHERE nam_hoc IS NOT NULL AND nam_hoc <> '' ORDER BY nam_hoc DESC")->fetchAll(PDO::FETCH_COLUMN);

    xuat_excel_response('success', 'Lấy danh mục xuất thành công', [
        'khoa' => $khoa,
        'bo_mon' => $boMon,
        'lop' => $lop,
        'mon_hoc' => $monHoc,
        'giang_vien' => $giangVien,
        'lop_hoc_phan' => $lopHocPhan,
        'khoa_hoc' => array_values($khoaHoc),
        'nam_nhap_hoc' => array_map('intval', array_values($namNhapHoc)),
        'nam_hoc' => array_values($namHoc),
        'hoc_ky' => ['HK1', 'HK2', 'HK3', 'HK4', 'HK5', 'HK6'],
    ]);
} catch (Throwable $e) {
    xuat_excel_response('error', 'Không thể lấy danh mục xuất', ['detail' => $e->getMessage()], 500);
}
