import 'package:flutter/foundation.dart';
import '../services/giang_vien_service.dart';
import '../model/giang_vien_model.dart';

class GiangVienProvider extends ChangeNotifier {
  final GiangVienService _service = GiangVienService();

  // ─── THÔNG TIN GIẢNG VIÊN ────────────────────────────────
  int _giangVienId = 0;
  int _nguoiDungId = 0;

  int get giangVienId => _giangVienId;
  int get nguoiDungId => _nguoiDungId;

  void khoiTaoGiangVien(int giangVienId, int nguoiDungId) {
    _giangVienId = giangVienId;
    _nguoiDungId = nguoiDungId;
  }

  // ─── LỚP HỌC PHẦN ────────────────────────────────────────
  List<LopHocPhan> _dsLopHocPhan = [];
  bool _lopLoading = false;
  String? _lopError;
  String _lopTuKhoa = '';
  String _lopTrangThai = '';
  String _lopHocKy = '';
  String _lopKhoaHoc = '';
  List<String> _dsKhoaHocLop = [];
  List<String> _dsHocKyLop = [];

  List<LopHocPhan> get dsLopHocPhan => _dsLopHocPhan;
  bool get lopLoading => _lopLoading;
  String? get lopError => _lopError;
  String get lopTuKhoa => _lopTuKhoa;
  String get lopTrangThai => _lopTrangThai;
  String get lopHocKy => _lopHocKy;
  String get lopKhoaHoc => _lopKhoaHoc;
  List<String> get dsKhoaHocLop => List.unmodifiable(_dsKhoaHocLop);
  List<String> get dsHocKyLop => List.unmodifiable(_dsHocKyLop);

  Future<void> layDanhSachLop({
    String? tuKhoa,
    String? trangThai,
    String? hocKy,
    String? khoaHoc,
  }) async {
    if (tuKhoa != null) _lopTuKhoa = tuKhoa;
    if (trangThai != null) _lopTrangThai = trangThai;
    if (hocKy != null) _lopHocKy = hocKy.trim();
    if (khoaHoc != null) _lopKhoaHoc = khoaHoc.trim();

    if (_giangVienId <= 0) {
      _dsLopHocPhan = [];
      _lopLoading = false;
      _lopError = 'Chưa khởi tạo ID giảng viên';
      notifyListeners();
      return;
    }

    _lopLoading = true;
    _lopError = null;
    notifyListeners();

    try {
      _dsLopHocPhan = await _service.layDanhSachLopHocPhan(
        giangVienId: _giangVienId,
        tuKhoa: _lopTuKhoa,
        trangThai: _lopTrangThai,
        hocKy: _lopHocKy,
        khoaHoc: _lopKhoaHoc,
      );

      // Giữ danh sách lựa chọn bộ lọc từ dữ liệu đã tải.
      // Không xóa cache khi đang lọc để người dùng vẫn đổi được sang giá trị khác.
      final khoaHocMoi = _dsLopHocPhan
          .map((e) => e.khoaHoc?.trim() ?? '')
          .where((e) => e.isNotEmpty);
      final hocKyMoi = _dsLopHocPhan
          .map((e) => e.hocKy?.trim() ?? '')
          .where((e) => e.isNotEmpty);

      _dsKhoaHocLop = {..._dsKhoaHocLop, ...khoaHocMoi}.toList()..sort();
      _dsHocKyLop = {..._dsHocKyLop, ...hocKyMoi}.toList()..sort();
    } catch (e) {
      _lopError = _xuLyLoi(e);
    } finally {
      _lopLoading = false;
      notifyListeners();
    }
  }

  Future<void> xoaBoLocLop() async {
    _lopTuKhoa = '';
    _lopTrangThai = '';
    _lopHocKy = '';
    _lopKhoaHoc = '';
    await layDanhSachLop(
      tuKhoa: '',
      trangThai: '',
      hocKy: '',
      khoaHoc: '',
    );
  }

  // ─── SINH VIÊN TRONG LỚP ─────────────────────────────────
  List<SinhVienLop> _dsSinhVienLop = [];
  bool _svLoading = false;
  String? _svError;
  int? _lopHocPhanDangXem;

  List<SinhVienLop> get dsSinhVienLop => _dsSinhVienLop;
  bool get svLoading => _svLoading;
  String? get svError => _svError;
  int? get lopHocPhanDangXem => _lopHocPhanDangXem;

  Future<void> layDanhSachSinhVien(
    int lopHocPhanId, {
    String tuKhoa = '',
  }) async {
    _lopHocPhanDangXem = lopHocPhanId;
    _svLoading = true;
    _svError = null;
    notifyListeners();

    try {
      _dsSinhVienLop = await _service.layDanhSachSinhVienLop(
        lopHocPhanId: lopHocPhanId,
        tuKhoa: tuKhoa,
      );
    } catch (e) {
      _svError = _xuLyLoi(e);
    } finally {
      _svLoading = false;
      notifyListeners();
    }
  }

  // ─── TÀI LIỆU ────────────────────────────────────────────
  List<TaiLieu> _dsTaiLieu = [];
  bool _tlLoading = false;
  bool _tlProcessing = false;
  String? _tlError;

  List<TaiLieu> get dsTaiLieu => _dsTaiLieu;
  bool get tlLoading => _tlLoading;
  bool get tlProcessing => _tlProcessing;
  String? get tlError => _tlError;

  Future<void> layDanhSachTaiLieu(
    int lopHocPhanId, {
    String tuKhoa = '',
    String trangThai = '',
  }) async {
    _tlLoading = true;
    _tlError = null;
    notifyListeners();

    try {
      _dsTaiLieu = await _service.layDanhSachTaiLieu(
        lopHocPhanId: lopHocPhanId,
        tuKhoa: tuKhoa,
        trangThai: trangThai,
      );
    } catch (e) {
      _tlError = _xuLyLoi(e);
    } finally {
      _tlLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> themTaiLieu({
    required String tieuDe,
    required int lopHocPhanId,
    String moTa = '',
    String duongDanFile = '',
    String trangThai = 'hien_thi',
  }) async {
    _tlProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.themTaiLieu(
        tieuDe: tieuDe,
        lopHocPhanId: lopHocPhanId,
        nguoiTaoId: _nguoiDungId,
        moTa: moTa,
        duongDanFile: duongDanFile,
        trangThai: trangThai,
      );
      await layDanhSachTaiLieu(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tlProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> suaTaiLieu({
    required int id,
    required String tieuDe,
    required int lopHocPhanId,
    String moTa = '',
    String duongDanFile = '',
    String trangThai = 'hien_thi',
  }) async {
    _tlProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.suaTaiLieu(
        id: id,
        tieuDe: tieuDe,
        moTa: moTa,
        duongDanFile: duongDanFile,
        trangThai: trangThai,
      );
      await layDanhSachTaiLieu(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tlProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> xoaTaiLieu(int id, int lopHocPhanId) async {
    _tlProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.xoaTaiLieu(id);
      await layDanhSachTaiLieu(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tlProcessing = false;
      notifyListeners();
    }
  }

  // ─── CHỦ ĐỀ ─────────────────────────────────────────────
  List<ChuDe> _dsChuDe = [];
  bool _chuDeLoading = false;
  String? _chuDeError;

  List<ChuDe> get dsChuDe => _dsChuDe;
  bool get chuDeLoading => _chuDeLoading;
  String? get chuDeError => _chuDeError;

  Future<void> layDanhSachChuDe(int lopHocPhanId) async {
    _chuDeLoading = true;
    _chuDeError = null;
    notifyListeners();

    try {
      _dsChuDe = await _service.layDanhSachChuDe(lopHocPhanId);
    } catch (e) {
      _chuDeError = _xuLyLoi(e);
    } finally {
      _chuDeLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> themChuDe({
    required int lopHocPhanId,
    required String tenChuDe,
  }) async {
    try {
      final msg = await _service.themChuDe(
        lopHocPhanId: lopHocPhanId,
        tenChuDe: tenChuDe,
      );

      await layDanhSachChuDe(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    }
  }

  Future<Map<String, dynamic>> suaChuDe({
    required int lopHocPhanId,
    required int chuDeId,
    required String tenChuDe,
  }) async {
    try {
      final msg = await _service.suaChuDe(chuDeId: chuDeId, tenChuDe: tenChuDe);

      await layDanhSachChuDe(lopHocPhanId);
      await layDanhSachBaiTap(lopHocPhanId, chuDeIds: _btChuDeIds);

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    }
  }

  Future<Map<String, dynamic>> xoaChuDe({
    required int lopHocPhanId,
    required int chuDeId,
  }) async {
    try {
      final msg = await _service.xoaChuDe(chuDeId);

      _btChuDeIds.remove(chuDeId);

      await layDanhSachChuDe(lopHocPhanId);
      await layDanhSachBaiTap(lopHocPhanId, chuDeIds: _btChuDeIds);

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    }
  }

  // ─── BÀI TẬP ─────────────────────────────────────────────
  List<BaiTap> _dsBaiTap = [];
  bool _btLoading = false;
  bool _btProcessing = false;
  String? _btError;

  List<int> _btChuDeIds = [];
  String _btTuKhoa = '';
  String _btTrangThai = '';

  List<BaiTap> get dsBaiTap => _dsBaiTap;
  bool get btLoading => _btLoading;
  bool get btProcessing => _btProcessing;
  String? get btError => _btError;

  List<int> get btChuDeIds => _btChuDeIds;
  String get btTuKhoa => _btTuKhoa;
  String get btTrangThai => _btTrangThai;

  Future<void> layDanhSachBaiTap(
    int lopHocPhanId, {
    String? tuKhoa,
    String? trangThai,
    List<int>? chuDeIds,
  }) async {
    if (tuKhoa != null) _btTuKhoa = tuKhoa;
    if (trangThai != null) _btTrangThai = trangThai;
    if (chuDeIds != null) _btChuDeIds = chuDeIds;

    _btLoading = true;
    _btError = null;
    notifyListeners();

    try {
      _dsBaiTap = await _service.layDanhSachBaiTap(
        lopHocPhanId: lopHocPhanId,
        tuKhoa: _btTuKhoa,
        trangThai: _btTrangThai,
        chuDeIds: _btChuDeIds,
      );
    } catch (e) {
      _btError = _xuLyLoi(e);
    } finally {
      _btLoading = false;
      notifyListeners();
    }
  }

  Future<void> xoaBoLocBaiTap(int lopHocPhanId) async {
    _btTuKhoa = '';
    _btTrangThai = '';
    _btChuDeIds = [];
    await layDanhSachBaiTap(lopHocPhanId, chuDeIds: []);
  }

  Future<void> toggleChuDeBaiTap(int lopHocPhanId, int chuDeId) async {
    if (_btChuDeIds.contains(chuDeId)) {
      _btChuDeIds.remove(chuDeId);
    } else {
      _btChuDeIds.add(chuDeId);
    }

    notifyListeners();
  }

  Future<void> xoaLocChuDeBaiTap(int lopHocPhanId) async {
    await layDanhSachBaiTap(lopHocPhanId, chuDeIds: []);
  }

  Future<Map<String, dynamic>> themBaiTap({
    required String tieuDe,
    required int lopHocPhanId,
    int? chuDeId,
    String moTa = '',
    String duongDanFile = '',
    DateTime? hanNop,
    bool yeuCauNopFile = true,
    String dinhDangFileChoPhep = '',
    int soFileToiDa = 1,
    int dungLuongToiDaMb = 25,
    bool choPhepNopLai = true,
    bool choPhepNopMuon = true,
    double diemToiDa = 10,
    String trangThai = 'dang_mo',
    DateTime? thoiGianGui,
    List<String> filePaths = const [],
  }) async {
    _btProcessing = true;
    notifyListeners();

    try {
      final msg = await _service.themBaiTap(
        tieuDe: tieuDe,
        lopHocPhanId: lopHocPhanId,
        nguoiTaoId: _nguoiDungId,
        chuDeId: chuDeId,
        moTa: moTa,
        duongDanFile: duongDanFile,
        hanNop: hanNop,
        yeuCauNopFile: yeuCauNopFile,
        dinhDangFileChoPhep: dinhDangFileChoPhep,
        soFileToiDa: soFileToiDa,
        dungLuongToiDaMb: dungLuongToiDaMb,
        choPhepNopLai: choPhepNopLai,
        choPhepNopMuon: choPhepNopMuon,
        diemToiDa: diemToiDa,
        trangThai: trangThai,
        thoiGianGui: thoiGianGui,
      );

      await layDanhSachBaiTap(lopHocPhanId, chuDeIds: _btChuDeIds);

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _btProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> suaBaiTap({
    required int id,
    required String tieuDe,
    required int lopHocPhanId,
    int? chuDeId,
    String moTa = '',
    String duongDanFile = '',
    DateTime? hanNop,
    bool yeuCauNopFile = true,
    String dinhDangFileChoPhep = '',
    int soFileToiDa = 1,
    int dungLuongToiDaMb = 25,
    bool choPhepNopLai = true,
    bool choPhepNopMuon = true,
    double diemToiDa = 10,
    String trangThai = 'dang_mo',
    DateTime? thoiGianGui,
    List<String> filePaths = const [],
  }) async {
    _btProcessing = true;
    notifyListeners();

    try {
      final msg = await _service.suaBaiTap(
        id: id,
        tieuDe: tieuDe,
        chuDeId: chuDeId,
        moTa: moTa,
        duongDanFile: duongDanFile,
        hanNop: hanNop,
        yeuCauNopFile: yeuCauNopFile,
        dinhDangFileChoPhep: dinhDangFileChoPhep,
        soFileToiDa: soFileToiDa,
        dungLuongToiDaMb: dungLuongToiDaMb,
        choPhepNopLai: choPhepNopLai,
        choPhepNopMuon: choPhepNopMuon,
        diemToiDa: diemToiDa,
        trangThai: trangThai,
        thoiGianGui: thoiGianGui,
      );

      await layDanhSachBaiTap(lopHocPhanId, chuDeIds: _btChuDeIds);

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _btProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> xoaBaiTap(int id, int lopHocPhanId) async {
    _btProcessing = true;
    notifyListeners();

    try {
      final msg = await _service.xoaBaiTap(id);

      await layDanhSachBaiTap(lopHocPhanId, chuDeIds: _btChuDeIds);

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _btProcessing = false;
      notifyListeners();
    }
  }

  static const int chuDeChuaPhanLoaiId = -1;

  Map<String, List<BaiTap>> get baiTapTheoChuDe {
    final List<BaiTap> dsLoc = _btChuDeIds.isEmpty
        ? _dsBaiTap
        : _dsBaiTap.where((bt) {
            final laChuaPhanLoai = bt.chuDeId == null || bt.chuDeId == 0;

            if (_btChuDeIds.contains(chuDeChuaPhanLoaiId) && laChuaPhanLoai) {
              return true;
            }

            if (bt.chuDeId != null && _btChuDeIds.contains(bt.chuDeId)) {
              return true;
            }

            return false;
          }).toList();

    final Map<String, List<BaiTap>> map = {};

    for (final bt in dsLoc) {
      final tenChuDe = (bt.tenChuDe != null && bt.tenChuDe!.trim().isNotEmpty)
          ? bt.tenChuDe!.trim()
          : 'Chưa phân loại';

      map.putIfAbsent(tenChuDe, () => []);
      map[tenChuDe]!.add(bt);
    }

    return map;
  }

  // ─── BÀI NỘP ─────────────────────────────────────────────
  List<BaiNop> _dsBaiNop = [];
  bool _bnLoading = false;
  bool _bnProcessing = false;
  String? _bnError;
  BaiTap? _baiTapDangXem;

  List<BaiNop> get dsBaiNop => _dsBaiNop;
  bool get bnLoading => _bnLoading;
  bool get bnProcessing => _bnProcessing;
  String? get bnError => _bnError;
  BaiTap? get baiTapDangXem => _baiTapDangXem;

  Future<void> layDanhSachBaiNop(BaiTap baiTap, {String trangThai = ''}) async {
    _baiTapDangXem = baiTap;
    _bnLoading = true;
    _bnError = null;
    notifyListeners();
    try {
      _dsBaiNop = await _service.layDanhSachBaiNop(
        baiTapId: baiTap.id,
        trangThai: trangThai,
      );
    } catch (e) {
      _bnError = _xuLyLoi(e);
    } finally {
      _bnLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> chamDiem({
    required int baiNopId,
    double? diem,
    String nhanXet = '',
  }) async {
    _bnProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.chamDiem(
        baiNopId: baiNopId,
        giangVienChamId: _giangVienId,
        diem: diem,
        nhanXet: nhanXet,
      );
      if (_baiTapDangXem != null) await layDanhSachBaiNop(_baiTapDangXem!);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _bnProcessing = false;
      notifyListeners();
    }
  }

  // ─── THÔNG BÁO ────────────────────────────────────────────
  List<ThongBao> _dsThongBao = [];
  bool _tbLoading = false;
  bool _tbProcessing = false;
  String? _tbError;

  List<ThongBao> get dsThongBao => _dsThongBao;
  bool get tbLoading => _tbLoading;
  bool get tbProcessing => _tbProcessing;
  String? get tbError => _tbError;

  Future<void> layDanhSachThongBao(
    int lopHocPhanId, {
    String trangThai = '',
  }) async {
    _tbLoading = true;
    _tbError = null;
    notifyListeners();
    try {
      _dsThongBao = await _service.layDanhSachThongBao(
        lopHocPhanId: lopHocPhanId,
        trangThai: trangThai,
      );
    } catch (e) {
      _tbError = _xuLyLoi(e);
    } finally {
      _tbLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> themThongBao({
    required String tieuDe,
    required int lopHocPhanId,
    String noiDung = '',
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<String> filePaths = const [],
  }) async {
    _tbProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.themThongBao(
        tieuDe: tieuDe,
        lopHocPhanId: lopHocPhanId,
        nguoiTaoId: _nguoiDungId,
        noiDung: noiDung,
        trangThai: trangThai,
        thoiGianGui: thoiGianGui,
      );
      await layDanhSachThongBao(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tbProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> suaThongBao({
    required int id,
    required String tieuDe,
    required int lopHocPhanId,
    String noiDung = '',
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<String> filePaths = const [],
  }) async {
    _tbProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.suaThongBao(
        id: id,
        tieuDe: tieuDe,
        noiDung: noiDung,
        trangThai: trangThai,
        thoiGianGui: thoiGianGui,
      );
      await layDanhSachThongBao(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tbProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> xoaThongBao(int id, int lopHocPhanId) async {
    _tbProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.xoaThongBao(id);
      await layDanhSachThongBao(lopHocPhanId);
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    } finally {
      _tbProcessing = false;
      notifyListeners();
    }
  }

  // ─── THỐNG KÊ ─────────────────────────────────────────────
  ThongKeGiangVien? _thongKe;
  bool _tkLoading = false;
  String? _tkError;

  ThongKeGiangVien? get thongKe => _thongKe;
  bool get tkLoading => _tkLoading;
  String? get tkError => _tkError;

  Future<void> layThongKe() async {
    if (_giangVienId <= 0) {
      _thongKe = null;
      _tkLoading = false;
      _tkError = 'Chưa khởi tạo ID giảng viên';
      notifyListeners();
      return;
    }

    _tkLoading = true;
    _tkError = null;
    notifyListeners();

    try {
      _thongKe = await _service.layThongKe(_giangVienId);
    } catch (e) {
      _tkError = _xuLyLoi(e);
    } finally {
      _tkLoading = false;
      notifyListeners();
    }
  }

  // ─── KHỞI TẠO TOÀN BỘ ────────────────────────────────────
  Future<void> khoiTaoDuLieu() async {
    await Future.wait([layDanhSachLop(), layThongKe()]);
  }

  // ─── HELPER ──────────────────────────────────────────────
  String _xuLyLoi(dynamic error) {
    var msg = error.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  // ✅ THÊM: khởi tạo giảng viên từ tài khoản đăng nhập
  Future<Map<String, dynamic>> khoiTaoTuNguoiDungId(int nguoiDungId) async {
    try {
      final data = await _service.layThongTinGiangVienTheoNguoiDung(
        nguoiDungId,
      );

      _giangVienId = int.tryParse(data['giang_vien_id'].toString()) ?? 0;
      _nguoiDungId = int.tryParse(data['nguoi_dung_id'].toString()) ?? 0;

      if (_giangVienId <= 0) {
        return {'success': false, 'message': 'Không tìm thấy ID giảng viên'};
      }

      await khoiTaoDuLieu();

      return {'success': true, 'message': 'Khởi tạo giảng viên thành công'};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    }
  }

  List<MonHocGV> _dsMonHoc = [];
  bool _mhLoading = false;
  String? _mhError;

  List<MonHocGV> get dsMonHoc => _dsMonHoc;
  bool get mhLoading => _mhLoading;
  String? get mhError => _mhError;

  Future<void> layDanhSachMonHoc() async {
    _mhLoading = true;
    _mhError = null;
    notifyListeners();

    try {
      _dsMonHoc = await _service.layDanhSachMonHoc();
    } catch (e) {
      _mhError = _xuLyLoi(e);
    } finally {
      _mhLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> taoLopHocPhan({
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
  }) async {
    if (_giangVienId <= 0) {
      return {'success': false, 'message': 'Chưa khởi tạo ID giảng viên'};
    }

    try {
      final msg = await _service.taoLopHocPhan(
        giangVienId: _giangVienId,
        maLopHocPhan: maLopHocPhan,
        tenLop: tenLop,
        monHocId: monHocId,
        hocKy: hocKy,
        namHoc: namHoc,
        siSoToiDa: siSoToiDa,
      );

      await layDanhSachLop();
      await layThongKe();

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _xuLyLoi(e)};
    }
  }

  void reset() {
    _giangVienId = 0;
    _nguoiDungId = 0;

    _dsLopHocPhan = [];
    _lopLoading = false;
    _lopError = null;
    _lopTuKhoa = '';
    _lopTrangThai = '';
    _lopHocKy = '';
    _lopKhoaHoc = '';
    _dsKhoaHocLop = [];
    _dsHocKyLop = [];

    _dsSinhVienLop = [];
    _svLoading = false;
    _svError = null;
    _lopHocPhanDangXem = null;

    _dsTaiLieu = [];
    _tlLoading = false;
    _tlProcessing = false;
    _tlError = null;

    _dsBaiTap = [];
    _btLoading = false;
    _btProcessing = false;
    _btError = null;

    _dsBaiNop = [];
    _bnLoading = false;
    _bnProcessing = false;
    _bnError = null;
    _baiTapDangXem = null;

    _dsThongBao = [];
    _tbLoading = false;
    _tbProcessing = false;
    _tbError = null;

    _thongKe = null;
    _tkLoading = false;
    _tkError = null;

    _dsChuDe = [];
    _chuDeLoading = false;
    _chuDeError = null;
    _btChuDeIds = [];
    _btTuKhoa = '';
    _btTrangThai = '';

    notifyListeners();
  }
}
