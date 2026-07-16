// ═══════════════════════════════════════════════════════
// MODEL PHÂN HỆ GIẢNG VIÊN
// ═══════════════════════════════════════════════════════

int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
double? _toDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());
DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
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

// ─── LỚP HỌC PHẦN ────────────────────────────────────────
class LopHocPhan {
  final int id;
  final String maLopHocPhan;
  final String? tenLop;
  final String? hocKy;
  final String? namHoc;
  final int? siSoToiDa;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int? monHocId;
  final String? maMon;
  final String? tenMon;
  final int? tinChi;
  final int soSinhVien;
  final int soBaiTap;
  final int soTaiLieu;

  const LopHocPhan({
    required this.id,
    required this.maLopHocPhan,
    this.tenLop,
    this.hocKy,
    this.namHoc,
    this.siSoToiDa,
    this.trangThai = 'dang_mo',
    this.ngayTao,
    this.ngayCapNhat,
    this.monHocId,
    this.maMon,
    this.tenMon,
    this.tinChi,
    this.soSinhVien = 0,
    this.soBaiTap = 0,
    this.soTaiLieu = 0,
  });

  factory LopHocPhan.fromJson(Map<String, dynamic> j) => LopHocPhan(
    id: _toInt(j['id']) ?? 0,
    maLopHocPhan: j['ma_lop_hoc_phan']?.toString() ?? '',
    tenLop: _toStr(j['ten_lop']),
    hocKy: _toStr(j['hoc_ky']),
    namHoc: _toStr(j['nam_hoc']),
    siSoToiDa: _toInt(j['si_so_toi_da']),
    trangThai: j['trang_thai']?.toString() ?? 'dang_mo',
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
    monHocId: _toInt(j['mon_hoc_id']),
    maMon: _toStr(j['ma_mon']),
    tenMon: _toStr(j['ten_mon']),
    tinChi: _toInt(j['tin_chi']),
    soSinhVien: _toInt(j['so_sinh_vien']) ?? 0,
    soBaiTap: _toInt(j['so_bai_tap']) ?? 0,
    soTaiLieu: _toInt(j['so_tai_lieu']) ?? 0,
  );

  bool get isDangMo => trangThai == 'dang_mo' || trangThai == 'hien_thi';
  bool get isDaKhoa => trangThai == 'da_khoa';
  bool get isDaKetThuc => trangThai == 'da_ket_thuc';
  bool get isDaLuu => isDaKhoa || isDaKetThuc;

  String get tenTrangThai => switch (trangThai) {
    'dang_mo' => 'Đang mở',
    'da_khoa' => 'Đã khóa',
    'da_ket_thuc' => 'Đã kết thúc',
    _ => trangThai,
  };

  String get tenHienThi => tenLop ?? maLopHocPhan;
  String get namHocHienThi => namHoc ?? 'Chưa cập nhật';
}

// ─── SINH VIÊN TRONG LỚP ─────────────────────────────────
class SinhVienLop {
  final int sinhVienId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final String? gioiTinh;
  final String? soDienThoai;
  final String? maLop;
  final String? tenLop;
  final int dangKyId;
  final String trangThaiDangKy;
  final DateTime? ngayDangKy;
  final int soBaiDaNop;
  final double? diemTrungBinh;

  const SinhVienLop({
    required this.sinhVienId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.gioiTinh,
    this.soDienThoai,
    this.maLop,
    this.tenLop,
    required this.dangKyId,
    this.trangThaiDangKy = 'dang_hoc',
    this.ngayDangKy,
    this.soBaiDaNop = 0,
    this.diemTrungBinh,
  });

  factory SinhVienLop.fromJson(Map<String, dynamic> j) => SinhVienLop(
    sinhVienId: _toInt(j['sinh_vien_id']) ?? 0,
    maSinhVien: j['ma_sinh_vien']?.toString() ?? '',
    hoTen: j['ho_ten']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    gioiTinh: _toStr(j['gioi_tinh']),
    soDienThoai: _toStr(j['so_dien_thoai']),
    maLop: _toStr(j['ma_lop']),
    tenLop: _toStr(j['ten_lop']),
    dangKyId: _toInt(j['dang_ky_id']) ?? 0,
    trangThaiDangKy: j['trang_thai_dang_ky']?.toString() ?? 'dang_hoc',
    ngayDangKy: _toDateTime(j['ngay_dang_ky']),
    soBaiDaNop: _toInt(j['so_bai_da_nop']) ?? 0,
    diemTrungBinh: _toDouble(j['diem_trung_binh']),
  );
}

// ─── TÀI LIỆU ────────────────────────────────────────────
class TaiLieu {
  final int id;
  final String tieuDe;
  final String? moTa;
  final String? duongDanFile;
  final int lopHocPhanId;
  final int nguoiTaoId;
  final String? tenNguoiTao;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const TaiLieu({
    required this.id,
    required this.tieuDe,
    this.moTa,
    this.duongDanFile,
    required this.lopHocPhanId,
    required this.nguoiTaoId,
    this.tenNguoiTao,
    this.trangThai = 'hien_thi',
    this.ngayTao,
    this.ngayCapNhat,
  });

  factory TaiLieu.fromJson(Map<String, dynamic> j) => TaiLieu(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    moTa: _toStr(j['mo_ta']),
    duongDanFile: _toStr(j['duong_dan_file']) ?? _toStr(j['file_url']) ?? _toStr(j['duong_dan']),
    lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
    nguoiTaoId: _toInt(j['nguoi_tao_id']) ?? 0,
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    trangThai: j['trang_thai']?.toString() ?? 'hien_thi',
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
  );

  bool get isHienThi => trangThai == 'hien_thi';

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

class ChuDe {
  final int id;
  final String tenChuDe;
  final int lopHocPhanId;
  final int thuTu;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int soBaiTap;

  const ChuDe({
    required this.id,
    required this.tenChuDe,
    required this.lopHocPhanId,
    this.thuTu = 0,
    this.trangThai = 'dang_mo',
    this.ngayTao,
    this.ngayCapNhat,
    this.soBaiTap = 0,
  });

  factory ChuDe.fromJson(Map<String, dynamic> j) => ChuDe(
    id: _toInt(j['id']) ?? 0,
    tenChuDe: j['ten_chu_de']?.toString() ?? '',
    lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
    thuTu: _toInt(j['thu_tu']) ?? 0,
    trangThai: j['trang_thai']?.toString() ?? 'dang_mo',
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
    soBaiTap: _toInt(j['so_bai_tap']) ?? 0,
  );

  bool get isDangMo => trangThai == 'dang_mo' || trangThai == 'hien_thi';
}

// ─── BÀI TẬP ─────────────────────────────────────────────
class BaiTap {
  final int id;
  final String tieuDe;
  final String? moTa;
  final String? duongDanFile;
  final String? fileName;
  final bool yeuCauNopFile;
  final String? dinhDangFileChoPhep;
  final int soFileToiDa;
  final int dungLuongToiDaMb;
  final bool choPhepNopLai;
  final bool choPhepNopMuon;
  final double diemToiDa;
  final DateTime? hanNop;
  final int lopHocPhanId;
  final int nguoiTaoId;
  final String? tenNguoiTao;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int soBaiNop;
  final int soDaCham;
  //thêm mới
  final String loaiBaiTap;
  final int? thoiGianLam;
  final bool choXemDapAn;
  final bool daoCauHoi;
  final bool daoDapAn;
  final int soBaiNopFile;
  final int soBaiLamQuiz;
  final int soCauHoi;
  final int? chuDeId;
  final String? tenChuDe;
  final DateTime? thoiGianGui;

  const BaiTap({
    required this.id,
    required this.tieuDe,
    this.moTa,
    this.duongDanFile,
    this.fileName,
    this.yeuCauNopFile = true,
    this.dinhDangFileChoPhep,
    this.soFileToiDa = 1,
    this.dungLuongToiDaMb = 25,
    this.choPhepNopLai = true,
    this.choPhepNopMuon = true,
    this.diemToiDa = 10,
    this.hanNop,
    required this.lopHocPhanId,
    required this.nguoiTaoId,
    this.tenNguoiTao,
    this.trangThai = 'hien_thi',
    this.ngayTao,
    this.ngayCapNhat,
    this.soBaiNop = 0,
    this.soDaCham = 0,
    //thêm mới
    this.loaiBaiTap = 'nop_file',
    this.thoiGianLam,
    this.choXemDapAn = false,
    this.daoCauHoi = false,
    this.daoDapAn = false,
    this.soBaiNopFile = 0,
    this.soBaiLamQuiz = 0,
    this.soCauHoi = 0,
    this.chuDeId,
    this.tenChuDe,
    this.thoiGianGui,
  });

  factory BaiTap.fromJson(Map<String, dynamic> j) => BaiTap(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    moTa: _toStr(j['mo_ta']),
    duongDanFile: _toStr(j['duong_dan_file']) ?? _toStr(j['file_url']) ?? _toStr(j['duong_dan']),
    fileName: _toStr(j['file_name']) ?? _toStr(j['ten_file_goc']) ?? _toStr(j['ten_file']),
    yeuCauNopFile: (_toInt(j['yeu_cau_nop_file']) ?? 1) == 1,
    dinhDangFileChoPhep: _toStr(j['dinh_dang_file_cho_phep']),
    soFileToiDa: 1,
    dungLuongToiDaMb: _toInt(j['dung_luong_toi_da_mb']) ?? 25,
    choPhepNopLai: (_toInt(j['cho_phep_nop_lai']) ?? 1) == 1,
    choPhepNopMuon: (_toInt(j['cho_phep_nop_muon']) ?? 1) == 1,
    diemToiDa: _toDouble(j['diem_toi_da']) ?? 10,
    hanNop: _toDateTime(j['han_nop']),
    lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
    nguoiTaoId: _toInt(j['nguoi_tao_id']) ?? 0,
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    trangThai: _chuanHoaTrangThaiBaiTap(j['trang_thai']),
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
    soBaiNop: _toInt(j['so_bai_nop']) ?? 0,
    soDaCham: _toInt(j['so_da_cham']) ?? 0,
    //thêm mới
    loaiBaiTap: j['loai_bai_tap']?.toString() ?? 'nop_file',
    thoiGianLam: _toInt(j['thoi_gian_lam']),
    choXemDapAn: (_toInt(j['cho_xem_dap_an']) ?? 0) == 1,
    daoCauHoi: (_toInt(j['dao_cau_hoi']) ?? 0) == 1,
    daoDapAn: (_toInt(j['dao_dap_an']) ?? 0) == 1,
    soBaiNopFile: _toInt(j['so_bai_nop_file']) ?? 0,
    soBaiLamQuiz: _toInt(j['so_bai_lam_quiz']) ?? 0,
    soCauHoi: _toInt(j['so_cau_hoi']) ?? 0,
    chuDeId: _toInt(j["chu_de_id"]),
    tenChuDe: _toStr(j["ten_chu_de"]),
    thoiGianGui: _toDateTime(j['thoi_gian_gui']),
  );

  bool get isDangMo => trangThai == 'hien_thi';
  bool get isDaDong => trangThai == 'an';

  String get tenTrangThai => switch (trangThai) {
    'hien_thi' => 'Đang mở',
    'an' => 'Đã đóng',
    _ => trangThai,
  };

  //thêm mới
  bool get laQuiz => loaiBaiTap == 'quiz';
  bool get laNopFile => loaiBaiTap == 'nop_file';
  String get tenLoaiBaiTap => laQuiz ? 'Quiz' : 'Nộp file';

  List<String> get dsDinhDangChoPhep {
    final raw = dinhDangFileChoPhep ?? '';
    return raw
        .split(',')
        .map((e) => e.trim().toLowerCase().replaceAll('.', ''))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  bool get choNopNhieuFile => soFileToiDa > 1;

  String get dinhDangFileHienThi {
    final ds = dsDinhDangChoPhep;
    if (ds.isEmpty) return 'Không giới hạn định dạng';
    return ds.map((e) => e.toUpperCase()).join(', ');
  }

  String get cauHinhNopFileTomTat {
    if (!yeuCauNopFile) return 'Không yêu cầu nộp file';
    return 'Tối đa $soFileToiDa file · $dungLuongToiDaMb MB/file';
  }

  //
  int get soChooCham => soBaiNop - soDaCham;

  bool get daQuaHan {
    if (hanNop == null) return false;
    return DateTime.now().isAfter(hanNop!);
  }

  bool get daHenGio {
    if (thoiGianGui == null) return false;
    return DateTime.now().isBefore(thoiGianGui!);
  }

  bool get daGui {
    if (thoiGianGui == null) return true;
    return !DateTime.now().isBefore(thoiGianGui!);
  }

  String get tenTrangThaiGui => daHenGio ? 'Hẹn gửi' : 'Đã gửi';
}

// ─── FILE BÀI NỘP ────────────────────────────────────────
class BaiNopFile {
  final int id;
  final int baiNopId;
  final String? tenFileGoc;
  final String duongDanFile;
  final String? loaiFile;
  final int kichThuoc;
  final DateTime? ngayTao;

  const BaiNopFile({
    required this.id,
    required this.baiNopId,
    this.tenFileGoc,
    required this.duongDanFile,
    this.loaiFile,
    this.kichThuoc = 0,
    this.ngayTao,
  });

  factory BaiNopFile.fromJson(Map<String, dynamic> j) => BaiNopFile(
    id: _toInt(j['id']) ?? 0,
    baiNopId: _toInt(j['bai_nop_id']) ?? 0,
    tenFileGoc: _toStr(j['ten_file_goc']),
    duongDanFile: j['duong_dan_file']?.toString() ?? '',
    loaiFile: _toStr(j['loai_file']),
    kichThuoc: _toInt(j['kich_thuoc']) ?? 0,
    ngayTao: _toDateTime(j['ngay_tao']),
  );

  String get tenHienThi {
    final ten = tenFileGoc?.trim();
    if (ten != null && ten.isNotEmpty) return ten;
    final normalized = duongDanFile.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  String get kichThuocHienThi {
    if (kichThuoc <= 0) return '';
    final kb = kichThuoc / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

// ─── BÀI NỘP ─────────────────────────────────────────────
class BaiNop {
  final int id;
  final int baiTapId;
  final int sinhVienId;
  final String maSinhVien;
  final String tenSinhVien;
  final String emailSinhVien;
  final String? duongDanFile;
  final List<BaiNopFile> files;
  final double? diem;
  final String? nhanXet;
  final String trangThai;
  final DateTime? ngayCham;
  final int? giangVienChamId;
  final String? tenGiangVienCham;
  final DateTime? ngayNop;
  final DateTime? ngayCapNhat;

  const BaiNop({
    required this.id,
    required this.baiTapId,
    required this.sinhVienId,
    required this.maSinhVien,
    required this.tenSinhVien,
    required this.emailSinhVien,
    this.duongDanFile,
    this.files = const [],
    this.diem,
    this.nhanXet,
    this.trangThai = 'da_nop',
    this.ngayCham,
    this.giangVienChamId,
    this.tenGiangVienCham,
    this.ngayNop,
    this.ngayCapNhat,
  });

  factory BaiNop.fromJson(Map<String, dynamic> j) => BaiNop(
    id: _toInt(j['id']) ?? 0,
    baiTapId: _toInt(j['bai_tap_id']) ?? 0,
    sinhVienId: _toInt(j['sinh_vien_id']) ?? 0,
    maSinhVien: j['ma_sinh_vien']?.toString() ?? '',
    tenSinhVien: j['ten_sinh_vien']?.toString() ?? '',
    emailSinhVien: j['email_sinh_vien']?.toString() ?? '',
    duongDanFile: _toStr(j['duong_dan_file']) ?? _toStr(j['file_url']) ?? _toStr(j['duong_dan']),
    files: (j['files'] is List)
        ? (j['files'] as List)
              .map((e) => BaiNopFile.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const [],
    diem: _toDouble(j['diem']),
    nhanXet: _toStr(j['nhan_xet']),
    trangThai: j['trang_thai']?.toString() ?? 'da_nop',
    ngayCham: _toDateTime(j['ngay_cham']),
    giangVienChamId: _toInt(j['giang_vien_cham_id']),
    tenGiangVienCham: _toStr(j['ten_giang_vien_cham']),
    ngayNop: _toDateTime(j['ngay_nop']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
  );

  bool get daDuocCham => trangThai == 'da_cham';

  List<BaiNopFile> get dsFileHienThi {
    if (files.isNotEmpty) return files;
    final path = duongDanFile?.trim();
    if (path == null || path.isEmpty) return const [];
    return [
      BaiNopFile(
        id: 0,
        baiNopId: id,
        tenFileGoc: path.replaceAll('\\', '/').split('/').last,
        duongDanFile: path,
      ),
    ];
  }

  int get soFile => dsFileHienThi.length;

  String get tenTrangThai => switch (trangThai) {
    'da_nop' => 'Đã nộp',
    'nop_muon' => 'Nộp muộn',
    'da_cham' => 'Đã chấm',
    _ => trangThai,
  };
}

// ─── THÔNG BÁO ────────────────────────────────────────────
class ThongBao {
  final int id;
  final String tieuDe;
  final String? noiDung;
  final int lopHocPhanId;
  final int nguoiTaoId;
  final String? tenNguoiTao;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final int soBinhLuan;
  final DateTime? thoiGianGui;

  const ThongBao({
    required this.id,
    required this.tieuDe,
    this.noiDung,
    required this.lopHocPhanId,
    required this.nguoiTaoId,
    this.tenNguoiTao,
    this.trangThai = 'hien_thi',
    this.ngayTao,
    this.ngayCapNhat,
    this.soBinhLuan = 0,
    this.thoiGianGui,
  });

  factory ThongBao.fromJson(Map<String, dynamic> j) => ThongBao(
    id: _toInt(j['id']) ?? 0,
    tieuDe: j['tieu_de']?.toString() ?? '',
    noiDung: _toStr(j['noi_dung']),
    lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
    nguoiTaoId: _toInt(j['nguoi_tao_id']) ?? 0,
    tenNguoiTao: _toStr(j['ten_nguoi_tao']),
    trangThai: j['trang_thai']?.toString() ?? 'hien_thi',
    ngayTao: _toDateTime(j['ngay_tao']),
    ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
    soBinhLuan: _toInt(j['so_binh_luan']) ?? 0,
    thoiGianGui: _toDateTime(j['thoi_gian_gui']),
  );

  bool get isHienThi => trangThai == 'hien_thi';
  bool get daHenGio {
    if (thoiGianGui == null) return false;
    return DateTime.now().isBefore(thoiGianGui!);
  }

  bool get daGui {
    if (thoiGianGui == null) return true;
    return !DateTime.now().isBefore(thoiGianGui!);
  }

  String get tenTrangThaiGui => daHenGio ? 'Hẹn gửi' : 'Đã gửi';
}

// ─── THỐNG KÊ ─────────────────────────────────────────────
class ThongKeGiangVien {
  final int tongLopHocPhan;
  final int lopDangMo;
  final int tongSinhVien;
  final int tongBaiTap;
  final int chooCham;
  final int tongTaiLieu;
  final int tongThongBao;
  final int binhLuanMoi;
  final double? diemTrungBinh;

  const ThongKeGiangVien({
    this.tongLopHocPhan = 0,
    this.lopDangMo = 0,
    this.tongSinhVien = 0,
    this.tongBaiTap = 0,
    this.chooCham = 0,
    this.tongTaiLieu = 0,
    this.tongThongBao = 0,
    this.binhLuanMoi = 0,
    this.diemTrungBinh,
  });

  factory ThongKeGiangVien.fromJson(Map<String, dynamic> j) => ThongKeGiangVien(
    tongLopHocPhan: _toInt(j['tong_lop_hoc_phan']) ?? 0,
    lopDangMo: _toInt(j['lop_dang_mo']) ?? 0,
    tongSinhVien: _toInt(j['tong_sinh_vien']) ?? 0,
    tongBaiTap: _toInt(j['tong_bai_tap']) ?? 0,
    chooCham: _toInt(j['cho_cham']) ?? 0,
    tongTaiLieu: _toInt(j['tong_tai_lieu']) ?? 0,
    tongThongBao: _toInt(j['tong_thong_bao']) ?? 0,
    binhLuanMoi: _toInt(j['binh_luan_moi']) ?? 0,
    diemTrungBinh: _toDouble(j['diem_trung_binh']),
  );
}

class MonHocGV {
  final int id;
  final String maMon;
  final String tenMon;
  final int tinChi;

  MonHocGV({
    required this.id,
    required this.maMon,
    required this.tenMon,
    required this.tinChi,
  });

  factory MonHocGV.fromJson(Map<String, dynamic> json) {
    return MonHocGV(
      id: int.tryParse(json['id'].toString()) ?? 0,
      maMon: json['ma_mon']?.toString() ?? '',
      tenMon: json['ten_mon']?.toString() ?? '',
      tinChi: int.tryParse(json['tin_chi'].toString()) ?? 0,
    );
  }
}
