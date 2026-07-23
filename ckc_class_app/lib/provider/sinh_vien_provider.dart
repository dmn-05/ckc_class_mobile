import 'package:ckc_class_app/model/giang_vien_model.dart';
import 'package:flutter/foundation.dart';
import '../services/sinh_vien_service.dart';
import '../model/sinh_vien_model.dart';

class SinhVienProvider extends ChangeNotifier {
  final SinhVienService _service = SinhVienService();

  List<ChuDe> _dsChuDe = [];
  List<int> _btChuDeIds = [];

  List<ChuDe> get dsChuDe => _dsChuDe;
  List<int> get btChuDeIds => _btChuDeIds;

  Future<void> layDanhSachChuDe(int lopHocPhanId) async {
    _dsChuDe = await _service.layDanhSachChuDe(lopHocPhanId);
    notifyListeners();
  }

  // ─── DANH TÍNH ───────────────────────────────────────────────
  int _sinhVienId = 0;
  int _nguoiDungId = 0;

  int get sinhVienId => _sinhVienId;
  int get nguoiDungId => _nguoiDungId;

  void khoiTao(int sinhVienId, int nguoiDungId) {
    _sinhVienId = sinhVienId;
    _nguoiDungId = nguoiDungId;
  }

  // ─── HỒ SƠ ───────────────────────────────────────────────────
  HoSoSinhVienModel? _hoSo;
  bool _hoSoLoading = false;
  String? _hoSoError;

  HoSoSinhVienModel? get hoSo => _hoSo;
  bool get hoSoLoading => _hoSoLoading;
  String? get hoSoError => _hoSoError;

  Future<void> layThongTin() async {
    _hoSoLoading = true;
    _hoSoError = null;
    notifyListeners();
    try {
      _hoSo = await _service.layThongTin(_sinhVienId);
    } catch (e) {
      _hoSoError = _err(e);
    } finally {
      _hoSoLoading = false;
      notifyListeners();
    }
  }

  // ─── LỚP HỌC PHẦN ────────────────────────────────────────────
  List<LopHocPhanSVModel> _dsLop = [];
  bool _lopLoading = false;
  String? _lopError;
  String _lopTuKhoa = '';
  String _lopTrangThai = '';
  String _lopHocKy = '';
  String _lopNamHoc = '';
  final Set<String> _dsNamHocLop = <String>{};
  final Set<String> _dsHocKyLop = <String>{};

  List<LopHocPhanSVModel> get dsLop => _dsLop;
  bool get lopLoading => _lopLoading;
  String? get lopError => _lopError;
  String get lopTuKhoa => _lopTuKhoa;
  String get lopTrangThai => _lopTrangThai;
  String get lopHocKy => _lopHocKy;
  String get lopNamHoc => _lopNamHoc;

  List<String> get dsNamHocLop {
    final list = _dsNamHocLop.toList()
      ..sort((a, b) => b.compareTo(a));
    return list;
  }

  List<String> get dsHocKyLop {
    const order = ['HK1', 'HK2', 'HK3', 'HK4', 'HK5', 'HK6'];
    final list = _dsHocKyLop.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });
    return list;
  }

  Future<void> layDanhSachLop({
    String? tuKhoa,
    String? trangThai,
    String? hocKy,
    String? namHoc,
  }) async {
    if (tuKhoa != null) _lopTuKhoa = tuKhoa;
    if (trangThai != null) _lopTrangThai = trangThai;
    if (hocKy != null) _lopHocKy = hocKy;
    if (namHoc != null) _lopNamHoc = namHoc;
    _lopLoading = true;
    _lopError = null;
    notifyListeners();
    try {
      _dsLop = await _service.layDanhSachLop(
        sinhVienId: _sinhVienId,
        tuKhoa: _lopTuKhoa,
        trangThai: _lopTrangThai,
        hocKy: _lopHocKy,
        namHoc: _lopNamHoc,
      );

      for (final lop in _dsLop) {
        final nam = lop.namHoc?.trim() ?? '';
        final ky = lop.hocKy?.trim() ?? '';
        if (nam.isNotEmpty) _dsNamHocLop.add(nam);
        if (ky.isNotEmpty) _dsHocKyLop.add(ky);
      }
    } catch (e) {
      _lopError = _err(e);
    } finally {
      _lopLoading = false;
      notifyListeners();
    }
  }

  Future<void> xoaBoLocLop() async {
    _lopTuKhoa = '';
    _lopTrangThai = '';
    _lopHocKy = '';
    _lopNamHoc = '';
    await layDanhSachLop();
  }

  // ─── TÀI LIỆU ────────────────────────────────────────────────
  List<TaiLieuSVModel> _dsTaiLieu = [];
  bool _tlLoading = false;
  String? _tlError;

  List<TaiLieuSVModel> get dsTaiLieu => _dsTaiLieu;
  bool get tlLoading => _tlLoading;
  String? get tlError => _tlError;

  Future<void> layDanhSachTaiLieu(
    int lopHocPhanId, {
    String tuKhoa = '',
  }) async {
    _tlLoading = true;
    _tlError = null;
    notifyListeners();
    try {
      _dsTaiLieu = await _service.layDanhSachTaiLieu(
        lopHocPhanId: lopHocPhanId,
        tuKhoa: tuKhoa,
      );
    } catch (e) {
      _tlError = _err(e);
    } finally {
      _tlLoading = false;
      notifyListeners();
    }
  }

  // ─── THÔNG BÁO ────────────────────────────────────────────────
  List<ThongBaoSVModel> _dsThongBao = [];
  bool _tbLoading = false;
  String? _tbError;

  List<ThongBaoSVModel> get dsThongBao => _dsThongBao;
  bool get tbLoading => _tbLoading;
  String? get tbError => _tbError;

  Future<void> layDanhSachThongBao(int lopHocPhanId) async {
    _tbLoading = true;
    _tbError = null;
    notifyListeners();
    try {
      _dsThongBao = await _service.layDanhSachThongBao(lopHocPhanId);
    } catch (e) {
      _tbError = _err(e);
    } finally {
      _tbLoading = false;
      notifyListeners();
    }
  }

  // ─── BÀI TẬP ─────────────────────────────────────────────────
  List<BaiTapSVModel> _dsBaiTap = [];
  bool _btLoading = false;
  bool _btProcessing = false;
  String? _btError;

  List<BaiTapSVModel> get dsBaiTap => _dsBaiTap;
  bool get btLoading => _btLoading;
  bool get btProcessing => _btProcessing;
  String? get btError => _btError;

  Future<void> layDanhSachBaiTap(
    int lopHocPhanId, {
    List<int>? chuDeIds,
  }) async {
    if (chuDeIds != null) {
      _btChuDeIds = chuDeIds;
    }

    _btLoading = true;
    _btError = null;
    notifyListeners();

    try {
      _dsBaiTap = await _service.layDanhSachBaiTap(
        sinhVienId: _sinhVienId,
        lopHocPhanId: lopHocPhanId,
        chuDeIds: _btChuDeIds,
      );
    } catch (e) {
      _btError = _err(e);
    } finally {
      _btLoading = false;
      notifyListeners();
    }
  }

  //- NHÓM THEO CHỦ ĐỀ
  Map<String, List<BaiTapSVModel>> get baiTapTheoChuDe {
    final Map<String, List<BaiTapSVModel>> map = {};

    for (final bt in _dsBaiTap) {
      final ten = bt.tenChuDe ?? 'Chưa phân loại';
      map.putIfAbsent(ten, () => []);
      map[ten]!.add(bt);
    }

    return map;
  }

  Future<void> toggleChuDeBaiTap(int lopHocPhanId, int chuDeId) async {
    final ids = List<int>.from(_btChuDeIds);

    if (ids.contains(chuDeId)) {
      ids.remove(chuDeId);
    } else {
      ids.add(chuDeId);
    }

    await layDanhSachBaiTap(lopHocPhanId, chuDeIds: ids);
  }

  Future<void> xoaLocChuDeBaiTap(int lopHocPhanId) async {
    await layDanhSachBaiTap(lopHocPhanId, chuDeIds: []);
  }

  //Future<void> locBaiTapTheoChuDe(int lopHocPhanId, int? chuDeId) async {
  //_btChuDeId = chuDeId;

  //await layDanhSachBaiTap(
  //lopHocPhanId,
  //chuDeId: chuDeId,
  //resetChuDe: chuDeId == null,
  //);
  //}

  Future<Map<String, dynamic>> nopBai({
    required int baiTapId,
    required String filePath,
    required int lopHocPhanId,
  }) {
    return nopBaiNhieuFile(
      baiTapId: baiTapId,
      filePaths: [filePath],
      lopHocPhanId: lopHocPhanId,
    );
  }

  Future<Map<String, dynamic>> nopBaiNhieuFile({
    required int baiTapId,
    required List<String> filePaths,
    required int lopHocPhanId,
  }) async {
    if (_sinhVienId <= 0) {
      return {'success': false, 'message': 'Chưa khởi tạo ID sinh viên'};
    }

    final paths = filePaths
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (paths.isEmpty) {
      return {'success': false, 'message': 'Vui lòng chọn file để nộp'};
    }

    _btProcessing = true;
    notifyListeners();

    try {
      final msg = await _service.nopBaiNhieuFile(
        sinhVienId: _sinhVienId,
        baiTapId: baiTapId,
        filePaths: paths,
      );

      await layDanhSachBaiTap(lopHocPhanId);
      await layBaiTapChuaNop();
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    } finally {
      _btProcessing = false;
      notifyListeners();
    }
  }

  // ─── BÀI TẬP CHƯA NỘP (dashboard) ───────────────────────────
  List<BaiTapChuaNopModel> _dsBaiChuaNop = [];
  bool _bcnLoading = false;
  String? _bcnError;

  List<BaiTapChuaNopModel> get dsBaiChuaNop => _dsBaiChuaNop;
  bool get bcnLoading => _bcnLoading;
  String? get bcnError => _bcnError;

  Future<void> layBaiTapChuaNop() async {
    _bcnLoading = true;
    _bcnError = null;
    notifyListeners();
    try {
      _dsBaiChuaNop = await _service.layBaiTapChuaNop(_sinhVienId);
    } catch (e) {
      _bcnError = _err(e);
    } finally {
      _bcnLoading = false;
      notifyListeners();
    }
  }

  // ─── BÌNH LUẬN ────────────────────────────────────────────────
  List<BinhLuanModel> _dsBinhLuan = [];
  bool _blLoading = false;
  bool _blProcessing = false;
  String? _blError;
  int? _lopBinhLuanDangXem;

  List<BinhLuanModel> get dsBinhLuan => _dsBinhLuan;
  bool get blLoading => _blLoading;
  bool get blProcessing => _blProcessing;
  String? get blError => _blError;

  Future<void> layDanhSachBinhLuan(int lopHocPhanId) async {
    _lopBinhLuanDangXem = lopHocPhanId;
    _blLoading = true;
    _blError = null;
    notifyListeners();
    try {
      _dsBinhLuan = await _service.layDanhSachBinhLuan(lopHocPhanId);
    } catch (e) {
      _blError = _err(e);
    } finally {
      _blLoading = false;
      notifyListeners();
    }
  }

  Future<void> layDanhSachBinhLuanThongBao(int baiVietId) async {
    if (baiVietId <= 0) {
      _dsBinhLuan = [];
      _blError = 'Thông báo chưa được liên kết với bài viết';
      notifyListeners();
      return;
    }

    _blLoading = true;
    _blError = null;
    notifyListeners();
    try {
      _dsBinhLuan = await _service.layDanhSachBinhLuanThongBao(baiVietId);
    } catch (e) {
      _blError = _err(e);
    } finally {
      _blLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> dangBinhLuanThongBao({
    required int baiVietId,
    required String noiDung,
  }) async {
    if (baiVietId <= 0) {
      return {
        'success': false,
        'message': 'Thông báo chưa được liên kết với bài viết',
      };
    }

    _blProcessing = true;
    notifyListeners();
    try {
      final bl = await _service.dangBinhLuanThongBao(
        nguoiDungId: _nguoiDungId,
        baiVietId: baiVietId,
        noiDung: noiDung,
      );
      _dsBinhLuan.add(bl);
      notifyListeners();
      return {
        'success': true,
        'message': 'Đăng bình luận thông báo thành công',
      };
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    } finally {
      _blProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> dangBinhLuan({
    required int lopHocPhanId,
    required String noiDung,
  }) async {
    _blProcessing = true;
    notifyListeners();
    try {
      final bl = await _service.dangBinhLuan(
        nguoiDungId: _nguoiDungId,
        lopHocPhanId: lopHocPhanId,
        noiDung: noiDung,
      );
      _dsBinhLuan.add(bl);
      notifyListeners();
      return {'success': true, 'message': 'Đăng bình luận thành công'};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    } finally {
      _blProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> suaBinhLuan({
    required int binhLuanId,
    required String noiDung,
  }) async {
    _blProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.suaBinhLuan(
        nguoiDungId: _nguoiDungId,
        binhLuanId: binhLuanId,
        noiDung: noiDung,
      );
      final idx = _dsBinhLuan.indexWhere((b) => b.id == binhLuanId);
      if (idx != -1) {
        final old = _dsBinhLuan[idx];
        _dsBinhLuan[idx] = BinhLuanModel(
          id: old.id,
          noiDung: noiDung,
          nguoiDungId: old.nguoiDungId,
          tenNguoiDung: old.tenNguoiDung,
          tenVaiTro: old.tenVaiTro,
          ngayTao: old.ngayTao,
          ngayCapNhat: DateTime.now(),
        );
      }
      notifyListeners();
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    } finally {
      _blProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> xoaBinhLuan(int binhLuanId) async {
    _blProcessing = true;
    notifyListeners();
    try {
      final msg = await _service.xoaBinhLuan(
        nguoiDungId: _nguoiDungId,
        binhLuanId: binhLuanId,
      );
      _dsBinhLuan.removeWhere((b) => b.id == binhLuanId);
      notifyListeners();
      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    } finally {
      _blProcessing = false;
      notifyListeners();
    }
  }

  // ─── KHỞI TẠO TOÀN BỘ ────────────────────────────────────────
  Future<void> khoiTaoDuLieu() async {
    await Future.wait([layThongTin(), layDanhSachLop(), layBaiTapChuaNop()]);
  }

  // ─── HELPER ──────────────────────────────────────────────────
  String _err(dynamic e) {
    var msg = e.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  Future<Map<String, dynamic>> khoiTaoTuNguoiDungId(int nguoiDungId) async {
    try {
      final data = await _service.layThongTinSinhVienTheoNguoiDung(nguoiDungId);

      _sinhVienId = int.tryParse(data['sinh_vien_id'].toString()) ?? 0;
      _nguoiDungId = int.tryParse(data['nguoi_dung_id'].toString()) ?? 0;

      if (_sinhVienId <= 0) {
        return {'success': false, 'message': 'Không tìm thấy ID sinh viên'};
      }

      await khoiTaoDuLieu();

      if (_hoSo == null) {
        return {
          'success': false,
          'message': _hoSoError ?? 'Không tải được hồ sơ sinh viên',
        };
      }

      return {'success': true, 'message': 'Khởi tạo sinh viên thành công'};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    }
  }

  List<ThanhVienLopSVModel> _dsSinhVienTrongLop = [];
  ThanhVienLopSVModel? _giangVienLop;
  bool _tvLoading = false;
  String? _tvError;

  List<ThanhVienLopSVModel> get dsSinhVienTrongLop => _dsSinhVienTrongLop;
  ThanhVienLopSVModel? get giangVienLop => _giangVienLop;
  bool get tvLoading => _tvLoading;
  String? get tvError => _tvError;

  Future<void> layThanhVienLop(int lopHocPhanId) async {
    _tvLoading = true;
    _tvError = null;
    notifyListeners();

    try {
      final data = await _service.layThanhVienLop(lopHocPhanId);

      final gv = data['giang_vien'];
      if (gv is Map) {
        _giangVienLop = ThanhVienLopSVModel.fromJson(
          Map<String, dynamic>.from(gv),
          vaiTro: 'giang_vien',
        );
      } else {
        _giangVienLop = null;
      }

      final ds = data['sinh_vien'];
      if (ds is List) {
        _dsSinhVienTrongLop = ds
            .map(
              (e) => ThanhVienLopSVModel.fromJson(
                Map<String, dynamic>.from(e),
                vaiTro: 'sinh_vien',
              ),
            )
            .toList();
      } else {
        _dsSinhVienTrongLop = [];
      }
    } catch (e) {
      _tvError = _err(e);
    } finally {
      _tvLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> thamGiaLopHocPhan(String maLopHocPhan) async {
    if (_sinhVienId <= 0) {
      return {'success': false, 'message': 'Chưa khởi tạo ID sinh viên'};
    }

    try {
      final msg = await _service.thamGiaLopHocPhan(
        sinhVienId: _sinhVienId,
        maLopHocPhan: maLopHocPhan.trim(),
      );

      return {'success': true, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': _err(e)};
    }
  }

  void reset() {
    _sinhVienId = 0;
    _nguoiDungId = 0;

    _hoSo = null;
    _hoSoLoading = false;
    _hoSoError = null;

    _dsLop = [];
    _lopLoading = false;
    _lopError = null;
    _lopTuKhoa = '';
    _lopTrangThai = '';
    _lopHocKy = '';
    _lopNamHoc = '';
    _dsNamHocLop.clear();
    _dsHocKyLop.clear();

    _dsTaiLieu = [];
    _tlLoading = false;
    _tlError = null;

    _dsThongBao = [];
    _tbLoading = false;
    _tbError = null;

    _dsBaiTap = [];
    _btLoading = false;
    _btProcessing = false;
    _btError = null;

    _dsChuDe = [];
    _btChuDeIds = [];

    _dsBaiChuaNop = [];
    _bcnLoading = false;
    _bcnError = null;

    _dsBinhLuan = [];
    _blLoading = false;
    _blProcessing = false;
    _blError = null;
    _lopBinhLuanDangXem = null;

    notifyListeners();
  }
}
