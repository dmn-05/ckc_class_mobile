import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:url_launcher/url_launcher.dart';

import '../model/nhap_excel_model.dart';
import 'ket_noi_api_service.dart';

class NhapExcelService {
  final ApiService _apiService = ApiService();

  String get _apiBaseUrl => _apiService.baseUrl;

  static const List<NhapExcelLoai> loaiNhapList = [
    NhapExcelLoai(
      ma: 'khoa',
      ten: 'Khoa',
      templateFile: 'mau_nhap_khoa.xlsx',
      moTa: 'Nhập danh sách khoa mới vào hệ thống.',
      headers: ['Mã khoa', 'Tên khoa', 'Trạng thái'],
      headerMap: {
        'Mã khoa': 'ma_khoa',
        'Tên khoa': 'ten_khoa',
        'Trạng thái': 'trang_thai',
      },
    ),
    NhapExcelLoai(
      ma: 'bo_mon',
      ten: 'Bộ môn',
      templateFile: 'mau_nhap_bo_mon.xlsx',
      moTa: 'Nhập bộ môn theo mã khoa đã có.',
      headers: ['Mã bộ môn', 'Tên bộ môn', 'Mã khoa', 'Trạng thái'],
      headerMap: {
        'Mã bộ môn': 'ma_bo_mon',
        'Tên bộ môn': 'ten_bo_mon',
        'Mã khoa': 'ma_khoa',
        'Trạng thái': 'trang_thai',
      },
    ),
    NhapExcelLoai(
      ma: 'mon_hoc',
      ten: 'Môn học',
      templateFile: 'mau_nhap_mon_hoc.xlsx',
      moTa: 'Nhập môn học theo mã khoa và mã bộ môn.',
      headers: [
        'Mã môn học',
        'Tên môn học',
        'Số tín chỉ',
        'Mã khoa',
        'Mã bộ môn',
        'Trạng thái',
      ],
      headerMap: {
        'Mã môn học': 'ma_mon',
        'Tên môn học': 'ten_mon',
        'Số tín chỉ': 'tin_chi',
        'Mã khoa': 'ma_khoa',
        'Mã bộ môn': 'ma_bo_mon',
        'Trạng thái': 'trang_thai',
      },
    ),
    NhapExcelLoai(
      ma: 'lop_hanh_chinh',
      ten: 'Lớp hành chính',
      templateFile: 'mau_nhap_lop_hanh_chinh.xlsx',
      moTa: 'Nhập lớp hành chính theo mã khoa và năm nhập học.',
      headers: ['Mã lớp', 'Tên lớp', 'Mã khoa', 'Năm nhập học', 'Trạng thái'],
      headerMap: {
        'Mã lớp': 'ma_lop',
        'Tên lớp': 'ten_lop',
        'Mã khoa': 'ma_khoa',
        'Năm nhập học': 'nam_nhap_hoc',
        'Trạng thái': 'trang_thai',
      },
    ),
    NhapExcelLoai(
      ma: 'sinh_vien',
      ten: 'Sinh viên',
      templateFile: 'mau_nhap_sinh_vien.xlsx',
      moTa:
          'Tạo tài khoản và hồ sơ sinh viên. Chỉ nhập Mã lớp; hệ thống tự lấy Khoa và khóa sinh viên từ năm nhập học của lớp. Tài khoản mặc định Đang hoạt động.',
      headers: [
        'Mã sinh viên',
        'Họ tên',
        'Email',
        'Mật khẩu',
        'Mã lớp',
        'Ngày sinh',
        'Giới tính',
        'Số điện thoại',
        'CCCD',
        'Địa chỉ',
        'Trạng thái sinh viên',
      ],
      headerMap: {
        'Mã sinh viên': 'ma_sinh_vien',
        'Họ tên': 'ho_ten',
        'Email': 'email',
        'Mật khẩu': 'mat_khau',
        'Mã lớp': 'ma_lop',
        'Ngày sinh': 'ngay_sinh',
        'Giới tính': 'gioi_tinh',
        'Số điện thoại': 'so_dien_thoai',
        'CCCD': 'cccd',
        'Địa chỉ': 'dia_chi',
        'Trạng thái sinh viên': 'trang_thai_sinh_vien',
      },
    ),
    NhapExcelLoai(
      ma: 'sinh_vien_theo_lop',
      ten: 'Sinh viên theo lớp hành chính',
      templateFile: 'mau_nhap_sinh_vien_theo_lop.xlsx',
      moTa:
          'Mỗi dòng sinh viên phải có Mã lớp. Hệ thống tự tìm lớp trùng mã, lấy Khoa và khóa sinh viên từ năm nhập học của lớp. Có thể nhập nhiều lớp trong cùng một file.',
      headers: [
        'Mã sinh viên',
        'Họ tên',
        'Email',
        'Mật khẩu',
        'Mã lớp',
        'Ngày sinh',
        'Giới tính',
        'Số điện thoại',
        'CCCD',
        'Địa chỉ',
        'Trạng thái sinh viên',
      ],
      headerMap: {
        'Mã sinh viên': 'ma_sinh_vien',
        'Họ tên': 'ho_ten',
        'Email': 'email',
        'Mật khẩu': 'mat_khau',
        'Mã lớp': 'ma_lop',
        'Ngày sinh': 'ngay_sinh',
        'Giới tính': 'gioi_tinh',
        'Số điện thoại': 'so_dien_thoai',
        'CCCD': 'cccd',
        'Địa chỉ': 'dia_chi',
        'Trạng thái sinh viên': 'trang_thai_sinh_vien',
      },
    ),
    NhapExcelLoai(
      ma: 'giang_vien',
      ten: 'Giảng viên',
      templateFile: 'mau_nhap_giang_vien.xlsx',
      moTa: 'Tạo tài khoản và hồ sơ giảng viên theo mã bộ môn.',
      headers: [
        'Mã giảng viên',
        'Họ tên',
        'Email',
        'Mật khẩu',
        'Mã bộ môn',
        'Ngày sinh',
        'Giới tính',
        'Số điện thoại',
        'CCCD',
        'Địa chỉ',
        'Trạng thái giảng viên',
        'Trạng thái tài khoản',
      ],
      headerMap: {
        'Mã giảng viên': 'ma_giang_vien',
        'Họ tên': 'ho_ten',
        'Email': 'email',
        'Mật khẩu': 'mat_khau',
        'Mã bộ môn': 'ma_bo_mon',
        'Ngày sinh': 'ngay_sinh',
        'Giới tính': 'gioi_tinh',
        'Số điện thoại': 'so_dien_thoai',
        'CCCD': 'cccd',
        'Địa chỉ': 'dia_chi',
        'Trạng thái giảng viên': 'trang_thai_giang_vien',
        'Trạng thái tài khoản': 'trang_thai_tai_khoan',
      },
    ),
    NhapExcelLoai(
      ma: 'lop_hoc_phan',
      ten: 'Lớp học phần',
      templateFile: 'mau_nhap_lop_hoc_phan.xlsx',
      moTa:
          'Nhập lớp học phần theo mã môn học, mã giảng viên, năm học và học kỳ.',
      headers: [
        'Mã lớp học phần',
        'Tên lớp học phần',
        'Mã môn học',
        'Mã giảng viên',
        'Năm học',
        'Học kỳ',
        'Sĩ số tối đa',
        'Trạng thái',
      ],
      headerMap: {
        'Mã lớp học phần': 'ma_lop_hoc_phan',
        'Tên lớp học phần': 'ten_lop',
        'Mã môn học': 'ma_mon',
        'Mã giảng viên': 'ma_giang_vien',
        'Năm học': 'nam_hoc',
        'Học kỳ': 'hoc_ky',
        'Sĩ số tối đa': 'si_so_toi_da',
        'Trạng thái': 'trang_thai',
      },
    ),
  ];

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

  String _xuLyLoi(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null)
        return data['message'].toString();
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map && decoded['message'] != null)
            return decoded['message'].toString();
        } catch (_) {}
      }
      return error.message ?? 'Lỗi kết nối server';
    }
    var message = error.toString();
    if (message.startsWith('Exception: '))
      message = message.replaceFirst('Exception: ', '');
    return message;
  }

  NhapExcelLoai loaiTheoMa(String ma) => loaiNhapList.firstWhere(
    (e) => e.ma == ma,
    orElse: () => loaiNhapList.first,
  );

  Future<void> taiFileMau(NhapExcelLoai loai) async {
    final url = Uri.parse(
      '$_apiBaseUrl/nhap_excel/tai_mau_excel.php?loai_nhap=${Uri.encodeComponent(loai.ma)}',
    );
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('Không thể mở link tải file mẫu');
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _textSpanToString(ex.TextSpan span) {
    final buffer = StringBuffer(span.text ?? '');
    final children = span.children;
    if (children != null) {
      for (final child in children) {
        buffer.write(_textSpanToString(child));
      }
    }
    return buffer.toString();
  }

  String _cellText(dynamic cell) {
    final value = cell?.value;
    if (value == null) return '';

    if (value is ex.TextCellValue) {
      return _textSpanToString(value.value).trim();
    }
    if (value is ex.IntCellValue) {
      return value.value.toString();
    }
    if (value is ex.DoubleCellValue) {
      final number = value.value;
      if (number.isFinite && number == number.truncateToDouble()) {
        return number.toInt().toString();
      }
      return number.toString();
    }
    if (value is ex.DateCellValue) {
      return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year}';
    }
    if (value is ex.DateTimeCellValue) {
      return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year}';
    }
    if (value is ex.BoolCellValue) {
      return value.value ? '1' : '0';
    }
    if (value is ex.TimeCellValue) {
      return '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}:${_twoDigits(value.second)}';
    }
    if (value is ex.FormulaCellValue) {
      return value.formula.trim();
    }

    return value.toString().trim();
  }

  String _normalizeHeader(String value) => value
      .replaceAll('\uFEFF', '')
      .replaceAll('\u00A0', ' ')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  ({int rowIndex, bool hasStt}) _timDongHeader(
    List<List<dynamic>> rows,
    NhapExcelLoai loai,
  ) {
    for (var r = 0; r < rows.length && r < 12; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;
      final first = row.isNotEmpty ? _normalizeHeader(_cellText(row[0])) : '';
      final hasStt = first == 'stt';
      final offset = hasStt ? 1 : 0;
      var match = true;
      for (var i = 0; i < loai.headers.length; i++) {
        final actual = i + offset < row.length
            ? _cellText(row[i + offset])
            : '';
        if (_normalizeHeader(actual) != _normalizeHeader(loai.headers[i])) {
          match = false;
          break;
        }
      }
      if (match) return (rowIndex: r, hasStt: hasStt);
    }
    throw Exception(
      'File Excel không đúng mẫu cho chức năng "${loai.ten}". Không tìm thấy dòng tiêu đề cột đúng trong sheet Dữ liệu. Hãy tải đúng file mẫu rồi nhập lại.',
    );
  }

  Future<({String fileName, List<Map<String, dynamic>> rows})> chonVaDocExcel(
    NhapExcelLoai loai,
  ) async {
    final fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('Chưa chọn file Excel');
    }

    final fp.PlatformFile file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw Exception(
        'Không đọc được nội dung file Excel. Hãy chọn file .xlsx và thử lại.',
      );
    }

    ex.Excel workbook;
    try {
      workbook = ex.Excel.decodeBytes(bytes);
    } catch (_) {
      throw Exception(
        'Không thể đọc file Excel. File phải đúng định dạng .xlsx và không bị hỏng hoặc đặt mật khẩu.',
      );
    }

    ex.Sheet? sheet;
    for (final entry in workbook.tables.entries) {
      if (_normalizeHeader(entry.key) == _normalizeHeader('Dữ liệu')) {
        sheet = entry.value;
        break;
      }
    }
    sheet ??= workbook.tables.values.firstOrNull;

    if (sheet == null) {
      throw Exception('File Excel không có sheet Dữ liệu');
    }

    final rawRows = sheet.rows;

    if (rawRows.isEmpty) {
      throw Exception('Sheet Dữ liệu đang trống');
    }

    final header = _timDongHeader(rawRows, loai);
    final offset = header.hasStt ? 1 : 0;
    final parsedRows = <Map<String, dynamic>>[];

    for (var r = header.rowIndex + 1; r < rawRows.length; r++) {
      final row = rawRows[r];
      final item = <String, dynamic>{'_dong_excel': r + 1};
      var empty = true;

      for (var c = 0; c < loai.headers.length; c++) {
        final headerName = loai.headers[c];
        final key = loai.headerMap[headerName]!;
        final value = c + offset < row.length ? _cellText(row[c + offset]) : '';

        if (value.trim().isNotEmpty) {
          empty = false;
        }

        item[key] = value;
      }

      if (!empty) {
        parsedRows.add(item);
      }
    }

    if (parsedRows.isEmpty) {
      throw Exception(
        'File Excel chưa có dòng dữ liệu nào. Hãy nhập dữ liệu từ dòng dưới tiêu đề cột.',
      );
    }

    return (fileName: file.name, rows: parsedRows);
  }

  Future<NhapExcelKetQuaKiemTra> kiemTraExcel({
    required String loaiNhap,
    required String tenFile,
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic> doiTuongDich = const {},
    int nguoiNhapId = 1,
  }) async {
    try {
      final response = await _apiService.post(
        '/nhap_excel/kiem_tra_json.php',
        data: {
          'loai_nhap': loaiNhap,
          'ten_file': tenFile,
          'nguoi_nhap_id': nguoiNhapId,
          'doi_tuong_dich': doiTuongDich,
          'rows': rows,
        },
      );
      final body = _layBody(response);
      if (body['status']?.toString().toLowerCase() != 'success')
        throw Exception(
          body['message']?.toString() ?? 'Không thể kiểm tra Excel',
        );
      return NhapExcelKetQuaKiemTra.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<NhapExcelXacNhanKetQua> xacNhanNhapExcel({
    required String loaiNhap,
    required String tenFile,
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic> doiTuongDich = const {},
    int nguoiNhapId = 1,
  }) async {
    try {
      final response = await _apiService.post(
        '/nhap_excel/xac_nhan_nhap_excel.php',
        data: {
          'loai_nhap': loaiNhap,
          'ten_file': tenFile,
          'nguoi_nhap_id': nguoiNhapId,
          'doi_tuong_dich': doiTuongDich,
          'rows': rows,
        },
      );

      final body = _layBody(response);

      if (body['status']?.toString().toLowerCase() != 'success') {
        throw Exception(
          body['message']?.toString() ?? 'Không thể nhập Excel',
        );
      }

      return NhapExcelXacNhanKetQua.fromJson(
        Map<String, dynamic>.from(body['data']),
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }


  Future<NhapExcelDanhSachLichSu> layLichSuNhapExcel({
    String tuKhoa = '',
    String loaiNhap = '',
    DateTime? tuNgay,
    DateTime? denNgay,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.post(
        '/nhap_excel/lich_su_nhap_excel.php',
        data: {
          'tu_khoa': tuKhoa.trim(),
          'loai_nhap': loaiNhap.trim(),
          'tu_ngay': tuNgay == null ? '' : _formatApiDate(tuNgay),
          'den_ngay': denNgay == null ? '' : _formatApiDate(denNgay),
          'page': page,
          'limit': limit,
        },
      );

      final body = _layBody(response);
      if (body['status']?.toString().toLowerCase() != 'success') {
        throw Exception(
          body['message']?.toString() ?? 'Không thể lấy lịch sử nhập Excel',
        );
      }

      final rawData = body['data'];
      if (rawData is! Map) {
        throw Exception('Dữ liệu lịch sử nhập Excel không hợp lệ');
      }

      return NhapExcelDanhSachLichSu.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  Future<NhapExcelChiTietLichSu> layChiTietLichSuNhapExcel(
    int dotNhapId,
  ) async {
    if (dotNhapId <= 0) {
      throw Exception('ID đợt nhập Excel không hợp lệ');
    }

    try {
      final response = await _apiService.post(
        '/nhap_excel/chi_tiet_nhap_excel.php',
        data: {'dot_nhap_id': dotNhapId},
      );

      final body = _layBody(response);
      if (body['status']?.toString().toLowerCase() != 'success') {
        throw Exception(
          body['message']?.toString() ??
              'Không thể lấy chi tiết lịch sử nhập Excel',
        );
      }

      final rawData = body['data'];
      if (rawData is! Map) {
        throw Exception('Dữ liệu chi tiết nhập Excel không hợp lệ');
      }

      return NhapExcelChiTietLichSu.fromJson(
        Map<String, dynamic>.from(rawData),
      );
    } catch (error) {
      throw Exception(_xuLyLoi(error));
    }
  }

  String _formatApiDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
