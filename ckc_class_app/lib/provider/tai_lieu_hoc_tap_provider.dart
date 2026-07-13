import 'package:flutter/foundation.dart';

import '../model/tai_lieu_hoc_tap_model.dart';
import '../services/tai_lieu_hoc_tap_service.dart';

class TaiLieuHocTapProvider extends ChangeNotifier {
  final TaiLieuHocTapService _service = TaiLieuHocTapService();

  List<TaiLieuHocTap> _dsTaiLieu = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _lopHocPhanId = 0;
  int _monHocId = 0;
  int _nguoiTaoId = 0;
  String _trangThai = '';

  List<TaiLieuHocTap> get dsTaiLieu => _dsTaiLieu;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get lopHocPhanId => _lopHocPhanId;
  int get monHocId => _monHocId;
  int get nguoiTaoId => _nguoiTaoId;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsTaiLieu.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsTaiLieu.isEmpty;

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

  Future<void> layDanhSachTaiLieu({
    String? tuKhoa,
    int? lopHocPhanId,
    int? monHocId,
    int? nguoiTaoId,
    String? trangThai,
  }) async {
    if (tuKhoa != null) _tuKhoa = tuKhoa.trim();
    if (lopHocPhanId != null) _lopHocPhanId = lopHocPhanId;
    if (monHocId != null) _monHocId = monHocId;
    if (nguoiTaoId != null) _nguoiTaoId = nguoiTaoId;
    if (trangThai != null) _trangThai = trangThai.trim();

    _error = null;
    _setLoading(true);

    try {
      _dsTaiLieu = await _service.layDanhSachTaiLieu(
        tuKhoa: _tuKhoa,
        lopHocPhanId: _lopHocPhanId,
        monHocId: _monHocId,
        nguoiTaoId: _nguoiTaoId,
        trangThai: _trangThai,
      );
      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsTaiLieu = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachTaiLieu();
  }

  Future<void> timKiemTaiLieu(String tuKhoa) async {
    await layDanhSachTaiLieu(tuKhoa: tuKhoa);
  }

  Future<void> locTheoLopHocPhan(int lopHocPhanId) async {
    await layDanhSachTaiLieu(lopHocPhanId: lopHocPhanId);
  }

  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachTaiLieu(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _lopHocPhanId = 0;
    _monHocId = 0;
    _nguoiTaoId = 0;
    _trangThai = '';

    await layDanhSachTaiLieu(
      tuKhoa: '',
      lopHocPhanId: 0,
      monHocId: 0,
      nguoiTaoId: 0,
      trangThai: '',
    );
  }

  Future<Map<String, dynamic>> themTaiLieu({
    required String tieuDe,
    String moTa = '',
    required String duongDanFile,
    required int lopHocPhanId,
    int nguoiTaoId = 1,
    String trangThai = 'hien_thi',
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _service.themTaiLieu(
        tieuDe: tieuDe,
        moTa: moTa,
        duongDanFile: duongDanFile,
        lopHocPhanId: lopHocPhanId,
        nguoiTaoId: nguoiTaoId,
        trangThai: trangThai,
      );
      await layDanhSachTaiLieu();
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

  Future<Map<String, dynamic>> suaTaiLieu({
    required int id,
    required String tieuDe,
    String moTa = '',
    required String duongDanFile,
    required int lopHocPhanId,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _service.suaTaiLieu(
        id: id,
        tieuDe: tieuDe,
        moTa: moTa,
        duongDanFile: duongDanFile,
        lopHocPhanId: lopHocPhanId,
        trangThai: trangThai,
      );
      await layDanhSachTaiLieu();
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

  Future<Map<String, dynamic>> capNhatTrangThaiTaiLieu({
    required int id,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _service.capNhatTrangThaiTaiLieu(
        id: id,
        trangThai: trangThai,
      );
      await layDanhSachTaiLieu();
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
