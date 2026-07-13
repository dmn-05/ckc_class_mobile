int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;

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

class SinhVienLopHocPhan {
  final int id;
  final int sinhVienId;
  final int lopHocPhanId;
  final String trangThai;
  final DateTime? ngayDangKy;

  final String maSinhVien;
  final String hoTen;
  final String email;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? soDienThoai;
  final String? cccd;
  final String? diaChi;
  final String? trangThaiSinhVien;
  final String? trangThaiTaiKhoan;

  final int? lopId;
  final String? maLop;
  final String? tenLopHanhChinh;

  final int? khoaId;
  final String? maKhoa;
  final String? tenKhoa;

  SinhVienLopHocPhan({
    required this.id,
    required this.sinhVienId,
    required this.lopHocPhanId,
    required this.trangThai,
    this.ngayDangKy,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.ngaySinh,
    this.gioiTinh,
    this.soDienThoai,
    this.cccd,
    this.diaChi,
    this.trangThaiSinhVien,
    this.trangThaiTaiKhoan,
    this.lopId,
    this.maLop,
    this.tenLopHanhChinh,
    this.khoaId,
    this.maKhoa,
    this.tenKhoa,
  });

  factory SinhVienLopHocPhan.fromJson(Map<String, dynamic> json) {
    return SinhVienLopHocPhan(
      id: _toInt(json['id']),
      sinhVienId: _toInt(json['sinh_vien_id']),
      lopHocPhanId: _toInt(json['lop_hoc_phan_id']),
      trangThai: json['trang_thai']?.toString() ?? 'dang_hoc',
      ngayDangKy: _toDateTime(json['ngay_dang_ky']),
      maSinhVien: json['ma_sinh_vien']?.toString() ?? '',
      hoTen: json['ho_ten']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      ngaySinh: _toDateTime(json['ngay_sinh']),
      gioiTinh: _toStringOrNull(json['gioi_tinh']),
      soDienThoai: _toStringOrNull(json['so_dien_thoai']),
      cccd: _toStringOrNull(json['cccd']),
      diaChi: _toStringOrNull(json['dia_chi']),
      trangThaiSinhVien: _toStringOrNull(json['trang_thai_sinh_vien']),
      trangThaiTaiKhoan: _toStringOrNull(json['trang_thai_tai_khoan']),
      lopId: _toIntOrNull(json['lop_id']),
      maLop: _toStringOrNull(json['ma_lop']),
      tenLopHanhChinh: _toStringOrNull(json['ten_lop_hanh_chinh']),
      khoaId: _toIntOrNull(json['khoa_id']),
      maKhoa: _toStringOrNull(json['ma_khoa']),
      tenKhoa: _toStringOrNull(json['ten_khoa']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinh_vien_id': sinhVienId,
      'lop_hoc_phan_id': lopHocPhanId,
      'trang_thai': trangThai,
      'ngay_dang_ky': ngayDangKy?.toIso8601String(),
      'ma_sinh_vien': maSinhVien,
      'ho_ten': hoTen,
      'email': email,
      'ngay_sinh': ngaySinh?.toIso8601String(),
      'gioi_tinh': gioiTinh,
      'so_dien_thoai': soDienThoai,
      'cccd': cccd,
      'dia_chi': diaChi,
      'trang_thai_sinh_vien': trangThaiSinhVien,
      'trang_thai_tai_khoan': trangThaiTaiKhoan,
      'lop_id': lopId,
      'ma_lop': maLop,
      'ten_lop_hanh_chinh': tenLopHanhChinh,
      'khoa_id': khoaId,
      'ma_khoa': maKhoa,
      'ten_khoa': tenKhoa,
    };
  }
  static const String DANG_HOC = 'dang_hoc';
  static const String DA_HUY = 'da_huy';
  static const String HOAN_THANH = 'hoan_thanh';

  bool get dangHoc => trangThai == 'dang_hoc';
  bool get daHuy => trangThai == 'da_huy';
  bool get hoanThanh => trangThai == 'hoan_thanh';

  String get trangThaiHienThi {
  switch (trangThai) {
    case 'dang_hoc':
      return 'Đang học';
    case 'da_huy':
      return 'Đã rút';
    case 'hoan_thanh':
      return 'Hoàn thành';
    default:
      return 'Không xác định';
  }
}

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoc':
        return 'Đang học';
      case 'da_huy':
        return 'Đã hủy';
      case 'hoan_thanh':
        return 'Hoàn thành';
      default:
        return trangThai;
    }
  }

  String get tenLopHienThi {
    final ma = maLop ?? '';
    final ten = tenLopHanhChinh ?? '';

    if (ma.isEmpty && ten.isEmpty) return 'Chưa có lớp hành chính';
    if (ma.isEmpty) return ten;
    if (ten.isEmpty) return ma;

    return '$ma - $ten';
  }

  String get tenKhoaHienThi {
    final ma = maKhoa ?? '';
    final ten = tenKhoa ?? '';

    if (ma.isEmpty && ten.isEmpty) return 'Chưa có khoa';
    if (ma.isEmpty) return ten;
    if (ten.isEmpty) return ma;

    return '$ma - $ten';
  }
}

class SinhVienCoTheThemLhp {
  final int sinhVienId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final String? trangThaiSinhVien;
  final String? trangThaiTaiKhoan;
  final String? maLop;
  final String? tenLopHanhChinh;
  final String? maKhoa;
  final String? tenKhoa;
  final int? dangKyId;
  final String? trangThaiDangKy;

  SinhVienCoTheThemLhp({
    required this.sinhVienId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.trangThaiSinhVien,
    this.trangThaiTaiKhoan,
    this.maLop,
    this.tenLopHanhChinh,
    this.maKhoa,
    this.tenKhoa,
    this.dangKyId,
    this.trangThaiDangKy,
  });

  factory SinhVienCoTheThemLhp.fromJson(Map<String, dynamic> json) {
    return SinhVienCoTheThemLhp(
      sinhVienId: _toInt(json['sinh_vien_id']),
      maSinhVien: json['ma_sinh_vien']?.toString() ?? '',
      hoTen: json['ho_ten']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      trangThaiSinhVien: _toStringOrNull(json['trang_thai_sinh_vien']),
      trangThaiTaiKhoan: _toStringOrNull(json['trang_thai_tai_khoan']),
      maLop: _toStringOrNull(json['ma_lop']),
      tenLopHanhChinh: _toStringOrNull(json['ten_lop_hanh_chinh']),
      maKhoa: _toStringOrNull(json['ma_khoa']),
      tenKhoa: _toStringOrNull(json['ten_khoa']),
      dangKyId: _toIntOrNull(json['dang_ky_id']),
      trangThaiDangKy: _toStringOrNull(json['trang_thai_dang_ky']),
    );
  }

  String get tenLopHienThi {
    final ma = maLop ?? '';
    final ten = tenLopHanhChinh ?? '';

    if (ma.isEmpty && ten.isEmpty) return 'Chưa có lớp hành chính';
    if (ma.isEmpty) return ten;
    if (ten.isEmpty) return ma;

    return '$ma - $ten';
  }

  String get tenKhoaHienThi {
    final ma = maKhoa ?? '';
    final ten = tenKhoa ?? '';

    if (ma.isEmpty && ten.isEmpty) return 'Chưa có khoa';
    if (ma.isEmpty) return ten;
    if (ten.isEmpty) return ma;

    return '$ma - $ten';
  }

  bool get daTungHuyKhoiLop => trangThaiDangKy == 'da_huy';
}
