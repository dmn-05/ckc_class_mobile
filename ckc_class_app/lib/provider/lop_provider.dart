import 'package:flutter/foundation.dart';

import '../services/lop_service.dart';
import '../model/lop_model.dart';

class LopProvider extends ChangeNotifier {
  final LopService _lopService = LopService();

  List<Lop> _dsLop = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _khoaId = 0;
  String _khoaHoc = '';
  String _trangThai = '';

  List<Lop> get dsLop => _dsLop;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get khoaId => _khoaId;
  String get khoaHoc => _khoaHoc;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsLop.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsLop.isEmpty;

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

  Future<void> layDanhSachLop({
    String? tuKhoa,
    int? khoaId,
    String? khoaHoc,
    String? trangThai,
  }) async {
    if (tuKhoa != null) _tuKhoa = tuKhoa.trim();
    if (khoaId != null) _khoaId = khoaId;
    if (khoaHoc != null) _khoaHoc = khoaHoc.trim();
    if (trangThai != null) _trangThai = trangThai.trim();

    _error = null;
    _setLoading(true);

    try {
      _dsLop = await _lopService.layDanhSachLop(
        tuKhoa: _tuKhoa,
        khoaId: _khoaId,
        khoaHoc: _khoaHoc,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsLop = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachLop();
  }

  Future<void> timKiemLop(String tuKhoa) async {
    await layDanhSachLop(tuKhoa: tuKhoa);
  }

  Future<void> locTheoKhoa(int khoaId) async {
    await layDanhSachLop(khoaId: khoaId);
  }

  Future<void> locTheoKhoaHoc(String khoaHoc) async {
    await layDanhSachLop(khoaHoc: khoaHoc);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachLop(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _khoaId = 0;
    _khoaHoc = '';
    _trangThai = '';

    await layDanhSachLop(
      tuKhoa: '',
      khoaId: 0,
      khoaHoc: '',
      trangThai: '',
    );
  }

  Future<Map<String, dynamic>> themLop({
    required String maLop,
    required String tenLop,
    required int khoaId,
    required String khoaHoc,
    String trangThai = 'dang_hoc',
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopService.themLop(
        maLop: maLop,
        tenLop: tenLop,
        khoaId: khoaId,
        khoaHoc: khoaHoc,
        trangThai: trangThai,
      );

      await layDanhSachLop();

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

  Future<Map<String, dynamic>> suaLop({
    required int id,
    required String maLop,
    required String tenLop,
    required int khoaId,
    required String khoaHoc,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopService.suaLop(
        id: id,
        maLop: maLop,
        tenLop: tenLop,
        khoaId: khoaId,
        khoaHoc: khoaHoc,
        trangThai: trangThai,
      );

      await layDanhSachLop();

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

  Future<Map<String, dynamic>> xoaLop(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopService.xoaLop(id);

      await layDanhSachLop();

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

  Future<Map<String, dynamic>> tamKhoaLop(int id) async {
    return xoaLop(id);
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
