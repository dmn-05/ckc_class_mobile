import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../model/giang_vien_model.dart';
import '../model/sinh_vien_model.dart';
import 'ket_noi_api_service.dart';

class GiangVienService {
  final ApiService _api = ApiService();

  // ─── HELPER ──────────────────────────────────────────────
  String _fmtMysql(DateTime? dt) {
    if (dt == null) return '';

    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');

    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }


  Future<List<MultipartFile>> _taoMultipartFiles(List<PlatformFile> files) async {
    final result = <MultipartFile>[];
    for (final file in files) {
      final path = file.path?.trim() ?? '';
      if (path.isNotEmpty) {
        result.add(await MultipartFile.fromFile(path, filename: file.name));
        continue;
      }

      final bytes = file.bytes;
      if (bytes != null && bytes.isNotEmpty) {
        result.add(MultipartFile.fromBytes(bytes, filename: file.name));
        continue;
      }

      throw Exception('Không đọc được nội dung file ${file.name}');
    }
    return result;
  }

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

  bool _laThanhCong(Map<String, dynamic> body) =>
      body['status']?.toString().toLowerCase() == 'success';

  String _layThongBao(
    Map<String, dynamic> body, {
    String macDinh = 'Có lỗi xảy ra',
  }) => body['message']?.toString() ?? macDinh;

  String _xuLyLoi(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null)
        return data['message'].toString();
      if (data is String) {
        try {
          final d = jsonDecode(data);
          if (d is Map && d['message'] != null) return d['message'].toString();
        } catch (_) {}
      }
      return switch (error.type) {
        DioExceptionType.connectionTimeout => 'Kết nối server quá lâu',
        DioExceptionType.receiveTimeout => 'Server phản hồi quá lâu',
        DioExceptionType.connectionError => 'Không thể kết nối server',
        _ => error.message ?? 'Lỗi kết nối server',
      };
    }
    var msg = error.toString();
    if (msg.startsWith('Exception: '))
      msg = msg.replaceFirst('Exception: ', '');
    return msg;
  }

  // ─── LỚP HỌC PHẦN ────────────────────────────────────────
  Future<List<LopHocPhan>> layDanhSachLopHocPhan({
    required int giangVienId,
    String tuKhoa = '',
    String trangThai = '',
    String hocKy = '',
    String namHoc = '',
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/danh_sach_lop_hoc_phan.php',
        data: {
          'giang_vien_id': giangVienId,
          'tu_khoa': tuKhoa.trim(),
          'trang_thai': trangThai.trim(),
          'hoc_ky': hocKy.trim(),
          'nam_hoc': namHoc.trim(),
        },
      );
      debugPrint('===== LẤY DANH SÁCH LỚP HỌC PHẦN GIẢNG VIÊN =====');
      debugPrint(res.data.toString());
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(
          _layThongBao(body, macDinh: 'Không lấy được danh sách lớp học phần'),
        );
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => LopHocPhan.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── SINH VIÊN TRONG LỚP ─────────────────────────────────
  Future<List<SinhVienLop>> layDanhSachSinhVienLop({
    required int lopHocPhanId,
    String tuKhoa = '',
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/danh_sach_sinh_vien_lop.php',
        data: {'lop_hoc_phan_id': lopHocPhanId, 'tu_khoa': tuKhoa.trim()},
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(
          _layThongBao(body, macDinh: 'Không lấy được danh sách sinh viên'),
        );
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => SinhVienLop.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── TÀI LIỆU ────────────────────────────────────────────
  Future<List<TaiLieu>> layDanhSachTaiLieu({
    required int lopHocPhanId,
    String tuKhoa = '',
    String trangThai = '',
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/tai_lieu.php',
        data: {
          'action': 'danh_sach',
          'lop_hoc_phan_id': lopHocPhanId,
          'tu_khoa': tuKhoa.trim(),
          'trang_thai': trangThai.trim(),
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Không lấy được tài liệu'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => TaiLieu.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> themTaiLieu({
    required String tieuDe,
    required int lopHocPhanId,
    required int nguoiTaoId,
    String moTa = '',
    String duongDanFile = '',
    String trangThai = 'hien_thi',
  }) async {
    try {
      if (tieuDe.trim().isEmpty) throw Exception('Tiêu đề không được để trống');
      final res = await _api.post(
        '/giang_vien/tai_lieu.php',
        data: {
          'action': 'them',
          'tieu_de': tieuDe.trim(),
          'mo_ta': moTa.trim(),
          'duong_dan_file': duongDanFile.trim(),
          'lop_hoc_phan_id': lopHocPhanId,
          'nguoi_tao_id': nguoiTaoId,
          'trang_thai': trangThai,
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Thêm tài liệu thất bại'));
      return _layThongBao(body, macDinh: 'Thêm tài liệu thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> suaTaiLieu({
    required int id,
    required String tieuDe,
    String moTa = '',
    String duongDanFile = '',
    String trangThai = 'hien_thi',
  }) async {
    try {
      if (tieuDe.trim().isEmpty) throw Exception('Tiêu đề không được để trống');
      final res = await _api.post(
        '/giang_vien/tai_lieu.php',
        data: {
          'action': 'sua',
          'id': id,
          'tieu_de': tieuDe.trim(),
          'mo_ta': moTa.trim(),
          'duong_dan_file': duongDanFile.trim(),
          'trang_thai': trangThai,
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(
          _layThongBao(body, macDinh: 'Cập nhật tài liệu thất bại'),
        );
      return _layThongBao(body, macDinh: 'Cập nhật tài liệu thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> xoaTaiLieu(int id) async {
    try {
      final res = await _api.post(
        '/giang_vien/tai_lieu.php',
        data: {'action': 'xoa', 'id': id},
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Xóa tài liệu thất bại'));
      return _layThongBao(body, macDinh: 'Xóa tài liệu thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── BÀI TẬP ─────────────────────────────────────────────
  Future<List<BaiTap>> layDanhSachBaiTap({
    required int lopHocPhanId,
    String tuKhoa = '',
    String trangThai = '',
    List<int> chuDeIds = const [],
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/bai_tap.php',
        data: {
          'action': 'danh_sach',
          'lop_hoc_phan_id': lopHocPhanId,
          'tu_khoa': tuKhoa.trim(),
          'trang_thai': trangThai.trim(),
          'chu_de_ids': chuDeIds,
        },
      );

      final body = _layBody(res);
      if (body['status'] != 'success') {
        throw Exception(
          body['message']?.toString() ?? 'Không lấy được bài tập',
        );
      }

      final raw = body['data'];
      if (raw is! List) return [];

      return raw
          .map((e) => BaiTap.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> themBaiTap({
    required String tieuDe,
    required int lopHocPhanId,
    required int nguoiTaoId,
    int? chuDeId,
    String moTa = '',
    String duongDanFile = '',
    String fileName = '',
    DateTime? hanNop,
    bool yeuCauNopFile = true,
    String dinhDangFileChoPhep = '',
    int soFileToiDa = 1,
    int dungLuongToiDaMb = 25,
    bool choPhepNopLai = true,
    bool choPhepNopMuon = true,
    double diemToiDa = 10,
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<PlatformFile> tepTinMoi = const [],
  }) async {
    try {
      if (tieuDe.trim().isEmpty) {
        throw Exception('Tiêu đề không được để trống');
      }
      final data = {
        'action': 'them',
        'tieu_de': tieuDe.trim(),
        'mo_ta': moTa.trim(),
        'duong_dan_file': duongDanFile.trim(),
        'file_name': fileName.trim(),
        'yeu_cau_nop_file': yeuCauNopFile ? 1 : 0,
        'dinh_dang_file_cho_phep': dinhDangFileChoPhep.trim(),
        'so_file_toi_da': soFileToiDa,
        'dung_luong_toi_da_mb': dungLuongToiDaMb,
        'cho_phep_nop_lai': choPhepNopLai ? 1 : 0,
        'cho_phep_nop_muon': choPhepNopMuon ? 1 : 0,
        'diem_toi_da': diemToiDa,
        'han_nop': hanNop?.toIso8601String() ?? '',
        'lop_hoc_phan_id': lopHocPhanId,
        'nguoi_tao_id': nguoiTaoId,
        'trang_thai': trangThai,
        'chu_de_id': chuDeId,
        'thoi_gian_gui': _fmtMysql(thoiGianGui),
      };

      if (chuDeId != null && chuDeId > 0) {
        data['chu_de_id'] = chuDeId;
      }

      final formData = FormData.fromMap({
        ...data,
        if (tepTinMoi.isNotEmpty) 'files[]': await _taoMultipartFiles(tepTinMoi),
      });
      final res = await _api.post('/giang_vien/bai_tap.php', data: formData);

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Thêm bài tập thất bại'));
      }

      return _layThongBao(body, macDinh: 'Thêm bài tập thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> suaBaiTap({
    required int id,
    required String tieuDe,
    int? chuDeId,
    String moTa = '',
    String duongDanFile = '',
    String fileName = '',
    DateTime? hanNop,
    bool yeuCauNopFile = true,
    String dinhDangFileChoPhep = '',
    int soFileToiDa = 1,
    int dungLuongToiDaMb = 25,
    bool choPhepNopLai = true,
    bool choPhepNopMuon = true,
    double diemToiDa = 10,
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<PlatformFile> tepTinMoi = const [],
    List<int> tepTinXoa = const [],
    int nguoiTaoId = 0,
  }) async {
    try {
      if (tieuDe.trim().isEmpty) {
        throw Exception('Tiêu đề không được để trống');
      }

      final data = {
        'action': 'sua',
        'id': id,
        'tieu_de': tieuDe.trim(),
        'mo_ta': moTa.trim(),
        'duong_dan_file': duongDanFile.trim(),
        'file_name': fileName.trim(),
        'yeu_cau_nop_file': yeuCauNopFile ? 1 : 0,
        'dinh_dang_file_cho_phep': dinhDangFileChoPhep.trim(),
        'so_file_toi_da': soFileToiDa,
        'dung_luong_toi_da_mb': dungLuongToiDaMb,
        'cho_phep_nop_lai': choPhepNopLai ? 1 : 0,
        'cho_phep_nop_muon': choPhepNopMuon ? 1 : 0,
        'diem_toi_da': diemToiDa,
        'han_nop': hanNop?.toIso8601String() ?? '',
        'trang_thai': trangThai,
        'chu_de_id': chuDeId ?? 0,
        'thoi_gian_gui': _fmtMysql(thoiGianGui),
        'nguoi_tao_id': nguoiTaoId,
        'xoa_tep_tin_ids': jsonEncode(tepTinXoa),
      };
      if (chuDeId != null && chuDeId > 0) {
        data['chu_de_id'] = chuDeId;
      }

      final formData = FormData.fromMap({
        ...data,
        if (tepTinMoi.isNotEmpty) 'files[]': await _taoMultipartFiles(tepTinMoi),
      });
      final res = await _api.post('/giang_vien/bai_tap.php', data: formData);

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Cập nhật bài tập thất bại'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật bài tập thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> xoaBaiTap(int id) async {
    try {
      final res = await _api.post(
        '/giang_vien/bai_tap.php',
        data: {'action': 'xoa', 'id': id},
      );

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Xóa bài tập thất bại'));
      }

      return _layThongBao(body, macDinh: 'Xóa bài tập thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<List<ChuDe>> layDanhSachChuDe(int lopHocPhanId) async {
    final res = await _api.post(
      '/chu_de/quan_ly_chu_de.php',
      data: {'action': 'danh_sach', 'lop_hoc_phan_id': lopHocPhanId},
    );

    final body = _layBody(res);

    if (!_laThanhCong(body)) {
      throw Exception(_layThongBao(body, macDinh: 'Không lấy được chủ đề'));
    }

    final raw = body['data'];
    if (raw is! List) return [];

    return raw
        .map((e) => ChuDe.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── CHỦ ĐỀ ─────────────────────────────────────────────

  Future<String> themChuDe({
    required int lopHocPhanId,
    required String tenChuDe,
  }) async {
    try {
      if (tenChuDe.trim().isEmpty) {
        throw Exception('Tên chủ đề không được để trống');
      }

      final res = await _api.post(
        '/chu_de/quan_ly_chu_de.php',
        data: {
          'action': 'them',
          'lop_hoc_phan_id': lopHocPhanId,
          'ten_chu_de': tenChuDe.trim(),
        },
      );

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Thêm chủ đề thất bại'));
      }

      return _layThongBao(body, macDinh: 'Thêm chủ đề thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> suaChuDe({
    required int chuDeId,
    required String tenChuDe,
  }) async {
    try {
      if (tenChuDe.trim().isEmpty) {
        throw Exception('Tên chủ đề không được để trống');
      }

      final res = await _api.post(
        '/chu_de/quan_ly_chu_de.php',
        data: {
          'action': 'sua',
          'chu_de_id': chuDeId,
          'ten_chu_de': tenChuDe.trim(),
        },
      );

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Cập nhật chủ đề thất bại'),
        );
      }

      return _layThongBao(body, macDinh: 'Cập nhật chủ đề thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> xoaChuDe(int chuDeId) async {
    try {
      final res = await _api.post(
        '/chu_de/quan_ly_chu_de.php',
        data: {'action': 'xoa', 'chu_de_id': chuDeId},
      );

      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(_layThongBao(body, macDinh: 'Xóa chủ đề thất bại'));
      }

      return _layThongBao(body, macDinh: 'Xóa chủ đề thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── BÀI NỘP ─────────────────────────────────────────────
  Future<List<BaiNop>> layDanhSachBaiNop({
    required int baiTapId,
    String trangThai = '',
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/bai_nop.php',
        data: {
          'action': 'danh_sach',
          'bai_tap_id': baiTapId,
          'trang_thai': trangThai.trim(),
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Không lấy được bài nộp'));
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => BaiNop.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> chamDiem({
    required int baiNopId,
    required int giangVienChamId,
    double? diem,
    String nhanXet = '',
  }) async {
    try {
      if (diem != null && diem < 0) {
        throw Exception('Điểm không được nhỏ hơn 0');
      }
      final res = await _api.post(
        '/giang_vien/bai_nop.php',
        data: {
          'action': 'cham_diem',
          'id': baiNopId,
          'diem': diem,
          'nhan_xet': nhanXet.trim(),
          'giang_vien_cham_id': giangVienChamId,
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Chấm điểm thất bại'));
      return _layThongBao(body, macDinh: 'Chấm điểm thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── THÔNG BÁO ────────────────────────────────────────────
  Future<List<ThongBao>> layDanhSachThongBao({
    required int lopHocPhanId,
    String trangThai = '',
  }) async {
    try {
      final res = await _api.post(
        '/giang_vien/thong_bao.php',
        data: {
          'action': 'danh_sach',
          'lop_hoc_phan_id': lopHocPhanId,
          'trang_thai': trangThai.trim(),
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(
          _layThongBao(body, macDinh: 'Không lấy được thông báo'),
        );
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => ThongBao.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> themThongBao({
    required String tieuDe,
    required int lopHocPhanId,
    required int nguoiTaoId,
    String noiDung = '',
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<PlatformFile> tepTinMoi = const [],
  }) async {
    try {
      if (tieuDe.trim().isEmpty) throw Exception('Tiêu đề không được để trống');
      final formData = FormData.fromMap({
          'action': 'them',
          'tieu_de': tieuDe.trim(),
          'noi_dung': noiDung.trim(),
          'lop_hoc_phan_id': lopHocPhanId,
          'nguoi_tao_id': nguoiTaoId,
          'trang_thai': trangThai,
          'thoi_gian_gui': _fmtMysql(thoiGianGui),
          if (tepTinMoi.isNotEmpty) 'files[]': await _taoMultipartFiles(tepTinMoi),
      });
      final res = await _api.post('/giang_vien/thong_bao.php', data: formData);
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Đăng thông báo thất bại'));
      return _layThongBao(body, macDinh: 'Đăng thông báo thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> suaThongBao({
    required int id,
    required String tieuDe,
    String noiDung = '',
    String trangThai = 'hien_thi',
    DateTime? thoiGianGui,
    List<PlatformFile> tepTinMoi = const [],
    List<int> tepTinXoa = const [],
    int nguoiTaoId = 0,
  }) async {
    try {
      if (tieuDe.trim().isEmpty) throw Exception('Tiêu đề không được để trống');
      final formData = FormData.fromMap({
          'action': 'sua',
          'id': id,
          'tieu_de': tieuDe.trim(),
          'noi_dung': noiDung.trim(),
          'trang_thai': trangThai,
          'thoi_gian_gui': _fmtMysql(thoiGianGui),
          'nguoi_tao_id': nguoiTaoId,
          'xoa_tep_tin_ids': jsonEncode(tepTinXoa),
          if (tepTinMoi.isNotEmpty) 'files[]': await _taoMultipartFiles(tepTinMoi),
      });
      final res = await _api.post('/giang_vien/thong_bao.php', data: formData);
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(
          _layThongBao(body, macDinh: 'Cập nhật thông báo thất bại'),
        );
      return _layThongBao(body, macDinh: 'Cập nhật thông báo thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<String> xoaThongBao(int id) async {
    try {
      final res = await _api.post(
        '/giang_vien/thong_bao.php',
        data: {'action': 'xoa', 'id': id},
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Xóa thông báo thất bại'));
      return _layThongBao(body, macDinh: 'Xóa thông báo thành công');
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }


  Future<List<BinhLuanModel>> layDanhSachBinhLuanThongBao(
    int baiVietId,
  ) async {
    try {
      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'danh_sach',
          'bai_viet_id': baiVietId,
          'nguoi_dung_id': 0,
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Không lấy được bình luận thông báo'),
        );
      }
      final raw = body['data'];
      if (raw is! List) return [];
      return raw
          .map((e) => BinhLuanModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  Future<BinhLuanModel> dangBinhLuanThongBao({
    required int nguoiDungId,
    required int baiVietId,
    required String noiDung,
  }) async {
    try {
      final text = noiDung.trim();
      if (text.isEmpty) throw Exception('Nội dung bình luận không được trống');

      final res = await _api.post(
        '/sinh_vien/binh_luan.php',
        data: {
          'action': 'dang',
          'nguoi_dung_id': nguoiDungId,
          'bai_viet_id': baiVietId,
          'noi_dung': text,
        },
      );
      final body = _layBody(res);
      if (!_laThanhCong(body)) {
        throw Exception(
          _layThongBao(body, macDinh: 'Đăng bình luận thất bại'),
        );
      }
      return BinhLuanModel.fromJson(
        Map<String, dynamic>.from(body['data'] ?? const {}),
      );
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ─── THỐNG KÊ ─────────────────────────────────────────────
  Future<ThongKeGiangVien> layThongKe(int giangVienId) async {
    try {
      final res = await _api.post(
        '/giang_vien/thong_ke.php',
        data: {'giang_vien_id': giangVienId},
      );
      final body = _layBody(res);
      if (!_laThanhCong(body))
        throw Exception(_layThongBao(body, macDinh: 'Không lấy được thống kê'));
      return ThongKeGiangVien.fromJson(
        Map<String, dynamic>.from(body['data'] ?? {}),
      );
    } catch (e) {
      throw Exception(_xuLyLoi(e));
    }
  }

  // ✅ THÊM: lấy giang_vien_id từ nguoi_dung_id
  Future<Map<String, dynamic>> layThongTinGiangVienTheoNguoiDung(
    int nguoiDungId,
  ) async {
    final res = await _api.post(
      '/giang_vien/thong_tin_giang_vien.php',
      data: {'nguoi_dung_id': nguoiDungId},
    );

    final body = _layBody(res);

    if (!_laThanhCong(body)) {
      throw Exception(
        _layThongBao(body, macDinh: 'Không lấy được thông tin giảng viên'),
      );
    }

    return Map<String, dynamic>.from(body['data'] ?? {});
  }

  Future<List<MonHocGV>> layDanhSachMonHoc() async {
    final response = await _api.post(
      '/mon_hoc/danh_sach_mon_hoc.php',
      data: {'trang_thai': 'dang_mo'},
    );

    final data = response.data;

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Không lấy được danh sách môn học');
    }

    return (data['data'] as List)
        .map((e) => MonHocGV.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> taoLopHocPhan({
    required int giangVienId,
    required String maLopHocPhan,
    required String tenLop,
    required int monHocId,
    required String hocKy,
    required String namHoc,
    int? siSoToiDa,
  }) async {
    final response = await _api.post(
      '/giang_vien/tao_lop_hoc_phan.php',
      data: {
        'giang_vien_id': giangVienId,
        'ma_lop_hoc_phan': maLopHocPhan,
        'ten_lop': tenLop,
        'mon_hoc_id': monHocId,
        'hoc_ky': hocKy,
        'nam_hoc': namHoc,
        'si_so_toi_da': siSoToiDa,
      },
    );

    final data = response.data;

    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Tạo lớp học phần thất bại');
    }

    return data['message'] ?? 'Tạo lớp học phần thành công';
  }
}
