import 'khoa_bo_mon_model.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
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

class Lop {
  final int id;
  final String maLop;
  final String tenLop;
  final int khoaId;
  final String khoaHoc;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  final String? maKhoa;
  final String? tenKhoa;
  final int soLuongSinhVien;

  final Khoa? khoa;

  Lop({
    required this.id,
    required this.maLop,
    required this.tenLop,
    required this.khoaId,
    required this.khoaHoc,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.maKhoa,
    this.tenKhoa,
    this.soLuongSinhVien = 0,
    this.khoa,
  });

  factory Lop.fromJson(Map<String, dynamic> json) {
    final khoaHocValue = _toStringOrNull(json['khoa_hoc']) ?? '';

    return Lop(
      id: _toInt(json['id']),
      maLop: json['ma_lop']?.toString() ?? '',
      tenLop: json['ten_lop']?.toString() ?? '',
      khoaId: _toInt(json['khoa_id']),
      khoaHoc: khoaHocValue,
      trangThai: json['trang_thai']?.toString() ?? 'dang_hoc',
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
      maKhoa: _toStringOrNull(json['ma_khoa']),
      tenKhoa: _toStringOrNull(json['ten_khoa']),
      soLuongSinhVien: _toInt(json['so_luong_sinh_vien']),
      khoa: json['khoa'] is Map
          ? Khoa.fromJson(Map<String, dynamic>.from(json['khoa']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ma_lop': maLop,
      'ten_lop': tenLop,
      'khoa_id': khoaId,
      'khoa_hoc': khoaHoc,
      'trang_thai': trangThai,
      'ngay_tao': ngayTao?.toIso8601String(),
      'ngay_cap_nhat': ngayCapNhat?.toIso8601String(),
      'ma_khoa': maKhoa,
      'ten_khoa': tenKhoa,
      'so_luong_sinh_vien': soLuongSinhVien,
      'khoa': khoa?.toJson(),
    };
  }

  bool get dangHoc => trangThai == 'dang_hoc';

  bool get daTotNghiep => trangThai == 'da_tot_nghiep';

  bool get tamKhoa => trangThai == 'tam_khoa';

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoc':
        return 'Đang học';
      case 'da_tot_nghiep':
        return 'Đã tốt nghiệp';
      case 'tam_khoa':
        return 'Tạm khóa';
      default:
        return trangThai;
    }
  }

  String get tenKhoaHienThi {
    final ma = maKhoa ?? khoa?.maKhoa ?? '';
    final ten = tenKhoa ?? khoa?.tenKhoa ?? '';

    if (ma.isEmpty && ten.isEmpty) {
      return 'Chưa có khoa';
    }

    if (ma.isEmpty) return ten;
    if (ten.isEmpty) return ma;

    return '$ma - $ten';
  }

  String get khoaHocHienThi {
    final value = khoaHoc.trim();
    return value.isEmpty ? 'Chưa cập nhật' : value;
  }
}
