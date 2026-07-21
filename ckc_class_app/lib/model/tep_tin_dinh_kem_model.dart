class TepTinDinhKem {
  final int id;
  final String tenFile;
  final String duongDan;
  final String? loaiFile;
  final int kichThuoc;
  final DateTime? ngayTao;

  const TepTinDinhKem({
    required this.id,
    required this.tenFile,
    required this.duongDan,
    this.loaiFile,
    this.kichThuoc = 0,
    this.ngayTao,
  });

  factory TepTinDinhKem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime? toDate(dynamic value) {
      final raw = value?.toString().trim() ?? '';
      return raw.isEmpty ? null : DateTime.tryParse(raw);
    }

    final duongDan =
        json['duong_dan']?.toString() ??
        json['duong_dan_file']?.toString() ??
        '';
    final tenFile =
        json['ten_file']?.toString() ??
        json['ten_file_goc']?.toString() ??
        _tenTuDuongDan(duongDan);

    return TepTinDinhKem(
      id: toInt(json['id']),
      tenFile: tenFile.trim().isEmpty ? 'File đính kèm' : tenFile.trim(),
      duongDan: duongDan,
      loaiFile: json['loai_file']?.toString(),
      kichThuoc: toInt(json['kich_thuoc']),
      ngayTao: toDate(json['ngay_tao']),
    );
  }

  static String _tenTuDuongDan(String value) {
    if (value.trim().isEmpty) return 'File đính kèm';
    final uri = Uri.tryParse(value);
    final path = uri?.path.isNotEmpty == true ? uri!.path : value;
    final name = path.replaceAll('\\', '/').split('/').last;
    return Uri.decodeComponent(name.trim().isEmpty ? 'File đính kèm' : name);
  }

  String get kichThuocHienThi {
    if (kichThuoc <= 0) return '';
    final kb = kichThuoc / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 100 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 100 ? 1 : 0)} MB';
  }
}
