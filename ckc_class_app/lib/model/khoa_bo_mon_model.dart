

int _toInt(dynamic value) {
  return int.tryParse(value.toString()) ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

class Khoa {
  final int id;
  final String maKhoa;
  final String tenKhoa;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  Khoa({
    required this.id,
    required this.maKhoa,
    required this.tenKhoa,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
  });

  factory Khoa.fromJson(Map<String, dynamic> json) {
    return Khoa(
      id: _toInt(json['id']),
      maKhoa: json['ma_khoa']?.toString() ?? '',
      tenKhoa: json['ten_khoa']?.toString() ?? '',
      trangThai: json['trang_thai']?.toString() ?? 'dang_hoat_dong',
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_khoa': maKhoa,
      'ten_khoa': tenKhoa,
      'trang_thai': trangThai,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),
    };
  }

  bool get dangHoatDong => trangThai == 'dang_hoat_dong';

  bool get ngungHoatDong => trangThai == 'ngung_hoat_dong';

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoat_dong':
        return 'Đang hoạt động';
      case 'ngung_hoat_dong':
        return 'Ngừng hoạt động';
      default:
        return trangThai;
    }
  }
}

class BoMon {
  final int id;
  final String maBoMon;
  final String tenBoMon;
  final int khoaId;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final Khoa? khoa;

  BoMon({
    required this.id,
    required this.maBoMon,
    required this.tenBoMon,
    required this.khoaId,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.khoa,
  });

  factory BoMon.fromJson(Map<String, dynamic> json) {
    return BoMon(
      id: _toInt(json['id']),
      maBoMon: json['ma_bo_mon']?.toString() ?? '',
      tenBoMon: json['ten_bo_mon']?.toString() ?? '',
      khoaId: _toInt(json['khoa_id']),
      trangThai: json['trang_thai']?.toString() ?? 'dang_hoat_dong',
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
      khoa: json['khoa'] != null
          ? Khoa.fromJson(Map<String, dynamic>.from(json['khoa']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_bo_mon': maBoMon,
      'ten_bo_mon': tenBoMon,
      'khoa_id': khoaId,
      'trang_thai': trangThai,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),
      'khoa': khoa?.toJson(),
    };
  }

  bool get dangHoatDong => trangThai == 'dang_hoat_dong';

  bool get ngungHoatDong => trangThai == 'ngung_hoat_dong';

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoat_dong':
        return 'Đang hoạt động';
      case 'ngung_hoat_dong':
        return 'Ngừng hoạt động';
      default:
        return trangThai;
    }
  }
}

class MonHoc {
  final int id;
  final String maMon;
  final String tenMon;
  final int tinChi;
  final int khoaId;
  final int boMonId;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  final String? maKhoa;
  final String? tenKhoa;
  final String? maBoMon;
  final String? tenBoMon;

  final Khoa? khoa;
  final BoMon? boMon;

  MonHoc({
    required this.id,
    required this.maMon,
    required this.tenMon,
    required this.tinChi,
    required this.khoaId,
    required this.boMonId,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.maKhoa,
    this.tenKhoa,
    this.maBoMon,
    this.tenBoMon,
    this.khoa,
    this.boMon,
  });

  factory MonHoc.fromJson(Map<String, dynamic> json) {
    return MonHoc(
      id: _toInt(json['id']),
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? '',
      tinChi: _toInt(json['tin_chi']),
      khoaId: _toInt(json['khoa_id']),
      boMonId: _toInt(json['bo_mon_id']),
      trangThai: json['trang_thai']?.toString() ?? 'dang_mo',
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
      maKhoa: json['ma_khoa']?.toString(),
      tenKhoa: json['ten_khoa']?.toString(),
      maBoMon: json['ma_bo_mon']?.toString(),
      tenBoMon: json['ten_bo_mon']?.toString(),
      khoa: json['khoa'] != null
          ? Khoa.fromJson(Map<String, dynamic>.from(json['khoa']))
          : null,
      boMon: json['bo_mon'] != null
          ? BoMon.fromJson(Map<String, dynamic>.from(json['bo_mon']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_mon': maMon,
      'ten_mon': tenMon,
      'tin_chi': tinChi,
      'khoa_id': khoaId,
      'bo_mon_id': boMonId,
      'trang_thai': trangThai,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),
      'ma_khoa': maKhoa,
      'ten_khoa': tenKhoa,
      'ma_bo_mon': maBoMon,
      'ten_bo_mon': tenBoMon,
      'khoa': khoa?.toJson(),
      'bo_mon': boMon?.toJson(),
    };
  }

  bool get dangMo => trangThai == 'dang_mo';

  bool get ngungSuDung => trangThai == 'ngung_su_dung';

  bool get dangHoatDong => dangMo;

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_mo':
        return 'Đang mở';
      case 'ngung_su_dung':
        return 'Ngừng sử dụng';
      default:
        return trangThai;
    }
  }
}

class DangKyLop {
  final int id;
  final int sinhVienId;
  final int lopHocPhanId;
  final DateTime? ngayDangKy;

  DangKyLop({
    required this.id,
    required this.sinhVienId,
    required this.lopHocPhanId,
    this.ngayDangKy,
  });

  factory DangKyLop.fromJson(Map<String, dynamic> json) {
    return DangKyLop(
      id: _toInt(json['id']),
      sinhVienId: _toInt(json['sinh_vien_id']),
      lopHocPhanId: _toInt(json['lop_hoc_phan_id']),
      ngayDangKy: _toDateTime(json['ngay_dang_ky']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinh_vien_id': sinhVienId,
      'lop_hoc_phan_id': lopHocPhanId,
      'ngay_dang_ky': ngayDangKy?.toIso8601String(),
    };
  }
}