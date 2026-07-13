import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/khoa_bo_mon_model.dart';
import '../../../provider/bo_mon_provider.dart';
import '../../../provider/khoa_provider.dart';

class QuanLyBoMonScreen extends StatefulWidget {
  const QuanLyBoMonScreen({super.key});

  @override
  State<QuanLyBoMonScreen> createState() => _QuanLyBoMonScreenState();
}

class _QuanLyBoMonScreenState extends State<QuanLyBoMonScreen> {
  final TextEditingController _timKiemController = TextEditingController();

  Timer? _debounce;
  int _khoaIdLoc = 0;
  String _trangThaiLoc = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<KhoaProvider>().layDanhSachKhoa(tuKhoa: '', trangThai: '');

      context.read<BoMonProvider>().layDanhSachBoMon();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timKiemController.dispose();
    super.dispose();
  }

  void _timKiem(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<BoMonProvider>().timKiemBoMon(value);
    });
  }

  void _doiKhoaLoc(int? value) {
    final khoaId = value ?? 0;

    setState(() {
      _khoaIdLoc = khoaId;
    });

    context.read<BoMonProvider>().locTheoKhoa(khoaId);
  }

  void _doiTrangThaiLoc(String? value) {
    final trangThai = value ?? '';

    setState(() {
      _trangThaiLoc = trangThai;
    });

    context.read<BoMonProvider>().locTheoTrangThai(trangThai);
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
      case 'dang_hoat_dong':
        return Colors.green;
      case 'ngung_hoat_dong':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _hienThiFormBoMon({
    BoMon? boMon,
    required List<Khoa> dsKhoa,
  }) async {
    final formKey = GlobalKey<FormState>();

    final maBoMonController = TextEditingController(text: boMon?.maBoMon ?? '');

    final tenBoMonController = TextEditingController(
      text: boMon?.tenBoMon ?? '',
    );

    int khoaId = boMon?.khoaId ?? 0;
    String trangThai = boMon?.trangThai ?? 'dang_hoat_dong';
    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(boMon == null ? 'Thêm Bộ môn' : 'Sửa Bộ môn'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: maBoMonController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Mã bộ môn',
                            hintText: 'Ví dụ: BM_LT',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ma = value?.trim() ?? '';

                            if (ma.isEmpty) {
                              return 'Mã bộ môn không được để trống';
                            }

                            if (ma.length < 2) {
                              return 'Mã bộ môn quá ngắn';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: tenBoMonController,
                          decoration: const InputDecoration(
                            labelText: 'Tên bộ môn',
                            hintText: 'Nhập tên bộ môn',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ten = value?.trim() ?? '';

                            if (ten.isEmpty) {
                              return 'Tên bộ môn không được để trống';
                            }

                            if (ten.length < 2) {
                              return 'Tên bộ môn quá ngắn';
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
                              value: 'dang_hoat_dong',
                              child: Text('Đang hoạt động'),
                            ),
                            DropdownMenuItem(
                              value: 'ngung_hoat_dong',
                              child: Text('Ngừng hoạt động'),
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
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            dangLuu = true;
                          });

                          final maBoMon = maBoMonController.text.trim();
                          final tenBoMon = tenBoMonController.text.trim();

                          final provider = context.read<BoMonProvider>();

                          final result = boMon == null
                              ? await provider.themBoMon(
                                  maBoMon: maBoMon,
                                  tenBoMon: tenBoMon,
                                  khoaId: khoaId,
                                  trangThai: trangThai,
                                )
                              : await provider.suaBoMon(
                                  id: boMon.id,
                                  maBoMon: maBoMon,
                                  tenBoMon: tenBoMon,
                                  khoaId: khoaId,
                                  trangThai: trangThai,
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

    maBoMonController.dispose();
    tenBoMonController.dispose();
  }

  Future<void> _xacNhanXoa(BoMon boMon) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận ngừng hoạt động'),
          content: Text(
            'Bạn có chắc muốn chuyển bộ môn "${boMon.tenBoMon}" sang trạng thái ngừng hoạt động không?',
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
              label: const Text('Ngừng hoạt động'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    final result = await context.read<BoMonProvider>().xoaBoMon(boMon.id);

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Ngừng hoạt động thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _buildThanhTimKiemVaBoLoc(List<Khoa> dsKhoa) {
    final provider = context.read<BoMonProvider>();
    final coKhoaDangHoatDong = dsKhoa.any((khoa) => khoa.dangHoatDong);
    final dangCoBoLoc =
        _khoaIdLoc != 0 ||
        _trangThaiLoc.isNotEmpty ||
        _timKiemController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            final isSmall = constraints.maxWidth < 430;
            final filterWidth =
                isWide ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;

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
                            labelText: 'Tìm kiếm bộ môn',
                            hintText: 'Mã bộ môn, tên bộ môn, khoa',
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
                                      provider.timKiemBoMon('');
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
                        onPressed: coKhoaDangHoatDong
                            ? () => _hienThiFormBoMon(dsKhoa: dsKhoa)
                            : null,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(isSmall ? 'Thêm' : 'Thêm bộ môn'),
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
                                  value: 'dang_hoat_dong',
                                  child: Text('Đang hoạt động'),
                                ),
                                DropdownMenuItem(
                                  value: 'ngung_hoat_dong',
                                  child: Text('Ngừng hoạt động'),
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



  Widget _buildTrangThaiRong() {
    return RefreshIndicator(
      onRefresh: () => context.read<BoMonProvider>().taiLaiDanhSach(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.business, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Chưa có bộ môn nào',
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
                context.read<BoMonProvider>().taiLaiDanhSach();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipTrangThai(BoMon boMon) {
    final mau = _mauTrangThai(boMon.trangThai);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: mau.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mau.withOpacity(0.5)),
      ),
      child: Text(
        boMon.tenTrangThai,
        style: TextStyle(color: mau, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDanhSach({
    required List<BoMon> dsBoMon,
    required List<Khoa> dsKhoa,
  }) {
    return RefreshIndicator(
      onRefresh: () => context.read<BoMonProvider>().taiLaiDanhSach(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: dsBoMon.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final boMon = dsBoMon[index];

          final tenKhoa = boMon.khoa?.tenKhoa ?? 'Chưa rõ khoa';
          final maKhoa = boMon.khoa?.maKhoa ?? '';

          return Card(
            elevation: 1,
            child: ListTile(
              title: Text(
                boMon.tenBoMon,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã bộ môn: ${boMon.maBoMon}'),
                    const SizedBox(height: 4),
                    Text(
                      maKhoa.isEmpty
                          ? 'Khoa: $tenKhoa'
                          : 'Khoa: $maKhoa - $tenKhoa',
                    ),
                    const SizedBox(height: 6),
                    _buildChipTrangThai(boMon),
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
                      _hienThiFormBoMon(boMon: boMon, dsKhoa: dsKhoa);
                    },
                  ),
                  IconButton(
                    tooltip: boMon.dangHoatDong
                        ? 'Ngừng hoạt động'
                        : 'Bộ môn đã ngừng hoạt động',
                    icon: Icon(
                      Icons.block,
                      color: boMon.dangHoatDong ? Colors.red : Colors.grey,
                    ),
                    onPressed: boMon.dangHoatDong
                        ? () => _xacNhanXoa(boMon)
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BoMonProvider, KhoaProvider>(
      builder: (context, boMonProvider, khoaProvider, _) {
        final dsKhoa = khoaProvider.dsKhoa;

        return Column(
          children: [
            _buildThanhTimKiemVaBoLoc(dsKhoa),

            if (dsKhoa.isEmpty && !khoaProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Bạn cần có ít nhất một khoa trước khi thêm bộ môn.',
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            if (boMonProvider.isProcessing)
              const LinearProgressIndicator(minHeight: 2),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (boMonProvider.isLoading || khoaProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (boMonProvider.error != null &&
                      boMonProvider.dsBoMon.isEmpty) {
                    return _buildLoi(boMonProvider.error!);
                  }

                  if (boMonProvider.dsBoMon.isEmpty) {
                    return _buildTrangThaiRong();
                  }

                  return _buildDanhSach(
                    dsBoMon: boMonProvider.dsBoMon,
                    dsKhoa: dsKhoa,
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
