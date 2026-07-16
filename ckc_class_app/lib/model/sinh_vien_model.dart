int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

double? _toDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());

bool _toBool(dynamic v, {bool def = false}) {
  if (v == null) return def;
  if (v is bool) return v;
  final s = v.toString().trim().toLowerCase();
  if (s == '1' || s == 'true' || s == 'yes' || s == 'co') return true;
  if (s == '0' || s == 'false' || s == 'no' || s == 'khong') return false;
  return def;
}

DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : DateTime.tryParse(s);
}

String? _toStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return (s.isEmpty || s.toLowerCase() == 'null') ? null : s;
}

String _chuanHoaTrangThaiBaiTap(dynamic value) {
  switch (value?.toString().trim()) {
    case 'dang_mo':
    case 'hien_thi':
      return 'hien_thi';
    case 'da_dong':
    case 'an':
      return 'an';
    default:
      return 'hien_thi';
  }
}

// ─── THÔNG KÊ NHANH ───────────────────────────────────────────
class ThongKeSinhVienModel {
  final int soLopDangHoc;
  final int soBaiDaNop;
  final int soBaiChuaNop;
  final double? diemTrungBinh;

  const ThongKeSinhVienModel({
    this.soLopDangHoc = 0,
    this.soBaiDaNop = 0,
    this.soBaiChuaNop = 0,
    this.diemTrungBinh,
  });

  factory ThongKeSinhVienModel.fromJson(Map<String, dynamic> j) =>
      ThongKeSinhVienModel(
        soLopDangHoc: _toInt(j['so_lop_dang_hoc']) ?? 0,
        soBaiDaNop: _toInt(j['so_bai_da_nop']) ?? 0,
        soBaiChuaNop: _toInt(j['so_bai_chua_nop']) ?? 0,
        diemTrungBinh: _toDouble(j['diem_trung_binh']),
      );
}

// ─── HỒ SƠ SINH VIÊN ─────────────────────────────────────────
class HoSoSinhVienModel {
  final int sinhVienId;
  final int nguoiDungId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? soDienThoai;
  final String? cccd;
  final String? diaChi;
  final String? khoaHoc;
  final String trangThai;
  final String trangThaiSinhVien;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int? lopId;
  final String? maLop;
  final String? tenLop;
  final int? namNhapHoc;
  final int? khoaId;
  final String? maKhoa;
  final String? tenKhoa;
  final ThongKeSinhVienModel thongKe;

  const HoSoSinhVienModel({
    required this.sinhVienId,
    required this.nguoiDungId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.ngaySinh,
    this.gioiTinh,
    this.soDienThoai,
    this.cccd,
    this.diaChi,
    this.khoaHoc,
    this.trangThai = 'dang_hoat_dong',
    this.trangThaiSinhVien = 'dang_hoc',
    this.ngayTao,
    this.ngayCapNhat,
    this.lopId,
    this.maLop,
    this.tenLop,
    this.namNhapHoc,
    this.khoaId,
    this.maKhoa,
    this.tenKhoa,
    this.thongKe = const ThongKeSinhVienModel(),
  });

  factory HoSoSinhVienModel.fromJson(Map<String, dynamic> j) =>
      HoSoSinhVienModel(
        sinhVienId: _toInt(j['sinh_vien_id']) ?? 0,
        nguoiDungId: _toInt(j['nguoi_dung_id']) ?? 0,
        maSinhVien: j['ma_sinh_vien']?.toString() ?? '',
        hoTen: j['ho_ten']?.toString() ?? '',
        email: j['email']?.toString() ?? '',
        ngaySinh: _toDateTime(j['ngay_sinh']),
        gioiTinh: _toStr(j['gioi_tinh']),
        soDienThoai: _toStr(j['so_dien_thoai']),
        cccd: _toStr(j['cccd']),
        diaChi: _toStr(j['dia_chi']),
        khoaHoc: _toStr(j['khoa_hoc']),
        trangThai: j['trang_thai']?.toString() ?? 'dang_hoat_dong',
        trangThaiSinhVien: j['trang_thai_sinh_vien']?.toString() ?? 'dang_hoc',
        ngayTao: _toDateTime(j['ngay_tao']),
        ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
        lopId: _toInt(j['lop_id']),
        maLop: _toStr(j['ma_lop']),
        tenLop: _toStr(j['ten_lop']),
        namNhapHoc: _toInt(j['nam_nhap_hoc']),
        khoaId: _toInt(j['khoa_id']),
        maKhoa: _toStr(j['ma_khoa']),
        tenKhoa: _toStr(j['ten_khoa']),
        thongKe: j['thong_ke'] is Map
            ? ThongKeSinhVienModel.fromJson(
                Map<String, dynamic>.from(j['thong_ke']),
              )
            : const ThongKeSinhVienModel(),
      );

  String get tenGioiTinh => switch (gioiTinh ?? '') {
    'nam' => 'Nam',
    'nu' => 'Nữ',
    'khac' => 'Khác',
    _ => 'Chưa cập nhật',
  };

  String get tenTrangThaiSV => switch (trangThaiSinhVien) {
    'dang_hoc' => 'Đang học',
    'tam_nghi' => 'Tạm nghỉ',
    'da_tot_nghiep' => 'Đã tốt nghiệp',
    _ => trangThaiSinhVien,
  };
}

// ─── LỚP HỌC PHẦN (góc nhìn sinh viên) ───────────────────────
class LopHocPhanSVModel {
  final int id;
  final String maLopHocPhan;
  final String? tenLop;
  final String? hocKy;
  final String? namHoc;
  final String trangThai;
  final String trangThaiDangKy;
  final DateTime? ngayDangKy;
  final int? monHocId;
  final String? maMon;
  final String? tenMon;
  final int? tinChi;
  final String? tenGiangVien;
  final String? maGiangVien;
  final int soTaiLieu;
  final int soBaiTap;
  final int soThongBao;
  final int soBaiDaNop;

  const LopHocPhanSVModel({
    required this.id,
    required this.maLopHocPhan,
    this.tenLop,
    this.hocKy,
    this.namHoc,
    this.trangThai = 'dang_mo',
    this.trangThaiDangKy = 'dang_hoc',
    this.ngayDangKy,
    this.monHocId,
    this.maMon,
    this.tenMon,
    this.tinChi,
    this.tenGiangVien,
    this.maGiangVien,
    this.soTaiLieu = 0,
    this.soBaiTap = 0,
    this.soThongBao = 0,
    this.soBaiDaNop = 0,
  });

  factory LopHocPhanSVModel.fromJson(Map<String, dynamic> j) =>
      LopHocPhanSVModel(
        id: _toInt(j['id']) ?? 0,
        maLopHocPhan: j['ma_lop_hoc_phan']?.toString() ?? '',
        tenLop: _toStr(j['ten_lop']),
        hocKy: _toStr(j['hoc_ky']),
        namHoc: _toStr(j['nam_hoc']),
        trangThai: j['trang_thai']?.toString() ?? 'dang_mo',
        trangThaiDangKy: j['trang_thai_dang_ky']?.toString() ?? 'dang_hoc',
        ngayDangKy: _toDateTime(j['ngay_dang_ky']),
        monHocId: _toInt(j['mon_hoc_id']),
        maMon: _toStr(j['ma_mon']),
        tenMon: _toStr(j['ten_mon']),
        tinChi: _toInt(j['tin_chi']),
        tenGiangVien: _toStr(j['ten_giang_vien']),
        maGiangVien: _toStr(j['ma_giang_vien']),
        soTaiLieu: _toInt(j['so_tai_lieu']) ?? 0,
        soBaiTap: _toInt(j['so_bai_tap']) ?? 0,
        soThongBao: _toInt(j['so_thong_bao']) ?? 0,
        soBaiDaNop: _toInt(j['so_bai_da_nop']) ?? 0,
      );

  String get tenHienThi => tenLop ?? maLopHocPhan;
  bool get isDangHoc => trangThaiDangKy == 'dang_hoc';
  bool get isDaLuu => trangThai == 'da_khoa' || trangThai == 'da_ket_thuc';
  String get namHocHienThi => namHoc ?? 'Chưa cập nhật';
}

// ─── TÀI LIỆU (góc nhìn sinh viên) ───────────────────────────
class TaiLieuSVModel {
  final int id;
  final String tieuDe;
  final String? moTa;
  final String? duongDanFile;
  final String? tenNguoiTao;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const TaiLieuSVModel({
    required this.id,
    required this.tieuDe,
    this.moTa,
    this.duongDanFile,
    this.tenNguoiTao,
    this.ngayTao,
    this.ngayCapNhat,
  });

  factory TaiLieuSVModel.fromJson(Map<String, dynamic> j) => TaiLieuSVModel(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    moTa: _toStr(j['mo_ta']),
    duongDanFile: _toStr(j['duong_dan_file']) ?? _toStr(j['file_url']) ?? _toStr(j['duong_dan']),
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
  );

  String get loaiFile {
    final f = duongDanFile?.toLowerCase() ?? '';
    if (f.endsWith('.pdf')) return 'PDF';
    if (f.endsWith('.ppt') || f.endsWith('.pptx')) return 'PPT';
    if (f.endsWith('.doc') || f.endsWith('.docx')) return 'Word';
    if (f.endsWith('.xls') || f.endsWith('.xlsx')) return 'Excel';
    if (f.endsWith('.zip') || f.endsWith('.rar')) return 'Archive';
    return 'File';
  }
}

// ─── THÔNG BÁO (góc nhìn sinh viên) ──────────────────────────
class ThongBaoSVModel {
  final int id;
  final String tieuDe;
  final String? noiDung;
  final String? tenNguoiTao;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int soBinhLuan;

  const ThongBaoSVModel({
    required this.id,
    required this.tieuDe,
    this.noiDung,
    this.tenNguoiTao,
    this.ngayTao,
    this.ngayCapNhat,
    this.soBinhLuan = 0,
  });

  factory ThongBaoSVModel.fromJson(Map<String, dynamic> j) => ThongBaoSVModel(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    noiDung: _toStr(j['noi_dung']),
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
    soBinhLuan: _toInt(j['so_binh_luan']) ?? 0,
  );
}

// ─── FILE ĐÃ NỘP CỦA SINH VIÊN ─────────────────────────────
class BaiNopFileSVModel {
  final int id;
  final String? tenFileGoc;
  final String duongDanFile;
  final String? loaiFile;
  final int kichThuoc;
  final DateTime? ngayTao;

  const BaiNopFileSVModel({
    required this.id,
    this.tenFileGoc,
    required this.duongDanFile,
    this.loaiFile,
    this.kichThuoc = 0,
    this.ngayTao,
  });

  factory BaiNopFileSVModel.fromJson(Map<String, dynamic> j) {
    final path = _toStr(j['duong_dan_file']) ?? _toStr(j['file_da_nop']) ?? '';
    return BaiNopFileSVModel(
      id: _toInt(j['id']) ?? 0,
      tenFileGoc: _toStr(j['ten_file_goc']),
      duongDanFile: path,
      loaiFile: _toStr(j['loai_file']),
      kichThuoc: _toInt(j['kich_thuoc']) ?? 0,
      ngayTao: _toDateTime(j['ngay_tao']),
    );
  }

  String get tenHienThi {
    if (tenFileGoc != null && tenFileGoc!.trim().isNotEmpty) {
      return tenFileGoc!.trim();
    }
    if (duongDanFile.trim().isEmpty) return 'File đã nộp';
    return duongDanFile.split('/').last.split('\\').last;
  }

  String get kichThuocHienThi {
    if (kichThuoc <= 0) return '';
    final kb = kichThuoc / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 100 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 100 ? 1 : 0)} MB';
  }
}

// ─── BÀI TẬP (góc nhìn sinh viên, kèm trạng thái nộp) ────────
class BaiTapSVModel {
  final int id;
  final String tieuDe;
  final String? moTa;
  final String? duongDanFile;
  final DateTime? hanNop;
  final String trangThai;
  final DateTime? ngayTao;
  final String? tenNguoiTao;

  // Cài đặt nộp file chuyên nghiệp
  final bool yeuCauNopFile;
  final String? dinhDangFileChoPhep;
  final int soFileToiDa;
  final int dungLuongToiDaMb;
  final bool choPhepNopLai;
  final bool choPhepNopMuon;
  final double diemToiDa;

  // Quiz
  final String loaiBaiTap;
  final int? thoiGianLam;
  final int? baiLamQuizId;
  final double? diemQuiz;
  final String? trangThaiQuiz;
  final int soCauHoi;

  // Trạng thái bài nộp file
  final int? baiNopId;
  final String? fileDaNop;
  final List<BaiNopFileSVModel> filesDaNop;
  final double? diem;
  final String? nhanXet;
  final String? trangThaiNop;
  final DateTime? ngayNop;
  //chủ đề
  final int? chuDeId;
  final String? tenChuDe;

  const BaiTapSVModel({
    required this.id,
    required this.tieuDe,
    this.moTa,
    this.duongDanFile,
    this.hanNop,
    this.trangThai = 'hien_thi',
    this.ngayTao,
    this.tenNguoiTao,
    this.yeuCauNopFile = true,
    this.dinhDangFileChoPhep,
    this.soFileToiDa = 1,
    this.dungLuongToiDaMb = 25,
    this.choPhepNopLai = true,
    this.choPhepNopMuon = true,
    this.diemToiDa = 10,
    this.loaiBaiTap = 'nop_file',
    this.thoiGianLam,
    this.baiLamQuizId,
    this.diemQuiz,
    this.trangThaiQuiz,
    this.soCauHoi = 0,
    this.baiNopId,
    this.fileDaNop,
    this.filesDaNop = const [],
    this.diem,
    this.nhanXet,
    this.trangThaiNop,
    this.ngayNop,
    this.chuDeId,
    this.tenChuDe,
  });

  factory BaiTapSVModel.fromJson(Map<String, dynamic> j) => BaiTapSVModel(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    moTa: _toStr(j['mo_ta']),
    duongDanFile: _toStr(j['duong_dan_file']) ?? _toStr(j['file_url']) ?? _toStr(j['duong_dan']),
    hanNop: _toDateTime(j['han_nop']),
    trangThai: _chuanHoaTrangThaiBaiTap(j['trang_thai']),
    ngayTao: _toDateTime(j['ngay_tao']),
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    yeuCauNopFile: _toBool(j['yeu_cau_nop_file'], def: true),
    dinhDangFileChoPhep: _toStr(j['dinh_dang_file_cho_phep']),
    // CSDL bai_nop hiện chỉ lưu một đường dẫn file cho mỗi bài nộp.
    soFileToiDa: 1,
    dungLuongToiDaMb: (_toInt(j['dung_luong_toi_da_mb']) ?? 25) <= 0
        ? 25
        : (_toInt(j['dung_luong_toi_da_mb']) ?? 25),
    choPhepNopLai: _toBool(j['cho_phep_nop_lai'], def: true),
    choPhepNopMuon: _toBool(j['cho_phep_nop_muon'], def: true),
    diemToiDa: _toDouble(j['diem_toi_da']) ?? 10,
    loaiBaiTap: j['loai_bai_tap']?.toString() ?? 'nop_file',
    thoiGianLam: _toInt(j['thoi_gian_lam']),
    baiLamQuizId: _toInt(j['bai_lam_quiz_id']),
    diemQuiz: _toDouble(j['diem_quiz']),
    trangThaiQuiz: _toStr(j['trang_thai_quiz']),
    soCauHoi: _toInt(j['so_cau_hoi']) ?? 0,
    baiNopId: _toInt(j['bai_nop_id']),
    fileDaNop: _toStr(j['file_da_nop']),
    filesDaNop: (j['files_da_nop'] is List)
        ? (j['files_da_nop'] as List)
              .map(
                (e) => BaiNopFileSVModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .where((e) => e.duongDanFile.trim().isNotEmpty)
              .toList()
        : const [],
    diem: _toDouble(j['diem']),
    nhanXet: _toStr(j['nhan_xet']),
    trangThaiNop: _toStr(j['trang_thai_nop']),
    ngayNop: _toDateTime(j['ngay_nop']),
    chuDeId: _toInt(j['chu_de_id']),
    tenChuDe: _toStr(j['ten_chu_de']),
  );

  bool get laQuiz => loaiBaiTap == 'quiz';
  bool get laNopFile => loaiBaiTap == 'nop_file';
  bool get choNopNhieuFile => soFileToiDa > 1;
  String get tenLoaiBaiTap => laQuiz ? 'Quiz' : 'Nộp file';

  List<String> get dsDinhDangChoPhep {
    final raw = dinhDangFileChoPhep ?? '';
    return raw
        .split(',')
        .map((e) => e.trim().toLowerCase().replaceFirst('.', ''))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String get dinhDangChoPhepHienThi {
    final ds = dsDinhDangChoPhep;
    if (ds.isEmpty) return 'Tất cả định dạng';
    return ds.map((e) => e.toUpperCase()).join(', ');
  }

  String get cauHinhNopFileTomTat {
    if (!yeuCauNopFile) return 'Không yêu cầu nộp file';
    return '$dinhDangChoPhepHienThi • Tối đa $soFileToiDa file • ${dungLuongToiDaMb}MB/file';
  }

  List<BaiNopFileSVModel> get dsFileDaNopHienThi {
    if (filesDaNop.isNotEmpty) return filesDaNop;
    final f = fileDaNop;
    if (f == null || f.trim().isEmpty) return const [];
    return [
      BaiNopFileSVModel(
        id: 0,
        tenFileGoc: f.split('/').last.split('\\').last,
        duongDanFile: f,
        loaiFile: f.contains('.') ? f.split('.').last.toLowerCase() : null,
      ),
    ];
  }

  bool get daDuocNop => baiNopId != null;
  bool get daDuocCham => diem != null;
  bool get daDong => trangThai == 'an';

  bool get daLamQuiz =>
      baiLamQuizId != null &&
      (trangThaiQuiz == 'da_nop' ||
          trangThaiQuiz == 'da_cham' ||
          trangThaiQuiz == 'qua_han');

  bool get daQuaHan {
    if (hanNop == null) return false;
    return DateTime.now().isAfter(hanNop!);
  }

  bool get coTheNopFile {
    if (laQuiz || daDong || !yeuCauNopFile) return false;
    if (daQuaHan && !choPhepNopMuon) return false;
    if (daDuocNop && !choPhepNopLai) return false;
    return true;
  }

  String? get lyDoKhongTheNopFile {
    if (laQuiz) return null;
    if (!yeuCauNopFile) return 'Bài tập này không yêu cầu nộp file';
    if (daDong) return 'Bài tập đã đóng';
    if (daQuaHan && !choPhepNopMuon) return 'Đã quá hạn nộp';
    if (daDuocNop && !choPhepNopLai) return 'Không cho phép nộp lại';
    return null;
  }

  String get tenTrangThaiNop {
    if (laQuiz) return tenTrangThaiQuiz;

    if (!daDuocNop) {
      return daQuaHan ? 'Đã quá hạn' : 'Chưa nộp';
    }

    return switch (trangThaiNop) {
      'da_nop' => 'Đã nộp',
      'nop_muon' => 'Nộp muộn',
      'da_cham' => 'Đã chấm',
      _ => 'Đã nộp',
    };
  }

  String get tenTrangThaiQuiz {
    if (!laQuiz) return '';

    if (daLamQuiz) {
      return diemQuiz != null
          ? 'Đã làm - ${diemQuiz!.toStringAsFixed(1)} điểm'
          : 'Đã làm';
    }

    return daQuaHan ? 'Đã quá hạn' : 'Chưa làm';
  }
}

// ─── BÀI TẬP CHƯA NỘP (dashboard) ────────────────────────────
class BaiTapChuaNopModel {
  final int id;
  final String tieuDe;
  final DateTime? hanNop;
  final int lopHocPhanId;
  final String? tenLop;
  final String? maLopHocPhan;
  final String? tenMon;

  const BaiTapChuaNopModel({
    required this.id,
    required this.tieuDe,
    this.hanNop,
    required this.lopHocPhanId,
    this.tenLop,
    this.maLopHocPhan,
    this.tenMon,
  });

  factory BaiTapChuaNopModel.fromJson(Map<String, dynamic> j) =>
      BaiTapChuaNopModel(
        id: _toInt(j['id']) ?? 0,
        tieuDe: j['tieu_de']?.toString() ?? '',
        hanNop: _toDateTime(j['han_nop']),
        lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
        tenLop: _toStr(j['ten_lop']),
        maLopHocPhan: _toStr(j['ma_lop_hoc_phan']),
        tenMon: _toStr(j['ten_mon']),
      );

  bool get sapHetHan {
    if (hanNop == null) return false;
    return hanNop!.difference(DateTime.now()).inHours <= 24;
  }

  bool get daQuaHan {
    if (hanNop == null) return false;
    return DateTime.now().isAfter(hanNop!);
  }
}

// ─── BÌNH LUẬN ────────────────────────────────────────────────
class BinhLuanModel {
  final int id;
  final String noiDung;
  final int nguoiDungId;
  final String tenNguoiDung;
  final String? tenVaiTro;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const BinhLuanModel({
    required this.id,
    required this.noiDung,
    required this.nguoiDungId,
    required this.tenNguoiDung,
    this.tenVaiTro,
    this.ngayTao,
    this.ngayCapNhat,
  });

  factory BinhLuanModel.fromJson(Map<String, dynamic> j) => BinhLuanModel(
    id: _toInt(j['id']) ?? 0,
    noiDung: j['noi_dung']?.toString() ?? '',
    nguoiDungId: _toInt(j['nguoi_dung_id']) ?? 0,
    tenNguoiDung: j['ten_nguoi_dung']?.toString() ?? '',
    tenVaiTro: _toStr(j['ten_vai_tro']),
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
  );

  bool laCuaToi(int myNguoiDungId) => nguoiDungId == myNguoiDungId;

  String get tenVaiTroHienThi => switch (tenVaiTro ?? '') {
    'giang_vien' => 'Giảng viên',
    'admin' => 'Admin',
    _ => 'Sinh viên',
  };
}

class ThanhVienLopSVModel {
  final int id;
  final String hoTen;
  final String? email;
  final String? maSo;
  final String vaiTro;
  final String? trangThai;
  final DateTime? ngayDangKy;

  const ThanhVienLopSVModel({
    required this.id,
    required this.hoTen,
    this.email,
    this.maSo,
    required this.vaiTro,
    this.trangThai,
    this.ngayDangKy,
  });

  factory ThanhVienLopSVModel.fromJson(
    Map<String, dynamic> j, {
    required String vaiTro,
  }) {
    return ThanhVienLopSVModel(
      id: _toInt(j['id']) ?? 0,
      hoTen: j['ho_ten']?.toString() ?? '',
      email: _toStr(j['email']),
      maSo: _toStr(j['ma_sinh_vien']) ?? _toStr(j['ma_giang_vien']),
      vaiTro: vaiTro,
      trangThai: _toStr(j['trang_thai']),
      ngayDangKy: _toDateTime(j['ngay_dang_ky']),
    );
  }
}
