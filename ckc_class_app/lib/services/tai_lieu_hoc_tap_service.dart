import 'dart:convert';
import 'package:dio/dio.dart';

import '../model/tai_lieu_hoc_tap_model.dart';
import 'ket_noi_api_service.dart';

class TaiLieuHocTapService {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _layBody(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Dữ liệu phản hồi từ server không hợp lệ');
  }

  bool _laThanhCong(Map<String, dynamic> body) {
    return body['status']?.toString().toLowerCase() == 'success';
  }

  String _layThongBao(
    Map<String, dynamic> body, {
    String macDinh = 'Có lỗi xảy ra',
  }) {
    return body['message']?.toString() ?? macDinh;
  }

  String _xuLyLoi(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map && decoded['message'] != null) {
            return decoded['message'].toString();
          }
        } catch (_) {}
      }
      if (error.type == DioExceptionType.connectionError) return 'Không thể kết nối đến server';
      if (error.type == DioExceptionType.connectionTimeout) return 'Kết nối đến server quá lâu';
      if (error.type == DioExceptionType.receiveTimeout) return 'Server phản hồi quá lâu';
      return error.message ?? 'Lỗi kết nối server';
    }

    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  void _kiemTraTrangThai(String trangThai) {
    const dsTrangThai = ['hien_thi', 'an'];
    if (!dsTrangThai.contains(trangThai)) {
      throw Exception('Trạng thái tài liệu không hợp lệ');
    }
  }

  Future<List<TaiLieuHocTap>> layDanhSachTaiLieu({
    String tuKhoa = '',
    int lopHocPhanId = 0,
    int monHocId = 0,
    int nguoiTaoId = 0,
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/tai_lieu/danh_sach_tai_lieu.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'lop_hoc_phan_id': lopHocPhanId,
          'mon_hoc_id': monHocId,
          'nguoi_tao_id': nguoiTaoId,
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể lấy danh sách tài liệu'));
      }

      final rawList = body['data'];
      if (rawList is! List) return [];
      return rawList
          .map((item) => TaiLieuHocTap.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themTaiLieu({
    required String tieuDe,
    String moTa = '',
    required String duongDanFile,
    required int lopHocPhanId,
    int nguoiTaoId = 1,
    String trangThai = 'hien_thi',
  }) async {
    try {
      final title = tieuDe.trim();
      final path = duongDanFile.trim();
      final status = trangThai.trim();

      if (title.isEmpty) throw Exception('Tiêu đề tài liệu không được để trống');
      if (path.isEmpty) throw Exception('Đường dẫn file không được để trống');
      if (lopHocPhanId <= 0) throw Exception('Vui lòng chọn lớp học phần');
      _kiemTraTrangThai(status);

      final response = await _apiService.post(
        '/tai_lieu/them_tai_lieu.php',
        data: {
          'tieu_de': title,
          'mo_ta': moTa.trim(),
          'duong_dan_file': path,
          'lop_hoc_phan_id': lopHocPhanId,
          'nguoi_tao_id': nguoiTaoId <= 0 ? 1 : nguoiTaoId,
          'trang_thai': status,
        },
      );

      final body = _layBody(response);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể thêm tài liệu'));
      }
      return _layThongBao(body, macDinh: 'Thêm tài liệu thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaTaiLieu({
    required int id,
    required String tieuDe,
    String moTa = '',
    required String duongDanFile,
    required int lopHocPhanId,
    required String trangThai,
  }) async {
    try {
      final title = tieuDe.trim();
      final path = duongDanFile.trim();
      final status = trangThai.trim();

      if (id <= 0) throw Exception('ID tài liệu không hợp lệ');
      if (title.isEmpty) throw Exception('Tiêu đề tài liệu không được để trống');
      if (path.isEmpty) throw Exception('Đường dẫn file không được để trống');
      if (lopHocPhanId <= 0) throw Exception('Vui lòng chọn lớp học phần');
      _kiemTraTrangThai(status);

      final response = await _apiService.post(
        '/tai_lieu/sua_tai_lieu.php',
        data: {
          'id': id,
          'tieu_de': title,
          'mo_ta': moTa.trim(),
          'duong_dan_file': path,
          'lop_hoc_phan_id': lopHocPhanId,
          'trang_thai': status,
        },
      );

      final body = _layBody(response);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể cập nhật tài liệu'));
      }
      return _layThongBao(body, macDinh: 'Cập nhật tài liệu thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> capNhatTrangThaiTaiLieu({
    required int id,
    required String trangThai,
  }) async {
    try {
      if (id <= 0) throw Exception('ID tài liệu không hợp lệ');
      _kiemTraTrangThai(trangThai);

      final response = await _apiService.post(
        '/tai_lieu/cap_nhat_trang_thai_tai_lieu.php',
        data: {'id': id, 'trang_thai': trangThai},
      );

      final body = _layBody(response);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể cập nhật trạng thái tài liệu'));
      }
      return _layThongBao(body, macDinh: 'Cập nhật trạng thái tài liệu thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
