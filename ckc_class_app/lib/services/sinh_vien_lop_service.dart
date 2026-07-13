import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/sinh_vien_lop_model.dart';
import 'ket_noi_api_service.dart';

class SinhVienLopService {
  final ApiService _api = ApiService();

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

  String _message(Map<String, dynamic> body, String fallback) {
    return body['message']?.toString() ?? fallback;
  }

  void _checkSuccess(Map<String, dynamic> body, String fallback) {
    if (body['status']?.toString().toLowerCase() != 'success') {
      throw Exception(_message(body, fallback));
    }
  }

  String _xuLyLoi(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map && decoded['message'] != null) {
            return decoded['message'].toString();
          }
        } catch (_) {}
      }

      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Kết nối đến server quá lâu';
      }

      if (error.type == DioExceptionType.receiveTimeout) {
        return 'Server phản hồi quá lâu';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối đến server';
      }

      return error.message ?? 'Lỗi kết nối server';
    }

    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  Future<List<SinhVienLop>> getSinhVienTrongLop({
    required int lopId,
    String keyword = '',
    String trangThai = '',
  }) async {
    try {
      final res = await _api.post(
        '/lop/danh_sach_sinh_vien_lop.php',
        data: {
          'action': 'list',
          'lop_id': lopId,
          'keyword': keyword.trim(),
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(res);
      _checkSuccess(body, 'Không thể lấy danh sách sinh viên trong lớp');

      final rawList = body['data'];
      if (rawList is! List) return [];

      return rawList
          .map((e) => SinhVienLop.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<SinhVienLop>> getSinhVienChuaCoTrongLop({
    required int lopId,
    String keyword = '',
  }) async {
    try {
      final res = await _api.post(
        '/lop/danh_sach_sinh_vien_lop.php',
        data: {
          'action': 'list_add',
          'lop_id': lopId,
          'keyword': keyword.trim(),
        },
      );

      final body = _layBody(res);
      _checkSuccess(body, 'Không thể lấy danh sách sinh viên có thể thêm');

      final rawList = body['data'];
      if (rawList is! List) return [];

      return rawList
          .map((e) => SinhVienLop.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themSinhVienVaoLop({
    required int lopId,
    required int sinhVienId,
  }) async {
    try {
      final res = await _api.post(
        '/lop/danh_sach_sinh_vien_lop.php',
        data: {
          'action': 'add',
          'lop_id': lopId,
          'sinh_vien_id': sinhVienId,
        },
      );

      final body = _layBody(res);
      _checkSuccess(body, 'Không thể thêm sinh viên vào lớp');
      return _message(body, 'Thêm sinh viên vào lớp thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaSinhVienKhoiLop({required int id}) async {
    try {
      final res = await _api.post(
        '/lop/danh_sach_sinh_vien_lop.php',
        data: {'action': 'delete', 'id': id},
      );

      final body = _layBody(res);
      _checkSuccess(body, 'Không thể chuyển sinh viên sang tạm nghỉ');
      return _message(body, 'Đã chuyển sinh viên sang tạm nghỉ');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> capNhatTrangThai({
    required int id,
    required String trangThai,
  }) async {
    try {
      final res = await _api.post(
        '/lop/danh_sach_sinh_vien_lop.php',
        data: {
          'action': 'update_status',
          'id': id,
          'trang_thai': trangThai,
        },
      );

      final body = _layBody(res);
      _checkSuccess(body, 'Không thể cập nhật trạng thái sinh viên');
      return _message(body, 'Cập nhật trạng thái sinh viên thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
