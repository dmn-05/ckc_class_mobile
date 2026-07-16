import 'dart:convert';
import 'package:ckc_class_app/model/giang_vien_model.dart';
import 'package:ckc_class_app/services/ket_noi_api_service.dart';
import 'package:dio/dio.dart';
import '../model/sinh_vien_model.dart';

class SinhVienService {
  final ApiService _api = ApiService();

  // ─── HELPER ──────────────────────────────────────────────────
  Map<String, dynamic> _layBody(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final d = jsonDecode(data);
      if (d is Map) return Map<String, dynamic>.from(d);
    }
    throw Exception('Dữ liệu phản hồi không hợp lệ');
  }

  bool _ok(Map<String, dynamic> b) =>
      b['status']?.toString().toLowerCase() == 'success';

  String _msg(Map<String, dynamic> b, {String def = 'Có lỗi xảy ra'}) =>
      b['message']?.toString() ?? def;

  String _err(dynamic e) {
    if (e is DioException) {
      final d = e.response?.data;
      if (d is Map && d['message'] != null) return d['message'].toString();
      if (d is String) {
        try {
          final decoded = jsonDecode(d);
          if (decoded is Map && decoded['message'] != null)
            return decoded['message'].toString();
        } catch (_) {}
      }
      return switch (e.type) {
        DioExceptionType.connectionTimeout => 'Kết nối server quá lâu',
        DioExceptionType.receiveTimeout => 'Server phản hồi quá lâu',
        DioExceptionType.connectionError => 'Không thể kết nối server',
        _ => e.message ?? 'Lỗi kết nối',
      };
    }
    var msg = e.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  // ─── HỒ SƠ ───────────────────────────────────────────────────
  Future<HoSoSinhVienModel> layThongTin(int sinhVienId) async {
    try {
      final res = await _api.post(
        '/sinh_vien/thong_tin_sinh_vien.php',
        data: {'sinh_vien_id': sinhVienId},
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được thông tin'));
      return HoSoSinhVienModel.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── LỚP HỌC PHẦN ────────────────────────────────────────────
  Future<List<LopHocPhanSVModel>> layDanhSachLop({
    required int sinhVienId,
    String tuKhoa = '',
    String trangThai = '',
    String hocKy = '',
    String namHoc = '',
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/lop_hoc_phan_sinh_vien.php',
        data: {
          'sinh_vien_id': sinhVienId,
          'tu_khoa': tuKhoa.trim(),
          'trang_thai': trangThai.trim(),
          'hoc_ky': hocKy.trim(),
          'nam_hoc': namHoc.trim(),
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được lớp học phần'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => LopHocPhanSVModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── TÀI LIỆU ────────────────────────────────────────────────
  Future<List<TaiLieuSVModel>> layDanhSachTaiLieu({
    required int lopHocPhanId,
    String tuKhoa = '',
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/noi_dung_lop.php',
        data: {
          'action': 'tai_lieu',
          'lop_hoc_phan_id': lopHocPhanId,
          'tu_khoa': tuKhoa.trim(),
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được tài liệu'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => TaiLieuSVModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── THÔNG BÁO ────────────────────────────────────────────────
  Future<List<ThongBaoSVModel>> layDanhSachThongBao(int lopHocPhanId) async {
    try {
      final res = await _api.post(
        '/sinh_vien/noi_dung_lop.php',
        data: {'action': 'thong_bao', 'lop_hoc_phan_id': lopHocPhanId},
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được thông báo'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => ThongBaoSVModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  //-CHỦ ĐỀ
  Future<List<ChuDe>> layDanhSachChuDe(int lopHocPhanId) async {
    final res = await _api.post(
      '/chu_de/quan_ly_chu_de.php',
      data: {'action': 'danh_sach', 'lop_hoc_phan_id': lopHocPhanId},
    );

    final body = _layBody(res);
    final raw = body['data'];
    if (raw is! List) return [];

    return raw
        .map((e) => ChuDe.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── BÀI TẬP ─────────────────────────────────────────────────
  Future<List<BaiTapSVModel>> layDanhSachBaiTap({
    required int sinhVienId,
    required int lopHocPhanId,
    List<int> chuDeIds = const [],
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/bai_tap_sinh_vien.php',
        data: {
          'action': 'danh_sach_theo_lop',
          'sinh_vien_id': sinhVienId,
          'lop_hoc_phan_id': lopHocPhanId,
          'chu_de_ids': chuDeIds,
        },
      );

      final body = _layBody(res);

      if (body['status'] != 'success') {
        throw Exception(
          body['message']?.toString() ?? 'Không lấy được bài tập',
        );
      }

      final raw = body['data'];
      if (raw is! List) return [];

      return raw
          .map((e) => BaiTapSVModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<BaiTapChuaNopModel>> layBaiTapChuaNop(int sinhVienId) async {
    try {
      final res = await _api.post(
        '/sinh_vien/bai_tap_sinh_vien.php',
        data: {'action': 'chua_nop', 'sinh_vien_id': sinhVienId},
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được bài tập chưa nộp'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => BaiTapChuaNopModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  String _tenFileTuPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? 'file_nop_bai' : parts.last;
  }

  Future<String> nopBai({
    required int sinhVienId,
    required int baiTapId,
    required String filePath,
  }) {
    return nopBaiNhieuFile(
      sinhVienId: sinhVienId,
      baiTapId: baiTapId,
      filePaths: [filePath],
    );
  }

  Future<String> nopBaiNhieuFile({
    required int sinhVienId,
    required int baiTapId,
    required List<String> filePaths,
  }) async {
    try {
      final paths = filePaths
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (paths.isEmpty) {
        throw Exception('Vui lòng chọn file để nộp');
      }

      final formData = FormData();
      formData.fields
        ..add(MapEntry('action', 'nop_bai'))
        ..add(MapEntry('sinh_vien_id', sinhVienId.toString()))
        ..add(MapEntry('bai_tap_id', baiTapId.toString()));

      for (final path in paths) {
        formData.files.add(
          MapEntry(
            'files[]',
            await MultipartFile.fromFile(path, filename: _tenFileTuPath(path)),
          ),
        );
      }

      final res = await _api.post(
        '/sinh_vien/bai_tap_sinh_vien.php',
        data: formData,
      );

      final body = _layBody(res);

      if (!_ok(body)) {
        throw Exception(_msg(body, def: 'Nộp bài thất bại'));
      }

      return _msg(body, def: 'Nộp bài thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── BÌNH LUẬN ────────────────────────────────────────────────
  Future<List<BinhLuanModel>> layDanhSachBinhLuan(int lopHocPhanId) async {
    try {
      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'danh_sach',
          'lop_hoc_phan_id': lopHocPhanId,
          'nguoi_dung_id': 0,
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Không lấy được bình luận'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => BinhLuanModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<BinhLuanModel> dangBinhLuan({
    required int nguoiDungId,
    required int lopHocPhanId,
    required String noiDung,
  }) async {
    try {
      if (noiDung.trim().isEmpty) throw Exception('Nội dung không được trống');
      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'dang',
          'nguoi_dung_id': nguoiDungId,
          'lop_hoc_phan_id': lopHocPhanId,
          'noi_dung': noiDung.trim(),
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Đăng bình luận thất bại'));
      return BinhLuanModel.fromJson(Map<String, dynamic>.from(body['data']));
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<String> suaBinhLuan({
    required int nguoiDungId,
    required int binhLuanId,
    required String noiDung,
  }) async {
    try {
      if (noiDung.trim().isEmpty) throw Exception('Nội dung không được trống');
      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'sua',
          'nguoi_dung_id': nguoiDungId,
          'binh_luan_id': binhLuanId,
          'noi_dung': noiDung.trim(),
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Sửa bình luận thất bại'));
      return _msg(body, def: 'Cập nhật thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<String> xoaBinhLuan({
    required int nguoiDungId,
    required int binhLuanId,
  }) async {
    try {
      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'xoa',
          'nguoi_dung_id': nguoiDungId,
          'binh_luan_id': binhLuanId,
        },
      );
      final body = _layBody(res);
      if (!_ok(body))
        throw Exception(_msg(body, def: 'Xóa bình luận thất bại'));
      return _msg(body, def: 'Xóa thành công');
    } catch (e) {
      throw Exception(_err(e));
    }
  }

  Future<Map<String, dynamic>> layThongTinSinhVienTheoNguoiDung(
    int nguoiDungId,
  ) async {
    final response = await _api.post(
      '/sinh_vien/thong_tin_sinh_vien_theo_nguoi_dung.php',
      data: {'nguoi_dung_id': nguoiDungId},
    );

    final data = response.data;

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Không lấy được thông tin sinh viên');
    }

    return Map<String, dynamic>.from(data['data']);
  }

  Future<Map<String, dynamic>> layThanhVienLop(int lopHocPhanId) async {
    final res = await _api.post(
      '/sinh_vien/danh_sach_thanh_vien_lop.php',
      data: {'lop_hoc_phan_id': lopHocPhanId},
    );

    final data = res.data;

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Không lấy được danh sách thành viên');
    }

    return Map<String, dynamic>.from(data['data']);
  }

  Future<String> thamGiaLopHocPhan({
    required int sinhVienId,
    required String maLopHocPhan,
  }) async {
    final response = await _api.post(
      '/sinh_vien/tham_gia_lop_hoc_phan.php',
      data: {'sinh_vien_id': sinhVienId, 'ma_lop_hoc_phan': maLopHocPhan},
    );

    final data = response.data;

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Tham gia lớp thất bại');
    }

    return data['message'] ?? 'Tham gia lớp thành công';
  }


}
