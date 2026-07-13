import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/khoa_bo_mon_model.dart';
import 'ket_noi_api_service.dart';

class KhoaService {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _layBody(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      final decoded = jsonDecode(data);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
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

  void _kiemTraTrangThaiKhoa(String trangThai) {
    const danhSachTrangThaiHopLe = ['dang_hoat_dong', 'ngung_hoat_dong'];

    if (!danhSachTrangThaiHopLe.contains(trangThai)) {
      throw Exception('Trạng thái khoa không hợp lệ');
    }
  }

  Future<List<Khoa>> layDanhSachKhoa({
    String tuKhoa = '',
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/khoa/danh_sach_khoa.php',
        data: {'tu_khoa': tuKhoa.trim(), 'trang_thai': trangThai.trim()},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách khoa'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) {
        return [];
      }

      return rawList
          .map((item) => Khoa.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themKhoa({
    required String maKhoa,
    required String tenKhoa,
    String trangThai = 'dang_hoat_dong',
  }) async {
    try {
      final ma = maKhoa.trim().toUpperCase();
      final ten = tenKhoa.trim();
      final trangThaiValue = trangThai.trim();

      if (ma.isEmpty) {
        throw Exception('Mã khoa không được để trống');
      }

      if (ten.isEmpty) {
        throw Exception('Tên khoa không được để trống');
      }

      _kiemTraTrangThaiKhoa(trangThaiValue);

      final response = await _apiService.post(
        '/khoa/them_khoa.php',
        data: {'ma_khoa': ma, 'ten_khoa': ten, 'trang_thai': trangThaiValue},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể thêm khoa'));
      }

      return _layThongBao(body, macDinh: 'Thêm khoa thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaKhoa({
    required int id,
    required String maKhoa,
    required String tenKhoa,
    required String trangThai,
  }) async {
    try {
      final ma = maKhoa.trim().toUpperCase();
      final ten = tenKhoa.trim();
      final trangThaiValue = trangThai.trim();

      if (id <= 0) {
        throw Exception('ID khoa không hợp lệ');
      }

      if (ma.isEmpty) {
        throw Exception('Mã khoa không được để trống');
      }

      if (ten.isEmpty) {
        throw Exception('Tên khoa không được để trống');
      }

      _kiemTraTrangThaiKhoa(trangThaiValue);

      final response = await _apiService.post(
        '/khoa/sua_khoa.php',
        data: {
          'id': id,
          'ma_khoa': ma,
          'ten_khoa': ten,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể cập nhật khoa'));
      }

      return _layThongBao(body, macDinh: 'Cập nhật khoa thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaKhoa(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID khoa không hợp lệ');
      }

      final response = await _apiService.post(
        '/khoa/xoa_khoa.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể chuyển trạng thái khoa'),
        );
      }

      return _layThongBao(
        body,
        macDinh: 'Đã chuyển khoa sang trạng thái ngừng hoạt động',
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
