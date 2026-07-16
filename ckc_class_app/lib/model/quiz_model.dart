// ═══════════════════════════════════════════════════════════════
// MODEL QUIZ - SINH VIÊN + GIẢNG VIÊN
// ═══════════════════════════════════════════════════════════════

int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
double? _toDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());

DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;
  return DateTime.tryParse(s.replaceFirst(' ', 'T'));
}

String? _toStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;
  return s;
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase().trim() ?? '';
  return s == '1' || s == 'true' || s == 'yes';
}

// ─── ĐÁP ÁN ───────────────────────────────────────────────────
class DapAnQuiz {
  final int id;
  final int? cauHoiId;
  final String noiDung;
  final bool laDapAnDung;
  final bool duocChon;
  final int thuTu;

  const DapAnQuiz({
    required this.id,
    this.cauHoiId,
    required this.noiDung,
    this.laDapAnDung = false,
    this.duocChon = false,
    this.thuTu = 0,
  });

  factory DapAnQuiz.fromJson(Map<String, dynamic> j) => DapAnQuiz(
    id: _toInt(j['id']) ?? 0,
    cauHoiId: _toInt(j['cau_hoi_id']),
    noiDung: j['noi_dung']?.toString() ?? '',
    laDapAnDung: _toBool(j['la_dap_an_dung']),
    duocChon: _toBool(j['duoc_chon']),
    thuTu: _toInt(j['thu_tu']) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cau_hoi_id': cauHoiId,
    'noi_dung': noiDung,
    'la_dap_an_dung': laDapAnDung ? 1 : 0,
    'thu_tu': thuTu,
  };
}

// ─── CÂU HỎI ──────────────────────────────────────────────────
class CauHoiQuiz {
  final int id;
  final int? baiTapId;
  final String noiDung;
  final String loaiCauHoi;
  final double diem;
  final int thuTu;
  final bool dung;
  final String? giaiThich;
  final String? dapAnTuLuan;
  final List<DapAnQuiz> dapAn;

  const CauHoiQuiz({
    required this.id,
    this.baiTapId,
    required this.noiDung,
    this.loaiCauHoi = 'mot_dap_an',
    this.diem = 1,
    this.thuTu = 0,
    this.dung = false,
    this.giaiThich,
    this.dapAnTuLuan,
    this.dapAn = const [],
  });

  factory CauHoiQuiz.fromJson(Map<String, dynamic> j) {
    final rawDapAn = j['dap_an'];
    return CauHoiQuiz(
      id: _toInt(j['id']) ?? 0,
      baiTapId: _toInt(j['bai_tap_id']),
      noiDung: j['noi_dung']?.toString() ?? '',
      loaiCauHoi: j['loai_cau_hoi']?.toString() ?? 'mot_dap_an',
      diem: _toDouble(j['diem']) ?? 1,
      thuTu: _toInt(j['thu_tu']) ?? 0,
      dung: _toBool(j['dung']),
      giaiThich: _toStr(j['giai_thich']),
      dapAnTuLuan: _toStr(j['dap_an_tu_luan']),
      dapAn: rawDapAn is List
          ? rawDapAn
                .map((e) => DapAnQuiz.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  bool get laNhieuDapAn => loaiCauHoi == 'nhieu_dap_an';
  bool get laTuLuan => loaiCauHoi == 'tu_luan' || loaiCauHoi == 'essay';

  String get tenLoaiCauHoi => switch (loaiCauHoi) {
    'mot_dap_an' => 'Một đáp án',
    'nhieu_dap_an' => 'Nhiều đáp án',
    'dung_sai' => 'Đúng / Sai',
    'tu_luan' => 'Tự luận',
    'essay' => 'Tự luận',
    _ => loaiCauHoi,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'bai_tap_id': baiTapId,
    'noi_dung': noiDung,
    'loai_cau_hoi': loaiCauHoi,
    'diem': diem,
    'thu_tu': thuTu,
    'giai_thich': giaiThich,
    'dap_an_tu_luan': dapAnTuLuan,
    'dap_an': dapAn.map((e) => e.toJson()).toList(),
  };
}

// ─── ĐỀ QUIZ SINH VIÊN ────────────────────────────────────────
class DeQuiz {
  final int baiTapId;
  final int? baiLamQuizId;
  final String tieuDe;
  final String? moTa;
  final DateTime? hanNop;
  final int? thoiGianLam;
  final DateTime? thoiGianBatDau;
  final int? thoiGianConLaiGiay;
  final bool choXemDapAn;
  final List<CauHoiQuiz> cauHoi;

  const DeQuiz({
    required this.baiTapId,
    this.baiLamQuizId,
    required this.tieuDe,
    this.moTa,
    this.hanNop,
    this.thoiGianLam,
    this.thoiGianBatDau,
    this.thoiGianConLaiGiay,
    this.choXemDapAn = false,
    this.cauHoi = const [],
  });

  factory DeQuiz.fromJson(Map<String, dynamic> j) {
    final raw = j['cau_hoi'];
    return DeQuiz(
      baiTapId: _toInt(j['bai_tap_id']) ?? _toInt(j['id']) ?? 0,
      baiLamQuizId: _toInt(j['bai_lam_quiz_id']),
      tieuDe: j['tieu_de']?.toString() ?? '',
      moTa: _toStr(j['mo_ta']),
      hanNop: _toDateTime(j['han_nop']),
      thoiGianLam: _toInt(j['thoi_gian_lam']),
      thoiGianBatDau: _toDateTime(j['thoi_gian_bat_dau']),
      thoiGianConLaiGiay: _toInt(j['thoi_gian_con_lai_giay']),
      choXemDapAn: _toBool(j['cho_xem_dap_an']),
      cauHoi: raw is List
          ? raw
                .map((e) => CauHoiQuiz.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

// ─── CHI TIẾT QUIZ CHO GIẢNG VIÊN ─────────────────────────────
class ChiTietQuizGV {
  final int id;
  final String tieuDe;
  final String? moTa;
  final int lopHocPhanId;
  final int? chuDeId;
  final int? nguoiTaoId;
  final DateTime? hanNop;
  final int? thoiGianLam;
  final bool choXemDapAn;
  final bool daoCauHoi;
  final bool daoDapAn;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;
  final List<CauHoiQuiz> cauHoi;

  const ChiTietQuizGV({
    required this.id,
    required this.tieuDe,
    this.moTa,
    required this.lopHocPhanId,
    this.chuDeId,
    this.nguoiTaoId,
    this.hanNop,
    this.thoiGianLam,
    this.choXemDapAn = true,
    this.daoCauHoi = false,
    this.daoDapAn = false,
    this.trangThai = 'dang_mo',
    this.ngayTao,
    this.ngayCapNhat,
    this.cauHoi = const [],
  });

  factory ChiTietQuizGV.fromJson(Map<String, dynamic> j) {
    final raw = j['cau_hoi'];
    return ChiTietQuizGV(
      id: _toInt(j['id']) ?? _toInt(j['bai_tap_id']) ?? 0,
      tieuDe: j['tieu_de']?.toString() ?? '',
      moTa: _toStr(j['mo_ta']),
      lopHocPhanId: _toInt(j['lop_hoc_phan_id']) ?? 0,
      chuDeId: _toInt(j['chu_de_id']),
      nguoiTaoId: _toInt(j['nguoi_tao_id']),
      hanNop: _toDateTime(j['han_nop']),
      thoiGianLam: _toInt(j['thoi_gian_lam']),
      choXemDapAn: _toBool(j['cho_xem_dap_an']),
      daoCauHoi: _toBool(j['dao_cau_hoi']),
      daoDapAn: _toBool(j['dao_dap_an']),
      trangThai: j['trang_thai']?.toString() ?? 'dang_mo',
      ngayTao: _toDateTime(j['ngay_tao']),
      ngayCapNhat: _toDateTime(j['ngay_cap_nhat']),
      cauHoi: raw is List
          ? raw
                .map((e) => CauHoiQuiz.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

// ─── KẾT QUẢ QUIZ SINH VIÊN ──────────────────────────────────
class KetQuaQuizSVModel {
  final int baiLamQuizId;
  final int baiTapId;
  final String tieuDe;
  final int tongCau;
  final int soCauDung;
  final double? diem;
  final String trangThai;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianNop;
  final bool choXemDapAn;
  final List<CauHoiQuiz> chiTiet;

  const KetQuaQuizSVModel({
    required this.baiLamQuizId,
    required this.baiTapId,
    required this.tieuDe,
    this.tongCau = 0,
    this.soCauDung = 0,
    this.diem,
    this.trangThai = 'dang_lam',
    this.thoiGianBatDau,
    this.thoiGianNop,
    this.choXemDapAn = false,
    this.chiTiet = const [],
  });

  factory KetQuaQuizSVModel.fromJson(Map<String, dynamic> j) {
    final raw = j['chi_tiet'];
    return KetQuaQuizSVModel(
      baiLamQuizId: _toInt(j['bai_lam_quiz_id']) ?? 0,
      baiTapId: _toInt(j['bai_tap_id']) ?? 0,
      tieuDe: j['tieu_de']?.toString() ?? '',
      tongCau: _toInt(j['tong_cau']) ?? 0,
      soCauDung: _toInt(j['so_cau_dung']) ?? 0,
      diem: _toDouble(j['diem']),
      trangThai: j['trang_thai']?.toString() ?? 'dang_lam',
      thoiGianBatDau: _toDateTime(j['thoi_gian_bat_dau']),
      thoiGianNop: _toDateTime(j['thoi_gian_nop']),
      choXemDapAn: _toBool(j['cho_xem_dap_an']),
      chiTiet: raw is List
          ? raw
                .map((e) => CauHoiQuiz.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }

  String get tenTrangThai => switch (trangThai) {
    'dang_lam' => 'Đang làm',
    'da_nop' => 'Đã nộp',
    'da_cham' => 'Đã chấm',
    'qua_han' => 'Quá hạn',
    _ => trangThai,
  };
}

// ─── KẾT QUẢ QUIZ GIẢNG VIÊN ─────────────────────────────────
class KetQuaQuizGV {
  final int baiLamQuizId;
  final int baiTapId;
  final int sinhVienId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final String trangThai;
  final int tongCau;
  final int soCauDung;
  final double? diem;
  final double diemTracNghiem;
  final double diemTuLuan;
  final double diemToiDa;
  final int soCauTuLuan;
  final int soCauTuLuanChuaCham;
  final bool canChamTuLuan;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianNop;

  const KetQuaQuizGV({
    required this.baiLamQuizId,
    required this.baiTapId,
    required this.sinhVienId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.trangThai = 'dang_lam',
    this.tongCau = 0,
    this.soCauDung = 0,
    this.diem,
    this.diemTracNghiem = 0,
    this.diemTuLuan = 0,
    this.diemToiDa = 10,
    this.soCauTuLuan = 0,
    this.soCauTuLuanChuaCham = 0,
    this.canChamTuLuan = false,
    this.thoiGianBatDau,
    this.thoiGianNop,
  });

  factory KetQuaQuizGV.fromJson(Map<String, dynamic> j) => KetQuaQuizGV(
    baiLamQuizId: _toInt(j['bai_lam_quiz_id']) ?? _toInt(j['id']) ?? 0,
    baiTapId: _toInt(j['bai_tap_id']) ?? 0,
    sinhVienId: _toInt(j['sinh_vien_id']) ?? 0,
    maSinhVien: j['ma_sinh_vien']?.toString() ?? '',
    hoTen: j['ho_ten']?.toString() ?? j['ten_sinh_vien']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    trangThai: j['trang_thai']?.toString() ?? 'dang_lam',
    tongCau: _toInt(j['tong_cau']) ?? 0,
    soCauDung: _toInt(j['so_cau_dung']) ?? 0,
    diem: _toDouble(j['diem']),
    diemTracNghiem: _toDouble(j['diem_trac_nghiem']) ?? 0,
    diemTuLuan: _toDouble(j['diem_tu_luan']) ?? 0,
    diemToiDa: _toDouble(j['diem_toi_da']) ?? 10,
    soCauTuLuan: _toInt(j['so_cau_tu_luan']) ?? 0,
    soCauTuLuanChuaCham: _toInt(j['so_cau_tu_luan_chua_cham']) ?? 0,
    canChamTuLuan: _toBool(j['can_cham_tu_luan']) ||
        ((j['trang_thai']?.toString() == 'da_nop') &&
            ((_toInt(j['so_cau_tu_luan']) ?? 0) > 0)),
    thoiGianBatDau: _toDateTime(j['thoi_gian_bat_dau']),
    thoiGianNop: _toDateTime(j['thoi_gian_nop']),
  );

  String get tenTrangThai => switch (trangThai) {
    'dang_lam' => 'Đang làm',
    'da_nop' => soCauTuLuan > 0 ? 'Chờ chấm tự luận' : 'Đã nộp',
    'da_cham' => 'Đã chấm',
    'qua_han' => 'Quá hạn',
    _ => trangThai,
  };
}

class CauHoiTuLuanChamGV {
  final int cauHoiId;
  final String noiDung;
  final String? giaiThich;
  final String? dapAnTuLuan;
  final double diemToiDa;
  final double diemDat;

  const CauHoiTuLuanChamGV({
    required this.cauHoiId,
    required this.noiDung,
    this.giaiThich,
    this.dapAnTuLuan,
    this.diemToiDa = 1,
    this.diemDat = 0,
  });

  factory CauHoiTuLuanChamGV.fromJson(Map<String, dynamic> j) =>
      CauHoiTuLuanChamGV(
        cauHoiId: _toInt(j['cau_hoi_id']) ?? 0,
        noiDung: j['noi_dung']?.toString() ?? '',
        giaiThich: _toStr(j['giai_thich']),
        dapAnTuLuan: _toStr(j['dap_an_tu_luan']),
        diemToiDa: _toDouble(j['diem_toi_da']) ?? 1,
        diemDat: _toDouble(j['diem_dat']) ?? 0,
      );
}

class ChiTietBaiLamQuizGV {
  final int baiLamQuizId;
  final int baiTapId;
  final String tieuDe;
  final int sinhVienId;
  final String maSinhVien;
  final String hoTen;
  final String email;
  final String trangThai;
  final double diemTracNghiem;
  final double diemTuLuan;
  final double tongDiem;
  final double diemToiDa;
  final List<CauHoiTuLuanChamGV> cauHoiTuLuan;

  const ChiTietBaiLamQuizGV({
    required this.baiLamQuizId,
    required this.baiTapId,
    required this.tieuDe,
    required this.sinhVienId,
    required this.maSinhVien,
    required this.hoTen,
    required this.email,
    this.trangThai = 'dang_lam',
    this.diemTracNghiem = 0,
    this.diemTuLuan = 0,
    this.tongDiem = 0,
    this.diemToiDa = 10,
    this.cauHoiTuLuan = const [],
  });

  factory ChiTietBaiLamQuizGV.fromJson(Map<String, dynamic> j) {
    final raw = j['cau_hoi_tu_luan'];
    return ChiTietBaiLamQuizGV(
      baiLamQuizId: _toInt(j['bai_lam_quiz_id']) ?? 0,
      baiTapId: _toInt(j['bai_tap_id']) ?? _toInt(j['bai_kiem_tra_id']) ?? 0,
      tieuDe: j['tieu_de']?.toString() ?? '',
      sinhVienId: _toInt(j['sinh_vien_id']) ?? 0,
      maSinhVien: j['ma_sinh_vien']?.toString() ?? '',
      hoTen: j['ho_ten']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      trangThai: j['trang_thai']?.toString() ?? 'dang_lam',
      diemTracNghiem: _toDouble(j['diem_trac_nghiem']) ?? 0,
      diemTuLuan: _toDouble(j['diem_tu_luan']) ?? 0,
      tongDiem: _toDouble(j['tong_diem']) ?? 0,
      diemToiDa: _toDouble(j['diem_toi_da']) ?? 10,
      cauHoiTuLuan: raw is List
          ? raw
              .map((e) =>
                  CauHoiTuLuanChamGV.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
