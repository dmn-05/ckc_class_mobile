class XuatExcelCot {
  final String key;
  final String label;
  final bool macDinh;

  const XuatExcelCot({
    required this.key,
    required this.label,
    required this.macDinh,
  });

  factory XuatExcelCot.fromJson(Map<String, dynamic> json) {
    return XuatExcelCot(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      macDinh: json['mac_dinh'] == true || json['mac_dinh'] == 1,
    );
  }
}

class XuatExcelLoai {
  final String key;
  final String label;
  final String description;
  final List<String> filters;
  final List<String> requiredFilters;
  final List<XuatExcelCot> columns;

  const XuatExcelLoai({
    required this.key,
    required this.label,
    required this.description,
    required this.filters,
    required this.requiredFilters,
    required this.columns,
  });

  factory XuatExcelLoai.fromJson(Map<String, dynamic> json) {
    return XuatExcelLoai(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      filters: (json['filters'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      requiredFilters: (json['required_filters'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      columns: (json['columns'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => XuatExcelCot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Set<String> get cotMacDinh => columns
      .where((cot) => cot.macDinh)
      .map((cot) => cot.key)
      .toSet();
}

class XuatExcelDanhMucItem {
  final int id;
  final String ma;
  final String ten;
  final int? parentId;
  final String? khoaHoc;
  final String? hocKy;
  final String? trangThai;
  final String? thongTinPhu;

  const XuatExcelDanhMucItem({
    required this.id,
    required this.ma,
    required this.ten,
    this.parentId,
    this.khoaHoc,
    this.hocKy,
    this.trangThai,
    this.thongTinPhu,
  });

  String get tenHienThi {
    if (ma.trim().isEmpty) return ten;
    if (ten.trim().isEmpty) return ma;
    return '$ma - $ten';
  }
}

class XuatExcelDanhMuc {
  final List<XuatExcelDanhMucItem> khoa;
  final List<XuatExcelDanhMucItem> boMon;
  final List<XuatExcelDanhMucItem> lop;
  final List<XuatExcelDanhMucItem> monHoc;
  final List<XuatExcelDanhMucItem> giangVien;
  final List<XuatExcelDanhMucItem> lopHocPhan;
  final List<String> khoaHoc;
  final List<String> hocKy;

  const XuatExcelDanhMuc({
    required this.khoa,
    required this.boMon,
    required this.lop,
    required this.monHoc,
    required this.giangVien,
    required this.lopHocPhan,
    required this.khoaHoc,
    required this.hocKy,
  });

  factory XuatExcelDanhMuc.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> maps(String key) {
      return (json[key] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    int toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

    return XuatExcelDanhMuc(
      khoa: maps('khoa')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_khoa']?.toString() ?? '',
              ten: e['ten_khoa']?.toString() ?? '',
              trangThai: e['trang_thai']?.toString(),
            ),
          )
          .toList(),
      boMon: maps('bo_mon')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_bo_mon']?.toString() ?? '',
              ten: e['ten_bo_mon']?.toString() ?? '',
              parentId: toInt(e['khoa_id']),
              trangThai: e['trang_thai']?.toString(),
            ),
          )
          .toList(),
      lop: maps('lop')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_lop']?.toString() ?? '',
              ten: e['ten_lop']?.toString() ?? '',
              parentId: toInt(e['khoa_id']),
              khoaHoc: e['khoa_hoc']?.toString(),
              trangThai: e['trang_thai']?.toString(),
            ),
          )
          .toList(),
      monHoc: maps('mon_hoc')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_mon']?.toString() ?? '',
              ten: e['ten_mon']?.toString() ?? '',
              parentId: toInt(e['khoa_id']),
              trangThai: e['trang_thai']?.toString(),
              thongTinPhu: e['bo_mon_id']?.toString(),
            ),
          )
          .toList(),
      giangVien: maps('giang_vien')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_giang_vien']?.toString() ?? '',
              ten: e['ho_ten']?.toString() ?? '',
              parentId: toInt(e['bo_mon_id']),
              trangThai: e['trang_thai']?.toString(),
            ),
          )
          .toList(),
      lopHocPhan: maps('lop_hoc_phan')
          .map(
            (e) => XuatExcelDanhMucItem(
              id: toInt(e['id']),
              ma: e['ma_lop_hoc_phan']?.toString() ?? '',
              ten: e['ten_lop']?.toString() ?? '',
              khoaHoc: e['khoa_hoc']?.toString(),
              hocKy: e['hoc_ky']?.toString(),
              trangThai: e['trang_thai']?.toString(),
              thongTinPhu: [
                e['ma_mon']?.toString() ?? '',
                e['ten_mon']?.toString() ?? '',
              ].where((e) => e.trim().isNotEmpty).join(' - '),
            ),
          )
          .toList(),
      khoaHoc: (json['khoa_hoc'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      hocKy: (json['hoc_ky'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static const empty = XuatExcelDanhMuc(
    khoa: [],
    boMon: [],
    lop: [],
    monHoc: [],
    giangVien: [],
    lopHocPhan: [],
    khoaHoc: [],
    hocKy: [],
  );
}

class XuatExcelXemTruoc {
  final int tongDong;
  final int soCot;
  final List<XuatExcelCot> columns;
  final List<Map<String, dynamic>> sample;
  final Map<String, dynamic> metadata;

  const XuatExcelXemTruoc({
    required this.tongDong,
    required this.soCot,
    required this.columns,
    required this.sample,
    required this.metadata,
  });

  factory XuatExcelXemTruoc.fromJson(Map<String, dynamic> json) {
    return XuatExcelXemTruoc(
      tongDong: int.tryParse(json['tong_dong']?.toString() ?? '') ?? 0,
      soCot: int.tryParse(json['so_cot']?.toString() ?? '') ?? 0,
      columns: (json['columns'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (e) => XuatExcelCot(
              key: e['key']?.toString() ?? '',
              label: e['label']?.toString() ?? '',
              macDinh: true,
            ),
          )
          .toList(),
      sample: (json['sample'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : const {},
    );
  }
}
