import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/khoa_bo_mon_model.dart';
import 'ket_noi_api_service.dart';

class MonHocService {
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

  Future<List<MonHoc>> layDanhSachMonHoc({
    String tuKhoa = '',
    int khoaId = 0,
    int boMonId = 0,
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/mon_hoc/danh_sach_mon_hoc.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'khoa_id': khoaId,
          'bo_mon_id': boMonId,
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách môn học'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) return [];

      return rawList
          .map((item) => MonHoc.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themMonHoc({
    required String maMon,
    required String tenMon,
    required int tinChi,
    required int khoaId,
    required int boMonId,
    String trangThai = 'dang_mo',
  }) async {
    try {
      final ma = maMon.trim().toUpperCase();
      final ten = tenMon.trim();

      if (ma.isEmpty) throw Exception('Mã môn học không được để trống');
      if (ten.isEmpty) throw Exception('Tên môn học không được để trống');
      if (tinChi <= 0 || tinChi > 10) {
        throw Exception('Số tín chỉ phải từ 1 đến 10');
      }

      if (trangThai != 'dang_mo' && trangThai != 'ngung_su_dung') {
        throw Exception('Trạng thái môn học không hợp lệ');
      }
      if (khoaId <= 0) throw Exception('Vui lòng chọn khoa');
      if (boMonId <= 0) throw Exception('Vui lòng chọn bộ môn');

      final response = await _apiService.post(
        '/mon_hoc/them_mon_hoc.php',
        data: {
          'ma_mon': ma,
          'ten_mon': ten,
          'khoa_id': khoaId,
          'bo_mon_id': boMonId,
          'trang_thai': trangThai,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể thêm môn học'));
      }

      return _layThongBao(body, macDinh: 'Thêm môn học thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaMonHoc({
    required int id,
    required String maMon,
    required String tenMon,
    required int tinChi,
    required int khoaId,
    required int boMonId,
    required String trangThai,
  }) async {
    try {
      final ma = maMon.trim().toUpperCase();
      final ten = tenMon.trim();

      if (id <= 0) throw Exception('ID môn học không hợp lệ');
      if (ma.isEmpty) throw Exception('Mã môn học không được để trống');
      if (ten.isEmpty) throw Exception('Tên môn học không được để trống');
      if (tinChi <= 0 || tinChi > 10) {
        throw Exception('Số tín chỉ phải từ 1 đến 10');
      }

      if (trangThai != 'dang_mo' && trangThai != 'ngung_su_dung') {
        throw Exception('Trạng thái môn học không hợp lệ');
      }
      if (khoaId <= 0) throw Exception('Vui lòng chọn khoa');
      if (boMonId <= 0) throw Exception('Vui lòng chọn bộ môn');

      final response = await _apiService.post(
        '/mon_hoc/sua_mon_hoc.php',
        data: {
          'id': id,
          'ma_mon': ma,
          'ten_mon': ten,
          'khoa_id': khoaId,
          'bo_mon_id': boMonId,
          'trang_thai': trangThai,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể cập nhật môn học'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật môn học thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaMonHoc(int id) async {
    try {
      if (id <= 0) throw Exception('ID môn học không hợp lệ');

      final response = await _apiService.post(
        '/mon_hoc/xoa_mon_hoc.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể chuyển trạng thái môn học'),
        );
      }

      return _layThongBao(
        body,
        macDinh: 'Đã chuyển môn học sang trạng thái ngừng sử dụng',
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
