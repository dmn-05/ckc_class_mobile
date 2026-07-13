import 'package:flutter/foundation.dart';

import '../services/khoa_service.dart';
import '../model/khoa_bo_mon_model.dart';

class KhoaProvider extends ChangeNotifier {
  final KhoaService _khoaService = KhoaService();

  List<Khoa> _dsKhoa = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String _tuKhoa = '';
  String _trangThai = '';

  List<Khoa> get dsKhoa => _dsKhoa;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String get tuKhoa => _tuKhoa;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsKhoa.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsKhoa.isEmpty;

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

  Future<void> layDanhSachKhoa({String? tuKhoa, String? trangThai}) async {
    if (tuKhoa != null) {
      _tuKhoa = tuKhoa.trim();
    }

    if (trangThai != null) {
      _trangThai = trangThai.trim();
    }

    _error = null;
    _setLoading(true);

    try {
      _dsKhoa = await _khoaService.layDanhSachKhoa(
        tuKhoa: _tuKhoa,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsKhoa = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachKhoa();
  }

  Future<void> timKiemKhoa(String tuKhoa) async {
    await layDanhSachKhoa(tuKhoa: tuKhoa);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachKhoa(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _trangThai = '';

    await layDanhSachKhoa(tuKhoa: '', trangThai: '');
  }

  Future<Map<String, dynamic>> themKhoa({
    required String maKhoa,
    required String tenKhoa,
    String trangThai = 'dang_hoat_dong',
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _khoaService.themKhoa(
        maKhoa: maKhoa,
        tenKhoa: tenKhoa,
        trangThai: trangThai,
      );

      await layDanhSachKhoa();

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

  Future<Map<String, dynamic>> suaKhoa({
    required int id,
    required String maKhoa,
    required String tenKhoa,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _khoaService.suaKhoa(
        id: id,
        maKhoa: maKhoa,
        tenKhoa: tenKhoa,
        trangThai: trangThai,
      );

      await layDanhSachKhoa();

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

  Future<Map<String, dynamic>> xoaKhoa(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _khoaService.xoaKhoa(id);

      await layDanhSachKhoa();

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

  Future<Map<String, dynamic>> ngungHoatDongKhoa(int id) async {
    return xoaKhoa(id);
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
