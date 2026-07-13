import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/khoa_bo_mon_model.dart';
import '../../../provider/bo_mon_provider.dart';
import '../../../provider/khoa_provider.dart';
import '../../../provider/mon_hoc_provider.dart';

class QuanLyMonHocScreen extends StatefulWidget {
  const QuanLyMonHocScreen({super.key});

  @override
  State<QuanLyMonHocScreen> createState() => _QuanLyMonHocScreenState();
}

class _QuanLyMonHocScreenState extends State<QuanLyMonHocScreen> {
  final TextEditingController _timKiemController = TextEditingController();

  Timer? _debounce;
  int _khoaIdLoc = 0;
  int _boMonIdLoc = 0;
  String _trangThaiLoc = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<KhoaProvider>().layDanhSachKhoa(tuKhoa: '', trangThai: '');

      context.read<BoMonProvider>().layDanhSachBoMon(
        tuKhoa: '',
        khoaId: 0,
        trangThai: '',
      );

      context.read<MonHocProvider>().layDanhSachMonHoc(
        tuKhoa: '',
        khoaId: 0,
        boMonId: 0,
        trangThai: '',
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timKiemController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _mauTrangThai(String trangThai) {
    switch (trangThai) {
      case 'dang_mo':
        return Colors.green;
      case 'ngung_su_dung':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  void _timKiem(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<MonHocProvider>().timKiemMonHoc(value);
    });
  }

  void _doiKhoaLoc(int? value) {
    final khoaId = value ?? 0;

    setState(() {
      _khoaIdLoc = khoaId;
      _boMonIdLoc = 0;
    });

    context.read<MonHocProvider>().layDanhSachMonHoc(
      khoaId: khoaId,
      boMonId: 0,
    );
  }

  void _doiBoMonLoc(int? value) {
    final boMonId = value ?? 0;

    setState(() {
      _boMonIdLoc = boMonId;
    });

    context.read<MonHocProvider>().locTheoBoMon(boMonId);
  }

  void _doiTrangThaiLoc(String? value) {
    final trangThai = value ?? '';

    setState(() {
      _trangThaiLoc = trangThai;
    });

    context.read<MonHocProvider>().locTheoTrangThai(trangThai);
  }

  Future<void> _hienThiFormMonHoc({
    MonHoc? monHoc,
    required List<Khoa> dsKhoa,
    required List<BoMon> dsBoMon,
  }) async {
    final formKey = GlobalKey<FormState>();

    final maMonController = TextEditingController(text: monHoc?.maMon ?? '');

    final tenMonController = TextEditingController(text: monHoc?.tenMon ?? '');
    final tinChiController = TextEditingController(
      text: (monHoc?.tinChi ?? 3).toString(),
    );

    int khoaId = monHoc?.khoaId ?? 0;
    int boMonId = monHoc?.boMonId ?? 0;
    String trangThai = monHoc?.trangThai ?? 'dang_mo';
    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dsBoMonTheoKhoa = khoaId <= 0
                ? <BoMon>[]
                : dsBoMon.where((bm) => bm.khoaId == khoaId).toList();

            final boMonHopLe = dsBoMonTheoKhoa.any((bm) => bm.id == boMonId);

            if (!boMonHopLe) {
              boMonId = 0;
            }

            return AlertDialog(
              title: Text(monHoc == null ? 'Thêm Môn học' : 'Sửa Môn học'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: maMonController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Mã môn học',
                            hintText: 'Ví dụ: LT_FLUTTER',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ma = value?.trim() ?? '';

                            if (ma.isEmpty) {
                              return 'Mã môn học không được để trống';
                            }

                            if (ma.length < 2) {
                              return 'Mã môn học quá ngắn';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: tenMonController,
                          decoration: const InputDecoration(
                            labelText: 'Tên môn học',
                            hintText: 'Nhập tên môn học',
                            prefixIcon: Icon(Icons.book),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ten = value?.trim() ?? '';

                            if (ten.isEmpty) {
                              return 'Tên môn học không được để trống';
                            }

                            if (ten.length < 2) {
                              return 'Tên môn học quá ngắn';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: tinChiController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số tín chỉ',
                            hintText: 'Ví dụ: 3',
                            prefixIcon: Icon(Icons.numbers),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';

                            if (text.isEmpty) {
                              return 'Số tín chỉ không được để trống';
                            }

                            final tinChi = int.tryParse(text);

                            if (tinChi == null) {
                              return 'Số tín chỉ phải là số';
                            }

                            if (tinChi <= 0 || tinChi > 10) {
                              return 'Số tín chỉ phải từ 1 đến 10';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        DropdownButtonFormField<int>(
                          value: khoaId,
                          decoration: const InputDecoration(
                            labelText: 'Khoa',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Chọn khoa'),
                            ),
                            ...dsKhoa.map(
                              (khoa) => DropdownMenuItem<int>(
                                value: khoa.id,
                                child: Text(
                                  '${khoa.maKhoa} - ${khoa.tenKhoa}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn khoa';
                            }

                            return null;
                          },
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    khoaId = value ?? 0;
                                    boMonId = 0;
                                  });
                                },
                        ),

                        const SizedBox(height: 14),

                        DropdownButtonFormField<int>(
                          value: boMonId,
                          decoration: const InputDecoration(
                            labelText: 'Bộ môn',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Chọn bộ môn'),
                            ),
                            ...dsBoMonTheoKhoa.map(
                              (boMon) => DropdownMenuItem<int>(
                                value: boMon.id,
                                child: Text(
                                  '${boMon.maBoMon} - ${boMon.tenBoMon}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value <= 0) {
                              return 'Vui lòng chọn bộ môn';
                            }

                            return null;
                          },
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    boMonId = value ?? 0;
                                  });
                                },
                        ),

                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: trangThai,
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
                              value: 'ngung_su_dung',
                              child: Text('Ngừng sử dụng'),
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
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: dangLuu
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            dangLuu = true;
                          });

                          final provider = context.read<MonHocProvider>();
                          final tinChi = int.parse(
                            tinChiController.text.trim(),
                          );
                          final result = monHoc == null
                              ? await provider.themMonHoc(
                                  maMon: maMonController.text.trim(),
                                  tenMon: tenMonController.text.trim(),
                                  khoaId: khoaId,
                                  boMonId: boMonId,
                                  trangThai: trangThai,
                                  tinChi: tinChi,
                                )
                              : await provider.suaMonHoc(
                                  id: monHoc.id,
                                  maMon: maMonController.text.trim(),
                                  tenMon: tenMonController.text.trim(),
                                  khoaId: khoaId,
                                  boMonId: boMonId,
                                  trangThai: trangThai,
                                  tinChi: tinChi,
                                );

                          if (!mounted) return;

                          final success = result['success'] == true;
                          final message =
                              result['message']?.toString() ??
                              (success
                                  ? 'Thao tác thành công'
                                  : 'Thao tác thất bại');

                          if (success) {
                            if (Navigator.canPop(dialogContext)) {
                              Navigator.pop(dialogContext);
                            }

                            _showSnackBar(message, Colors.green);
                          } else {
                            setDialogState(() {
                              dangLuu = false;
                            });

                            _showSnackBar(message, Colors.red);
                          }
                        },
                  icon: dangLuu
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

    maMonController.dispose();
    tenMonController.dispose();
    tinChiController.dispose();
  }

  Future<void> _xacNhanXoa(MonHoc monHoc) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận ngừng sử dụng'),
          content: Text(
            'Bạn có chắc muốn chuyển môn học "${monHoc.tenMon}" sang trạng thái ngừng sử dụng không?',
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
              icon: const Icon(Icons.block),
              label: const Text('Ngừng sử dụng'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    final result = await context.read<MonHocProvider>().xoaMonHoc(monHoc.id);

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Ngừng sử dụng thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _buildChipTrangThai(MonHoc monHoc) {
    final mau = _mauTrangThai(monHoc.trangThai);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: mau.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mau.withOpacity(0.5)),
      ),
      child: Text(
        monHoc.tenTrangThai,
        style: TextStyle(color: mau, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

Widget _buildThanhTimKiemVaBoLoc({
    required List<Khoa> dsKhoa,
    required List<BoMon> dsBoMon,
  }) {
    final provider = context.read<MonHocProvider>();
    final dsBoMonTheoKhoa = _khoaIdLoc <= 0
        ? dsBoMon
        : dsBoMon.where((bm) => bm.khoaId == _khoaIdLoc).toList();

    final boMonHopLe =
        _boMonIdLoc == 0 || dsBoMonTheoKhoa.any((bm) => bm.id == _boMonIdLoc);

    if (!boMonHopLe) {
      _boMonIdLoc = 0;
    }

    final coDuLieuNen = dsKhoa.isNotEmpty && dsBoMon.isNotEmpty;
    final dangCoBoLoc =
        _khoaIdLoc != 0 ||
        _boMonIdLoc != 0 ||
        _trangThaiLoc.isNotEmpty ||
        _timKiemController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final isSmall = constraints.maxWidth < 430;
            final filterWidth =
                isWide ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth;

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
                          onChanged: _timKiem,
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Tìm kiếm môn học',
                            hintText: 'Mã môn, tên môn, khoa, bộ môn',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _timKiemController.text.isEmpty
                                ? null
                                : IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _timKiemController.clear();
                                      setState(() {});
                                      provider.timKiemMonHoc('');
                                    },
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: coDuLieuNen
                            ? () => _hienThiFormMonHoc(
                                  dsKhoa: dsKhoa,
                                  dsBoMon: dsBoMon,
                                )
                            : null,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(isSmall ? 'Thêm' : 'Thêm môn'),
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
                              _timKiemController.clear();
                              setState(() {
                                _khoaIdLoc = 0;
                                _boMonIdLoc = 0;
                                _trangThaiLoc = '';
                              });
                              provider.xoaBoLoc();
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
                              value: _khoaIdLoc,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: false,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 14),
                                labelText: 'Khoa',
                                prefixIcon:
                                    Icon(Icons.account_balance, size: 20),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text('Tất cả khoa'),
                                ),
                                ...dsKhoa.map(
                                  (khoa) => DropdownMenuItem<int>(
                                    value: khoa.id,
                                    child: Text(
                                      '${khoa.maKhoa} - ${khoa.tenKhoa}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _doiKhoaLoc,
                            ),
                          ),
                          SizedBox(
                            width: filterWidth,
                            child: DropdownButtonFormField<int>(
                              value: _boMonIdLoc,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                isDense: false,
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                contentPadding: EdgeInsets.fromLTRB(12, 18, 12, 14),
                                labelText: 'Bộ môn',
                                prefixIcon:
                                    Icon(Icons.menu_book_outlined, size: 20),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text('Tất cả bộ môn'),
                                ),
                                ...dsBoMonTheoKhoa.map(
                                  (boMon) => DropdownMenuItem<int>(
                                    value: boMon.id,
                                    child: Text(
                                      '${boMon.maBoMon} - ${boMon.tenBoMon}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: _doiBoMonLoc,
                            ),
                          ),
                          SizedBox(
                            width: filterWidth,
                            child: DropdownButtonFormField<String>(
                              value: _trangThaiLoc,
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
                                  value: 'dang_mo',
                                  child: Text('Đang mở'),
                                ),
                                DropdownMenuItem(
                                  value: 'ngung_su_dung',
                                  child: Text('Ngừng sử dụng'),
                                ),
                              ],
                              onChanged: _doiTrangThaiLoc,
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


  Widget _buildDanhSach({
    required List<MonHoc> dsMonHoc,
    required List<Khoa> dsKhoa,
    required List<BoMon> dsBoMon,
  }) {
    return RefreshIndicator(
      onRefresh: () => context.read<MonHocProvider>().taiLaiDanhSach(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: dsMonHoc.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final monHoc = dsMonHoc[index];

          final maKhoa = monHoc.khoa?.maKhoa ?? monHoc.maKhoa ?? '';
          final tenKhoa =
              monHoc.khoa?.tenKhoa ?? monHoc.tenKhoa ?? 'Chưa rõ khoa';

          final maBoMon = monHoc.boMon?.maBoMon ?? monHoc.maBoMon ?? '';
          final tenBoMon =
              monHoc.boMon?.tenBoMon ?? monHoc.tenBoMon ?? 'Chưa rõ bộ môn';

          return Card(
            elevation: 1,
            child: ListTile(
              title: Text(
                monHoc.tenMon,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã môn: ${monHoc.maMon}'),
                    const SizedBox(height: 4),
                    Text('Số tín chỉ: ${monHoc.tinChi}'),
                    const SizedBox(height: 4),
                    Text(
                      maKhoa.isEmpty
                          ? 'Khoa: $tenKhoa'
                          : 'Khoa: $maKhoa - $tenKhoa',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maBoMon.isEmpty
                          ? 'Bộ môn: $tenBoMon'
                          : 'Bộ môn: $maBoMon - $tenBoMon',
                    ),
                    const SizedBox(height: 6),
                    _buildChipTrangThai(monHoc),
                  ],
                ),
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Sửa',
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _hienThiFormMonHoc(
                        monHoc: monHoc,
                        dsKhoa: dsKhoa,
                        dsBoMon: dsBoMon,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: monHoc.dangMo
                        ? 'Ngừng sử dụng'
                        : 'Môn học đã ngừng sử dụng',
                    icon: Icon(
                      Icons.block,
                      color: monHoc.dangMo ? Colors.red : Colors.grey,
                    ),
                    onPressed: monHoc.dangMo ? () => _xacNhanXoa(monHoc) : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrangThaiRong() {
    return RefreshIndicator(
      onRefresh: () => context.read<MonHocProvider>().taiLaiDanhSach(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.book, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Chưa có môn học nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoi(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MonHocProvider>().taiLaiDanhSach();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MonHocProvider, KhoaProvider, BoMonProvider>(
      builder: (context, monHocProvider, khoaProvider, boMonProvider, _) {
        final dsKhoa = khoaProvider.dsKhoa;
        final dsBoMon = boMonProvider.dsBoMon;

        return Column(
          children: [
            _buildThanhTimKiemVaBoLoc(dsKhoa: dsKhoa, dsBoMon: dsBoMon),


            if ((dsKhoa.isEmpty || dsBoMon.isEmpty) &&
                !khoaProvider.isLoading &&
                !boMonProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Bạn cần có Khoa và Bộ môn trước khi thêm Môn học.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            if (monHocProvider.isProcessing)
              const LinearProgressIndicator(minHeight: 2),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (monHocProvider.isLoading ||
                      khoaProvider.isLoading ||
                      boMonProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (monHocProvider.error != null &&
                      monHocProvider.dsMonHoc.isEmpty) {
                    return _buildLoi(monHocProvider.error!);
                  }

                  if (monHocProvider.dsMonHoc.isEmpty) {
                    return _buildTrangThaiRong();
                  }

                  return _buildDanhSach(
                    dsMonHoc: monHocProvider.dsMonHoc,
                    dsKhoa: dsKhoa,
                    dsBoMon: dsBoMon,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
