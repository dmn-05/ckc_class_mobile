import 'package:ckc_class_app/provider/sinh_vien_lop_provider.dart';
import 'package:ckc_class_app/screen/admin/quan_ly_lop/sinh_vien_lop_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/modal_lifecycle.dart';

import '../../../model/khoa_bo_mon_model.dart';
import '../../../model/lop_model.dart';
import '../../../provider/khoa_provider.dart';
import '../../../provider/lop_provider.dart';

class QuanLyLop extends StatefulWidget {
  const QuanLyLop({super.key});

  @override
  State<QuanLyLop> createState() => _QuanLyLopState();
}

class _QuanLyLopState extends State<QuanLyLop> {
  final TextEditingController _timKiemLopController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KhoaProvider>().layDanhSachKhoa();
      context.read<LopProvider>().layDanhSachLop();
    });
  }

  @override
  void dispose() {
    _timKiemLopController.dispose();
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

  Color _mauTrangThaiLop(String trangThai) {
    switch (trangThai) {
      case 'dang_hoc':
        return Colors.green;
      case 'da_tot_nghiep':
        return Colors.blue;
      case 'tam_khoa':
        return Colors.grey;
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

  String _kyTuDau(String value, String fallback) {
    final text = value.trim();

    if (text.isEmpty) return fallback;

    return text.substring(0, 1).toUpperCase();
  }

  int _namNhapHocMacDinh() => DateTime.now().year;

  List<int> _taoDanhSachNamNhapHoc() {
    final namHienTai = DateTime.now().year;
    return List.generate(11, (index) => namHienTai - 7 + index);
  }

  Future<void> _hienThiChiTietLop(Lop lop) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Chi tiết lớp hành chính'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tieuDeChiTiet('Thông tin lớp', Icons.class_),
                  _dongChiTiet('ID', lop.id),
                  _dongChiTiet('Mã lớp', lop.maLop),
                  _dongChiTiet('Tên lớp', lop.tenLop),
                  _dongChiTiet('Năm nhập học', lop.namNhapHocHienThi),
                  _dongChiTiet('Trạng thái', lop.tenTrangThai),
                  _dongChiTiet('Số sinh viên', lop.soLuongSinhVien),
                  _dongChiTiet('Ngày tạo', _dinhDangNgay(lop.ngayTao)),
                  _dongChiTiet('Ngày cập nhật', _dinhDangNgay(lop.ngayCapNhat)),
                  const Divider(height: 24),
                  _tieuDeChiTiet('Thông tin khoa', Icons.account_balance),
                  _dongChiTiet('ID khoa', lop.khoaId),
                  _dongChiTiet('Mã khoa', lop.maKhoa ?? lop.khoa?.maKhoa),
                  _dongChiTiet('Tên khoa', lop.tenKhoa ?? lop.khoa?.tenKhoa),
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

  Future<void> _hienThiFormLop({Lop? lop, required List<Khoa> dsKhoa}) async {
    final dsKhoaDangHoatDong = dsKhoa.where((khoa) {
      return khoa.dangHoatDong;
    }).toList();

    if (dsKhoaDangHoatDong.isEmpty) {
      _showSnackBar('Chưa có khoa đang hoạt động để tạo lớp', Colors.red);
      return;
    }

    final formKey = GlobalKey<FormState>();

    final maLopController = TextEditingController(text: lop?.maLop ?? '');

    final tenLopController = TextEditingController(text: lop?.tenLop ?? '');

    int namNhapHoc = lop?.namNhapHoc ?? _namNhapHocMacDinh();
    final dsNamNhapHocForm = _taoDanhSachNamNhapHoc();
    if (!dsNamNhapHocForm.contains(namNhapHoc)) {
      dsNamNhapHocForm.insert(0, namNhapHoc);
    }

    int khoaId = lop?.khoaId ?? dsKhoaDangHoatDong.first.id;

    if (!dsKhoaDangHoatDong.any((khoa) => khoa.id == khoaId)) {
      khoaId = dsKhoaDangHoatDong.first.id;
    }

    String trangThai = lop?.trangThai ?? 'dang_hoc';

    if (!['dang_hoc', 'da_tot_nghiep', 'tam_khoa'].contains(trangThai)) {
      trangThai = 'dang_hoc';
    }

    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(lop == null ? 'Thêm lớp' : 'Cập nhật lớp'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: maLopController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Mã lớp',
                            hintText: 'Ví dụ: CDTH25A',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Mã lớp không được để trống';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: tenLopController,
                          decoration: const InputDecoration(
                            labelText: 'Tên lớp',
                            hintText: 'Ví dụ: CĐ Tin học 25A',
                            prefixIcon: Icon(Icons.class_),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Tên lớp không được để trống';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: namNhapHoc,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Năm nhập học',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          items: dsNamNhapHocForm.map((item) {
                            return DropdownMenuItem<int>(
                              value: item,
                              child: Text('Năm $item'),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setDialogState(() => namNhapHoc = value);
                                },
                          validator: (value) => value == null
                              ? 'Vui lòng chọn năm nhập học'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: khoaId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Khoa',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                          items: dsKhoaDangHoatDong.map((khoa) {
                            return DropdownMenuItem<int>(
                              value: khoa.id,
                              child: Text('${khoa.maKhoa} - ${khoa.tenKhoa}'),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;

                                  setDialogState(() {
                                    khoaId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn khoa';
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
                              value: 'dang_hoc',
                              child: Text('Đang học'),
                            ),
                            DropdownMenuItem(
                              value: 'da_tot_nghiep',
                              child: Text('Đã tốt nghiệp'),
                            ),
                            DropdownMenuItem(
                              value: 'tam_khoa',
                              child: Text('Tạm khóa'),
                            ),
                          ],
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    trangThai = value ?? 'dang_hoc';
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

                          final provider = context.read<LopProvider>();

                          final result = lop == null
                              ? await provider.themLop(
                                  maLop: maLopController.text.trim(),
                                  tenLop: tenLopController.text.trim(),
                                  khoaId: khoaId,
                                  namNhapHoc: namNhapHoc,
                                  trangThai: trangThai,
                                )
                              : await provider.suaLop(
                                  id: lop.id,
                                  maLop: maLopController.text.trim(),
                                  tenLop: tenLopController.text.trim(),
                                  khoaId: khoaId,
                                  namNhapHoc: namNhapHoc,
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
      maLopController,
      tenLopController,
    ]);
  }

  Future<void> _xacNhanTamKhoaLop(Lop lop) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận tạm khóa lớp'),
          content: Text(
            'Bạn có chắc muốn chuyển lớp "${lop.tenLop}" sang trạng thái tạm khóa không?',
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
              label: const Text('Tạm khóa'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    final result = await context.read<LopProvider>().tamKhoaLop(lop.id);

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Tạm khóa lớp thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _dongThongTinLop(String label, String value) {
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

  Widget _trangThaiNhoLop({
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

  Widget _buildBoLocLop(LopProvider lopProvider, List<Khoa> dsKhoa) {
    final dangCoBoLoc =
        lopProvider.khoaId != 0 ||
        lopProvider.namNhapHoc != null ||
        lopProvider.trangThai.isNotEmpty ||
        _timKiemLopController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final filterWidth = isWide
                ? (constraints.maxWidth - 20) / 3
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
                          controller: _timKiemLopController,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Tìm kiếm lớp',
                            hintText: 'Mã lớp, tên lớp, khoa, khóa học',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _timKiemLopController.text.isEmpty
                                ? null
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _timKiemLopController.clear();
                                      lopProvider.timKiemLop('');
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.clear, size: 20),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            lopProvider.timKiemLop(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed:
                            dsKhoa.where((khoa) => khoa.dangHoatDong).isEmpty
                            ? null
                            : () {
                                _hienThiFormLop(dsKhoa: dsKhoa);
                              },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          constraints.maxWidth < 430 ? 'Thêm' : 'Thêm lớp',
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
                    trailing: dangCoBoLoc
                        ? IconButton(
                            tooltip: 'Xóa bộ lọc',
                            icon: const Icon(Icons.filter_alt_off, size: 20),
                            onPressed: () {
                              _timKiemLopController.clear();
                              lopProvider.xoaBoLoc();
                              setState(() {});
                            },
                          )
                        : const Icon(Icons.expand_more),
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
                                value: lopProvider.khoaId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: false,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    18,
                                    12,
                                    14,
                                  ),
                                  labelText: 'Khoa',
                                  prefixIcon: Icon(
                                    Icons.account_balance,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('Tất cả khoa'),
                                  ),
                                  ...dsKhoa.map((khoa) {
                                    return DropdownMenuItem<int>(
                                      value: khoa.id,
                                      child: Text(
                                        '${khoa.maKhoa} - ${khoa.tenKhoa}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  lopProvider.locTheoKhoa(value ?? 0);
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<int>(
                                value: lopProvider.namNhapHoc ?? 0,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: false,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 14),
                                  labelText: 'Năm nhập học',
                                  prefixIcon: Icon(Icons.date_range, size: 20),
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: 0,
                                    child: Text('Tất cả năm'),
                                  ),
                                  ..._taoDanhSachNamNhapHoc().map((nam) =>
                                      DropdownMenuItem<int>(
                                        value: nam,
                                        child: Text('Năm $nam'),
                                      )),
                                ],
                                onChanged: (value) {
                                  lopProvider.locTheoNamNhapHoc(
                                    value == null || value == 0 ? null : value,
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: filterWidth,
                              child: DropdownButtonFormField<String>(
                                value: lopProvider.trangThai,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  isDense: false,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    12,
                                    18,
                                    12,
                                    14,
                                  ),
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
                                    value: 'dang_hoc',
                                    child: Text('Đang học'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'da_tot_nghiep',
                                    child: Text('Đã tốt nghiệp'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'tam_khoa',
                                    child: Text('Tạm khóa'),
                                  ),
                                ],
                                onChanged: (value) {
                                  lopProvider.locTheoTrangThai(value ?? '');
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

  Widget _buildDanhSachLop(LopProvider lopProvider, List<Khoa> dsKhoa) {
    if (lopProvider.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (lopProvider.error != null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              lopProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (lopProvider.dsLop.isEmpty) {
      return const Expanded(child: Center(child: Text('Chưa có lớp nào')));
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: lopProvider.taiLaiDanhSach,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: lopProvider.dsLop.length,
          itemBuilder: (context, index) {
            final lop = lopProvider.dsLop[index];
            final color = _mauTrangThaiLop(lop.trangThai);

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
                          child: Text(_kyTuDau(lop.maLop, 'L')),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lop.tenLop,
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

                    _dongThongTinLop('Mã lớp', lop.maLop),
                    _dongThongTinLop('Khoa', lop.tenKhoaHienThi),
                    _dongThongTinLop('Năm nhập học', lop.namNhapHocHienThi),
                    _dongThongTinLop(
                      'Số sinh viên',
                      lop.soLuongSinhVien.toString(),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _trangThaiNhoLop(
                          label: lop.tenTrangThai,
                          color: color,
                          icon: lop.tamKhoa
                              ? Icons.lock
                              : lop.daTotNghiep
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
                            _hienThiChiTietLop(lop);
                          },
                        ),
                        IconButton(
                          tooltip: 'Xem sinh viên',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: const Icon(Icons.group, size: 22),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => SinhVienLopProvider(),
                                  child: SinhVienLopScreen(lopId: lop.id),
                                ),
                              ),
                            );
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
                            _hienThiFormLop(lop: lop, dsKhoa: dsKhoa);
                          },
                        ),
                        IconButton(
                          tooltip: lop.tamKhoa
                              ? 'Lớp đã tạm khóa'
                              : 'Tạm khóa lớp',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            Icons.lock,
                            size: 22,
                            color: lop.tamKhoa ? Colors.grey : Colors.red,
                          ),
                          onPressed: lop.tamKhoa
                              ? null
                              : () => _xacNhanTamKhoaLop(lop),
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

  Widget _buildTabLopHanhChinh() {
    return Consumer2<LopProvider, KhoaProvider>(
      builder: (context, lopProvider, khoaProvider, child) {
        final dsKhoa = khoaProvider.dsKhoa;

        return Column(
          children: [
            _buildBoLocLop(lopProvider, dsKhoa),
            _buildDanhSachLop(lopProvider, dsKhoa),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTabLopHanhChinh();
  }
}
