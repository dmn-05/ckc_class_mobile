import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/nguoi_dung_model.dart';
import '../../provider/nguoi_dung_provider.dart';

class QuanLyNguoiDung extends StatefulWidget {
  const QuanLyNguoiDung({super.key});

  @override
  State<QuanLyNguoiDung> createState() => _QuanLyNguoiDungState();
}

class _QuanLyNguoiDungState extends State<QuanLyNguoiDung> {
  final TextEditingController _timKiemController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NguoiDungProvider>();
      await provider.xoaBoLoc();
      await provider.khoiTaoDuLieu();
    });
  }

  @override
  void dispose() {
    _timKiemController.dispose();
    super.dispose();
  }

  Color _mauTrangThai(String trangThai) {
    switch (trangThai) {
      case 'dang_hoat_dong':
        return Colors.green;
      case 'bi_khoa':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _iconVaiTro(String tenVaiTro) {
    switch (tenVaiTro) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'giang_vien':
        return Icons.school;
      case 'sinh_vien':
        return Icons.person;
      default:
        return Icons.account_circle;
    }
  }

  String _dinhDangNgay(DateTime? value) {
    if (value == null) return 'Chưa có';

    final ngay = value.day.toString().padLeft(2, '0');
    final thang = value.month.toString().padLeft(2, '0');
    final nam = value.year.toString();

    return '$ngay/$thang/$nam';
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  String _textNgay(DateTime? value) {
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

  Future<void> _hienThiChiTietNguoiDung(NguoiDung nguoiDung) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chi tiết người dùng'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tieuDeChiTiet('Thông tin tài khoản', Icons.account_circle),
                  _dongChiTiet('ID tài khoản', nguoiDung.id),
                  _dongChiTiet('Họ tên', nguoiDung.hoTen),
                  _dongChiTiet('Email', nguoiDung.email),
                  _dongChiTiet('Vai trò', nguoiDung.tenVaiTroHienThi),
                  _dongChiTiet('Trạng thái', nguoiDung.tenTrangThai),
                  _dongChiTiet('Ngày tạo', _textNgay(nguoiDung.ngayTao)),
                  _dongChiTiet(
                    'Ngày cập nhật',
                    _textNgay(nguoiDung.ngayCapNhat),
                  ),

                  if (nguoiDung.isGiangVien) ...[
                    const Divider(height: 24),
                    _tieuDeChiTiet('Hồ sơ giảng viên', Icons.school),
                    _dongChiTiet('ID giảng viên', nguoiDung.giangVienId),
                    _dongChiTiet('Mã giảng viên', nguoiDung.maGiangVien),
                    _dongChiTiet('Ngày sinh', _textNgay(nguoiDung.ngaySinh)),
                    _dongChiTiet('Giới tính', nguoiDung.tenGioiTinh),
                    _dongChiTiet('Số điện thoại', nguoiDung.soDienThoai),
                    _dongChiTiet('CCCD', nguoiDung.cccd),
                    _dongChiTiet('Địa chỉ', nguoiDung.diaChi),
                    _dongChiTiet('ID bộ môn', nguoiDung.boMonId),
                    _dongChiTiet('Mã bộ môn', nguoiDung.maBoMon),
                    _dongChiTiet('Tên bộ môn', nguoiDung.tenBoMon),
                    _dongChiTiet('ID khoa', nguoiDung.khoaGiangVienId),
                    _dongChiTiet('Mã khoa', nguoiDung.maKhoaGiangVien),
                    _dongChiTiet('Tên khoa', nguoiDung.tenKhoaGiangVien),
                    _dongChiTiet(
                      'Trạng thái GV',
                      nguoiDung.tenTrangThaiGiangVien,
                    ),
                    _dongChiTiet(
                      'Ngày tạo hồ sơ',
                      _textNgay(nguoiDung.ngayTaoGiangVien),
                    ),
                    _dongChiTiet(
                      'Ngày cập nhật HS',
                      _textNgay(nguoiDung.ngayCapNhatGiangVien),
                    ),
                  ],

                  if (nguoiDung.isSinhVien) ...[
                    const Divider(height: 24),
                    _tieuDeChiTiet('Hồ sơ sinh viên', Icons.person),
                    _dongChiTiet('ID sinh viên', nguoiDung.sinhVienId),
                    _dongChiTiet('Mã sinh viên', nguoiDung.maSinhVien),
                    _dongChiTiet('Ngày sinh', _textNgay(nguoiDung.ngaySinh)),
                    _dongChiTiet('Giới tính', nguoiDung.tenGioiTinh),
                    _dongChiTiet('Số điện thoại', nguoiDung.soDienThoai),
                    _dongChiTiet('CCCD', nguoiDung.cccd),
                    _dongChiTiet('Địa chỉ', nguoiDung.diaChi),
                    _dongChiTiet('ID lớp', nguoiDung.lopId),
                    _dongChiTiet('Mã lớp', nguoiDung.maLop),
                    _dongChiTiet('Tên lớp', nguoiDung.tenLop),
                    _dongChiTiet('ID khoa', nguoiDung.khoaSinhVienId),
                    _dongChiTiet('Mã khoa', nguoiDung.maKhoaSinhVien),
                    _dongChiTiet('Tên khoa', nguoiDung.tenKhoaSinhVien),
                    _dongChiTiet(
                      'Trạng thái SV',
                      nguoiDung.tenTrangThaiSinhVien,
                    ),
                    _dongChiTiet(
                      'Ngày tạo hồ sơ',
                      _textNgay(nguoiDung.ngayTaoSinhVien),
                    ),
                    _dongChiTiet(
                      'Ngày cập nhật HS',
                      _textNgay(nguoiDung.ngayCapNhatSinhVien),
                    ),
                  ],

                  if (nguoiDung.isAdmin) ...[
                    const Divider(height: 24),
                    _tieuDeChiTiet('Ghi chú', Icons.info_outline),
                    const Text(
                      'Tài khoản Admin chỉ có thông tin đăng nhập, không có hồ sơ giảng viên hoặc sinh viên.',
                    ),
                  ],
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

  Future<void> _hienThiFormNguoiDung({NguoiDung? nguoiDung}) async {
    final provider = context.read<NguoiDungProvider>();
    final dsVaiTro = provider.dsVaiTro;
    final dsKhoa = provider.dsKhoa;
    final dsLopHanhChinh = provider.dsLopHanhChinh;
    final dsBoMon = provider.dsBoMon;

    if (dsVaiTro.isEmpty) {
      _showSnackBar('Chưa có dữ liệu vai trò', Colors.red);
      return;
    }

    final formKey = GlobalKey<FormState>();

    final hoTenController = TextEditingController(text: nguoiDung?.hoTen ?? '');

    final emailController = TextEditingController(text: nguoiDung?.email ?? '');

    final matKhauController = TextEditingController();

    // Thông tin riêng của sinh viên/giảng viên.
    // Sinh viên chọn khoa và lớp hành chính có sẵn trong CSDL, không nhập ID tay.
    final maSinhVienController = TextEditingController(
      text: nguoiDung?.maSinhVien ?? '',
    );
    final maGiangVienController = TextEditingController(
      text: nguoiDung?.maGiangVien ?? '',
    );

    int? khoaId = nguoiDung?.khoaSinhVienId;
    int? lopId = nguoiDung?.lopId;
    int? boMonId = nguoiDung?.boMonId;

    if (khoaId != null && !dsKhoa.any((khoa) => khoa.id == khoaId)) {
      khoaId = null;
    }
    if (lopId != null && !dsLopHanhChinh.any((lop) => lop.id == lopId)) {
      lopId = null;
    }
    if (boMonId != null && !dsBoMon.any((boMon) => boMon.id == boMonId)) {
      boMonId = null;
    }

    int vaiTroId = nguoiDung?.vaiTroId ?? dsVaiTro.first.id;

    if (!dsVaiTro.any((vaiTro) => vaiTro.id == vaiTroId)) {
      vaiTroId = dsVaiTro.first.id;
    }

    String trangThai = nguoiDung?.trangThai ?? 'dang_hoat_dong';

    if (trangThai != 'dang_hoat_dong' && trangThai != 'bi_khoa') {
      trangThai = 'dang_hoat_dong';
    }

    bool dangLuu = false;
    bool hienMatKhau = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                nguoiDung == null ? 'Thêm người dùng' : 'Cập nhật người dùng',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: hoTenController,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên',
                            hintText: 'Nhập họ tên người dùng',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Họ tên không được để trống';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Ví dụ: user@gmail.com',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Email không được để trống';
                            }

                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );

                            if (!emailRegex.hasMatch(text)) {
                              return 'Email không hợp lệ';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: matKhauController,
                          obscureText: !hienMatKhau,
                          decoration: InputDecoration(
                            labelText: nguoiDung == null
                                ? 'Mật khẩu'
                                : 'Mật khẩu mới',
                            hintText: nguoiDung == null
                                ? 'Nhập mật khẩu'
                                : 'Bỏ trống nếu không đổi mật khẩu',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setDialogState(() {
                                  hienMatKhau = !hienMatKhau;
                                });
                              },
                              icon: Icon(
                                hienMatKhau
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (nguoiDung == null && text.isEmpty) {
                              return 'Mật khẩu không được để trống';
                            }

                            if (text.isNotEmpty && text.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        DropdownButtonFormField<int>(
                          value: vaiTroId,
                          decoration: const InputDecoration(
                            labelText: 'Vai trò',
                            prefixIcon: Icon(Icons.manage_accounts),
                            border: OutlineInputBorder(),
                          ),
                          items: dsVaiTro.map((vaiTro) {
                            return DropdownMenuItem<int>(
                              value: vaiTro.id,
                              child: Text(vaiTro.tenHienThi),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    vaiTroId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn vai trò';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Khi chọn Sinh viên: nhập mã sinh viên, chọn khoa và lớp hành chính.
                        // Đây là lớp hành chính, KHÔNG phải lớp học phần tham gia bằng mã.
                        if (vaiTroId == 3) ...[
                          TextFormField(
                            controller: maSinhVienController,
                            decoration: const InputDecoration(
                              labelText: 'Mã sinh viên',
                              hintText: 'Bỏ trống để tự sinh, ví dụ SV007',
                              prefixIcon: Icon(Icons.confirmation_number),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            value: khoaId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Khoa',
                              prefixIcon: Icon(Icons.account_tree),
                              border: OutlineInputBorder(),
                            ),
                            items: dsKhoa.map((khoa) {
                              return DropdownMenuItem<int>(
                                value: khoa.id,
                                child: Text(
                                  khoa.tenHienThi,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: dangLuu
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      khoaId = value;
                                      if (lopId != null) {
                                        final lopDangChon = dsLopHanhChinh
                                            .where((lop) => lop.id == lopId)
                                            .toList();
                                        if (lopDangChon.isNotEmpty &&
                                            lopDangChon.first.khoaId != null &&
                                            lopDangChon.first.khoaId != value) {
                                          lopId = null;
                                        }
                                      }
                                    });
                                  },
                            validator: (value) {
                              if (vaiTroId != 3) return null;
                              if (value == null || value <= 0) {
                                return 'Vui lòng chọn khoa cho sinh viên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            value: lopId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Lớp hành chính',
                              prefixIcon: Icon(Icons.class_),
                              border: OutlineInputBorder(),
                            ),
                            items: dsLopHanhChinh
                                .where(
                                  (lop) =>
                                      khoaId == null ||
                                      lop.khoaId == null ||
                                      lop.khoaId == khoaId,
                                )
                                .map((lop) {
                                  return DropdownMenuItem<int>(
                                    value: lop.id,
                                    child: Text(
                                      lop.tenHienThi,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                })
                                .toList(),
                            onChanged: dangLuu
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      lopId = value;
                                    });
                                  },
                            validator: (value) {
                              if (vaiTroId != 3) return null;
                              if (value == null || value <= 0) {
                                return 'Vui lòng chọn lớp hành chính cho sinh viên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Khi chọn Giảng viên: nhập mã giảng viên và chọn bộ môn có sẵn.
                        if (vaiTroId == 2) ...[
                          TextFormField(
                            controller: maGiangVienController,
                            decoration: const InputDecoration(
                              labelText: 'Mã giảng viên',
                              hintText: 'Bỏ trống để tự sinh, ví dụ GV007',
                              prefixIcon: Icon(Icons.confirmation_number),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int>(
                            value: boMonId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Bộ môn',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Chưa chọn bộ môn'),
                              ),
                              ...dsBoMon.map((boMon) {
                                return DropdownMenuItem<int>(
                                  value: boMon.id,
                                  child: Text(
                                    boMon.tenHienThi,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: dangLuu
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      boMonId = value ?? 0;
                                    });
                                  },
                          ),
                          const SizedBox(height: 14),
                        ],

                        DropdownButtonFormField<String>(
                          value: trangThai,
                          decoration: const InputDecoration(
                            labelText: 'Trạng thái',
                            prefixIcon: Icon(Icons.toggle_on),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'dang_hoat_dong',
                              child: Text('Đang hoạt động'),
                            ),
                            DropdownMenuItem(
                              value: 'bi_khoa',
                              child: Text('Bị khóa'),
                            ),
                          ],
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    trangThai = value ?? 'dang_hoat_dong';
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
                          Navigator.pop(dialogContext);
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

                          final result = nguoiDung == null
                              ? await provider.themNguoiDung(
                                  hoTen: hoTenController.text.trim(),
                                  email: emailController.text.trim(),
                                  matKhau: matKhauController.text.trim(),
                                  vaiTroId: vaiTroId,
                                  trangThai: trangThai,
                                  maSinhVien: maSinhVienController.text.trim(),
                                  lopId: lopId ?? 0,
                                  khoaId: khoaId ?? 0,
                                  maGiangVien: maGiangVienController.text
                                      .trim(),
                                  boMonId: boMonId ?? 0,
                                )
                              : await provider.suaNguoiDung(
                                  id: nguoiDung.id,
                                  hoTen: hoTenController.text.trim(),
                                  email: emailController.text.trim(),
                                  matKhau: matKhauController.text.trim(),
                                  vaiTroId: vaiTroId,
                                  trangThai: trangThai,
                                  maSinhVien: maSinhVienController.text.trim(),
                                  lopId: lopId ?? 0,
                                  khoaId: khoaId ?? 0,
                                  maGiangVien: maGiangVienController.text
                                      .trim(),
                                  boMonId: boMonId ?? 0,
                                );

                          if (!mounted) return;

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
                            Navigator.pop(dialogContext);
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

    await Future.delayed(const Duration(milliseconds: 300));

    hoTenController.dispose();
    emailController.dispose();
    matKhauController.dispose();
    maSinhVienController.dispose();
    maGiangVienController.dispose();
  }

  Future<void> _xacNhanKhoa(NguoiDung nguoiDung) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận khóa người dùng'),
          content: Text(
            'Bạn có chắc muốn khóa tài khoản "${nguoiDung.hoTen}" không?',
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
              label: const Text('Khóa tài khoản'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    final result = await context.read<NguoiDungProvider>().khoaNguoiDung(
      nguoiDung.id,
    );

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Khóa người dùng thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _buildBoLoc(NguoiDungProvider provider) {
    final dangCoBoLoc =
        provider.vaiTroId != 0 ||
        provider.trangThai.isNotEmpty ||
        _timKiemController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            final filterWidth = isWide
                ? (constraints.maxWidth - 10) / 2
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
                          controller: _timKiemController,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Tìm kiếm người dùng',
                            hintText: 'Họ tên, email, vai trò, mã GV/SV',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _timKiemController.text.isEmpty
                                ? null
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _timKiemController.clear();
                                      provider.timKiemNguoiDung('');
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.clear, size: 20),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            provider.timKiemNguoiDung(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: provider.dsVaiTro.isEmpty
                            ? null
                            : () {
                                _hienThiFormNguoiDung();
                              },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          constraints.maxWidth < 430 ? 'Thêm' : 'Thêm người dùng',
                          overflow: TextOverflow.ellipsis,
                        ),
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
                    initiallyExpanded: dangCoBoLoc,
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
                              _timKiemController.clear();
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
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: filterWidth,
                            child: DropdownButtonFormField<int>(
                              value: provider.vaiTroId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: false,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 14),
                                labelText: 'Vai trò',
                                prefixIcon: Icon(
                                  Icons.manage_accounts,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text('Tất cả vai trò'),
                                ),
                                ...provider.dsVaiTro.map((vaiTro) {
                                  return DropdownMenuItem<int>(
                                    value: vaiTro.id,
                                    child: Text(
                                      vaiTro.tenHienThi,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                provider.locTheoVaiTro(value ?? 0);
                              },
                            ),
                          ),

                          SizedBox(
                            width: filterWidth,
                            child: DropdownButtonFormField<String>(
                              value: provider.trangThai,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: false,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 14),
                                labelText: 'Trạng thái',
                                prefixIcon: Icon(Icons.toggle_on, size: 20),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '',
                                  child: Text('Tất cả trạng thái'),
                                ),
                                DropdownMenuItem(
                                  value: 'dang_hoat_dong',
                                  child: Text('Đang hoạt động'),
                                ),
                                DropdownMenuItem(
                                  value: 'bi_khoa',
                                  child: Text('Bị khóa'),
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

  Widget _buildNutThem(NguoiDungProvider provider) {
    return const SizedBox.shrink();
  }

  Widget _dongThongTinNguoiDung(String label, String value) {
    final text = value.trim().isEmpty ? 'Chưa cập nhật' : value.trim();

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
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget _buildTrangThaiChip(NguoiDung nguoiDung) {
    final color = _mauTrangThai(nguoiDung.trangThai);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            nguoiDung.isHoatDong ? Icons.check_circle : Icons.lock,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            nguoiDung.tenTrangThai,
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

  Widget _buildDanhSach(NguoiDungProvider provider) {
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

    if (provider.dsNguoiDung.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Chưa có người dùng nào')),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: provider.taiLaiDanhSach,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: provider.dsNguoiDung.length,
          itemBuilder: (context, index) {
            final nguoiDung = provider.dsNguoiDung[index];
            final tenVaiTro = nguoiDung.tenVaiTro ?? '';

            String maLabel = '';
            String maLienKet = '';

            if (nguoiDung.maGiangVien != null &&
                nguoiDung.maGiangVien!.isNotEmpty) {
              maLabel = 'Mã giảng viên';
              maLienKet = nguoiDung.maGiangVien!;
            } else if (nguoiDung.maSinhVien != null &&
                nguoiDung.maSinhVien!.isNotEmpty) {
              maLabel = 'Mã sinh viên';
              maLienKet = nguoiDung.maSinhVien!;
            }

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
                        CircleAvatar(
                          radius: 18,
                          child: Icon(_iconVaiTro(tenVaiTro), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            nguoiDung.hoTen,
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
                    _dongThongTinNguoiDung('Email', nguoiDung.email),
                    _dongThongTinNguoiDung(
                      'Vai trò',
                      nguoiDung.tenVaiTroHienThi,
                    ),
                    if (maLienKet.isNotEmpty)
                      _dongThongTinNguoiDung(maLabel, maLienKet),
                    _dongThongTinNguoiDung(
                      'Ngày tạo',
                      _dinhDangNgay(nguoiDung.ngayTao),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTrangThaiChip(nguoiDung),
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
                            _hienThiChiTietNguoiDung(nguoiDung);
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
                            _hienThiFormNguoiDung(nguoiDung: nguoiDung);
                          },
                        ),
                        IconButton(
                          tooltip: nguoiDung.isHoatDong
                              ? 'Khóa tài khoản'
                              : 'Tài khoản đã bị khóa',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            Icons.lock,
                            size: 22,
                            color: nguoiDung.isHoatDong
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: nguoiDung.isHoatDong
                              ? () => _xacNhanKhoa(nguoiDung)
                              : null,
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
    return Consumer<NguoiDungProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBoLoc(provider),
            _buildNutThem(provider),
            _buildDanhSach(provider),
          ],
        );
      },
    );
  }
}
