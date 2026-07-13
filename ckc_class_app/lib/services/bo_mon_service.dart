import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/khoa_bo_mon_model.dart';
import 'ket_noi_api_service.dart';

class BoMonService {
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

  void _kiemTraTrangThaiBoMon(String trangThai) {
    const danhSachTrangThaiHopLe = ['dang_hoat_dong', 'ngung_hoat_dong'];

    if (!danhSachTrangThaiHopLe.contains(trangThai)) {
      throw Exception('Trạng thái bộ môn không hợp lệ');
    }
  }

  Future<List<BoMon>> layDanhSachBoMon({
    String tuKhoa = '',
    int khoaId = 0,
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/bo_mon/danh_sach_bo_mon.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'khoa_id': khoaId,
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách bộ môn'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) {
        return [];
      }

      return rawList
          .map((item) => BoMon.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themBoMon({
    required String maBoMon,
    required String tenBoMon,
    required int khoaId,
    String trangThai = 'dang_hoat_dong',
  }) async {
    try {
      final ma = maBoMon.trim().toUpperCase();
      final ten = tenBoMon.trim();
      final trangThaiValue = trangThai.trim();

      if (ma.isEmpty) {
        throw Exception('Mã bộ môn không được để trống');
      }

      if (ten.isEmpty) {
        throw Exception('Tên bộ môn không được để trống');
      }

      if (khoaId <= 0) {
        throw Exception('Vui lòng chọn khoa');
      }

      _kiemTraTrangThaiBoMon(trangThaiValue);

      final response = await _apiService.post(
        '/bo_mon/them_bo_mon.php',
        data: {
          'ma_bo_mon': ma,
          'ten_bo_mon': ten,
          'khoa_id': khoaId,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể thêm bộ môn'));
      }

      return _layThongBao(body, macDinh: 'Thêm bộ môn thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaBoMon({
    required int id,
    required String maBoMon,
    required String tenBoMon,
    required int khoaId,
    required String trangThai,
  }) async {
    try {
      final ma = maBoMon.trim().toUpperCase();
      final ten = tenBoMon.trim();
      final trangThaiValue = trangThai.trim();

      if (id <= 0) {
        throw Exception('ID bộ môn không hợp lệ');
      }

      if (ma.isEmpty) {
        throw Exception('Mã bộ môn không được để trống');
      }

      if (ten.isEmpty) {
        throw Exception('Tên bộ môn không được để trống');
      }

      if (khoaId <= 0) {
        throw Exception('Vui lòng chọn khoa');
      }

      _kiemTraTrangThaiBoMon(trangThaiValue);

      final response = await _apiService.post(
        '/bo_mon/sua_bo_mon.php',
        data: {
          'id': id,
          'ma_bo_mon': ma,
          'ten_bo_mon': ten,
          'khoa_id': khoaId,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể cập nhật bộ môn'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật bộ môn thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaBoMon(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID bộ môn không hợp lệ');
      }

      final response = await _apiService.post(
        '/bo_mon/xoa_bo_mon.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể chuyển trạng thái bộ môn'),
        );
      }

      return _layThongBao(
        body,
        macDinh: 'Đã chuyển bộ môn sang trạng thái ngừng hoạt động',
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
