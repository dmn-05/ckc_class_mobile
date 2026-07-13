import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/quiz_model.dart';
import 'ket_noi_api_service.dart';

class QuizService {
  final ApiService _api = ApiService();

  Map<String, dynamic> _body(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Dữ liệu phản hồi từ server không hợp lệ');
  }

  bool _ok(Map<String, dynamic> body) =>
      body['status']?.toString().toLowerCase() == 'success';

  String _message(
    Map<String, dynamic> body, {
    String fallback = 'Có lỗi xảy ra',
  }) => body['message']?.toString() ?? fallback;

  String _err(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null)
        return data['message'].toString();
      if (data is String) {
        try {
          final d = jsonDecode(data);
          if (d is Map && d['message'] != null) return d['message'].toString();
        } catch (_) {}
      }
      return error.message ?? 'Lỗi kết nối server';
    }
    var msg = error.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  String? _dt(DateTime? value) => value?.toIso8601String();

  // ─── GIẢNG VIÊN: TẠO QUIZ ─────────────────────────────────
  Future<String> taoQuiz({
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
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'tao_quiz',
          'tieu_de': tieuDe.trim(),
          'mo_ta': moTa.trim(),
          'lop_hoc_phan_id': lopHocPhanId,
          'chu_de_id': chuDeId,
          'nguoi_tao_id': nguoiTaoId,
          'han_nop': _dt(hanNop),
          'thoi_gian_lam': thoiGianLam,
          'cho_xem_dap_an': choXemDapAn ? 1 : 0,
          'dao_cau_hoi': daoCauHoi ? 1 : 0,
          'dao_dap_an': daoDapAn ? 1 : 0,
          'trang_thai': trangThai,
          'cau_hoi': cauHoi.map((e) => e.toJson()).toList(),
        },
      );
      final b = _body(res);
      if (!_ok(b)) throw Exception(_message(b, fallback: 'Tạo quiz thất bại'));
      return _message(b, fallback: 'Tạo quiz thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── GIẢNG VIÊN: LẤY CHI TIẾT QUIZ ĐỂ SỬA ─────────────────
  Future<ChiTietQuizGV> layChiTietQuizGiangVien({
    required int baiTapId,
    int nguoiTaoId = 0,
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'chi_tiet_quiz',
          'bai_tap_id': baiTapId,
          'nguoi_tao_id': nguoiTaoId,
        },
      );
      final b = _body(res);
      if (!_ok(b))
        throw Exception(_message(b, fallback: 'Không lấy được chi tiết quiz'));
      return ChiTietQuizGV.fromJson(Map<String, dynamic>.from(b['data'] ?? {}));
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── GIẢNG VIÊN: CẬP NHẬT QUIZ ─────────────────────────────
  Future<String> suaQuiz({
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
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'sua_quiz',
          'bai_tap_id': baiTapId,
          'tieu_de': tieuDe.trim(),
          'mo_ta': moTa.trim(),
          'chu_de_id': chuDeId,
          'nguoi_tao_id': nguoiTaoId,
          'han_nop': _dt(hanNop),
          'thoi_gian_lam': thoiGianLam,
          'cho_xem_dap_an': choXemDapAn ? 1 : 0,
          'dao_cau_hoi': daoCauHoi ? 1 : 0,
          'dao_dap_an': daoDapAn ? 1 : 0,
          'trang_thai': trangThai,
          'cau_hoi': cauHoi.map((e) => e.toJson()).toList(),
        },
      );
      final b = _body(res);
      if (!_ok(b))
        throw Exception(_message(b, fallback: 'Cập nhật quiz thất bại'));
      return _message(b, fallback: 'Cập nhật quiz thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── GIẢNG VIÊN: KẾT QUẢ QUIZ ──────────────────────────────
  Future<List<KetQuaQuizGV>> layKetQuaQuizGiangVien(int baiTapId) async {
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {'action': 'ket_qua_quiz_giang_vien', 'bai_tap_id': baiTapId},
      );
      final b = _body(res);
      if (!_ok(b))
        throw Exception(_message(b, fallback: 'Không lấy được kết quả quiz'));
      final raw = b['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => KetQuaQuizGV.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }


  Future<String> xoaQuizGiangVien({
    required int baiTapId,
    int nguoiTaoId = 0,
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'xoa_quiz',
          'bai_tap_id': baiTapId,
          'nguoi_tao_id': nguoiTaoId,
        },
      );
      final b = _body(res);
      if (!_ok(b)) throw Exception(_message(b, fallback: 'Xóa quiz thất bại'));
      return _message(b, fallback: 'Xóa quiz thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }



  Future<ChiTietBaiLamQuizGV> layChiTietBaiLamQuizGiangVien(
    int baiLamQuizId,
  ) async {
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'chi_tiet_bai_lam_quiz_giang_vien',
          'bai_lam_quiz_id': baiLamQuizId,
        },
      );
      final b = _body(res);
      if (!_ok(b)) {
        throw Exception(
          _message(b, fallback: 'Không lấy được chi tiết bài tự luận'),
        );
      }
      return ChiTietBaiLamQuizGV.fromJson(
        Map<String, dynamic>.from(b['data'] ?? {}),
      );
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<String> chamTuLuan({
    required int baiLamQuizId,
    required Map<int, double> diemTheoCauHoi,
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/quiz_giang_vien.php',
        data: {
          'action': 'cham_tu_luan',
          'bai_lam_quiz_id': baiLamQuizId,
          'diem_tu_luan': diemTheoCauHoi.entries
              .map((e) => {'cau_hoi_id': e.key, 'diem': e.value})
              .toList(),
        },
      );
      final b = _body(res);
      if (!_ok(b)) throw Exception(_message(b, fallback: 'Chấm tự luận thất bại'));
      return _message(b, fallback: 'Chấm tự luận thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── SINH VIÊN: LẤY ĐỀ QUIZ ────────────────────────────────
  Future<DeQuiz> layQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/quiz_sinh_vien.php',
        data: {
          'action': 'lay_quiz',
          'sinh_vien_id': sinhVienId,
          'bai_tap_id': baiTapId,
        },
      );
      final b = _body(res);
      if (!_ok(b))
        throw Exception(_message(b, fallback: 'Không lấy được quiz'));
      return DeQuiz.fromJson(Map<String, dynamic>.from(b['data'] ?? {}));
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── SINH VIÊN: NỘP QUIZ ───────────────────────────────────
  Future<String> nopQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
    required Map<int, Set<int>> dapAnTheoCauHoi,
    Map<int, String> dapAnTuLuanTheoCauHoi = const {},
  }) async {
    try {
      final dsDapAn = dapAnTheoCauHoi.entries
          .map((e) => {'cau_hoi_id': e.key, 'dap_an_ids': e.value.toList()})
          .toList();
      for (final entry in dapAnTuLuanTheoCauHoi.entries) {
        final text = entry.value.trim();
        if (text.isNotEmpty) {
          dsDapAn.add({'cau_hoi_id': entry.key, 'dap_an_ids': <int>[], 'dap_an_tu_luan': text});
        }
      }

      final res = await _api.post(
        '/sinh_vien/quiz_sinh_vien.php',
        data: {
          'action': 'nop_quiz',
          'sinh_vien_id': sinhVienId,
          'bai_tap_id': baiTapId,
          'dap_an': dsDapAn,
        },
      );
      final b = _body(res);
      if (!_ok(b)) throw Exception(_message(b, fallback: 'Nộp quiz thất bại'));
      return _message(b, fallback: 'Nộp quiz thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── SINH VIÊN: XEM KẾT QUẢ ────────────────────────────────
  Future<KetQuaQuizSVModel> layKetQuaQuizSinhVien({
    required int sinhVienId,
    required int baiTapId,
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/quiz_sinh_vien.php',
        data: {
          'action': 'ket_qua_quiz',
          'sinh_vien_id': sinhVienId,
          'bai_tap_id': baiTapId,
        },
      );
      final b = _body(res);
      if (!_ok(b))
        throw Exception(_message(b, fallback: 'Không lấy được kết quả quiz'));
      return KetQuaQuizSVModel.fromJson(
        Map<String, dynamic>.from(b['data'] ?? {}),
      );
    } catch (e) {
      throw Exception(_err(e));
    }
  }
}
