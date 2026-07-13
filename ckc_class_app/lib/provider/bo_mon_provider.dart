import 'package:flutter/foundation.dart';

import '../services/bo_mon_service.dart';
import '../model/khoa_bo_mon_model.dart';

class BoMonProvider extends ChangeNotifier {
  final BoMonService _boMonService = BoMonService();

  List<BoMon> _dsBoMon = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _khoaId = 0;
  String _trangThai = '';

  List<BoMon> get dsBoMon => _dsBoMon;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get khoaId => _khoaId;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsBoMon.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsBoMon.isEmpty;

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

  Future<void> layDanhSachBoMon({
    String? tuKhoa,
    int? khoaId,
    String? trangThai,
  }) async {
    if (tuKhoa != null) {
      _tuKhoa = tuKhoa.trim();
    }

    if (khoaId != null) {
      _khoaId = khoaId;
    }

    if (trangThai != null) {
      _trangThai = trangThai.trim();
    }

    _error = null;
    _setLoading(true);

    try {
      _dsBoMon = await _boMonService.layDanhSachBoMon(
        tuKhoa: _tuKhoa,
        khoaId: _khoaId,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsBoMon = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachBoMon();
  }

  Future<void> timKiemBoMon(String tuKhoa) async {
    await layDanhSachBoMon(tuKhoa: tuKhoa);
  }

  Future<void> locTheoKhoa(int khoaId) async {
    await layDanhSachBoMon(khoaId: khoaId);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachBoMon(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _khoaId = 0;
    _trangThai = '';

    await layDanhSachBoMon(tuKhoa: '', khoaId: 0, trangThai: '');
  }

  Future<Map<String, dynamic>> themBoMon({
    required String maBoMon,
    required String tenBoMon,
    required int khoaId,
    String trangThai = 'dang_hoat_dong',
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _boMonService.themBoMon(
        maBoMon: maBoMon,
        tenBoMon: tenBoMon,
        khoaId: khoaId,
        trangThai: trangThai,
      );

      await layDanhSachBoMon();

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

  Future<Map<String, dynamic>> suaBoMon({
    required int id,
    required String maBoMon,
    required String tenBoMon,
    required int khoaId,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _boMonService.suaBoMon(
        id: id,
        maBoMon: maBoMon,
        tenBoMon: tenBoMon,
        khoaId: khoaId,
        trangThai: trangThai,
      );

      await layDanhSachBoMon();

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

  Future<Map<String, dynamic>> xoaBoMon(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _boMonService.xoaBoMon(id);

      await layDanhSachBoMon();

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

  Future<Map<String, dynamic>> ngungHoatDongBoMon(int id) async {
    return xoaBoMon(id);
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
