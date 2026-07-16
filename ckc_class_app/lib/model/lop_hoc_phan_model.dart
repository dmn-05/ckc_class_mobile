int _toInt(dynamic value) {
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return int.tryParse(text);
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return text;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return DateTime.tryParse(text);
}

class LopHocPhan {
  final int id;
  final String maLopHocPhan;
  final String tenLop;
  final int? monHocId;
  final int? giangVienId;
  final String hocKy;
  final String namHoc;
  final int? siSoToiDa;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  final int tongSoSinhVien;
  final int soSinhVienDangHoc;

  final String? maMon;
  final String? tenMon;
  final int? tinChi;
  final String? trangThaiMonHoc;

  final String? maBoMon;
  final String? tenBoMon;

  final int? khoaId;
  final String? maKhoa;
  final String? tenKhoa;

  final String? maGiangVien;
  final String? tenGiangVien;
  final String? emailGiangVien;
  final String? trangThaiGiangVien;
  final String? trangThaiTaiKhoanGv;

  LopHocPhan({
    required this.id,
    required this.maLopHocPhan,
    required this.tenLop,
    this.monHocId,
    this.giangVienId,
    required this.hocKy,
    required this.namHoc,
    this.siSoToiDa,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.tongSoSinhVien = 0,
    this.soSinhVienDangHoc = 0,
    this.maMon,
    this.tenMon,
    this.tinChi,
    this.trangThaiMonHoc,
    this.maBoMon,
    this.tenBoMon,
    this.khoaId,
    this.maKhoa,
    this.tenKhoa,
    this.maGiangVien,
    this.tenGiangVien,
    this.emailGiangVien,
    this.trangThaiGiangVien,
    this.trangThaiTaiKhoanGv,
  });

  factory LopHocPhan.fromJson(Map<String, dynamic> json) {
    return LopHocPhan(
      id: _toInt(json['id']),
      maLopHocPhan: json['ma_lop_hoc_phan']?.toString() ?? '',
      tenLop: json['ten_lop']?.toString() ?? '',
      monHocId: _toIntOrNull(json['mon_hoc_id']),
      giangVienId: _toIntOrNull(json['giang_vien_id']),
      hocKy: json['hoc_ky']?.toString() ?? 'HK1',
      namHoc: json['nam_hoc']?.toString() ?? '',
      siSoToiDa: _toIntOrNull(json['si_so_toi_da']),
      trangThai: json['trang_thai']?.toString() ?? 'dang_mo',
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
      tongSoSinhVien: _toInt(json['tong_so_sinh_vien']),
      soSinhVienDangHoc: _toInt(json['so_sinh_vien_dang_hoc']),
      maMon: _toStringOrNull(json['ma_mon']),
      tenMon: _toStringOrNull(json['ten_mon']),
      tinChi: _toIntOrNull(json['tin_chi']),
      trangThaiMonHoc: _toStringOrNull(json['trang_thai_mon_hoc']),
      maBoMon: _toStringOrNull(json['ma_bo_mon']),
      tenBoMon: _toStringOrNull(json['ten_bo_mon']),
      khoaId: _toIntOrNull(json['khoa_id']),
      maKhoa: _toStringOrNull(json['ma_khoa']),
      tenKhoa: _toStringOrNull(json['ten_khoa']),
      maGiangVien: _toStringOrNull(json['ma_giang_vien']),
      tenGiangVien: _toStringOrNull(json['ten_giang_vien']),
      emailGiangVien: _toStringOrNull(json['email_giang_vien']),
      trangThaiGiangVien: _toStringOrNull(json['trang_thai_giang_vien']),
      trangThaiTaiKhoanGv: _toStringOrNull(json['trang_thai_tai_khoan_gv']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_lop_hoc_phan': maLopHocPhan,
      'ten_lop': tenLop,
      'mon_hoc_id': monHocId,
      'giang_vien_id': giangVienId,
      'hoc_ky': hocKy,
      'nam_hoc': namHoc,
      'si_so_toi_da': siSoToiDa,
      'trang_thai': trangThai,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),
      'tong_so_sinh_vien': tongSoSinhVien,
      'so_sinh_vien_dang_hoc': soSinhVienDangHoc,
      'ma_mon': maMon,
      'ten_mon': tenMon,
      'tin_chi': tinChi,
      'trang_thai_mon_hoc': trangThaiMonHoc,
      'ma_bo_mon': maBoMon,
      'ten_bo_mon': tenBoMon,
      'khoa_id': khoaId,
      'ma_khoa': maKhoa,
      'ten_khoa': tenKhoa,
      'ma_giang_vien': maGiangVien,
      'ten_giang_vien': tenGiangVien,
      'email_giang_vien': emailGiangVien,
      'trang_thai_giang_vien': trangThaiGiangVien,
      'trang_thai_tai_khoan_gv': trangThaiTaiKhoanGv,
    };
  }

  bool get dangMo => trangThai == 'dang_mo';

  bool get daKhoa => trangThai == 'da_khoa';

  bool get daKetThuc => trangThai == 'da_ket_thuc';

  bool get isDaLuu => daKhoa || daKetThuc;

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_mo':
        return 'Đang mở';
      case 'da_khoa':
        return 'Đã khóa';
      case 'da_ket_thuc':
        return 'Đã kết thúc';
      default:
        return trangThai;
    }
  }

  String get tenMonHienThi {
    if ((maMon ?? '').isEmpty && (tenMon ?? '').isEmpty) {
      return 'Chưa có môn học';
    }

    if ((maMon ?? '').isEmpty) return tenMon ?? '';
    if ((tenMon ?? '').isEmpty) return maMon ?? '';

    return '$maMon - $tenMon';
  }

  String get tenGiangVienHienThi {
    if ((maGiangVien ?? '').isEmpty && (tenGiangVien ?? '').isEmpty) {
      return 'Chưa có giảng viên';
    }

    if ((maGiangVien ?? '').isEmpty) return tenGiangVien ?? '';
    if ((tenGiangVien ?? '').isEmpty) return maGiangVien ?? '';

    return '$maGiangVien - $tenGiangVien';
  }

  String get tenKhoaHienThi {
    if ((maKhoa ?? '').isEmpty && (tenKhoa ?? '').isEmpty) {
      return 'Chưa có khoa';
    }

    if ((maKhoa ?? '').isEmpty) return tenKhoa ?? '';
    if ((tenKhoa ?? '').isEmpty) return maKhoa ?? '';

    return '$maKhoa - $tenKhoa';
  }

  String get siSoHienThi {
    if (siSoToiDa == null) {
      return '$soSinhVienDangHoc';
    }

    return '$soSinhVienDangHoc/$siSoToiDa';
  }
}
