import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/lop_model.dart';
import 'ket_noi_api_service.dart';

class LopService {
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

  void _kiemTraTrangThaiLop(String trangThai) {
    const danhSachTrangThaiHopLe = ['dang_hoc', 'da_tot_nghiep', 'tam_khoa'];

    if (!danhSachTrangThaiHopLe.contains(trangThai)) {
      throw Exception('Trạng thái lớp không hợp lệ');
    }
  }

  void _kiemTraKhoaHoc(String khoaHoc) {
    final value = khoaHoc.trim();
    final regex = RegExp(r'^\d{4}-\d{4}$');

    if (!regex.hasMatch(value)) {
      throw Exception('Khóa học không hợp lệ. Ví dụ đúng: 2024-2027');
    }

    final parts = value.split('-');
    final namBatDau = int.tryParse(parts[0]) ?? 0;
    final namKetThuc = int.tryParse(parts[1]) ?? 0;
    final namHienTai = DateTime.now().year;

    if (namBatDau < 2000 || namBatDau > namHienTai + 1) {
      throw Exception('Năm bắt đầu khóa học không hợp lệ');
    }

    if (namKetThuc - namBatDau != 3) {
      throw Exception('Khóa học phải kéo dài đúng 3 năm. Ví dụ: 2024-2027');
    }
  }

  Future<List<Lop>> layDanhSachLop({
    String tuKhoa = '',
    int khoaId = 0,
    String khoaHoc = '',
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/lop/danh_sach_lop.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'khoa_id': khoaId,
          'khoa_hoc': khoaHoc.trim(),
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách lớp'),
        );
      }

      final rawList = body['data'];
      if (rawList is! List) return [];

      return rawList
          .map((item) => Lop.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themLop({
    required String maLop,
    required String tenLop,
    required int khoaId,
    required String khoaHoc,
    String trangThai = 'dang_hoc',
  }) async {
    try {
      final ma = maLop.trim().toUpperCase();
      final ten = tenLop.trim();
      final khoaHocValue = khoaHoc.trim();
      final trangThaiValue = trangThai.trim();

      if (ma.isEmpty) throw Exception('Mã lớp không được để trống');
      if (ten.isEmpty) throw Exception('Tên lớp không được để trống');
      if (khoaId <= 0) throw Exception('Vui lòng chọn khoa');

      _kiemTraKhoaHoc(khoaHocValue);
      _kiemTraTrangThaiLop(trangThaiValue);

      final response = await _apiService.post(
        '/lop/them_lop.php',
        data: {
          'ma_lop': ma,
          'ten_lop': ten,
          'khoa_id': khoaId,
          'khoa_hoc': khoaHocValue,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể thêm lớp'));
      }

      return _layThongBao(body, macDinh: 'Thêm lớp thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaLop({
    required int id,
    required String maLop,
    required String tenLop,
    required int khoaId,
    required String khoaHoc,
    required String trangThai,
  }) async {
    try {
      final ma = maLop.trim().toUpperCase();
      final ten = tenLop.trim();
      final khoaHocValue = khoaHoc.trim();
      final trangThaiValue = trangThai.trim();

      if (id <= 0) throw Exception('ID lớp không hợp lệ');
      if (ma.isEmpty) throw Exception('Mã lớp không được để trống');
      if (ten.isEmpty) throw Exception('Tên lớp không được để trống');
      if (khoaId <= 0) throw Exception('Vui lòng chọn khoa');

      _kiemTraKhoaHoc(khoaHocValue);
      _kiemTraTrangThaiLop(trangThaiValue);

      final response = await _apiService.post(
        '/lop/sua_lop.php',
        data: {
          'id': id,
          'ma_lop': ma,
          'ten_lop': ten,
          'khoa_id': khoaId,
          'khoa_hoc': khoaHocValue,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể cập nhật lớp'));
      }

      return _layThongBao(body, macDinh: 'Cập nhật lớp thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaLop(int id) async {
    try {
      if (id <= 0) throw Exception('ID lớp không hợp lệ');

      final response = await _apiService.post(
        '/lop/xoa_lop.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể tạm khóa lớp'));
      }

      return _layThongBao(
        body,
        macDinh: 'Đã chuyển lớp sang trạng thái tạm khóa',
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
