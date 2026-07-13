import 'package:flutter/foundation.dart';

import '../model/nhap_excel_model.dart';
import '../services/nhap_excel_service.dart';

class NhapExcelProvider extends ChangeNotifier {
  final NhapExcelService _service = NhapExcelService();

  NhapExcelLoai _loaiDangChon = NhapExcelService.loaiNhapList.first;
  NhapExcelKetQuaKiemTra? _ketQuaKiemTra;
  NhapExcelXacNhanKetQua? _ketQuaXacNhan;
  List<Map<String, dynamic>> _rowsDaDoc = [];
  String _tenFile = '';
  Map<String, dynamic> _doiTuongDichDaKiemTra = const {};
  int _nguoiNhapIdDaKiemTra = 1;
  String? _error;
  bool _isReading = false;
  bool _isChecking = false;
  bool _isConfirming = false;

  NhapExcelLoai get loaiDangChon => _loaiDangChon;
  NhapExcelKetQuaKiemTra? get ketQuaKiemTra => _ketQuaKiemTra;
  NhapExcelXacNhanKetQua? get ketQuaXacNhan => _ketQuaXacNhan;
  List<Map<String, dynamic>> get rowsDaDoc => _rowsDaDoc;
  String get tenFile => _tenFile;
  String? get error => _error;
  bool get isReading => _isReading;
  bool get isChecking => _isChecking;
  bool get isConfirming => _isConfirming;
  bool get coFileDaDoc => _rowsDaDoc.isNotEmpty;

  String _xuLyLoi(dynamic e) {
    var message = e.toString();
    if (message.startsWith('Exception: ')) message = message.replaceFirst('Exception: ', '');
    return message;
  }

  void chonLoai(String ma) {
    _loaiDangChon = _service.loaiTheoMa(ma);
    _ketQuaKiemTra = null;
    _ketQuaXacNhan = null;
    _rowsDaDoc = [];
    _tenFile = '';
    _doiTuongDichDaKiemTra = const {};
    _nguoiNhapIdDaKiemTra = 1;
    _error = null;
    notifyListeners();
  }

  Future<void> taiFileMau() async => _service.taiFileMau(_loaiDangChon);

  Future<Map<String, dynamic>> chonFileVaDoc() async {
    _isReading = true; _error = null; _ketQuaKiemTra = null; _ketQuaXacNhan = null; notifyListeners();
    try {
      final result = await _service.chonVaDocExcel(_loaiDangChon);
      _tenFile = result.fileName;
      _rowsDaDoc = result.rows;
      return {'success': true, 'message': 'Đã đọc file $_tenFile với ${_rowsDaDoc.length} dòng dữ liệu'};
    } catch (e) {
      _error = _xuLyLoi(e);
      return {'success': false, 'message': _error};
    } finally { _isReading = false; notifyListeners(); }
  }

  Future<Map<String, dynamic>> kiemTra({
    Map<String, dynamic> doiTuongDich = const {},
    int nguoiNhapId = 1,
  }) async {
    if (_rowsDaDoc.isEmpty) {
      return {
        'success': false,
        'message': 'Chưa chọn hoặc chưa đọc file Excel',
      };
    }

    _isChecking = true;
    _error = null;
    _ketQuaKiemTra = null;
    _ketQuaXacNhan = null;
    _doiTuongDichDaKiemTra = Map<String, dynamic>.from(doiTuongDich);
    _nguoiNhapIdDaKiemTra = nguoiNhapId;
    notifyListeners();

    try {
      _ketQuaKiemTra = await _service.kiemTraExcel(
        loaiNhap: _loaiDangChon.ma,
        tenFile: _tenFile,
        rows: _rowsDaDoc,
        doiTuongDich: _doiTuongDichDaKiemTra,
        nguoiNhapId: _nguoiNhapIdDaKiemTra,
      );

      return {
        'success': true,
        'message': 'Kiểm tra dữ liệu thành công',
      };
    } catch (e) {
      _error = _xuLyLoi(e);
      return {'success': false, 'message': _error};
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> xacNhanNhap() async {
    if (_ketQuaKiemTra == null) {
      return {
        'success': false,
        'message': 'Chưa có kết quả kiểm tra để xác nhận',
      };
    }

    if (_ketQuaKiemTra?.coTheXacNhan != true) {
      return {
        'success': false,
        'message': 'Dữ liệu còn lỗi, chưa thể nhập thật',
      };
    }

    if (_rowsDaDoc.isEmpty || _tenFile.isEmpty) {
      return {
        'success': false,
        'message': 'Dữ liệu file đã chọn không còn khả dụng',
      };
    }

    _isConfirming = true;
    _error = null;
    notifyListeners();

    try {
      _ketQuaXacNhan = await _service.xacNhanNhapExcel(
        loaiNhap: _loaiDangChon.ma,
        tenFile: _tenFile,
        rows: _rowsDaDoc,
        doiTuongDich: _doiTuongDichDaKiemTra,
        nguoiNhapId: _nguoiNhapIdDaKiemTra,
      );

      return {
        'success': true,
        'message': 'Nhập dữ liệu thành công',
      };
    } catch (e) {
      _error = _xuLyLoi(e);
      return {'success': false, 'message': _error};
    } finally {
      _isConfirming = false;
      notifyListeners();
    }
  }
}
