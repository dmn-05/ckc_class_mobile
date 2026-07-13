import 'package:flutter/foundation.dart';

import '../model/sinh_vien_lop_model.dart';
import '../services/sinh_vien_lop_service.dart';

class SinhVienLopProvider extends ChangeNotifier {
  final SinhVienLopService _service = SinhVienLopService();

  int _lopId = 0;
  List<SinhVienLop> _danhSach = [];
  List<SinhVienLop> _danhSachThem = [];
  String _keyword = '';
  String _trangThai = '';
  bool _loading = false;
  bool _loadingThem = false;
  bool _processing = false;
  String? _error;
  String? _message;

  List<SinhVienLop> get danhSach => _danhSach;
  List<SinhVienLop> get danhSachThem => _danhSachThem;
  String get keyword => _keyword;
  String get trangThai => _trangThai;
  bool get loading => _loading;
  bool get loadingThem => _loadingThem;
  bool get processing => _processing;
  int get lopId => _lopId;
  String? get error => _error;
  String? get message => _message;

  String _xuLyLoi(dynamic error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setLoadingThem(bool value) {
    _loadingThem = value;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _processing = value;
    notifyListeners();
  }

  Future<void> init(int lopId) async {
    _lopId = lopId;
    _keyword = '';
    _trangThai = '';
    _error = null;
    _message = null;
    _danhSachThem = [];
    await loadDanhSach();
  }

  Future<void> loadDanhSach() async {
    if (_lopId <= 0) {
      _error = 'ID lớp không hợp lệ';
      _danhSach = [];
      notifyListeners();
      return;
    }

    _error = null;
    _setLoading(true);

    try {
      _danhSach = await _service.getSinhVienTrongLop(
        lopId: _lopId,
        keyword: _keyword,
        trangThai: _trangThai,
      );
    } catch (e) {
      _error = _xuLyLoi(e);
      _danhSach = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> search(String value) async {
    _keyword = value.trim();
    await loadDanhSach();
  }

  Future<void> filterTrangThai(String value) async {
    _trangThai = value.trim();
    await loadDanhSach();
  }

  Future<void> loadDanhSachThem(String keyword) async {
    if (_lopId <= 0) return;

    _error = null;
    _setLoadingThem(true);

    try {
      _danhSachThem = await _service.getSinhVienChuaCoTrongLop(
        lopId: _lopId,
        keyword: keyword,
      );
    } catch (e) {
      _error = _xuLyLoi(e);
      _danhSachThem = [];
    } finally {
      _setLoadingThem(false);
    }
  }

  Future<bool> themSinhVien(int sinhVienId) async {
    _error = null;
    _message = null;
    _setProcessing(true);

    try {
      _message = await _service.themSinhVienVaoLop(
        lopId: _lopId,
        sinhVienId: sinhVienId,
      );
      await loadDanhSach();
      await loadDanhSachThem('');
      return true;
    } catch (e) {
      _error = _xuLyLoi(e);
      notifyListeners();
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  Future<bool> xoaSinhVien(int id) async {
    _error = null;
    _message = null;
    _setProcessing(true);

    try {
      _message = await _service.xoaSinhVienKhoiLop(id: id);
      await loadDanhSach();
      return true;
    } catch (e) {
      _error = _xuLyLoi(e);
      notifyListeners();
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  Future<bool> doiTrangThai(int id, String trangThai) async {
    _error = null;
    _message = null;
    _setProcessing(true);

    try {
      _message = await _service.capNhatTrangThai(
        id: id,
        trangThai: trangThai,
      );
      await loadDanhSach();
      return true;
    } catch (e) {
      _error = _xuLyLoi(e);
      notifyListeners();
      return false;
    } finally {
      _setProcessing(false);
    }
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
