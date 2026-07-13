int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

String _toString(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.toLowerCase() == 'null') return '';
  return text;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return DateTime.tryParse(text);
}

class TaiLieuHocTap {
  final int id;
  final String tieuDe;
  final String moTa;
  final String duongDanFile;
  final int lopHocPhanId;
  final int nguoiTaoId;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  final String maLopHocPhan;
  final String tenLopHocPhan;
  final String hocKy;
  final String namHoc;
  final String maMon;
  final String tenMon;
  final String maBoMon;
  final String tenBoMon;
  final String maKhoa;
  final String tenKhoa;
  final String tenNguoiTao;
  final String emailNguoiTao;

  const TaiLieuHocTap({
    required this.id,
    required this.tieuDe,
    required this.moTa,
    required this.duongDanFile,
    required this.lopHocPhanId,
    required this.nguoiTaoId,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
    this.maLopHocPhan = '',
    this.tenLopHocPhan = '',
    this.hocKy = '',
    this.namHoc = '',
    this.maMon = '',
    this.tenMon = '',
    this.maBoMon = '',
    this.tenBoMon = '',
    this.maKhoa = '',
    this.tenKhoa = '',
    this.tenNguoiTao = '',
    this.emailNguoiTao = '',
  });

  factory TaiLieuHocTap.fromJson(Map<String, dynamic> json) {
    return TaiLieuHocTap(
      id: _toInt(json['id']),
      tieuDe: _toString(json['tieu_de']),
      moTa: _toString(json['mo_ta']),
      duongDanFile: _toString(json['duong_dan_file']),
      lopHocPhanId: _toInt(json['lop_hoc_phan_id']),
      nguoiTaoId: _toInt(json['nguoi_tao_id']),
      trangThai: _toString(json['trang_thai']).isEmpty
          ? 'hien_thi'
          : _toString(json['trang_thai']),
      ngayTao: _toDateTime(json['ngay_tao']),
      ngayCapNhat: _toDateTime(json['ngay_cap_nhat']),
      maLopHocPhan: _toString(json['ma_lop_hoc_phan']),
      tenLopHocPhan: _toString(json['ten_lop_hoc_phan']),
      hocKy: _toString(json['hoc_ky']),
      namHoc: _toString(json['nam_hoc']),
      maMon: _toString(json['ma_mon']),
      tenMon: _toString(json['ten_mon']),
      maBoMon: _toString(json['ma_bo_mon']),
      tenBoMon: _toString(json['ten_bo_mon']),
      maKhoa: _toString(json['ma_khoa']),
      tenKhoa: _toString(json['ten_khoa']),
      tenNguoiTao: _toString(json['ten_nguoi_tao']),
      emailNguoiTao: _toString(json['email_nguoi_tao']),
    );
  }

  bool get hienThi => trangThai == 'hien_thi';
  bool get daAn => trangThai == 'an';

  String get tenTrangThai {
    switch (trangThai) {
      case 'hien_thi':
        return 'Hiển thị';
      case 'an':
        return 'Đã ẩn';
      default:
        return trangThai;
    }
  }

  String get tenLopHienThi {
    if (maLopHocPhan.isEmpty && tenLopHocPhan.isEmpty) {
      return 'Chưa có lớp học phần';
    }
    if (tenLopHocPhan.isEmpty) return maLopHocPhan;
    if (maLopHocPhan.isEmpty) return tenLopHocPhan;
    return '$maLopHocPhan - $tenLopHocPhan';
  }

  String get tenMonHienThi {
    if (maMon.isEmpty && tenMon.isEmpty) return 'Chưa có môn học';
    if (tenMon.isEmpty) return maMon;
    if (maMon.isEmpty) return tenMon;
    return '$maMon - $tenMon';
  }

  String get tenNguoiTaoHienThi {
    if (tenNguoiTao.isEmpty && emailNguoiTao.isEmpty) return 'Chưa cập nhật';
    if (emailNguoiTao.isEmpty) return tenNguoiTao;
    if (tenNguoiTao.isEmpty) return emailNguoiTao;
    return '$tenNguoiTao <$emailNguoiTao>';
  }
}
