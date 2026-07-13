import 'dart:convert';

import 'package:dio/dio.dart';

import '../model/nguoi_dung_model.dart';
import 'ket_noi_api_service.dart';

class NguoiDungService {
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

  void _kiemTraTrangThaiNguoiDung(String trangThai) {
    const danhSachTrangThaiHopLe = ['dang_hoat_dong', 'bi_khoa'];

    if (!danhSachTrangThaiHopLe.contains(trangThai)) {
      throw Exception('Trạng thái người dùng không hợp lệ');
    }
  }

  void _kiemTraEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      throw Exception('Email không hợp lệ');
    }
  }

  Future<List<NguoiDung>> layDanhSachNguoiDung({
    String tuKhoa = '',
    int vaiTroId = 0,
    String trangThai = '',
  }) async {
    try {
      final response = await _apiService.post(
        '/nguoi_dung/danh_sach_nguoi_dung.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'vai_tro_id': vaiTroId,
          'trang_thai': trangThai.trim(),
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách người dùng'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) {
        return [];
      }

      return rawList
          .map((item) => NguoiDung.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<VaiTro>> layDanhSachVaiTro() async {
    try {
      final response = await _apiService.post(
        '/nguoi_dung/danh_sach_vai_tro.php',
        data: {},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách vai trò'),
        );
      }

      final rawList = body['data'];

      if (rawList is! List) {
        return [];
      }

      return rawList
          .map((item) => VaiTro.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<KhoaNguoiDung>> layDanhSachKhoa() async {
    try {
      final response = await _apiService.post(
        '/khoa/danh_sach_khoa.php',
        data: {'tu_khoa': '', 'trang_thai': ''},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách khoa'),
        );
      }

      final rawList = body['data'];
      if (rawList is! List) return [];

      return rawList
          .map(
            (item) => KhoaNguoiDung.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id > 0)
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<LopHanhChinhNguoiDung>> layDanhSachLopHanhChinh() async {
    try {
      final response = await _apiService.post(
        '/lop/danh_sach_lop.php',
        data: {'tu_khoa': '', 'trang_thai': '', 'khoa_id': 0},
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
          .map(
            (item) =>
                LopHanhChinhNguoiDung.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id > 0)
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<List<BoMonNguoiDung>> layDanhSachBoMon() async {
    try {
      final response = await _apiService.post(
        '/bo_mon/danh_sach_bo_mon.php',
        data: {'tu_khoa': '', 'trang_thai': '', 'khoa_id': 0},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể lấy danh sách bộ môn'),
        );
      }

      final rawList = body['data'];
      if (rawList is! List) return [];

      return rawList
          .map(
            (item) => BoMonNguoiDung.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((item) => item.id > 0)
          .toList();
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> themNguoiDung({
    required String hoTen,
    required String email,
    required String matKhau,
    required int vaiTroId,
    String trangThai = 'dang_hoat_dong',
    String maSinhVien = '',
    int lopId = 0,
    int khoaId = 0,
    String maGiangVien = '',
    int boMonId = 0,
  }) async {
    try {
      final hoTenValue = hoTen.trim();
      final emailValue = email.trim().toLowerCase();
      final matKhauValue = matKhau.trim();
      final trangThaiValue = trangThai.trim();

      if (hoTenValue.isEmpty) {
        throw Exception('Họ tên không được để trống');
      }

      if (emailValue.isEmpty) {
        throw Exception('Email không được để trống');
      }

      _kiemTraEmail(emailValue);

      if (matKhauValue.isEmpty) {
        throw Exception('Mật khẩu không được để trống');
      }

      if (matKhauValue.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }

      if (vaiTroId <= 0) {
        throw Exception('Vui lòng chọn vai trò');
      }

      _kiemTraTrangThaiNguoiDung(trangThaiValue);

      final maSinhVienValue = maSinhVien.trim();
      final maGiangVienValue = maGiangVien.trim();

      // CSDL hiện tại bắt buộc sinh viên phải có lop_id và khoa_id.
      // Đây là lớp hành chính/khoa, không phải lớp học phần tham gia bằng mã.
      if (vaiTroId == 3) {
        if (lopId <= 0) {
          throw Exception('Vui lòng chọn lớp hành chính cho sinh viên');
        }
        if (khoaId <= 0) {
          throw Exception('Vui lòng chọn khoa cho sinh viên');
        }
      }

      final response = await _apiService.post(
        '/nguoi_dung/them_nguoi_dung.php',
        data: {
          'ho_ten': hoTenValue,
          'email': emailValue,
          'mat_khau': matKhauValue,
          'vai_tro_id': vaiTroId,
          'trang_thai': trangThaiValue,
          'ma_sinh_vien': maSinhVienValue,
          'lop_id': lopId,
          'khoa_id': khoaId,
          'ma_giang_vien': maGiangVienValue,
          'bo_mon_id': boMonId,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể thêm người dùng'),
        );
      }

      return _layThongBao(body, macDinh: 'Thêm người dùng thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> suaNguoiDung({
    required int id,
    required String hoTen,
    required String email,
    String matKhau = '',
    required int vaiTroId,
    required String trangThai,
    String maSinhVien = '',
    int lopId = 0,
    int khoaId = 0,
    String maGiangVien = '',
    int boMonId = 0,
  }) async {
    try {
      final hoTenValue = hoTen.trim();
      final emailValue = email.trim().toLowerCase();
      final matKhauValue = matKhau.trim();
      final trangThaiValue = trangThai.trim();

      if (id <= 0) {
        throw Exception('ID người dùng không hợp lệ');
      }

      if (hoTenValue.isEmpty) {
        throw Exception('Họ tên không được để trống');
      }

      if (emailValue.isEmpty) {
        throw Exception('Email không được để trống');
      }

      _kiemTraEmail(emailValue);

      if (matKhauValue.isNotEmpty && matKhauValue.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }

      if (vaiTroId <= 0) {
        throw Exception('Vui lòng chọn vai trò');
      }

      _kiemTraTrangThaiNguoiDung(trangThaiValue);

      final maSinhVienValue = maSinhVien.trim();
      final maGiangVienValue = maGiangVien.trim();

      // CSDL hiện tại bắt buộc sinh viên phải có lop_id và khoa_id.
      // Đây là lớp hành chính/khoa, không phải lớp học phần tham gia bằng mã.
      if (vaiTroId == 3) {
        if (lopId <= 0) {
          throw Exception('Vui lòng chọn lớp hành chính cho sinh viên');
        }
        if (khoaId <= 0) {
          throw Exception('Vui lòng chọn khoa cho sinh viên');
        }
      }

      final response = await _apiService.post(
        '/nguoi_dung/sua_nguoi_dung.php',
        data: {
          'id': id,
          'ho_ten': hoTenValue,
          'email': emailValue,
          'mat_khau': matKhauValue,
          'vai_tro_id': vaiTroId,
          'trang_thai': trangThaiValue,
          'ma_sinh_vien': maSinhVienValue,
          'lop_id': lopId,
          'khoa_id': khoaId,
          'ma_giang_vien': maGiangVienValue,
          'bo_mon_id': boMonId,
        },
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể cập nhật người dùng'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật người dùng thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> xoaNguoiDung(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID người dùng không hợp lệ');
      }

      final response = await _apiService.post(
        '/nguoi_dung/xoa_nguoi_dung.php',
        data: {'id': id},
      );

      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không thể khóa người dùng'),
        );
      }

      return _layThongBao(body, macDinh: 'Đã khóa người dùng thành công');
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<String> khoaNguoiDung(int id) async {
    return xoaNguoiDung(id);
  }
}
