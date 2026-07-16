import '../utils/safe_change_notifier.dart';

import '../services/lop_hoc_phan_service.dart';
import '../model/lop_hoc_phan_model.dart';

class LopHocPhanProvider extends SafeChangeNotifier {
  final LopHocPhanService _lopHocPhanService = LopHocPhanService();

  List<LopHocPhan> _dsLopHocPhan = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  String _tuKhoa = '';
  int _monHocId = 0;
  int _giangVienId = 0;
  String _hocKy = '';
  String _namHoc = '';
  String _trangThai = '';

  List<LopHocPhan> get dsLopHocPhan => _dsLopHocPhan;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  String get tuKhoa => _tuKhoa;
  int get monHocId => _monHocId;
  int get giangVienId => _giangVienId;
  String get hocKy => _hocKy;
  String get namHoc => _namHoc;
  String get trangThai => _trangThai;

  bool get coDuLieu => _dsLopHocPhan.isNotEmpty;
  bool get khongCoDuLieu => !_isLoading && _dsLopHocPhan.isEmpty;

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

  Future<void> layDanhSachLopHocPhan({
    String? tuKhoa,
    int? monHocId,
    int? giangVienId,
    String? hocKy,
  
    String? namHoc,
    String? trangThai,
  }) async {
    if (tuKhoa != null) _tuKhoa = tuKhoa.trim();
    if (monHocId != null) _monHocId = monHocId;
    if (giangVienId != null) _giangVienId = giangVienId;
    

    if (namHoc != null) _namHoc = namHoc.trim();

    if (hocKy != null) _hocKy = hocKy.trim();
    if (trangThai != null) _trangThai = trangThai.trim();

    _error = null;
    _setLoading(true);

    try {
      _dsLopHocPhan = await _lopHocPhanService.layDanhSachLopHocPhan(
        tuKhoa: _tuKhoa,
        monHocId: _monHocId,
        giangVienId: _giangVienId,
        hocKy: _hocKy,
       
        namHoc: _namHoc,
        trangThai: _trangThai,
      );

      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _dsLopHocPhan = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> taiLaiDanhSach() async {
    await layDanhSachLopHocPhan();
  }

  Future<void> timKiemLopHocPhan(String tuKhoa) async {
    await layDanhSachLopHocPhan(tuKhoa: tuKhoa);
  }

  Future<void> locTheoMonHoc(int monHocId) async {
    await layDanhSachLopHocPhan(monHocId: monHocId);
  }

  Future<void> locTheoGiangVien(int giangVienId) async {
    await layDanhSachLopHocPhan(giangVienId: giangVienId);
  }

  Future<void> locTheoNamHoc(String namHoc) async {
    await layDanhSachLopHocPhan(namHoc: namHoc);
  }

  Future<void> locTheoHocKy(String hocKy) async {
    await layDanhSachLopHocPhan(hocKy: hocKy);
  }


  Future<void> locTheoTrangThai(String trangThai) async {
    await layDanhSachLopHocPhan(trangThai: trangThai);
  }

  Future<void> xoaBoLoc() async {
    _tuKhoa = '';
    _monHocId = 0;
    _giangVienId = 0;
    _hocKy = '';
    
    _namHoc = '';
    _trangThai = '';

    await layDanhSachLopHocPhan(
      tuKhoa: '',
      monHocId: 0,
      giangVienId: 0,
      hocKy: '',
     
      namHoc: '',
      trangThai: '',
    );
  }

  Future<Map<String, dynamic>> themLopHocPhan({
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required int giangVienId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
    String trangThai = 'dang_mo',
    int lopId = 0,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopHocPhanService.themLopHocPhan(
        maLopHocPhan: maLopHocPhan,
        tenLop: tenLop,
        monHocId: monHocId,
        giangVienId: giangVienId,
        hocKy: hocKy,
        namHoc: namHoc,
        siSoToiDa: siSoToiDa,
        trangThai: trangThai,
        lopId: lopId,
      );

      await layDanhSachLopHocPhan();

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

  Future<Map<String, dynamic>> suaLopHocPhan({
    required int id,
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required int giangVienId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
    required String trangThai,
  }) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopHocPhanService.suaLopHocPhan(
        id: id,
        maLopHocPhan: maLopHocPhan,
        tenLop: tenLop,
        monHocId: monHocId,
        giangVienId: giangVienId,
        hocKy: hocKy,
        namHoc: namHoc,
        siSoToiDa: siSoToiDa,
        trangThai: trangThai,
      );

      await layDanhSachLopHocPhan();

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

  Future<Map<String, dynamic>> xoaLopHocPhan(int id) async {
    _error = null;
    _setProcessing(true);

    try {
      final message = await _lopHocPhanService.xoaLopHocPhan(id);

      await layDanhSachLopHocPhan();

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

  Future<Map<String, dynamic>> khoaLopHocPhan(int id) async {
    return xoaLopHocPhan(id);
  }

  void xoaLoi() {
    _error = null;
    notifyListeners();
  }
}
