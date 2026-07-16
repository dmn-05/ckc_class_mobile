import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ket_noi_api_service.dart';

String tenFileHienThi({String? tenFile, String? duongDan}) {
  final provided = tenFile?.trim() ?? '';
  if (provided.isNotEmpty) return provided;

  final raw = duongDan?.trim() ?? '';
  if (raw.isEmpty) return 'File đính kèm';

  final uri = Uri.tryParse(raw);
  final path = uri?.path.isNotEmpty == true ? uri!.path : raw;
  final normalized = path.replaceAll('\\', '/');
  final last = normalized.split('/').last.trim();
  return last.isEmpty ? 'File đính kèm' : Uri.decodeComponent(last);
}

String _base64UrlNoPadding(String value) {
  return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}

Uri? taoUriTaiFile({required String duongDan, required String tenFile}) {
  final path = duongDan.trim();
  if (path.isEmpty) return null;

  final base = ApiService().baseUrl.replaceFirst(RegExp(r'/+$'), '');
  return Uri.tryParse(
    '$base/upload/tai_file.php'
    '?u=${Uri.encodeQueryComponent(_base64UrlNoPadding(path))}'
    '&f=${Uri.encodeQueryComponent(_base64UrlNoPadding(tenFileHienThi(tenFile: tenFile, duongDan: path)))}',
  );
}

Future<bool> taiFileVeMay(
  BuildContext context, {
  required String duongDan,
  String? tenFile,
}) async {
  final displayName = tenFileHienThi(tenFile: tenFile, duongDan: duongDan);
  final uri = taoUriTaiFile(duongDan: duongDan, tenFile: displayName);

  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có đường dẫn file để tải')),
    );
    return false;
  }

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải file $displayName')),
      );
    }
    return opened;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải file: $e')),
      );
    }
    return false;
  }
}
