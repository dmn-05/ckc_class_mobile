import 'package:flutter/foundation.dart';
import '../model/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _service = QuizService();

  bool _loading = false;
  bool _processing = false;
  String? _error;

  DeQuiz? _deQuiz;
  KetQuaQuizSVModel? _ketQuaSV;
  List<KetQuaQuizGV> _ketQuaGV = [];
  ChiTietQuizGV? _chiTietQuizGV;
  ChiTietBaiLamQuizGV? _chiTietBaiLamGV;

  bool get loading => _loading;
  bool get processing => _processing;
  String? get error => _error;

  DeQuiz? get deQuiz => _deQuiz;
  KetQuaQuizSVModel? get ketQuaSV => _ketQuaSV;
  List<KetQuaQuizGV> get ketQuaGV => _ketQuaGV;
  ChiTietQuizGV? get chiTietQuizGV => _chiTietQuizGV;
  ChiTietBaiLamQuizGV? get chiTietBaiLamGV => _chiTietBaiLamGV;

  String _err(dynamic e) {
    var msg = e.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── GIẢNG VIÊN: TẠO QUIZ ─────────────────────────────────
  Future<Map<String, dynamic>> taoQuiz({
    required String tieuDe,
    String moTa = '',
    required int lopHocPhanId,
    int? chuDeId,
    required int nguoiTaoId,
    DateTime? hanNop,
    int? thoiGianLam,
    bool choXemDapAn = true,
    bool daoCauHoi = false,
    bool daoDapAn = false,
    String trangThai = 'dang_mo',
    required List<CauHoiQuiz> cauHoi,
  }) async {
    _processing = true;
    _error = null;
    notifyListeners();

    try {
      final msg = await _service.taoQuiz(
        tieuDe: tieuDe,
        moTa: moTa,
        lopHocPhanId: lopHocPhanId,
        chuDeId: chuDeId,
        nguoiTaoId: nguoiTaoId,
        hanNop: hanNop,
        thoiGianLam: thoiGianLam,
        choXemDapAn: choXemDapAn,
        daoCauHoi: daoCauHoi,
        daoDapAn: daoDapAn,
        trangThai: trangThai,
        cauHoi: cauHoi,
      );
      return {'success': true, 'message': msg};
    } catch (e) {
      final msg = _err(e);
      _error = msg;
      return {'success': false, 'message': msg};
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  // ─── GIẢNG VIÊN: LẤY CHI TIẾT QUIZ ĐỂ SỬA ─────────────────
  Future<void> layChiTietQuizGiangVien({
    required int baiTapId,
    int nguoiTaoId = 0,
  }) async {
    _loading = true;
    _error = null;
    _chiTietQuizGV = null;
    notifyListeners();

    try {
      _chiTietQuizGV = await _service.layChiTietQuizGiangVien(
        baiTapId: baiTapId,
        nguoiTaoId: nguoiTaoId,
      );
    } catch (e) {
      _error = _err(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─── GIẢNG VIÊN: CẬP NHẬT QUIZ ─────────────────────────────
  Future<Map<String, dynamic>> suaQuiz({
    required int baiTapId,
    required String tieuDe,
    String moTa = '',
    int? chuDeId,
    required int nguoiTaoId,
    DateTime? hanNop,
    int? thoiGianLam,
    bool choXemDapAn = true,
    bool daoCauHoi = false,
    bool daoDapAn = false,
    String trangThai = 'dang_mo',
    required List<CauHoiQuiz> cauHoi,
  }) async {
    _processing = true;
    _error = null;
    notifyListeners();

    try {
      final msg = await _service.suaQuiz(
        baiTapId: baiTapId,
        tieuDe: tieuDe,
        moTa: moTa,
        chuDeId: chuDeId,
        nguoiTaoId: nguoiTaoId,
        hanNop: hanNop,
        thoiGianLam: thoiGianLam,
        choXemDapAn: choXemDapAn,
        daoCauHoi: daoCauHoi,
        daoDapAn: daoDapAn,
        trangThai: trangThai,
        cauHoi: cauHoi,
      );
      return {'success': true, 'message': msg};
    } catch (e) {
      final msg = _err(e);
      _error = msg;
      return {'success': false, 'message': msg};
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  // ─── GIẢNG VIÊN: KẾT QUẢ QUIZ ──────────────────────────────
  Future<void> layKetQuaQuizGiangVien(int baiTapId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _ketQuaGV = await _service.layKetQuaQuizGiangVien(baiTapId);
    } catch (e) {
      _error = _err(e);
      _ketQuaGV = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<Map<String, dynamic>> xoaQuizGiangVien({
    required int baiTapId,
    int nguoiTaoId = 0,
  }) async {
    _processing = true;
    _error = null;
    notifyListeners();
    try {
      final msg = await _service.xoaQuizGiangVien(
        baiTapId: baiTapId,
        nguoiTaoId: nguoiTaoId,
      );
      return {'success': true, 'message': msg};
    } catch (e) {
      final msg = _err(e);
      _error = msg;
      return {'success': false, 'message': msg};
    } finally {
      _processing = false;
      notifyListeners();
    }
  }



  Future<void> layChiTietBaiLamQuizGiangVien(int baiLamQuizId) async {
    _loading = true;
    _error = null;
    _chiTietBaiLamGV = null;
    notifyListeners();
    try {
      _chiTietBaiLamGV =
          await _service.layChiTietBaiLamQuizGiangVien(baiLamQuizId);
    } catch (e) {
      _error = _err(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> chamTuLuan({
    required int baiLamQuizId,
    required Map<int, double> diemTheoCauHoi,
  }) async {
    _processing = true;
    _error = null;
    notifyListeners();
    try {
      final msg = await _service.chamTuLuan(
        baiLamQuizId: baiLamQuizId,
        diemTheoCauHoi: diemTheoCauHoi,
      );
      return {'success': true, 'message': msg};
    } catch (e) {
      final msg = _err(e);
      _error = msg;
      return {'success': false, 'message': msg};
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  // ─── SINH VIÊN: BẮT ĐẦU VÀ LẤY ĐỀ QUIZ ────────────────────
  Future<void> batDauVaLayQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
  }) async {
    _loading = true;
    _error = null;
    _deQuiz = null;
    notifyListeners();

    try {
      await _service.batDauQuizSinhVien(
        sinhVienId: sinhVienId,
        baiTapId: baiTapId,
      );
      _deQuiz = await _service.layQuizSinhVien(
        sinhVienId: sinhVienId,
        baiTapId: baiTapId,
      );
    } catch (e) {
      _error = _err(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─── SINH VIÊN: LẤY ĐỀ QUIZ ────────────────────────────────
  Future<void> layQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
  }) async {
    _loading = true;
    _error = null;
    _deQuiz = null;
    notifyListeners();

    try {
      _deQuiz = await _service.layQuizSinhVien(
        sinhVienId: sinhVienId,
        baiTapId: baiTapId,
      );
    } catch (e) {
      _error = _err(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─── SINH VIÊN: NỘP QUIZ ───────────────────────────────────
  Future<Map<String, dynamic>> nopQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
    required Map<int, Set<int>> dapAnTheoCauHoi,
    Map<int, String> dapAnTuLuanTheoCauHoi = const {},
  }) async {
    _processing = true;
    _error = null;
    notifyListeners();

    try {
      final msg = await _service.nopQuizSinhVien(
        sinhVienId: sinhVienId,
        baiTapId: baiTapId,
        dapAnTheoCauHoi: dapAnTheoCauHoi,
        dapAnTuLuanTheoCauHoi: dapAnTuLuanTheoCauHoi,
      );
      return {'success': true, 'message': msg};
    } catch (e) {
      final msg = _err(e);
      _error = msg;
      return {'success': false, 'message': msg};
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  // ─── SINH VIÊN: KẾT QUẢ QUIZ ───────────────────────────────
  Future<void> layKetQuaQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
  }) async {
    _loading = true;
    _error = null;
    _ketQuaSV = null;
    notifyListeners();

    try {
      _ketQuaSV = await _service.layKetQuaQuizSinhVien(
        sinhVienId: sinhVienId,
        baiTapId: baiTapId,
      );
    } catch (e) {
      _error = _err(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
