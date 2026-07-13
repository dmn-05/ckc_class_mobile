import 'dart:convert';
import 'package:dio/dio.dart';

import '../model/sinh_vien_lop_hoc_phan_model.dart';
import 'ket_noi_api_service.dart';

class SinhVienLopHocPhanService {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _layBody(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

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

  void _kiemTraTrangThai(String trangThai) {
    const dsTrangThai = ['dang_hoc', 'da_huy', 'hoan_thanh'];

    if (!dsTrangThai.contains(trangThai)) {
      throw Exception('Trạng thái sinh viên trong lớp học phần không hợp lệ');
    }
  }

  Future<List<SinhVienLopHocPhan>> layDanhSachSinhVienLopHocPhan({
    required int lopHocPhanId,
    String tuKhoa = '',
    String trangThai = '',
  }) async {
    try {
      if (lopHocPhanId <= 0) {
        throw Exception('ID lớp học phần không hợp lệ');
      }

      final response = await _apiService.post(
        '/lop_hoc_phan/danh_sach_sinh_vien_lop_hoc_phan.php',
        data: {
          'lop_hoc_phan_id': lopHocPhanId,
          'tu_khoa': tuKhoa.trim(),
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(
            body,
            macDinh: 'Không thể lấy danh sách sinh viên lớp học phần',
          ),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) return [];

      return rawList
          .map(
            (item) =>
                SinhVienLopHocPhan.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<SinhVienCoTheThemLhp>> layDanhSachSinhVienCoTheThem({
    required int lopHocPhanId,
    String tuKhoa = '',
  }) async {
    try {
      if (lopHocPhanId <= 0) {
        throw Exception('ID lớp học phần không hợp lệ');
      }

      final response = await _apiService.post(
        '/lop_hoc_phan/danh_sach_sinh_vien_co_the_them.php',
        data: {
          'lop_hoc_phan_id': lopHocPhanId,
          'tu_khoa': tuKhoa.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(
            body,
            macDinh: 'Không thể lấy danh sách sinh viên có thể thêm',
          ),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) return [];

      return rawList
          .map(
            (item) =>
                SinhVienCoTheThemLhp.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themSinhVienVaoLopHocPhan({
    required int lopHocPhanId,
    required int sinhVienId,
  }) async {
    try {
      if (lopHocPhanId <= 0) {
        throw Exception('ID lớp học phần không hợp lệ');
      }

      if (sinhVienId <= 0) {
        throw Exception('ID sinh viên không hợp lệ');
      }

      final response = await _apiService.post(
        '/lop_hoc_phan/them_sinh_vien_lop_hoc_phan.php',
        data: {
          'lop_hoc_phan_id': lopHocPhanId,
          'sinh_vien_id': sinhVienId,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể thêm sinh viên vào lớp học phần'),
        );
      }

      return _layThongBao(body, macDinh: 'Thêm sinh viên vào lớp học phần thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
  Future<Map<String, dynamic>> themSinhVienTheoLopHanhChinh({
  required int lopHocPhanId,
  required int lopId,
}) async {
  try {
    if (lopHocPhanId <= 0) {
      throw Exception('ID lớp học phần không hợp lệ');
    }

    if (lopId <= 0) {
      throw Exception('Vui lòng chọn lớp hành chính');
    }

    final response = await _apiService.post(
      '/lop_hoc_phan/them_sinh_vien_lop_hanh_chinh_vao_lhp.php',
      data: {
        'lop_hoc_phan_id': lopHocPhanId,
        'lop_id': lopId,
      },
    );

    final body = _layBody(response);

    if (!_laThanhCong(body)) {
      throw Exception(
        _layThongBao(
          body,
          macDinh: 'Không thể thêm sinh viên từ lớp hành chính',
        ),
      );
    }

    return body;
  } catch (error) {
    throw Exception(_xuLyLoi(error));
  }
}

  Future<String> xoaSinhVienKhoiLopHocPhan(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID sinh viên lớp học phần không hợp lệ');
      }

      final response = await _apiService.post(
        '/lop_hoc_phan/xoa_sinh_vien_lop_hoc_phan.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể xóa sinh viên khỏi lớp học phần'),
        );
      }

      return _layThongBao(body, macDinh: 'Đã xóa sinh viên khỏi lớp học phần');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> capNhatTrangThaiSinhVienLopHocPhan({
    required int id,
    required String trangThai,
  }) async {
    try {
      if (id <= 0) {
        throw Exception('ID sinh viên lớp học phần không hợp lệ');
      }

      final trangThaiValue = trangThai.trim();
      _kiemTraTrangThai(trangThaiValue);

      final response = await _apiService.post(
        '/lop_hoc_phan/cap_nhat_trang_thai_sinh_vien_lop_hoc_phan.php',
        data: {
          'id': id,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể cập nhật trạng thái sinh viên'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật trạng thái sinh viên thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
