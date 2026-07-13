import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    // Chạy Flutter Web trên cùng máy với XAMPP
    if (kIsWeb) {
      return 'http://localhost/backend';
    }

    // Chạy Android Emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/backend';
    }

    // Chạy app desktop Windows hoặc nền tảng khác trên cùng máy
    return 'http://localhost/backend';
  }


  String get baseUrl => _baseUrl;

  String get origin {
    final uri = Uri.parse(_baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 600;
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('API REQUEST: ${options.method} ${options.uri}');
          debugPrint('API DATA: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('API RESPONSE: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('API ERROR: ${e.message}');
          debugPrint('API ERROR RESPONSE: ${e.response?.data}');
          handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(
      path,
      data: data,
      options: data is FormData
          ? Options(contentType: 'multipart/form-data')
          : null,
    );
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
