import 'package:flutter/foundation.dart';

import '../model/nhap_excel_model.dart';
import '../services/nhap_excel_service.dart';

class LichSuNhapExcelProvider extends ChangeNotifier {
  final NhapExcelService _service = NhapExcelService();

  List<NhapExcelLichSu> _danhSach = [];
  bool _isLoading = false;
  String? _error;

  String _tuKhoa = '';
  String _loaiNhap = '';
  DateTime? _tuNgay;
  DateTime? _denNgay;

  int _page = 1;
  int _limit = 20;
  int _total = 0;
  int _totalPages = 1;

  List<NhapExcelLichSu> get danhSach => _danhSach;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  String get loaiNhap => _loaiNhap;
  DateTime? get tuNgay => _tuNgay;
  DateTime? get denNgay => _denNgay;

  int get page => _page;
  int get limit => _limit;
  int get total => _total;
  int get totalPages => _totalPages;
  bool get coTrangTruoc => _page > 1;
  bool get coTrangSau => _page < _totalPages;

  String _xuLyLoi(dynamic error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  Future<void> taiDanhSach({int? page}) async {
    _isLoading = true;
    _error = null;
    if (page != null) _page = page;
    notifyListeners();

    try {
      final result = await _service.layLichSuNhapExcel(
        tuKhoa: _tuKhoa,
        loaiNhap: _loaiNhap,
        tuNgay: _tuNgay,
        denNgay: _denNgay,
        page: _page,
        limit: _limit,
      );

      _danhSach = result.items;
      _page = result.page;
      _limit = result.limit;
      _total = result.total;
      _totalPages = result.totalPages;
    } catch (error) {
      _error = _xuLyLoi(error);
      _danhSach = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> apDungBoLoc({
    required String tuKhoa,
    required String loaiNhap,
    DateTime? tuNgay,
    DateTime? denNgay,
  }) async {
    _tuKhoa = tuKhoa.trim();
    _loaiNhap = loaiNhap.trim();
    _tuNgay = tuNgay;
    _denNgay = denNgay;
    _page = 1;
    await taiDanhSach();
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _loaiNhap = '';
    _tuNgay = null;
    _denNgay = null;
    _page = 1;
    await taiDanhSach();
  }

  Future<void> trangTruoc() async {
    if (!coTrangTruoc || _isLoading) return;
    await taiDanhSach(page: _page - 1);
  }

  Future<void> trangSau() async {
    if (!coTrangSau || _isLoading) return;
    await taiDanhSach(page: _page + 1);
  }

  Future<NhapExcelChiTietLichSu> layChiTiet(int dotNhapId) {
    return _service.layChiTietLichSuNhapExcel(dotNhapId);
  }
}
