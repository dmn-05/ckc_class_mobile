import 'package:flutter/foundation.dart';

import '../services/mon_hoc_service.dart';
import '../model/khoa_bo_mon_model.dart';

class MonHocProvider extends ChangeNotifier {
  final MonHocService _monHocService = MonHocService();

  List<MonHoc> _dsMonHoc = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _khoaId = 0;
  int _boMonId = 0;
  String _trangThai = '';

  List<MonHoc> get dsMonHoc => _dsMonHoc;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get khoaId => _khoaId;
  int get boMonId => _boMonId;
  String get trangThai => _trangThai;

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

  Future<void> layDanhSachMonHoc({
    String? tuKhoa,
    int? khoaId,
    int? boMonId,
    String? trangThai,
  }) async {
    if (tuKhoa != null) _tuKhoa = tuKhoa.trim();
    if (khoaId != null) _khoaId = khoaId;
    if (boMonId != null) _boMonId = boMonId;
    if (trangThai != null) _trangThai = trangThai.trim();

    _error = null;
    _setLoading(true);

    try {
      _dsMonHoc = await _monHocService.layDanhSachMonHoc(
        tuKhoa: _tuKhoa,
        khoaId: _khoaId,
        boMonId: _boMonId,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsMonHoc = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachMonHoc();
  }

  Future<void> timKiemMonHoc(String tuKhoa) async {
    await layDanhSachMonHoc(tuKhoa: tuKhoa);
  }

  Future<void> locTheoKhoa(int khoaId) async {
    await layDanhSachMonHoc(khoaId: khoaId, boMonId: 0);
  }

  Future<void> locTheoBoMon(int boMonId) async {
    await layDanhSachMonHoc(boMonId: boMonId);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachMonHoc(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _khoaId = 0;
    _boMonId = 0;
    _trangThai = '';

    await layDanhSachMonHoc(tuKhoa: '', khoaId: 0, boMonId: 0, trangThai: '');
  }

  Future<Map<String, dynamic>> themMonHoc({
    required String maMon,
    required String tenMon,
    required int tinChi,
    required int khoaId,
    required int boMonId,
    String trangThai = 'dang_mo',
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _monHocService.themMonHoc(
        maMon: maMon,
        tenMon: tenMon,
        tinChi: tinChi,
        khoaId: khoaId,
        boMonId: boMonId,
        trangThai: trangThai,
      );

      await layDanhSachMonHoc();

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

  Future<Map<String, dynamic>> suaMonHoc({
    required int id,
    required String maMon,
    required String tenMon,
    required int tinChi,
    required int khoaId,
    required int boMonId,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _monHocService.suaMonHoc(
        id: id,
        maMon: maMon,
        tenMon: tenMon,
        tinChi: tinChi,
        khoaId: khoaId,
        boMonId: boMonId,
        trangThai: trangThai,
      );

      await layDanhSachMonHoc();

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

  Future<Map<String, dynamic>> xoaMonHoc(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _monHocService.xoaMonHoc(id);

      await layDanhSachMonHoc();

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
}
