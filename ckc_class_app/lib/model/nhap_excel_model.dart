class NhapExcelLoai {
  final String ma;
  final String ten;
  final String templateFile;
  final List<String> headers;
  final Map<String, String> headerMap;
  final bool canDoiTuongDich;
  final String? labelDoiTuongDich;
  final String? keyDoiTuongDich;
  final String moTa;

  const NhapExcelLoai({
    required this.ma,
    required this.ten,
    required this.templateFile,
    required this.headers,
    required this.headerMap,
    this.canDoiTuongDich = false,
    this.labelDoiTuongDich,
    this.keyDoiTuongDich,
    this.moTa = '',
  });
}

class NhapExcelDongKetQua {
  final int soDong;
  final Map<String, dynamic> duLieu;
  final String trangThai;
  final String hanhDong;
  final String thongBao;

  const NhapExcelDongKetQua({
    required this.soDong,
    required this.duLieu,
    required this.trangThai,
    required this.hanhDong,
    required this.thongBao,
  });

  factory NhapExcelDongKetQua.fromJson(Map<String, dynamic> json) {
    return NhapExcelDongKetQua(
      soDong: int.tryParse(json['so_dong']?.toString() ?? '') ?? 0,
      duLieu: json['du_lieu'] is Map
          ? Map<String, dynamic>.from(json['du_lieu'])
          : <String, dynamic>{},
      trangThai: json['trang_thai']?.toString() ?? '',
      hanhDong: json['hanh_dong']?.toString() ?? '',
      thongBao: json['thong_bao']?.toString() ?? '',
    );
  }

  String get trangThaiHienThi {
    switch (trangThai) {
      case 'hop_le':
        return 'Hợp lệ';
      case 'canh_bao':
        return 'Cảnh báo';
      case 'loi':
        return 'Lỗi';
      default:
        return trangThai;
    }
  }

  String get hanhDongHienThi {
    switch (hanhDong) {
      case 'them_moi':
        return 'Thêm mới';
      case 'bo_qua':
        return 'Bỏ qua';
      case 'kich_hoat_lai':
        return 'Kích hoạt lại';
      default:
        return hanhDong;
    }
  }
}

class NhapExcelKetQuaKiemTra {
  final int dotNhapId;
  final int tongDong;
  final int soHopLe;
  final int soLoi;
  final int soCanhBao;
  final bool coTheXacNhan;
  final List<NhapExcelDongKetQua> ketQuaDong;

  const NhapExcelKetQuaKiemTra({
    required this.dotNhapId,
    required this.tongDong,
    required this.soHopLe,
    required this.soLoi,
    required this.soCanhBao,
    required this.coTheXacNhan,
    required this.ketQuaDong,
  });

  factory NhapExcelKetQuaKiemTra.fromJson(Map<String, dynamic> json) {
    final rawRows = json['ket_qua_dong'];
    return NhapExcelKetQuaKiemTra(
      dotNhapId: int.tryParse(json['dot_nhap_id']?.toString() ?? '') ?? 0,
      tongDong: int.tryParse(json['tong_dong']?.toString() ?? '') ?? 0,
      soHopLe: int.tryParse(json['so_hop_le']?.toString() ?? '') ?? 0,
      soLoi: int.tryParse(json['so_loi']?.toString() ?? '') ?? 0,
      soCanhBao: int.tryParse(json['so_canh_bao']?.toString() ?? '') ?? 0,
      coTheXacNhan: json['co_the_xac_nhan'] == true,
      ketQuaDong: rawRows is List
          ? rawRows
                .map(
                  (e) => NhapExcelDongKetQua.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : <NhapExcelDongKetQua>[],
    );
  }
}

class NhapExcelXacNhanKetQua {
  final int dotNhapId;
  final int daThemMoi;
  final int daKichHoatLai;
  final int boQua;

  const NhapExcelXacNhanKetQua({
    required this.dotNhapId,
    required this.daThemMoi,
    required this.daKichHoatLai,
    required this.boQua,
  });

  factory NhapExcelXacNhanKetQua.fromJson(Map<String, dynamic> json) {
    return NhapExcelXacNhanKetQua(
      dotNhapId: int.tryParse(json['dot_nhap_id']?.toString() ?? '') ?? 0,
      daThemMoi: int.tryParse(json['da_them_moi']?.toString() ?? '') ?? 0,
      daKichHoatLai:
          int.tryParse(json['da_kich_hoat_lai']?.toString() ?? '') ?? 0,
      boQua: int.tryParse(json['bo_qua']?.toString() ?? '') ?? 0,
    );
  }
}

int _nhapExcelToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

DateTime? _nhapExcelToDateTime(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return DateTime.tryParse(text);
}

class NhapExcelLichSu {
  final int id;
  final String loaiNhap;
  final String tenFile;
  final int? nguoiNhapId;
  final String? tenNguoiNhap;
  final int tongDong;
  final int soHopLe;
  final int soLoi;
  final int soCanhBao;
  final String trangThai;
  final DateTime? ngayTao;
  final DateTime? ngayCapNhat;

  const NhapExcelLichSu({
    required this.id,
    required this.loaiNhap,
    required this.tenFile,
    this.nguoiNhapId,
    this.tenNguoiNhap,
    required this.tongDong,
    required this.soHopLe,
    required this.soLoi,
    required this.soCanhBao,
    required this.trangThai,
    this.ngayTao,
    this.ngayCapNhat,
  });

  factory NhapExcelLichSu.fromJson(Map<String, dynamic> json) {
    final nguoiNhapRaw = json['nguoi_nhap_id'];
    return NhapExcelLichSu(
      id: _nhapExcelToInt(json['id']),
      loaiNhap: json['loai_nhap']?.toString() ?? '',
      tenFile: json['ten_file']?.toString() ?? '',
      nguoiNhapId: nguoiNhapRaw == null
          ? null
          : int.tryParse(nguoiNhapRaw.toString()),
      tenNguoiNhap: json['ten_nguoi_nhap']?.toString(),
      tongDong: _nhapExcelToInt(json['tong_dong']),
      soHopLe: _nhapExcelToInt(json['so_hop_le']),
      soLoi: _nhapExcelToInt(json['so_loi']),
      soCanhBao: _nhapExcelToInt(json['so_canh_bao']),
      trangThai: json['trang_thai']?.toString() ?? '',
      ngayTao: _nhapExcelToDateTime(json['ngay_tao']),
      ngayCapNhat: _nhapExcelToDateTime(json['ngay_cap_nhat']),
    );
  }

  String get trangThaiHienThi {
    switch (trangThai) {
      case 'cho_xac_nhan':
        return 'Chờ xác nhận';
      case 'da_nhap':
        return 'Đã nhập';
      case 'that_bai':
        return 'Thất bại';
      case 'da_huy':
        return 'Đã hủy';
      default:
        return trangThai;
    }
  }
}

class NhapExcelDanhSachLichSu {
  final List<NhapExcelLichSu> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const NhapExcelDanhSachLichSu({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NhapExcelDanhSachLichSu.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final pagination = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'] as Map)
        : <String, dynamic>{};

    return NhapExcelDanhSachLichSu(
      items: rawItems is List
          ? rawItems
                .map(
                  (e) => NhapExcelLichSu.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : <NhapExcelLichSu>[],
      page: _nhapExcelToInt(pagination['page']).clamp(1, 999999).toInt(),
      limit: _nhapExcelToInt(pagination['limit']).clamp(1, 100).toInt(),
      total: _nhapExcelToInt(pagination['total']),
      totalPages: _nhapExcelToInt(
        pagination['total_pages'],
      ).clamp(1, 999999).toInt(),
    );
  }
}

class NhapExcelChiTietLichSu {
  final NhapExcelLichSu dotNhap;
  final List<NhapExcelDongKetQua> dong;

  const NhapExcelChiTietLichSu({required this.dotNhap, required this.dong});

  factory NhapExcelChiTietLichSu.fromJson(Map<String, dynamic> json) {
    final dotRaw = json['dot'];
    final rowsRaw = json['dong'];

    return NhapExcelChiTietLichSu(
      dotNhap: NhapExcelLichSu.fromJson(
        dotRaw is Map ? Map<String, dynamic>.from(dotRaw) : <String, dynamic>{},
      ),
      dong: rowsRaw is List
          ? rowsRaw
                .map(
                  (e) => NhapExcelDongKetQua.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : <NhapExcelDongKetQua>[],
    );
  }
}
