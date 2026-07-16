import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modal_lifecycle.dart';
import 'package:ckc_class_app/model/khoa_bo_mon_model.dart';
import 'package:ckc_class_app/model/lop_model.dart';
import 'package:ckc_class_app/model/lop_hoc_phan_model.dart';
import 'package:ckc_class_app/model/nguoi_dung_model.dart';
import 'package:ckc_class_app/provider/lop_provider.dart';
import 'package:ckc_class_app/provider/lop_hoc_phan_provider.dart';
import 'package:ckc_class_app/provider/sinh_vien_lop_hoc_phan_provider.dart';
import 'package:ckc_class_app/provider/mon_hoc_provider.dart';
import 'package:ckc_class_app/provider/nguoi_dung_provider.dart';
import 'package:ckc_class_app/screen/admin/quan_ly_lop/quan_ly_sinh_vien_lop_hoc_phan_screen.dart';

class QuanLyLopHocPhan extends StatefulWidget {
  const QuanLyLopHocPhan({super.key});

  @override
  State<QuanLyLopHocPhan> createState() => _QuanLyLopHocPhanState();
}

class _QuanLyLopHocPhanState extends State<QuanLyLopHocPhan> {
  final TextEditingController _timKiemLopHocPhanController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonHocProvider>().layDanhSachMonHoc();
      context.read<NguoiDungProvider>().khoiTaoDuLieu();
      context.read<LopProvider>().layDanhSachLop();
      context.read<LopHocPhanProvider>().layDanhSachLopHocPhan();
    });
  }

  @override
  void dispose() {
    _timKiemLopHocPhanController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _dinhDangNgay(DateTime? value) {
    if (value == null) return 'Chưa cập nhật';

    final ngay = value.day.toString().padLeft(2, '0');
    final thang = value.month.toString().padLeft(2, '0');
    final nam = value.year.toString();

    return '$ngay/$thang/$nam';
  }

  String _textGiaTri(dynamic value) {
    if (value == null) return 'Chưa cập nhật';

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return 'Chưa cập nhật';
    }

    return text;
  }

  List<String> _taoDanhSachNamHoc() {
    final namHienTai = DateTime.now().year;
    return List.generate(10, (index) {
      final batDau = namHienTai - 6 + index;
      return '$batDau-${batDau + 1}';
    });
  }

  String _namHocMacDinh() {
    final nam = DateTime.now().year;
    return '$nam-${nam + 1}';
  }

  List<String> _dsHocKyTheoKhoa() {
    return const ['HK1', 'HK2', 'HK3', 'HK4', 'HK5', 'HK6'];
  }

  bool _laHocKyHopLe(String hocKy) {
    return _dsHocKyTheoKhoa().contains(hocKy);
  }

  String _labelHocKyTheoKhoa(String hocKy) {
    switch (hocKy) {
      case 'HK1':
        return 'Học Kỳ 1';
      case 'HK2':
        return 'Học Kỳ 2';
      case 'HK3':
        return 'Học Kỳ 3';
      case 'HK4':
        return 'Học Kỳ 4';
      case 'HK5':
        return 'Học Kỳ 5';
      case 'HK6':
        return 'Học Kỳ 6';
      default:
        return hocKy;
    }
  }

  String _labelHocKyNgan(String hocKy) {
    switch (hocKy) {
      case 'HK1':
        return 'Học kỳ 1';
      case 'HK2':
        return 'Học kỳ 2';
      case 'HK3':
        return 'Học kỳ 3';
      case 'HK4':
        return 'Học kỳ 4';
      case 'HK5':
        return 'Học kỳ 5';
      case 'HK6':
        return 'Học kỳ 6';
      default:
        return hocKy;
    }
  }

  MonHoc? _timMonHocTheoId(List<MonHoc> dsMonHoc, int id) {
    for (final monHoc in dsMonHoc) {
      if (monHoc.id == id) return monHoc;
    }
    return null;
  }

  Lop? _timLopTheoId(List<Lop> dsLop, int id) {
    for (final lop in dsLop) {
      if (lop.id == id) return lop;
    }
    return null;
  }

  String _taoTenLopHocPhanTuDong({
    required int lopId,
    required List<Lop> dsLop,
    required int monHocId,
    required List<MonHoc> dsMonHoc,
    required String hocKy,
    required String namHoc,
  }) {
    final monHoc = _timMonHocTheoId(dsMonHoc, monHocId);
    final lop = _timLopTheoId(dsLop, lopId);

    final tenMon = (monHoc?.tenMon ?? '').trim();
    final hocKyText = hocKy.trim();
    final namHocText = namHoc.trim();

    if (lop != null && monHoc != null) {
      return '${lop.maLop} - $tenMon - $hocKyText - $namHocText'.trim();
    }

    if (tenMon.isEmpty) {
      return 'HKP - $hocKyText - $namHocText'.trim();
    }

    return 'HKP - $tenMon - $hocKyText - $namHocText'.trim();
  }

  String _namHocTuLopHocPhan(LopHocPhan? lopHocPhan) {
    final value = lopHocPhan?.namHoc.trim() ?? '';
    return value.isEmpty ? _namHocMacDinh() : value;
  }

  Color _mauTrangThaiLopHocPhan(String trangThai) {
    switch (trangThai) {
      case 'dang_mo':
        return Colors.green;
      case 'da_khoa':
        return Colors.grey;
      case 'da_ket_thuc':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildChipTrangThai({
    required String label,
    required Color color,
    IconData icon = Icons.info_outline,
  }) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      side: BorderSide(color: color.withOpacity(0.35)),
      backgroundColor: color.withOpacity(0.08),
    );
  }

  Widget _dongChiTiet(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(_textGiaTri(value))),
        ],
      ),
    );
  }

  Widget _tieuDeChiTiet(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _hienThiChiTietLopHocPhan(LopHocPhan lopHocPhan) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chi tiết lớp học phần'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tieuDeChiTiet('Thông tin lớp học phần', Icons.groups),
                  _dongChiTiet('ID', lopHocPhan.id),
                  _dongChiTiet('Mã lớp học phần', lopHocPhan.maLopHocPhan),
                  _dongChiTiet('Tên lớp', lopHocPhan.tenLop),
                  _dongChiTiet('Năm học', _namHocTuLopHocPhan(lopHocPhan)),
                  _dongChiTiet('Học kỳ', lopHocPhan.hocKy),
                  _dongChiTiet('Sĩ số', lopHocPhan.siSoHienThi),
                  _dongChiTiet('Tổng SV đăng ký', lopHocPhan.tongSoSinhVien),
                  _dongChiTiet('SV đang học', lopHocPhan.soSinhVienDangHoc),
                  _dongChiTiet('Trạng thái', lopHocPhan.tenTrangThai),
                  _dongChiTiet('Ngày tạo', _dinhDangNgay(lopHocPhan.ngayTao)),
                  _dongChiTiet(
                    'Ngày cập nhật',
                    _dinhDangNgay(lopHocPhan.ngayCapNhat),
                  ),
                  const Divider(height: 24),
                  _tieuDeChiTiet('Thông tin môn học', Icons.menu_book),
                  _dongChiTiet('ID môn học', lopHocPhan.monHocId),
                  _dongChiTiet('Mã môn', lopHocPhan.maMon),
                  _dongChiTiet('Tên môn', lopHocPhan.tenMon),
                  _dongChiTiet('Số tín chỉ', lopHocPhan.tinChi),
                  _dongChiTiet('Trạng thái môn', lopHocPhan.trangThaiMonHoc),
                  const Divider(height: 24),
                  _tieuDeChiTiet('Thông tin bộ môn / khoa', Icons.account_tree),
                  _dongChiTiet('Mã bộ môn', lopHocPhan.maBoMon),
                  _dongChiTiet('Tên bộ môn', lopHocPhan.tenBoMon),
                  _dongChiTiet('ID khoa', lopHocPhan.khoaId),
                  _dongChiTiet('Mã khoa', lopHocPhan.maKhoa),
                  _dongChiTiet('Tên khoa', lopHocPhan.tenKhoa),
                  const Divider(height: 24),
                  _tieuDeChiTiet('Giảng viên phụ trách', Icons.school),
                  _dongChiTiet('ID giảng viên', lopHocPhan.giangVienId),
                  _dongChiTiet('Mã giảng viên', lopHocPhan.maGiangVien),
                  _dongChiTiet('Họ tên', lopHocPhan.tenGiangVien),
                  _dongChiTiet('Email', lopHocPhan.emailGiangVien),
                  _dongChiTiet('Trạng thái GV', lopHocPhan.trangThaiGiangVien),
                  _dongChiTiet(
                    'Trạng thái tài khoản',
                    lopHocPhan.trangThaiTaiKhoanGv,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _hienThiFormLopHocPhan({
    LopHocPhan? lopHocPhan,
    required List<MonHoc> dsMonHoc,
    required List<NguoiDung> dsNguoiDung,
    required List<Lop> dsLop,
  }) async {
    final dsMonHocDangMo = dsMonHoc.where((monHoc) {
      return monHoc.dangMo;
    }).toList();

    final dsGiangVienDangHoatDong = dsNguoiDung.where((nguoiDung) {
      return nguoiDung.isGiangVien &&
          nguoiDung.giangVienId != null &&
          nguoiDung.isHoatDong;
    }).toList();

    final dsLopDangHoc = dsLop.where((lop) => lop.dangHoc).toList();

    if (dsMonHocDangMo.isEmpty) {
      _showSnackBar('Chưa có môn học đang mở để tạo lớp học phần', Colors.red);
      return;
    }

    if (dsGiangVienDangHoatDong.isEmpty) {
      _showSnackBar('Chưa có giảng viên đang hoạt động', Colors.red);
      return;
    }

    final formKey = GlobalKey<FormState>();

    final maLopHocPhanController = TextEditingController(
      text: lopHocPhan?.maLopHocPhan ?? '',
    );

    final tenLopController = TextEditingController(
      text: lopHocPhan?.tenLop ?? '',
    );

    final siSoToiDaController = TextEditingController(
      text: lopHocPhan?.siSoToiDa?.toString() ?? '40',
    );

    int monHocId = lopHocPhan?.monHocId ?? dsMonHocDangMo.first.id;

    if (!dsMonHocDangMo.any((monHoc) => monHoc.id == monHocId)) {
      monHocId = dsMonHocDangMo.first.id;
    }

    int giangVienId =
        lopHocPhan?.giangVienId ?? dsGiangVienDangHoatDong.first.giangVienId!;

    if (!dsGiangVienDangHoatDong.any(
      (nguoiDung) => nguoiDung.giangVienId == giangVienId,
    )) {
      giangVienId = dsGiangVienDangHoatDong.first.giangVienId!;
    }

    // 0 = Học kỳ phụ, không tự động thêm sinh viên từ lớp hành chính.
    int lopId = 0;

    String namHoc = _namHocTuLopHocPhan(lopHocPhan);
    final dsNamHoc = _taoDanhSachNamHoc();
    if (!dsNamHoc.contains(namHoc)) dsNamHoc.insert(0, namHoc);

    String hocKy = lopHocPhan?.hocKy ?? 'HK1';
    if (!_laHocKyHopLe(hocKy)) {
      hocKy = 'HK1';
    }

    String trangThai = lopHocPhan?.trangThai ?? 'dang_mo';

    if (!['dang_mo', 'da_khoa', 'da_ket_thuc'].contains(trangThai)) {
      trangThai = 'dang_mo';
    }

    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                lopHocPhan == null
                    ? 'Thêm lớp học phần'
                    : 'Cập nhật lớp học phần',
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lopHocPhan != null) ...[
                          TextFormField(
                            controller: maLopHocPhanController,
                            decoration: const InputDecoration(
                              labelText: 'Mã lớp học phần',
                              prefixIcon: Icon(Icons.qr_code),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Mã lớp học phần không được để trống';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: tenLopController,
                            decoration: const InputDecoration(
                              labelText: 'Tên lớp học phần',
                              prefixIcon: Icon(Icons.groups),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Tên lớp học phần không được để trống';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        DropdownButtonFormField<int>(
                          value: monHocId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Môn học',
                            prefixIcon: Icon(Icons.menu_book),
                            border: OutlineInputBorder(),
                          ),
                          items: dsMonHocDangMo.map((monHoc) {
                            return DropdownMenuItem<int>(
                              value: monHoc.id,
                              child: Text('${monHoc.maMon} - ${monHoc.tenMon}'),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    monHocId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn môn học';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: giangVienId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Giảng viên phụ trách',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(),
                          ),
                          items: dsGiangVienDangHoatDong.map((nguoiDung) {
                            return DropdownMenuItem<int>(
                              value: nguoiDung.giangVienId,
                              child: Text(
                                '${nguoiDung.maGiangVien ?? 'GV'} - ${nguoiDung.hoTen}',
                              ),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    giangVienId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn giảng viên';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        if (lopHocPhan == null) ...[
                          DropdownButtonFormField<int>(
                            value: lopId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Lớp học',
                              prefixIcon: Icon(Icons.class_),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Học kỳ phụ'),
                              ),
                              ...dsLopDangHoc.map((lop) {
                                return DropdownMenuItem<int>(
                                  value: lop.id,
                                  child: Text(
                                    '${lop.maLop} - ${lop.tenLop} - Nhập học ${lop.namNhapHocHienThi}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: dangLuu
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      lopId = value ?? 0;
                                    });
                                  },
                          ),
                          const SizedBox(height: 14),
                        ],
                        DropdownButtonFormField<String>(
                          value: namHoc,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Năm học',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          items: dsNamHoc.map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text('Năm học $item'),
                          )).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) => setDialogState(() {
                                  namHoc = value ?? namHoc;
                                }),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Vui lòng chọn năm học'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: hocKy,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Học kỳ',
                            prefixIcon: Icon(Icons.event),
                            border: OutlineInputBorder(),
                          ),
                          items: _dsHocKyTheoKhoa().map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(_labelHocKyTheoKhoa(item)),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    hocKy = value ?? 'HK1';
                                  });
                                },
                        ),
                        const SizedBox(height: 14),
                        if (lopHocPhan == null) ...[
                          const SizedBox(height: 14),
                          InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Tên/Mã lớp học phần tự động',
                              prefixIcon: Icon(Icons.auto_awesome),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _taoTenLopHocPhanTuDong(
                                lopId: lopId,
                                dsLop: dsLopDangHoc,
                                monHocId: monHocId,
                                dsMonHoc: dsMonHocDangMo,
                                hocKy: hocKy,
                                namHoc: namHoc,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: siSoToiDaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sĩ số tối đa',
                            hintText: 'Ví dụ: 40',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return null;
                            }

                            final siSo = int.tryParse(text);

                            if (siSo == null) {
                              return 'Sĩ số phải là số';
                            }

                            if (siSo <= 0 || siSo > 500) {
                              return 'Sĩ số tối đa phải từ 1 đến 500';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: trangThai,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Trạng thái',
                            prefixIcon: Icon(Icons.toggle_on),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'dang_mo',
                              child: Text('Đang mở'),
                            ),
                            DropdownMenuItem(
                              value: 'da_khoa',
                              child: Text('Đã khóa'),
                            ),
                            DropdownMenuItem(
                              value: 'da_ket_thuc',
                              child: Text('Đã kết thúc'),
                            ),
                          ],
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    trangThai = value ?? 'dang_mo';
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dangLuu
                      ? null
                      : () {
                          unfocusCurrentInput();
                          Navigator.of(dialogContext, rootNavigator: true).pop();
                        },
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: dangLuu
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          setDialogState(() {
                            dangLuu = true;
                          });

                          final siSoText = siSoToiDaController.text.trim();
                          final siSoToiDa = siSoText.isEmpty
                              ? null
                              : int.parse(siSoText);

                          final tenLopTuDong = _taoTenLopHocPhanTuDong(
                            lopId: lopId,
                            dsLop: dsLopDangHoc,
                            monHocId: monHocId,
                            dsMonHoc: dsMonHocDangMo,
                            hocKy: hocKy,
                            namHoc: namHoc,
                          );

                          final maLopHocPhan = lopHocPhan == null
                              ? tenLopTuDong
                              : maLopHocPhanController.text.trim();
                          final tenLop = lopHocPhan == null
                              ? tenLopTuDong
                              : tenLopController.text.trim();

                          final provider = context.read<LopHocPhanProvider>();

                          final result = lopHocPhan == null
                              ? await provider.themLopHocPhan(
                                  maLopHocPhan: maLopHocPhan,
                                  tenLop: tenLop,
                                  monHocId: monHocId,
                                  giangVienId: giangVienId,
                                  hocKy: hocKy,
                                  namHoc: namHoc,
                                  siSoToiDa: siSoToiDa,
                                  trangThai: trangThai,
                                  lopId: lopId,
                                )
                              : await provider.suaLopHocPhan(
                                  id: lopHocPhan.id,
                                  maLopHocPhan: maLopHocPhan,
                                  tenLop: tenLop,
                                  monHocId: monHocId,
                                  giangVienId: giangVienId,
                                  hocKy: hocKy,
                                  namHoc: namHoc,
                                  siSoToiDa: siSoToiDa,
                                  trangThai: trangThai,
                                );

                          if (!mounted || !dialogContext.mounted) return;

                          setDialogState(() {
                            dangLuu = false;
                          });

                          final success = result['success'] == true;
                          final message =
                              result['message']?.toString() ??
                              (success
                                  ? 'Thao tác thành công'
                                  : 'Thao tác thất bại');

                          if (success) {
                            unfocusCurrentInput();
                            Navigator.of(dialogContext, rootNavigator: true).pop();
                          }

                          _showSnackBar(
                            message,
                            success ? Colors.green : Colors.red,
                          );
                        },
                  icon: dangLuu
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(dangLuu ? 'Đang lưu...' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    await disposeControllersAfterModal([
      maLopHocPhanController,
      tenLopController,
      siSoToiDaController,
    ]);
  }

  Future<void> _hienThiDanhSachSinhVienLopHocPhan(LopHocPhan lopHocPhan) async {
    final provider = context.read<SinhVienLopHocPhanProvider>();

    await provider.init(lopHocPhan.id);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuanLySinhVienLopHocPhanScreen(lopHocPhan: lopHocPhan),
      ),
    );


    if (mounted) {
      await context.read<LopHocPhanProvider>().taiLaiDanhSach();
    }
  }

  Future<void> _xacNhanKhoaLopHocPhan(LopHocPhan lopHocPhan) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận khóa lớp học phần'),
          content: Text(
            'Bạn có chắc muốn khóa lớp học phần "${lopHocPhan.tenLop}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.lock),
              label: const Text('Khóa lớp'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    final result = await context.read<LopHocPhanProvider>().khoaLopHocPhan(
      lopHocPhan.id,
    );

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Khóa lớp học phần thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  InputDecoration _dropdownFilterDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: const OutlineInputBorder(),
    );
  }

  Widget _buildBoLocLopHocPhan(
    LopHocPhanProvider provider,
    List<MonHoc> dsMonHoc,
    List<NguoiDung> dsNguoiDung,
    List<Lop> dsLop,
  ) {
    final dsGiangVien = dsNguoiDung.where((nguoiDung) {
      return nguoiDung.isGiangVien && nguoiDung.giangVienId != null;
    }).toList();

    final dangCoBoLoc =
        provider.monHocId != 0 ||
        provider.giangVienId != 0 ||
        provider.namHoc.isNotEmpty ||
        provider.hocKy.isNotEmpty ||
        provider.trangThai.isNotEmpty ||
        _timKiemLopHocPhanController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final filterWidth = isWide
                ? (constraints.maxWidth - 30) / 4
                : constraints.maxWidth;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _timKiemLopHocPhanController,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Tìm kiếm lớp học phần',
                            hintText: 'Mã lớp, tên lớp, môn học, giảng viên',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon:
                                _timKiemLopHocPhanController.text.isEmpty
                                ? null
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _timKiemLopHocPhanController.clear();
                                      provider.timKiemLopHocPhan('');
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.clear, size: 20),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            provider.timKiemLopHocPhan(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _hienThiFormLopHocPhan(
                            dsMonHoc: dsMonHoc,
                            dsNguoiDung: dsNguoiDung,
                            dsLop: dsLop,
                          );
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Thêm'),
                      ),
                    ),
                  ],
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    dense: true,
                    initiallyExpanded: true,
                    leading: Icon(
                      dangCoBoLoc
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      size: 20,
                    ),
                    title: Text(
                      dangCoBoLoc ? 'Bộ lọc đang áp dụng' : 'Bộ lọc nâng cao',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dangCoBoLoc)
                          TextButton.icon(
                            onPressed: () {
                              _timKiemLopHocPhanController.clear();
                              provider.xoaBoLoc();
                              setState(() {});
                            },
                            icon: const Icon(Icons.filter_alt_off, size: 18),
                            label: const Text('Xóa'),
                          ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<int>(
                                value: provider.monHocId,
                                isExpanded: true,
                                decoration: _dropdownFilterDecoration(
                                  label: 'Môn học',
                                  icon: Icons.menu_book,
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('Tất cả môn học'),
                                  ),
                                  ...dsMonHoc.map((monHoc) {
                                    return DropdownMenuItem<int>(
                                      value: monHoc.id,
                                      child: Text(
                                        '${monHoc.maMon} - ${monHoc.tenMon}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  provider.locTheoMonHoc(value ?? 0);
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<int>(
                                value: provider.giangVienId,
                                isExpanded: true,
                                decoration: _dropdownFilterDecoration(
                                  label: 'Giảng viên',
                                  icon: Icons.school,
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('Tất cả giảng viên'),
                                  ),
                                  ...dsGiangVien.map((nguoiDung) {
                                    return DropdownMenuItem<int>(
                                      value: nguoiDung.giangVienId,
                                      child: Text(
                                        '${nguoiDung.maGiangVien ?? 'GV'} - ${nguoiDung.hoTen}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  provider.locTheoGiangVien(value ?? 0);
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<String>(
                                value: provider.namHoc,
                                isExpanded: true,
                                decoration: _dropdownFilterDecoration(
                                  label: 'Năm học',
                                  icon: Icons.date_range,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('Tất cả năm học'),
                                  ),
                                  ..._taoDanhSachNamHoc().map((namHoc) =>
                                      DropdownMenuItem<String>(
                                        value: namHoc,
                                        child: Text(namHoc),
                                      )),
                                ],
                                onChanged: (value) {
                                  provider.locTheoNamHoc(value ?? '');
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<String>(
                                value: provider.hocKy,
                                isExpanded: true,
                                decoration: _dropdownFilterDecoration(
                                  label: 'Học kỳ',
                                  icon: Icons.event,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('Tất cả học kỳ'),
                                  ),
                                  ..._dsHocKyTheoKhoa().map((hocKy) =>
                                      DropdownMenuItem<String>(
                                        value: hocKy,
                                        child: Text(
                                          _labelHocKyTheoKhoa(hocKy),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                ],
                                onChanged: (value) {
                                  provider.locTheoHocKy(value ?? '');
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<String>(
                                value: provider.trangThai,
                                isExpanded: true,
                                decoration: _dropdownFilterDecoration(
                                  label: 'Trạng thái',
                                  icon: Icons.toggle_on,
                                ),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('Tất cả trạng thái'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'dang_mo',
                                    child: Text('Đang mở'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'da_khoa',
                                    child: Text('Đã khóa'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'da_ket_thuc',
                                    child: Text('Đã kết thúc'),
                                  ),
                                ],
                                onChanged: (value) {
                                  provider.locTheoTrangThai(value ?? '');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dongThongTinLopHocPhan(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: DefaultTextStyle.of(
            context,
          ).style.copyWith(fontSize: 13.5, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _trangThaiNhoLopHocPhan({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanhSachLopHocPhan(
    LopHocPhanProvider provider,
    List<MonHoc> dsMonHoc,
    List<NguoiDung> dsNguoiDung,
  ) {
    if (provider.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (provider.dsLopHocPhan.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Chưa có lớp học phần nào')),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: provider.taiLaiDanhSach,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: provider.dsLopHocPhan.length,
          itemBuilder: (context, index) {
            final lopHocPhan = provider.dsLopHocPhan[index];
            final color = _mauTrangThaiLopHocPhan(lopHocPhan.trangThai);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.class_, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lopHocPhan.tenLop,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _dongThongTinLopHocPhan(
                      'Mã lớp HP',
                      lopHocPhan.maLopHocPhan,
                    ),
                    _dongThongTinLopHocPhan(
                      'Môn học',
                      lopHocPhan.tenMonHienThi,
                    ),
                    _dongThongTinLopHocPhan(
                      'Giảng viên',
                      lopHocPhan.tenGiangVienHienThi,
                    ),
                    _dongThongTinLopHocPhan('Khoa', lopHocPhan.tenKhoaHienThi),
                    _dongThongTinLopHocPhan(
                      'Năm học',
                      lopHocPhan.namHoc,
                    ),
                    _dongThongTinLopHocPhan(
                      'Học kỳ',
                      _labelHocKyTheoKhoa(lopHocPhan.hocKy),
                    ),
                    _dongThongTinLopHocPhan('Sĩ số', lopHocPhan.siSoHienThi),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _trangThaiNhoLopHocPhan(
                          label: lopHocPhan.tenTrangThai,
                          color: color,
                          icon: lopHocPhan.daKhoa
                              ? Icons.lock
                              : lopHocPhan.daKetThuc
                              ? Icons.verified
                              : Icons.check_circle,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Xem chi tiết',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(Icons.info_outline, size: 22),
                          onPressed: () {
                            _hienThiChiTietLopHocPhan(lopHocPhan);
                          },
                        ),
                        IconButton(
                          tooltip: 'Danh sách sinh viên',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(Icons.people_alt_outlined, size: 22),
                          onPressed: () {
                            _hienThiDanhSachSinhVienLopHocPhan(lopHocPhan);
                          },
                        ),
                        IconButton(
                          tooltip: 'Cập nhật',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(Icons.edit, size: 22),
                          onPressed: () {
                            _hienThiFormLopHocPhan(
                              lopHocPhan: lopHocPhan,
                              dsMonHoc: dsMonHoc,
                              dsNguoiDung: dsNguoiDung,
                              dsLop: context.read<LopProvider>().dsLop,
                            );
                          },
                        ),
                        IconButton(
                          tooltip: lopHocPhan.daKhoa
                              ? 'Lớp học phần đã khóa'
                              : 'Khóa lớp học phần',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            Icons.lock,
                            size: 22,
                            color: lopHocPhan.daKhoa ? Colors.grey : Colors.red,
                          ),
                          onPressed: lopHocPhan.daKhoa
                              ? null
                              : () => _xacNhanKhoaLopHocPhan(lopHocPhan),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      LopHocPhanProvider,
      MonHocProvider,
      NguoiDungProvider,
      LopProvider
    >(
      builder:
          (
            context,
            lopHocPhanProvider,
            monHocProvider,
            nguoiDungProvider,
            lopProvider,
            child,
          ) {
            final dsMonHoc = monHocProvider.dsMonHoc;
            final dsNguoiDung = nguoiDungProvider.dsNguoiDung;
            final dsLop = lopProvider.dsLop;

            return Column(
              children: [
                _buildBoLocLopHocPhan(
                  lopHocPhanProvider,
                  dsMonHoc,
                  dsNguoiDung,
                  dsLop,
                ),
                _buildDanhSachLopHocPhan(
                  lopHocPhanProvider,
                  dsMonHoc,
                  dsNguoiDung,
                ),
              ],
            );
          },
    );
  }
}
