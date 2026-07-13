import 'dart:convert';
import 'package:dio/dio.dart';

import '../model/bao_cao_thong_ke_model.dart';
import 'ket_noi_api_service.dart';

class BaoCaoThongKeService {
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

  Future<BaoCaoThongKeAdmin> layBaoCaoThongKe() async {
    try {
      final response = await _apiService.post('/bao_cao/thong_ke_admin.php');
      final body = _layBody(response);

      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Không thể lấy báo cáo thống kê'));
      }

      return BaoCaoThongKeAdmin.fromJson(body);
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }
}
