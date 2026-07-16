import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/lop_hoc_phan_model.dart';
import 'ket_noi_api_service.dart';

class LopHocPhanService {
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

  void _kiemTraHocKy(String hocKy) {
    const List<String> dsHocKy = [
      'HK1',
      'HK2',
      'HK3',
      'HK4',
      'HK5',
      'HK6',
    ];

    if (!dsHocKy.contains(hocKy)) {
      throw Exception('Học kỳ không hợp lệ');
    }
  }

  void _kiemTraTrangThai(String trangThai) {
    const dsTrangThai = ['dang_mo', 'da_khoa', 'da_ket_thuc'];

    if (!dsTrangThai.contains(trangThai)) {
      throw Exception('Trạng thái lớp học phần không hợp lệ');
    }
  }

  void _kiemTraNamHoc(String namHoc) {
    final value = namHoc.trim();
    final match = RegExp(r'^(\d{4})-(\d{4})$').firstMatch(value);
    if (match == null) {
      throw Exception('Năm học không hợp lệ. Ví dụ đúng: 2025-2026');
    }
    final batDau = int.parse(match.group(1)!);
    final ketThuc = int.parse(match.group(2)!);
    if (batDau < 2000 || batDau > DateTime.now().year + 2 || ketThuc - batDau != 1) {
      throw Exception('Năm học không hợp lệ. Ví dụ đúng: 2025-2026');
    }
  }

  Future<List<LopHocPhan>> layDanhSachLopHocPhan({
    String tuKhoa = '',
    int monHocId = 0,
    int giangVienId = 0,
    String hocKy = '',
    String namHoc = '',
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/lop_hoc_phan/danh_sach_lop_hoc_phan.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'mon_hoc_id': monHocId,
          'giang_vien_id': giangVienId,
          'hoc_ky': hocKy.trim(),
          'nam_hoc': namHoc.trim(),
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách lớp học phần'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) return [];

      return rawList
          .map((item) => LopHocPhan.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themLopHocPhan({
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required int giangVienId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
    String trangThai = 'dang_mo',
    int lopId = 0,
  }) async {
    try {
      final ma = maLopHocPhan.trim();
      final ten = tenLop.trim();
      final namHocValue = namHoc.trim();
      final hocKyValue = hocKy.trim();
      final trangThaiValue = trangThai.trim();

      if (ma.isEmpty) throw Exception('Mã lớp học phần không được để trống');
      if (ten.isEmpty) throw Exception('Tên lớp học phần không được để trống');
      if (monHocId <= 0) throw Exception('Vui lòng chọn môn học');
      if (giangVienId <= 0) throw Exception('Vui lòng chọn giảng viên');

      _kiemTraNamHoc(namHocValue);

      if (siSoToiDa != null && (siSoToiDa <= 0 || siSoToiDa > 500)) {
        throw Exception('Sĩ số tối đa phải từ 1 đến 500');
      }

      _kiemTraHocKy(hocKyValue);
      _kiemTraTrangThai(trangThaiValue);

      final response = await _apiService.post(
        '/lop_hoc_phan/them_lop_hoc_phan.php',
        data: {
          'ma_lop_hoc_phan': ma,
          'ten_lop': ten,
          'mon_hoc_id': monHocId,
          'giang_vien_id': giangVienId,
          'hoc_ky': hocKyValue,

          'nam_hoc': namHocValue,
          'si_so_toi_da': siSoToiDa,
          'trang_thai': trangThaiValue,
          'lop_id': lopId,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể thêm lớp học phần'),
        );
      }

      return _layThongBao(body, macDinh: 'Thêm lớp học phần thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaLopHocPhan({
    required int id,
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required int giangVienId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
    required String trangThai,
  }) async {
    try {
      final ma = maLopHocPhan.trim();
      final ten = tenLop.trim();
      final namHocValue = namHoc.trim();
      final hocKyValue = hocKy.trim();
      final trangThaiValue = trangThai.trim();

      if (id <= 0) throw Exception('ID lớp học phần không hợp lệ');
      if (ma.isEmpty) throw Exception('Mã lớp học phần không được để trống');
      if (ten.isEmpty) throw Exception('Tên lớp học phần không được để trống');
      if (monHocId <= 0) throw Exception('Vui lòng chọn môn học');
      if (giangVienId <= 0) throw Exception('Vui lòng chọn giảng viên');

      _kiemTraNamHoc(namHocValue);

      if (siSoToiDa != null && (siSoToiDa <= 0 || siSoToiDa > 500)) {
        throw Exception('Sĩ số tối đa phải từ 1 đến 500');
      }

      _kiemTraHocKy(hocKyValue);
      _kiemTraTrangThai(trangThaiValue);

      final response = await _apiService.post(
        '/lop_hoc_phan/sua_lop_hoc_phan.php',
        data: {
          'id': id,
          'ma_lop_hoc_phan': ma,
          'ten_lop': ten,
          'mon_hoc_id': monHocId,
          'giang_vien_id': giangVienId,
          'hoc_ky': hocKyValue,
          'nam_hoc': namHocValue,
          'si_so_toi_da': siSoToiDa,
          'trang_thai': trangThaiValue,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể cập nhật lớp học phần'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật lớp học phần thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaLopHocPhan(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID lớp học phần không hợp lệ');
      }

      final response = await _apiService.post(
        '/lop_hoc_phan/xoa_lop_hoc_phan.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể khóa lớp học phần'),
        );
      }

      return _layThongBao(body, macDinh: 'Đã khóa lớp học phần thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> khoaLopHocPhan(int id) async {
    return xoaLopHocPhan(id);
  }
}
