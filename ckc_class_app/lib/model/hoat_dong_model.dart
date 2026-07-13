class TaiNguyen {
  final int id;
  final String tieuDe;
  final String duongDanFile;
  final int lopHocPhanId;
  final int nguoiTaoId;
  final DateTime? ngayTao;

  TaiNguyen({
    required this.id,
    required this.tieuDe,
    required this.duongDanFile,
    required this.lopHocPhanId,
    required this.nguoiTaoId,
    this.ngayTao,
  });

  factory TaiNguyen.fromJson(Map<String, dynamic> json) {
    return TaiNguyen(
      id: json['id'],
      tieuDe: json['tieu_de'],
      duongDanFile: json['duong_dan_file'],
      lopHocPhanId: json['lop_hoc_phan_id'],
      nguoiTaoId: json['nguoi_tao_id'],
      ngayTao: json['ngay_tao'] != null ? DateTime.parse(json['ngay_tao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tieu_de': tieuDe,
      'duong_dan_file': duongDanFile,
      'lop_hoc_phan_id': lopHocPhanId,
      'nguoi_tao_id': nguoiTaoId,
      'ngay_tao': ngayTao?.toIso8601String(),
    };
  }
}

class BaiTap {
  final int id;
  final String tieuDe;
  final String? moTa;
  final DateTime? hanNop;
  final int lopHocPhanId;
  final DateTime? ngayTao;

  BaiTap({
    required this.id,
    required this.tieuDe,
    this.moTa,
    this.hanNop,
    required this.lopHocPhanId,
    this.ngayTao,
  });

  factory BaiTap.fromJson(Map<String, dynamic> json) {
    return BaiTap(
      id: json['id'],
      tieuDe: json['tieu_de'],
      moTa: json['mo_ta'],
      hanNop: json['han_nop'] != null ? DateTime.parse(json['han_nop']) : null,
      lopHocPhanId: json['lop_hoc_phan_id'],
      ngayTao: json['ngay_tao'] != null ? DateTime.parse(json['ngay_tao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tieu_de': tieuDe,
      'mo_ta': moTa,
      'han_nop': hanNop?.toIso8601String(),
      'lop_hoc_phan_id': lopHocPhanId,
      'ngay_tao': ngayTao?.toIso8601String(),
    };
  }
}

class BaiNop {
  final int id;
  final int baiTapId;
  final int sinhVienId;
  final String duongDanFile;
  final double? diem;
  final String? nhanXet;
  final DateTime? ngayNop;

  BaiNop({
    required this.id,
    required this.baiTapId,
    required this.sinhVienId,
    required this.duongDanFile,
    this.diem,
    this.nhanXet,
    this.ngayNop,
  });

  factory BaiNop.fromJson(Map<String, dynamic> json) {
    return BaiNop(
      id: json['id'],
      baiTapId: json['bai_tap_id'],
      sinhVienId: json['sinh_vien_id'],
      duongDanFile: json['duong_dan_file'],
      diem: json['diem']?.toDouble(),
      nhanXet: json['nhan_xet'],
      ngayNop: json['ngay_nop'] != null ? DateTime.parse(json['ngay_nop']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bai_tap_id': baiTapId,
      'sinh_vien_id': sinhVienId,
      'duong_dan_file': duongDanFile,
      'diem': diem,
      'nhan_xet': nhanXet,
      'ngay_nop': ngayNop?.toIso8601String(),
    };
  }
}

class ThongBao {
  final int id;
  final String tieuDe;
  final String noiDung;
  final int lopHocPhanId;
  final DateTime? ngayTao;

  ThongBao({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.lopHocPhanId,
    this.ngayTao,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: json['id'],
      tieuDe: json['tieu_de'],
      noiDung: json['noi_dung'],
      lopHocPhanId: json['lop_hoc_phan_id'],
      ngayTao: json['ngay_tao'] != null ? DateTime.parse(json['ngay_tao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tieu_de': tieuDe,
      'noi_dung': noiDung,
      'lop_hoc_phan_id': lopHocPhanId,
      'ngay_tao': ngayTao?.toIso8601String(),
    };
  }
}

class BinhLuan {
  final int id;
  final String noiDung;
  final int nguoiDungId;
  final int lopHocPhanId;
  final DateTime? ngayTao;

  BinhLuan({
    required this.id,
    required this.noiDung,
    required this.nguoiDungId,
    required this.lopHocPhanId,
    this.ngayTao,
  });

  factory BinhLuan.fromJson(Map<String, dynamic> json) {
    return BinhLuan(
      id: json['id'],
      noiDung: json['noi_dung'],
      nguoiDungId: json['nguoi_dung_id'],
      lopHocPhanId: json['lop_hoc_phan_id'],
      ngayTao: json['ngay_tao'] != null ? DateTime.parse(json['ngay_tao']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noi_dung': noiDung,
      'nguoi_dung_id': nguoiDungId,
      'lop_hoc_phan_id': lopHocPhanId,
      'ngay_tao': ngayTao?.toIso8601String(),
    };
  }
}
