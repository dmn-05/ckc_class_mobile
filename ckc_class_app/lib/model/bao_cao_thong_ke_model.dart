int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return double.tryParse(text);
}

String _toString(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.toLowerCase() == 'null') return '';
  return text;
}

class BaoCaoLopHocPhan {
  final int id;
  final String maLopHocPhan;
  final String tenLop;
  final String hocKy;
  final String namHoc;
  final String trangThai;
  final String maMon;
  final String tenMon;
  final String maGiangVien;
  final String tenGiangVien;
  final int soSinhVienDangHoc;
  final int soTaiLieu;
  final int soBaiTap;
  final int soBaiNop;
  final int soBaiDaCham;
  final int soBaiNopMuon;
  final double? diemTrungBinh;

  const BaoCaoLopHocPhan({
    required this.id,
    required this.maLopHocPhan,
    required this.tenLop,
    required this.hocKy,
    required this.namHoc,
    required this.trangThai,
    required this.maMon,
    required this.tenMon,
    required this.maGiangVien,
    required this.tenGiangVien,
    required this.soSinhVienDangHoc,
    required this.soTaiLieu,
    required this.soBaiTap,
    required this.soBaiNop,
    required this.soBaiDaCham,
    required this.soBaiNopMuon,
    required this.diemTrungBinh,
  });

  factory BaoCaoLopHocPhan.fromJson(Map<String, dynamic> json) {
    return BaoCaoLopHocPhan(
      id: _toInt(json['id']),
      maLopHocPhan: _toString(json['ma_lop_hoc_phan']),
      tenLop: _toString(json['ten_lop']),
      hocKy: _toString(json['hoc_ky']),
      namHoc: _toString(json['nam_hoc']),
      trangThai: _toString(json['trang_thai']),
      maMon: _toString(json['ma_mon']),
      tenMon: _toString(json['ten_mon']),
      maGiangVien: _toString(json['ma_giang_vien']),
      tenGiangVien: _toString(json['ten_giang_vien']),
      soSinhVienDangHoc: _toInt(json['so_sinh_vien_dang_hoc']),
      soTaiLieu: _toInt(json['so_tai_lieu']),
      soBaiTap: _toInt(json['so_bai_tap']),
      soBaiNop: _toInt(json['so_bai_nop']),
      soBaiDaCham: _toInt(json['so_bai_da_cham']),
      soBaiNopMuon: _toInt(json['so_bai_nop_muon']),
      diemTrungBinh: _toDouble(json['diem_trung_binh']),
    );
  }

  String get tenLopHienThi {
    if (maLopHocPhan.isEmpty && tenLop.isEmpty) return 'Lớp #$id';
    if (tenLop.isEmpty) return maLopHocPhan;
    if (maLopHocPhan.isEmpty) return tenLop;
    return '$maLopHocPhan - $tenLop';
  }

  String get tenMonHienThi {
    if (maMon.isEmpty && tenMon.isEmpty) return 'Chưa có môn';
    if (tenMon.isEmpty) return maMon;
    if (maMon.isEmpty) return tenMon;
    return '$maMon - $tenMon';
  }

  String get tenGiangVienHienThi {
    if (maGiangVien.isEmpty && tenGiangVien.isEmpty) return 'Chưa có GV';
    if (tenGiangVien.isEmpty) return maGiangVien;
    if (maGiangVien.isEmpty) return tenGiangVien;
    return '$maGiangVien - $tenGiangVien';
  }
}

class BaoCaoMonHoc {
  final int monHocId;
  final String maMon;
  final String tenMon;
  final int soLopHocPhan;
  final int soSinhVienThamGia;
  final int soTaiLieu;
  final int soBaiTap;
  final double? diemTrungBinh;

  const BaoCaoMonHoc({
    required this.monHocId,
    required this.maMon,
    required this.tenMon,
    required this.soLopHocPhan,
    required this.soSinhVienThamGia,
    required this.soTaiLieu,
    required this.soBaiTap,
    required this.diemTrungBinh,
  });

  factory BaoCaoMonHoc.fromJson(Map<String, dynamic> json) {
    return BaoCaoMonHoc(
      monHocId: _toInt(json['mon_hoc_id']),
      maMon: _toString(json['ma_mon']),
      tenMon: _toString(json['ten_mon']),
      soLopHocPhan: _toInt(json['so_lop_hoc_phan']),
      soSinhVienThamGia: _toInt(json['so_sinh_vien_tham_gia']),
      soTaiLieu: _toInt(json['so_tai_lieu']),
      soBaiTap: _toInt(json['so_bai_tap']),
      diemTrungBinh: _toDouble(json['diem_trung_binh']),
    );
  }

  String get tenMonHienThi {
    if (maMon.isEmpty && tenMon.isEmpty) return 'Môn #$monHocId';
    if (tenMon.isEmpty) return maMon;
    if (maMon.isEmpty) return tenMon;
    return '$maMon - $tenMon';
  }
}

class BaoCaoThongKeAdmin {
  final Map<String, int> tongQuan;
  final List<BaoCaoLopHocPhan> baoCaoLopHocPhan;
  final List<BaoCaoMonHoc> baoCaoMonHoc;

  const BaoCaoThongKeAdmin({
    required this.tongQuan,
    required this.baoCaoLopHocPhan,
    required this.baoCaoMonHoc,
  });

  factory BaoCaoThongKeAdmin.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : Map<String, dynamic>.from(json);

    final rawTongQuan = data['tong_quan'] is Map
        ? Map<String, dynamic>.from(data['tong_quan'])
        : <String, dynamic>{};

    final rawLop = data['bao_cao_lop_hoc_phan'] is List
        ? data['bao_cao_lop_hoc_phan'] as List
        : <dynamic>[];

    final rawMon = data['bao_cao_mon_hoc'] is List
        ? data['bao_cao_mon_hoc'] as List
        : <dynamic>[];

    return BaoCaoThongKeAdmin(
      tongQuan: rawTongQuan.map((key, value) => MapEntry(key, _toInt(value))),
      baoCaoLopHocPhan: rawLop
          .map((item) => BaoCaoLopHocPhan.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      baoCaoMonHoc: rawMon
          .map((item) => BaoCaoMonHoc.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  int getValue(String key) => tongQuan[key] ?? 0;
}
