import 'package:flutter/foundation.dart';

import '../model/sinh_vien_lop_hoc_phan_model.dart';
import '../services/sinh_vien_lop_hoc_phan_service.dart';

class SinhVienLopHocPhanProvider extends ChangeNotifier {
  final SinhVienLopHocPhanService _service =
      SinhVienLopHocPhanService();

  // ================= STATE =================
  int _lopHocPhanId = 0;

  List<SinhVienLopHocPhan> _dsSinhVienLopHocPhan = [];
  List<SinhVienCoTheThemLhp> _dsSinhVienCoTheThem = [];

  bool _isLoading = false;
  bool _isLoadingDanhSachThem = false;
  bool _isProcessing = false;

  String? _error;

  String _tuKhoa = '';
  String _trangThai = '';
  String _tuKhoaThem = '';

  // ================= GETTERS =================
  List<SinhVienLopHocPhan> get dsSinhVienLopHocPhan =>
      _dsSinhVienLopHocPhan;

  List<SinhVienCoTheThemLhp> get dsSinhVienCoTheThem =>
      _dsSinhVienCoTheThem;

  bool get isLoading => _isLoading;
  bool get isLoadingDanhSachThem => _isLoadingDanhSachThem;
  bool get isProcessing => _isProcessing;

  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  String get trangThai => _trangThai;

  // ================= INIT =================
  Future<void> init(int lopHocPhanId) async {
    _lopHocPhanId = lopHocPhanId;
    _tuKhoa = '';
    _trangThai = '';
    await loadDanhSach();
  }

  // ================= LOAD DANH SÁCH =================
  Future<void> loadDanhSach() async {
    _setLoading(true);
    _error = null;

    try {
      _dsSinhVienLopHocPhan =
          await _service.layDanhSachSinhVienLopHocPhan(
        lopHocPhanId: _lopHocPhanId,
        tuKhoa: _tuKhoa,
        trangThai: _trangThai,
      );
    } catch (e) {
      _error = _xuLyLoi(e);
    }

    _setLoading(false);
  }

  // ================= SEARCH =================
  Future<void> timKiemSinhVien({
    required int lopHocPhanId,
    required String tuKhoa,
  }) async {
    _lopHocPhanId = lopHocPhanId;
    _tuKhoa = tuKhoa;
    await loadDanhSach();
  }

  // ================= FILTER =================
  Future<void> locTheoTrangThai({
    required int lopHocPhanId,
    required String trangThai,
  }) async {
    _lopHocPhanId = lopHocPhanId;
    _trangThai = trangThai;
    await loadDanhSach();
  }

  // ================= RESET FILTER =================
  Future<void> xoaBoLoc(int lopHocPhanId) async {
    _lopHocPhanId = lopHocPhanId;
    _tuKhoa = '';
    _trangThai = '';
    await loadDanhSach();
  }

  // ================= RELOAD =================
  Future<void> taiLaiDanhSach(int lopHocPhanId) async {
    _lopHocPhanId = lopHocPhanId;
    await loadDanhSach();
  }

  // ================= DANH SÁCH CÓ THỂ THÊM =================
  Future<void> layDanhSachSinhVienCoTheThem({
    required int lopHocPhanId,
    String tuKhoa = '',
  }) async {
    _setLoadingDanhSachThem(true);
    _error = null;

    try {
      _dsSinhVienCoTheThem =
          await _service.layDanhSachSinhVienCoTheThem(
        lopHocPhanId: lopHocPhanId,
        tuKhoa: tuKhoa,
      );
    } catch (e) {
      _error = _xuLyLoi(e);
    }

    _setLoadingDanhSachThem(false);
  }

  // ================= THÊM SINH VIÊN =================
  Future<Map<String, dynamic>> themSinhVienVaoLopHocPhan({
    required int lopHocPhanId,
    required int sinhVienId,
  }) async {
    _setProcessing(true);

    try {
      final msg = await _service.themSinhVienVaoLopHocPhan(
        lopHocPhanId: lopHocPhanId,
        sinhVienId: sinhVienId,
      );

      await loadDanhSach();

      return {
        'success': true,
        'message': msg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _xuLyLoi(e),
      };
    } finally {
      _setProcessing(false);
    }
  }
  // ================= THÊM SINH VIÊN THEO LỚP HÀNH CHÍNHH =================
  Future<Map<String, dynamic>> themSinhVienTheoLopHanhChinh({
  required int lopHocPhanId,
  required int lopId,
}) async {
  _setProcessing(true);

  try {
    final body = await _service.themSinhVienTheoLopHanhChinh(
      lopHocPhanId: lopHocPhanId,
      lopId: lopId,
    );

    _lopHocPhanId = lopHocPhanId;
    await loadDanhSach();

    return {
      'success': true,
      'message': body['message']?.toString() ??
          'Thêm sinh viên từ lớp hành chính thành công',
      'data': body['data'],
    };
  } catch (e) {
    return {
      'success': false,
      'message': _xuLyLoi(e),
    };
  } finally {
    _setProcessing(false);
  }
}

  // ================= XÓA SINH VIÊN =================
  Future<Map<String, dynamic>> xoaSinhVienKhoiLopHocPhan({
    required int id,
    required int lopHocPhanId,
  }) async {
    _setProcessing(true);

    try {
      final msg =
          await _service.xoaSinhVienKhoiLopHocPhan(id);

      await loadDanhSach();

      return {
        'success': true,
        'message': msg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _xuLyLoi(e),
      };
    } finally {
      _setProcessing(false);
    }
  }

  // ================= UPDATE TRẠNG THÁI =================
  Future<Map<String, dynamic>> capNhatTrangThaiSinhVien({
    required int id,
    required int lopHocPhanId,
    required String trangThai,
  }) async {
    _setProcessing(true);

    try {
      final msg =
          await _service.capNhatTrangThaiSinhVienLopHocPhan(
        id: id,
        trangThai: trangThai,
      );

      await loadDanhSach();

      return {
        'success': true,
        'message': msg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': _xuLyLoi(e),
      };
    } finally {
      _setProcessing(false);
    }
  }

  // ================= UTILS =================
  String _xuLyLoi(dynamic error) {
    var msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.replaceFirst('Exception: ', '');
    }
    return msg;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingDanhSachThem(bool value) {
    _isLoadingDanhSachThem = value;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }
}