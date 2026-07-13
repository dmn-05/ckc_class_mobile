import 'dart:async';
import 'package:ckc_class_app/provider/khoa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ckc_class_app/model/khoa_bo_mon_model.dart';

class QuanLyKhoaBoMonScreen extends StatefulWidget {
  const QuanLyKhoaBoMonScreen({super.key});

  @override
  State<QuanLyKhoaBoMonScreen> createState() => _QuanLyKhoaBoMonScreenState();
}

class _QuanLyKhoaBoMonScreenState extends State<QuanLyKhoaBoMonScreen> {
  final TextEditingController _timKiemController = TextEditingController();
  Timer? _debounce;
  String _trangThaiLoc = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<KhoaProvider>().layDanhSachKhoa();
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
      context.read<KhoaProvider>().timKiemKhoa(value);
    });
  }

  void _doiTrangThaiLoc(String? value) {
    final trangThai = value ?? '';

    setState(() {
      _trangThaiLoc = trangThai;
    });

    context.read<KhoaProvider>().locTheoTrangThai(trangThai);
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

  Future<void> _hienThiFormKhoa({Khoa? khoa}) async {
    final formKey = GlobalKey<FormState>();

    final maKhoaController = TextEditingController(text: khoa?.maKhoa ?? '');

    final tenKhoaController = TextEditingController(text: khoa?.tenKhoa ?? '');

    String trangThai = khoa?.trangThai ?? 'dang_hoat_dong';
    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(khoa == null ? 'Thêm Khoa' : 'Sửa Khoa'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: maKhoaController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Mã khoa',
                            hintText: 'Ví dụ: CNTT',
                            prefixIcon: Icon(Icons.qr_code),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ma = value?.trim() ?? '';

                            if (ma.isEmpty) {
                              return 'Mã khoa không được để trống';
                            }

                            if (ma.length < 2) {
                              return 'Mã khoa quá ngắn';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: tenKhoaController,
                          decoration: const InputDecoration(
                            labelText: 'Tên khoa',
                            hintText: 'Nhập tên khoa',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final ten = value?.trim() ?? '';

                            if (ten.isEmpty) {
                              return 'Tên khoa không được để trống';
                            }

                            if (ten.length < 2) {
                              return 'Tên khoa quá ngắn';
                            }

                            return null;
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

                          final maKhoa = maKhoaController.text.trim();
                          final tenKhoa = tenKhoaController.text.trim();

                          final provider = context.read<KhoaProvider>();

                          final result = khoa == null
                              ? await provider.themKhoa(
                                  maKhoa: maKhoa,
                                  tenKhoa: tenKhoa,
                                  trangThai: trangThai,
                                )
                              : await provider.suaKhoa(
                                  id: khoa.id,
                                  maKhoa: maKhoa,
                                  tenKhoa: tenKhoa,
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

    maKhoaController.dispose();
    tenKhoaController.dispose();
  }

  Future<void> _xacNhanXoa(Khoa khoa) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận ngừng hoạt động'),
          content: Text(
            'Bạn có chắc muốn chuyển khoa "${khoa.tenKhoa}" sang trạng thái ngừng hoạt động không?',
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

    final result = await context.read<KhoaProvider>().xoaKhoa(khoa.id);

    if (!mounted) return;

    final success = result['success'] == true;
    final message =
        result['message']?.toString() ??
        (success ? 'Ngừng hoạt động thành công' : 'Thao tác thất bại');

    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _buildThanhTimKiemVaBoLoc() {
    final provider = context.read<KhoaProvider>();
    final dangCoBoLoc =
        _trangThaiLoc.isNotEmpty || _timKiemController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 430;

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
                            labelText: 'Tìm kiếm khoa',
                            hintText: 'Mã khoa, tên khoa',
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
                                      provider.timKiemKhoa('');
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
                        onPressed: () => _hienThiFormKhoa(),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(isSmall ? 'Thêm' : 'Thêm khoa'),
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
                                _trangThaiLoc = '';
                              });
                              provider.xoaBoLoc();
                            },
                          )
                        : const Icon(Icons.expand_more),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
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
            );
          },
        ),
      ),
    );
  }

 

  Widget _buildTrangThaiRong() {
    return RefreshIndicator(
      onRefresh: () => context.read<KhoaProvider>().taiLaiDanhSach(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.account_balance, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Chưa có khoa nào',
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
                context.read<KhoaProvider>().taiLaiDanhSach();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipTrangThai(Khoa khoa) {
    final mau = _mauTrangThai(khoa.trangThai);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: mau.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mau.withOpacity(0.5)),
      ),
      child: Text(
        khoa.tenTrangThai,
        style: TextStyle(color: mau, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDanhSach(List<Khoa> dsKhoa) {
    return RefreshIndicator(
      onRefresh: () => context.read<KhoaProvider>().taiLaiDanhSach(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: dsKhoa.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final khoa = dsKhoa[index];

          return Card(
            elevation: 1,
            child: ListTile(
              title: Text(
                khoa.tenKhoa,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã khoa: ${khoa.maKhoa}'),
                    const SizedBox(height: 6),
                    _buildChipTrangThai(khoa),
                  ],
                ),
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Sửa',
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _hienThiFormKhoa(khoa: khoa),
                  ),
                  IconButton(
                    tooltip: khoa.dangHoatDong
                        ? 'Ngừng hoạt động'
                        : 'Khoa đã ngừng hoạt động',
                    icon: Icon(
                      Icons.block,
                      color: khoa.dangHoatDong ? Colors.red : Colors.grey,
                    ),
                    onPressed: khoa.dangHoatDong
                        ? () => _xacNhanXoa(khoa)
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
    return Consumer<KhoaProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildThanhTimKiemVaBoLoc(),

            if (provider.isProcessing)
              const LinearProgressIndicator(minHeight: 2),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null && provider.dsKhoa.isEmpty) {
                    return _buildLoi(provider.error!);
                  }

                  if (provider.dsKhoa.isEmpty) {
                    return _buildTrangThaiRong();
                  }

                  return _buildDanhSach(provider.dsKhoa);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
