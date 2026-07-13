import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/xuat_excel_model.dart';
import 'ket_noi_api_service.dart';

class XuatExcelService {
  final ApiService _api = ApiService();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost/backend';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/backend';
    }
    return 'http://localhost/backend';
  }

  Map<String, dynamic> _body(Response response) {
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

  void _check(Map<String, dynamic> body, String fallback) {
    if (body['status']?.toString().toLowerCase() != 'success') {
      final detail = body['data'] is Map
          ? (body['data']['detail']?.toString() ?? '')
          : '';
      throw Exception(
        detail.isEmpty ? _message(body, fallback) : '${_message(body, fallback)}: $detail',
      );
    }
  }

  String _error(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;

      if (data is Map) {
        final message = data['message']?.toString() ?? '';
        final detail = data['data'] is Map
            ? data['data']['detail']?.toString() ?? ''
            : '';

        if (message.isNotEmpty && detail.isNotEmpty) {
          return '$message: $detail';
        }
        if (message.isNotEmpty) return message;
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Hết thời gian kết nối đến server';
        case DioExceptionType.sendTimeout:
          return 'Gửi yêu cầu tạo file lên server quá lâu';
        case DioExceptionType.receiveTimeout:
          return 'Server tạo file quá lâu. Hãy thử xuất ít dữ liệu hơn';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối Apache. Hãy kiểm tra Apache, URL backend và Apache error.log';
        case DioExceptionType.badResponse:
          return 'Server trả về lỗi HTTP ${response?.statusCode ?? ''}';
        case DioExceptionType.cancel:
          return 'Yêu cầu xuất file đã bị hủy';
        default:
          final message = error.message?.trim() ?? '';
          return message.isEmpty
              ? 'Không nhận được phản hồi từ server. Hãy kiểm tra Apache error.log'
              : message;
      }
    }

    var text = error.toString();
    if (text.startsWith('Exception: ')) {
      text = text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  Future<List<XuatExcelLoai>> layDanhSachLoai() async {
    try {
      final response = await _api.get('/xuat_excel/danh_sach_loai_xuat.php');
      final body = _body(response);
      _check(body, 'Không thể lấy danh sách loại xuất');
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .whereType<Map>()
          .map((e) => XuatExcelLoai.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (error) {
      throw Exception(_error(error));
    }
  }

  Future<XuatExcelDanhMuc> layDanhMuc() async {
    try {
      final response = await _api.get('/xuat_excel/danh_muc_xuat.php');
      final body = _body(response);
      _check(body, 'Không thể lấy danh mục xuất');
      return XuatExcelDanhMuc.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception(_error(error));
    }
  }

  Map<String, dynamic> _payload({
    required String loaiXuat,
    required String phamVi,
    required Map<String, dynamic> boLoc,
    required Set<String> cotXuat,
    required List<int> selectedIds,
    String? tenFile,
  }) {
    final payload = <String, dynamic>{
      'loai_xuat': loaiXuat,
      'pham_vi': phamVi,
      'bo_loc': boLoc,
      'cot_xuat': cotXuat.toList(),
      'selected_ids': selectedIds,
    };

    final fileName = tenFile?.trim() ?? '';
    if (fileName.isNotEmpty) {
      payload['ten_file'] = fileName;
    }

    return payload;
  }

  Future<XuatExcelXemTruoc> xemTruoc({
    required String loaiXuat,
    required String phamVi,
    required Map<String, dynamic> boLoc,
    required Set<String> cotXuat,
    required List<int> selectedIds,
  }) async {
    try {
      final response = await _api.post(
        '/xuat_excel/xem_truoc_xuat.php',
        data: _payload(
          loaiXuat: loaiXuat,
          phamVi: phamVi,
          boLoc: boLoc,
          cotXuat: cotXuat,
          selectedIds: selectedIds,
        ),
      );
      final body = _body(response);
      _check(body, 'Không thể xem trước dữ liệu xuất');
      return XuatExcelXemTruoc.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (error) {
      throw Exception(_error(error));
    }
  }

  Future<String> taoVaTaiFile({
    required String loaiXuat,
    required String phamVi,
    required Map<String, dynamic> boLoc,
    required Set<String> cotXuat,
    required List<int> selectedIds,
    required String tenFile,
  }) async {
    try {
      final response = await _api.post(
        '/xuat_excel/tao_file_xuat.php',
        data: _payload(
          loaiXuat: loaiXuat,
          phamVi: phamVi,
          boLoc: boLoc,
          cotXuat: cotXuat,
          selectedIds: selectedIds,
          tenFile: tenFile,
        ),
      );
      final body = _body(response);
      _check(body, 'Không thể tạo file Excel');

      final data = Map<String, dynamic>.from(body['data'] as Map);
      final downloadPath = data['download_path']?.toString() ?? '';
      final fileName = data['file_name']?.toString() ?? 'du_lieu.xlsx';
      if (downloadPath.isEmpty) {
        throw Exception('Server không trả về đường dẫn tải file');
      }

      final uri = Uri.parse('$_baseUrl$downloadPath');
      final opened = await launchUrl(
        uri,
        mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (!opened) {
        throw Exception('Không thể mở trình tải file');
      }
      return fileName;
    } catch (error) {
      throw Exception(_error(error));
    }
  }
}
