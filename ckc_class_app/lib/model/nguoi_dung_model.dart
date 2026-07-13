int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  final direct = DateTime.tryParse(text);
  if (direct != null) return direct;

  final slash = RegExp(r'^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})$').firstMatch(text);
  if (slash != null) {
    final day = int.tryParse(slash.group(1)!);
    final month = int.tryParse(slash.group(2)!);
    final year = int.tryParse(slash.group(3)!);
    if (day != null && month != null && year != null) {
      return DateTime.tryParse(
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      );
    }
  }

  return null;
}

class VaiTro {
  final int id;
  final String tenVaiTro;

  VaiTro({required this.id, required this.tenVaiTro});

  factory VaiTro.fromJson(Map<String, dynamic> json) {
    return VaiTro(
      id: int.tryParse(json['id'].toString()) ?? 0,
      tenVaiTro: json['ten_vai_tro']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'ten_vai_tro': tenVaiTro};
  }

  String get tenHienThi {
    switch (tenVaiTro) {
      case 'admin':
      case 'quan_tri':
        return 'Admin';
      case 'giang_vien':
        return 'Giảng viên';
      case 'sinh_vien':
        return 'Sinh viên';
      default:
        return tenVaiTro;
    }
  }
}

class KhoaNguoiDung {
  final int id;
  final String maKhoa;
  final String tenKhoa;

  KhoaNguoiDung({
    required this.id,
    required this.maKhoa,
    required this.tenKhoa,
  });

  factory KhoaNguoiDung.fromJson(Map<String, dynamic> json) {
    return KhoaNguoiDung(
      id: _toInt(json['id']) ?? 0,
      maKhoa: json['ma_khoa']?.toString() ?? '',
      tenKhoa: json['ten_khoa']?.toString() ?? '',
    );
  }

  String get tenHienThi {
    final ma = maKhoa.trim();
    final ten = tenKhoa.trim();
    if (ma.isEmpty) return ten.isEmpty ? 'Khoa #$id' : ten;
    if (ten.isEmpty) return ma;
    return '$ma - $ten';
  }
}

class LopHanhChinhNguoiDung {
  final int id;
  final String maLop;
  final String tenLop;
  final int? khoaId;

  LopHanhChinhNguoiDung({
    required this.id,
    required this.maLop,
    required this.tenLop,
    this.khoaId,
  });

  factory LopHanhChinhNguoiDung.fromJson(Map<String, dynamic> json) {
    return LopHanhChinhNguoiDung(
      id: _toInt(json['id']) ?? 0,
      maLop: json['ma_lop']?.toString() ?? '',
      tenLop: json['ten_lop']?.toString() ?? '',
      khoaId: _toInt(json['khoa_id']),
    );
  }

  String get tenHienThi {
    final ma = maLop.trim();
    final ten = tenLop.trim();
    if (ma.isEmpty) return ten.isEmpty ? 'Lớp #$id' : ten;
    if (ten.isEmpty) return ma;
    return '$ma - $ten';
  }
}

class BoMonNguoiDung {
  final int id;
  final String maBoMon;
  final String tenBoMon;
  final int? khoaId;

  BoMonNguoiDung({
    required this.id,
    required this.maBoMon,
    required this.tenBoMon,
    this.khoaId,
  });

  factory BoMonNguoiDung.fromJson(Map<String, dynamic> json) {
    return BoMonNguoiDung(
      id: _toInt(json['id']) ?? 0,
      maBoMon: json['ma_bo_mon']?.toString() ?? '',
      tenBoMon: json['ten_bo_mon']?.toString() ?? '',
      khoaId: _toInt(json['khoa_id']),
    );
  }

  String get tenHienThi {
    final ma = maBoMon.trim();
    final ten = tenBoMon.trim();
    if (ma.isEmpty) return ten.isEmpty ? 'Bộ môn #$id' : ten;
    if (ten.isEmpty) return ma;
    return '$ma - $ten';
  }
}

class NguoiDung {
  final int id;
  final String hoTen;
  final String email;
  final String? matKhau;
  final int vaiTroId;
  final String? tenVaiTro;
  final String trangThai;
  final String? avatar;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  final int? giangVienId;
  final String? maGiangVien;
  final String? trangThaiGiangVien;
  final DateTime? ngayTaoGiangVien;
  final DateTime? ngayCapNhatGiangVien;

  final int? sinhVienId;
  final String? maSinhVien;
  final String? trangThaiSinhVien;
  final DateTime? ngayTaoSinhVien;
  final DateTime? ngayCapNhatSinhVien;

  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? soDienThoai;
  final String? cccd;
  final String? diaChi;

  final int? boMonId;
  final String? maBoMon;
  final String? tenBoMon;
  final int? khoaGiangVienId;
  final String? maKhoaGiangVien;
  final String? tenKhoaGiangVien;

  final int? lopId;
  final String? maLop;
  final String? tenLop;
  final int? khoaSinhVienId;
  final String? maKhoaSinhVien;
  final String? tenKhoaSinhVien;

  final VaiTro? vaiTro;

  NguoiDung({
    required this.id,
    required this.hoTen,
    required this.email,
    this.matKhau,
    required this.vaiTroId,
    this.tenVaiTro,
    this.trangThai = 'dang_hoat_dong',
    this.avatar,
    this.ngayTao,
    this.ngayCapNhat,
    this.giangVienId,
    this.maGiangVien,
    this.trangThaiGiangVien,
    this.ngayTaoGiangVien,
    this.ngayCapNhatGiangVien,
    this.sinhVienId,
    this.maSinhVien,
    this.trangThaiSinhVien,
    this.ngayTaoSinhVien,
    this.ngayCapNhatSinhVien,
    this.ngaySinh,
    this.gioiTinh,
    this.soDienThoai,
    this.cccd,
    this.diaChi,
    this.boMonId,
    this.maBoMon,
    this.tenBoMon,
    this.khoaGiangVienId,
    this.maKhoaGiangVien,
    this.tenKhoaGiangVien,
    this.lopId,
    this.maLop,
    this.tenLop,
    this.khoaSinhVienId,
    this.maKhoaSinhVien,
    this.tenKhoaSinhVien,
    this.vaiTro,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    return NguoiDung(
      id: _toInt(json['id']) ?? 0,
      hoTen: json['ho_ten']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      matKhau: _toStringOrNull(json['mat_khau']),
      vaiTroId: _toInt(json['vai_tro_id']) ?? 0,
      tenVaiTro: _toStringOrNull(json['ten_vai_tro']),
      trangThai: json['trang_thai']?.toString() ?? 'dang_hoat_dong',
      avatar: _toStringOrNull(json['avatar']),
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),

      giangVienId: _toInt(json['giang_vien_id']),
      maGiangVien: _toStringOrNull(json['ma_giang_vien']),
      trangThaiGiangVien: _toStringOrNull(json['trang_thai_giang_vien']),
      ngayTaoGiangVien: _toDateTime(json['ngay_tao_giang_vien']),
      ngayCapNhatGiangVien: _toDateTime(json['ngay_cap_nhat_giang_vien']),

      sinhVienId: _toInt(json['sinh_vien_id']),
      maSinhVien: _toStringOrNull(json['ma_sinh_vien']),
      trangThaiSinhVien: _toStringOrNull(json['trang_thai_sinh_vien']),
      ngayTaoSinhVien: _toDateTime(json['ngay_tao_sinh_vien']),
      ngayCapNhatSinhVien: _toDateTime(json['ngay_cap_nhat_sinh_vien']),

      ngaySinh: _toDateTime(json['ngay_sinh']),
      gioiTinh: _toStringOrNull(json['gioi_tinh']),
      soDienThoai: _toStringOrNull(json['so_dien_thoai']),
      cccd: _toStringOrNull(json['cccd']),
      diaChi: _toStringOrNull(json['dia_chi']),

      boMonId: _toInt(json['bo_mon_id']),
      maBoMon: _toStringOrNull(json['ma_bo_mon']),
      tenBoMon: _toStringOrNull(json['ten_bo_mon']),
      khoaGiangVienId: _toInt(json['khoa_giang_vien_id']),
      maKhoaGiangVien: _toStringOrNull(json['ma_khoa_giang_vien']),
      tenKhoaGiangVien: _toStringOrNull(json['ten_khoa_giang_vien']),

      lopId: _toInt(json['lop_id']),
      maLop: _toStringOrNull(json['ma_lop']),
      tenLop: _toStringOrNull(json['ten_lop']),
      khoaSinhVienId: _toInt(json['khoa_sinh_vien_id']),
      maKhoaSinhVien: _toStringOrNull(json['ma_khoa_sinh_vien']),
      tenKhoaSinhVien: _toStringOrNull(json['ten_khoa_sinh_vien']),

      vaiTro: json['vai_tro'] is Map
          ? VaiTro.fromJson(Map<String, dynamic>.from(json['vai_tro']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ho_ten': hoTen,
      'email': email,
      'mat_khau': matKhau,
      'vai_tro_id': vaiTroId,
      'ten_vai_tro': tenVaiTro,
      'trang_thai': trangThai,
      'avatar': avatar,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),

      'giang_vien_id': giangVienId,
      'ma_giang_vien': maGiangVien,
      'trang_thai_giang_vien': trangThaiGiangVien,
      'ngay_tao_giang_vien': ngayTaoGiangVien?.toIso8601String(),
      'ngay_cap_nhat_giang_vien': ngayCapNhatGiangVien?.toIso8601String(),

      'sinh_vien_id': sinhVienId,
      'ma_sinh_vien': maSinhVien,
      'trang_thai_sinh_vien': trangThaiSinhVien,
      'ngay_tao_sinh_vien': ngayTaoSinhVien?.toIso8601String(),
      'ngay_cap_nhat_sinh_vien': ngayCapNhatSinhVien?.toIso8601String(),

      'ngay_sinh': ngaySinh?.toIso8601String(),
      'gioi_tinh': gioiTinh,
      'so_dien_thoai': soDienThoai,
      'cccd': cccd,
      'dia_chi': diaChi,

      'bo_mon_id': boMonId,
      'ma_bo_mon': maBoMon,
      'ten_bo_mon': tenBoMon,
      'khoa_giang_vien_id': khoaGiangVienId,
      'ma_khoa_giang_vien': maKhoaGiangVien,
      'ten_khoa_giang_vien': tenKhoaGiangVien,

      'lop_id': lopId,
      'ma_lop': maLop,
      'ten_lop': tenLop,
      'khoa_sinh_vien_id': khoaSinhVienId,
      'ma_khoa_sinh_vien': maKhoaSinhVien,
      'ten_khoa_sinh_vien': tenKhoaSinhVien,

      'vai_tro': vaiTro?.toJson(),
    };
  }

  bool get isAdmin => vaiTroId == 1 || tenVaiTro == 'admin' || tenVaiTro == 'quan_tri';

  bool get isGiangVien => vaiTroId == 2 || tenVaiTro == 'giang_vien';

  bool get isSinhVien => vaiTroId == 3 || tenVaiTro == 'sinh_vien';

  bool get isHoatDong => trangThai == 'dang_hoat_dong';

  bool get biKhoa => trangThai == 'bi_khoa';

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoat_dong':
        return 'Đang hoạt động';
      case 'bi_khoa':
        return 'Bị khóa';
      default:
        return trangThai;
    }
  }

  String get tenVaiTroHienThi {
    switch (tenVaiTro ?? '') {
      case 'admin':
      case 'quan_tri':
        return 'Admin';
      case 'giang_vien':
        return 'Giảng viên';
      case 'sinh_vien':
        return 'Sinh viên';
      default:
        return tenVaiTro ?? '';
    }
  }

  String get tenGioiTinh {
    switch (gioiTinh ?? '') {
      case 'nam':
        return 'Nam';
      case 'nu':
        return 'Nữ';
      case 'khac':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }

  String get tenTrangThaiGiangVien {
    switch (trangThaiGiangVien ?? '') {
      case 'dang_day':
        return 'Đang dạy';
      case 'ngung_day':
        return 'Ngừng dạy';
      default:
        return 'Chưa có hồ sơ giảng viên';
    }
  }

  String get tenTrangThaiSinhVien {
    switch (trangThaiSinhVien ?? '') {
      case 'dang_hoc':
        return 'Đang học';
      case 'tam_nghi':
        return 'Tạm nghỉ';
      case 'da_tot_nghiep':
        return 'Đã tốt nghiệp';
      default:
        return 'Chưa có hồ sơ sinh viên';
    }
  }

  NguoiDung copyWith({
    int? id,
    String? hoTen,
    String? email,
    int? vaiTroId,
    String? tenVaiTro,
    String? trangThai,
    String? avatar,
    DateTime? ngaySinh,
    String? gioiTinh,
    String? soDienThoai,
    String? cccd,
    String? diaChi,
  }) {
    return NguoiDung(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      matKhau: matKhau,
      vaiTroId: vaiTroId ?? this.vaiTroId,
      tenVaiTro: tenVaiTro ?? this.tenVaiTro,
      trangThai: trangThai ?? this.trangThai,
      avatar: avatar ?? this.avatar,
      ngayTao: ngayTao,
      ngayCapNhat: ngayCapNhat,
      giangVienId: giangVienId,
      maGiangVien: maGiangVien,
      trangThaiGiangVien: trangThaiGiangVien,
      ngayTaoGiangVien: ngayTaoGiangVien,
      ngayCapNhatGiangVien: ngayCapNhatGiangVien,
      sinhVienId: sinhVienId,
      maSinhVien: maSinhVien,
      trangThaiSinhVien: trangThaiSinhVien,
      ngayTaoSinhVien: ngayTaoSinhVien,
      ngayCapNhatSinhVien: ngayCapNhatSinhVien,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      cccd: cccd ?? this.cccd,
      diaChi: diaChi ?? this.diaChi,
      boMonId: boMonId,
      maBoMon: maBoMon,
      tenBoMon: tenBoMon,
      khoaGiangVienId: khoaGiangVienId,
      maKhoaGiangVien: maKhoaGiangVien,
      tenKhoaGiangVien: tenKhoaGiangVien,
      lopId: lopId,
      maLop: maLop,
      tenLop: tenLop,
      khoaSinhVienId: khoaSinhVienId,
      maKhoaSinhVien: maKhoaSinhVien,
      tenKhoaSinhVien: tenKhoaSinhVien,
      vaiTro: vaiTro,
    );
  }
}
