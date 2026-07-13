import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/nguoi_dung_model.dart';
import '../services/ket_noi_api_service.dart';

class AuthProvider with ChangeNotifier {
  NguoiDung? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  NguoiDung? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');

    if (userStr != null && userStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(userStr);

        if (decoded is Map) {
          _user = NguoiDung.fromJson(Map<String, dynamic>.from(decoded));
          notifyListeners();
        } else {
          await prefs.remove('user');
        }
      } catch (e) {
        await prefs.remove('user');
        debugPrint('Load user error: $e');
      }
    }
  }

  Map<String, dynamic>? _parseResponseData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String && responseData.isNotEmpty) {
      final decoded = jsonDecode(responseData);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/dang_nhap.php',
        data: {'email': email.trim(), 'password': password.trim()},
      );

      final data = _parseResponseData(response.data);

      if (data == null) {
        return {
          'success': false,
          'message': 'Dữ liệu server trả về không hợp lệ',
        };
      }

      if (response.statusCode == 200 && data['status'] == 'success') {
        final userData = data['user'];

        if (userData is! Map) {
          return {'success': false, 'message': 'Thiếu dữ liệu người dùng'};
        }

        _user = NguoiDung.fromJson(Map<String, dynamic>.from(userData));

        if (!_user!.isHoatDong) {
          _user = null;

          return {
            'success': false,
            'message': 'Tài khoản đã bị khóa hoặc ngừng hoạt động',
          };
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        return {
          'success': true,
          'message': data['message'] ?? 'Đăng nhập thành công',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    } catch (e) {
      debugPrint('Login error: $e');

      return {
        'success': false,
        'message':
            'Không thể kết nối đến máy chủ. Kiểm tra XAMPP, URL API hoặc CORS.',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    notifyListeners();
  }

  Future<Map<String, dynamic>> layHoSoCaNhan() async {
    if (_user == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }

    try {
      final response = await _apiService.post(
        '/nguoi_dung/ho_so_ca_nhan.php',
        data: {'action': 'lay', 'id': _user!.id},
      );

      final data = _parseResponseData(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      if (data['status'] == 'success' && data['data'] is Map) {
        _user = NguoiDung.fromJson(Map<String, dynamic>.from(data['data']));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        notifyListeners();
        return {'success': true, 'message': data['message'] ?? 'Lấy hồ sơ thành công'};
      }

      return {'success': false, 'message': data['message'] ?? 'Không lấy được hồ sơ'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server'};
    }
  }

  Future<Map<String, dynamic>> capNhatHoSoCaNhan({
    required String hoTen,
    required String email,
    String ngaySinh = '',
    String gioiTinh = '',
    String soDienThoai = '',
    String cccd = '',
    String diaChi = '',
  }) async {
    if (_user == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }

    final ten = hoTen.trim();
    final mail = email.trim();

    if (ten.isEmpty) {
      return {'success': false, 'message': 'Họ tên không được để trống'};
    }
    if (mail.isEmpty || !mail.contains('@')) {
      return {'success': false, 'message': 'Email không hợp lệ'};
    }

    try {
      final response = await _apiService.post(
        '/nguoi_dung/ho_so_ca_nhan.php',
        data: {
          'action': 'cap_nhat',
          'id': _user!.id,
          'ho_ten': ten,
          'email': mail,
          'ngay_sinh': ngaySinh.trim(),
          'gioi_tinh': gioiTinh.trim(),
          'so_dien_thoai': soDienThoai.trim(),
          'cccd': cccd.trim(),
          'dia_chi': diaChi.trim(),
        },
      );

      final data = _parseResponseData(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      if (data['status'] == 'success' && data['data'] is Map) {
        _user = NguoiDung.fromJson(Map<String, dynamic>.from(data['data']));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        notifyListeners();
        return {'success': true, 'message': data['message'] ?? 'Cập nhật hồ sơ thành công'};
      }

      return {'success': false, 'message': data['message'] ?? 'Cập nhật hồ sơ thất bại'};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server'};
    }
  }


  Future<Map<String, dynamic>> capNhatAvatar({
    required String filePath,
    required String fileName,
  }) async {
    if (_user == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }

    final path = filePath.trim();
    if (path.isEmpty) {
      return {'success': false, 'message': 'Không tìm thấy ảnh đã chọn'};
    }

    try {
      final formData = FormData.fromMap({
        'folder': 'avatars',
        'file': await MultipartFile.fromFile(path, filename: fileName),
      });

      final uploadResponse = await _apiService.post(
        '/upload/cloudinary_upload.php',
        data: formData,
      );

      final uploadData = _parseResponseData(uploadResponse.data);
      if (uploadData == null) {
        return {'success': false, 'message': 'Dữ liệu upload không hợp lệ'};
      }
      if (uploadData['status'] != 'success') {
        return {
          'success': false,
          'message': uploadData['message']?.toString() ?? 'Upload ảnh thất bại',
        };
      }

      final rawData = uploadData['data'];
      String avatarUrl = '';
      if (rawData is Map) {
        avatarUrl = (rawData['secure_url'] ?? rawData['duong_dan_file'] ?? '').toString();
      }
      if (avatarUrl.trim().isEmpty) {
        avatarUrl = (uploadData['duong_dan_file'] ?? '').toString();
      }
      if (avatarUrl.trim().isEmpty) {
        return {'success': false, 'message': 'Cloudinary không trả URL ảnh'};
      }

      final response = await _apiService.post(
        '/nguoi_dung/ho_so_ca_nhan.php',
        data: {
          'action': 'cap_nhat_avatar',
          'id': _user!.id,
          'avatar': avatarUrl,
        },
      );

      final data = _parseResponseData(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      if (data['status'] == 'success' && data['data'] is Map) {
        _user = NguoiDung.fromJson(Map<String, dynamic>.from(data['data']));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        notifyListeners();
        return {
          'success': true,
          'message': data['message'] ?? 'Cập nhật ảnh đại diện thành công',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Không lưu được ảnh đại diện',
      };
    } catch (e) {
      debugPrint('Update avatar error: $e');
      return {'success': false, 'message': 'Không thể upload ảnh đại diện'};
    }
  }


  Future<Map<String, dynamic>> quenMatKhauSinhVien({
    required String maSinhVien,
    required String email,
    required String cccd,
  }) async {
    final ma = maSinhVien.trim();
    final mail = email.trim();
    final soCccd = cccd.replaceAll(RegExp(r'\D'), '');

    if (ma.isEmpty) {
      return {'success': false, 'message': 'Vui lòng nhập mã sinh viên'};
    }
    if (mail.isEmpty || !mail.contains('@')) {
      return {'success': false, 'message': 'Email không hợp lệ'};
    }
    if (!RegExp(r'^\d{12}$').hasMatch(soCccd)) {
      return {'success': false, 'message': 'CCCD phải gồm đúng 12 chữ số'};
    }

    try {
      final response = await _apiService.post(
        '/nguoi_dung/quen_mat_khau_sinh_vien.php',
        data: {
          'ma_sinh_vien': ma,
          'email': mail,
          'cccd': soCccd,
        },
      );

      final data = _parseResponseData(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      return {
        'success': data['status'] == 'success',
        'message': data['message']?.toString() ??
            (data['status'] == 'success'
                ? 'Đặt lại mật khẩu thành công'
                : 'Đặt lại mật khẩu thất bại'),
      };
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return {'success': false, 'message': 'Không thể kết nối server'};
    }
  }

  Future<Map<String, dynamic>> doiMatKhau({
    required String matKhauHienTai,
    required String matKhauMoi,
    required String nhapLaiMatKhauMoi,
  }) async {
    if (_user == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }

    final current = matKhauHienTai.trim();
    final next = matKhauMoi.trim();
    final confirm = nhapLaiMatKhauMoi.trim();

    if (current.isEmpty) {
      return {'success': false, 'message': 'Vui lòng nhập mật khẩu hiện tại'};
    }
    if (next.length < 6) {
      return {'success': false, 'message': 'Mật khẩu mới phải có ít nhất 6 ký tự'};
    }
    if (next != confirm) {
      return {'success': false, 'message': 'Nhập lại mật khẩu mới không khớp'};
    }
    if (current == next) {
      return {'success': false, 'message': 'Mật khẩu mới không được trùng mật khẩu hiện tại'};
    }

    try {
      final response = await _apiService.post(
        '/nguoi_dung/ho_so_ca_nhan.php',
        data: {
          'action': 'doi_mat_khau',
          'id': _user!.id,
          'mat_khau_hien_tai': current,
          'mat_khau_moi': next,
          'nhap_lai_mat_khau_moi': confirm,
        },
      );

      final data = _parseResponseData(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      return {
        'success': data['status'] == 'success',
        'message': data['message']?.toString() ??
            (data['status'] == 'success'
                ? 'Đổi mật khẩu thành công'
                : 'Đổi mật khẩu thất bại'),
      };
    } catch (e) {
      debugPrint('Change password error: $e');
      return {'success': false, 'message': 'Không thể kết nối server'};
    }
  }

  Future<Map<String, dynamic>> doiTen(String hoTenMoi) async {
    if (_user == null) {
      return {'success': false, 'message': 'Chưa đăng nhập'};
    }

    final ten = hoTenMoi.trim();

    if (ten.isEmpty) {
      return {'success': false, 'message': 'Họ tên không được để trống'};
    }

    try {
      final response = await _apiService.post(
        '/nguoi_dung/doi_ten_nguoi_dung.php',
        data: {'id': _user!.id, 'ho_ten': ten},
      );

      final data = _parseResponseData(response.data);

      if (data == null) {
        return {'success': false, 'message': 'Dữ liệu server không hợp lệ'};
      }

      if (data['status'] == 'success') {
        _user = _user!.copyWith(hoTen: ten);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));

        notifyListeners();

        return {
          'success': true,
          'message': data['message'] ?? 'Đổi tên thành công',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Đổi tên thất bại',
      };
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server'};
    }
  }
}
