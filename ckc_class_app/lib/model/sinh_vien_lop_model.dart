int _toInt(dynamic value) {
  if (value == null) return 0;
  return int.tryParse(value.toString()) ?? 0;
}

String _toString(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.toLowerCase() == 'null') return '';
  return text;
}

class SinhVienLop {
  final int id;
  final int sinhVienId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final String tenLop;
  final String khoaHoc;
  final String trangThai; // dang_hoc | tam_nghi | da_tot_nghiep

  const SinhVienLop({
    required this.id,
    required this.sinhVienId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    required this.tenLop,
    required this.khoaHoc,
    required this.trangThai,
  });

  factory SinhVienLop.fromJson(Map<String, dynamic> json) {
    final sinhVienId = _toInt(json['sinh_vien_id'] ?? json['id']);

    return SinhVienLop(
      id: _toInt(json['id'] ?? sinhVienId),
      sinhVienId: sinhVienId,
      maSinhVien: _toString(json['ma_sinh_vien']),
      hoTen: _toString(json['ho_ten']),
      email: _toString(json['email']),
      tenLop: _toString(json['ten_lop']),
      khoaHoc: _toString(json['khoa_hoc']),
      trangThai: _toString(json['trang_thai']).isEmpty
          ? 'dang_hoc'
          : _toString(json['trang_thai']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinh_vien_id': sinhVienId,
      'ma_sinh_vien': maSinhVien,
      'ho_ten': hoTen,
      'email': email,
      'ten_lop': tenLop,
      'khoa_hoc': khoaHoc,
      'trang_thai': trangThai,
    };
  }

  String get tenTrangThai {
    switch (trangThai) {
      case 'dang_hoc':
        return 'Đang học';
      case 'tam_nghi':
        return 'Tạm nghỉ';
      case 'da_tot_nghiep':
        return 'Đã tốt nghiệp';
      default:
        return trangThai;
    }
  }

  String get khoaHocHienThi {
    final value = khoaHoc.trim();
    return value.isEmpty ? 'Chưa cập nhật' : value;
  }
}
