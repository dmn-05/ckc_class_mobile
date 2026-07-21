import 'package:flutter/foundation.dart';

import '../services/nguoi_dung_service.dart';
import '../model/nguoi_dung_model.dart';

class NguoiDungProvider extends ChangeNotifier {
  final NguoiDungService _nguoiDungService = NguoiDungService();

  List<NguoiDung> _dsNguoiDung = [];
  List<VaiTro> _dsVaiTro = [];
  List<KhoaNguoiDung> _dsKhoa = [];
  List<LopHanhChinhNguoiDung> _dsLopHanhChinh = [];
  List<BoMonNguoiDung> _dsBoMon = [];

  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _vaiTroId = 0;
  String _trangThai = '';

  List<NguoiDung> get dsNguoiDung => _dsNguoiDung;
  List<VaiTro> get dsVaiTro => _dsVaiTro;
  List<KhoaNguoiDung> get dsKhoa => _dsKhoa;
  List<LopHanhChinhNguoiDung> get dsLopHanhChinh => _dsLopHanhChinh;
  List<BoMonNguoiDung> get dsBoMon => _dsBoMon;

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get vaiTroId => _vaiTroId;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsNguoiDung.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsNguoiDung.isEmpty;

  String _xuLyLoi(dynamic error) {
    var message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }

    return message;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  Future<void> khoiTaoDuLieu() async {
    _error = null;
    _setLoading(true);

    try {
      // Danh sách người dùng là dữ liệu chính của màn hình. Không để lỗi của
      // một danh mục phụ (ví dụ danh sách lớp) làm xóa toàn bộ người dùng.
      _dsNguoiDung = await _nguoiDungService.layDanhSachNguoiDung(
        tuKhoa: _tuKhoa,
        vaiTroId: _vaiTroId,
        trangThai: _trangThai,
      );
      _error = null;

      try {
        _dsVaiTro = await _nguoiDungService.layDanhSachVaiTro();
      } catch (_) {
        _dsVaiTro = [];
      }
      try {
        _dsKhoa = await _nguoiDungService.layDanhSachKhoa();
      } catch (_) {
        _dsKhoa = [];
      }
      try {
        _dsLopHanhChinh =
            await _nguoiDungService.layDanhSachLopHanhChinh();
      } catch (_) {
        _dsLopHanhChinh = [];
      }
      try {
        _dsBoMon = await _nguoiDungService.layDanhSachBoMon();
      } catch (_) {
        _dsBoMon = [];
      }
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsNguoiDung = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> layDanhSachDanhMuc() async {
    String? loiDanhMuc;

    try {
      _dsKhoa = await _nguoiDungService.layDanhSachKhoa();
    } catch (error) {
      _dsKhoa = [];
      loiDanhMuc ??= _xuLyLoi(error);
    }

    try {
      _dsLopHanhChinh =
          await _nguoiDungService.layDanhSachLopHanhChinh();
    } catch (error) {
      _dsLopHanhChinh = [];
      loiDanhMuc ??= _xuLyLoi(error);
    }

    try {
      _dsBoMon = await _nguoiDungService.layDanhSachBoMon();
    } catch (error) {
      _dsBoMon = [];
      loiDanhMuc ??= _xuLyLoi(error);
    }

    // Chỉ báo lỗi danh mục khi màn hình chưa có dữ liệu người dùng chính.
    if (_dsNguoiDung.isEmpty && loiDanhMuc != null) {
      _error = loiDanhMuc;
    }
    notifyListeners();
  }

  Future<void> layDanhSachVaiTro() async {
    try {
      _dsVaiTro = await _nguoiDungService.layDanhSachVaiTro();
      notifyListeners();
    } catch (error) {
      _error = _xuLyLoi(error);
      notifyListeners();
    }
  }

  Future<void> layDanhSachNguoiDung({
    String? tuKhoa,
    int? vaiTroId,
    String? trangThai,
  }) async {
    if (tuKhoa != null) {
      _tuKhoa = tuKhoa.trim();
    }

    if (vaiTroId != null) {
      _vaiTroId = vaiTroId;
    }

    if (trangThai != null) {
      _trangThai = trangThai.trim();
    }

    _error = null;
    _setLoading(true);

    try {
      _dsNguoiDung = await _nguoiDungService.layDanhSachNguoiDung(
        tuKhoa: _tuKhoa,
        vaiTroId: _vaiTroId,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsNguoiDung = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachNguoiDung();
  }

  Future<void> timKiemNguoiDung(String tuKhoa) async {
    await layDanhSachNguoiDung(tuKhoa: tuKhoa);
  }

  Future<void> locTheoVaiTro(int vaiTroId) async {
    await layDanhSachNguoiDung(vaiTroId: vaiTroId);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachNguoiDung(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _vaiTroId = 0;
    _trangThai = '';

    await layDanhSachNguoiDung(tuKhoa: '', vaiTroId: 0, trangThai: '');
  }

  Future<Map<String, dynamic>> themNguoiDung({
    required String hoTen,
    required String email,
    required String matKhau,
    required int vaiTroId,
    String trangThai = 'dang_hoat_dong',
    String maSinhVien = '',
    int lopId = 0,
    int khoaId = 0,
    String maGiangVien = '',
    int boMonId = 0,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _nguoiDungService.themNguoiDung(
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        vaiTroId: vaiTroId,
        trangThai: trangThai,
        maSinhVien: maSinhVien,
        lopId: lopId,
        khoaId: khoaId,
        maGiangVien: maGiangVien,
        boMonId: boMonId,
      );

      await layDanhSachNguoiDung();

      return {'success': true, 'message': message};
    } catch (error) {
      final message = _xuLyLoi(error);
      _error = message;
      notifyListeners();

      return {'success': false, 'message': message};
    } finally {
      _setProcessing(false);
    }
  }

  Future<Map<String, dynamic>> suaNguoiDung({
    required int id,
    required String hoTen,
    required String email,
    String matKhau = '',
    required int vaiTroId,
    required String trangThai,
    String maSinhVien = '',
    int lopId = 0,
    int khoaId = 0,
    String maGiangVien = '',
    int boMonId = 0,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _nguoiDungService.suaNguoiDung(
        id: id,
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        vaiTroId: vaiTroId,
        trangThai: trangThai,
        maSinhVien: maSinhVien,
        lopId: lopId,
        khoaId: khoaId,
        maGiangVien: maGiangVien,
        boMonId: boMonId,
      );

      await layDanhSachNguoiDung();

      return {'success': true, 'message': message};
    } catch (error) {
      final message = _xuLyLoi(error);
      _error = message;
      notifyListeners();

      return {'success': false, 'message': message};
    } finally {
      _setProcessing(false);
    }
  }

  Future<Map<String, dynamic>> xoaNguoiDung(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _nguoiDungService.xoaNguoiDung(id);

      await layDanhSachNguoiDung();

      return {'success': true, 'message': message};
    } catch (error) {
      final message = _xuLyLoi(error);
      _error = message;
      notifyListeners();

      return {'success': false, 'message': message};
    } finally {
      _setProcessing(false);
    }
  }

  Future<Map<String, dynamic>> khoaNguoiDung(int id) async {
    return xoaNguoiDung(id);
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
