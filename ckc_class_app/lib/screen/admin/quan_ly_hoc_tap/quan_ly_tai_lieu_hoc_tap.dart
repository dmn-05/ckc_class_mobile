import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ckc_class_app/model/lop_hoc_phan_model.dart';
import 'package:ckc_class_app/model/tai_lieu_hoc_tap_model.dart';
import 'package:ckc_class_app/provider/lop_hoc_phan_provider.dart';
import 'package:ckc_class_app/provider/tai_lieu_hoc_tap_provider.dart';

class QuanLyTaiLieuHocTapScreen extends StatelessWidget {
  const QuanLyTaiLieuHocTapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaiLieuHocTapProvider>(
          create: (_) => TaiLieuHocTapProvider(),
        ),
        ChangeNotifierProvider<LopHocPhanProvider>(
          create: (_) => LopHocPhanProvider(),
        ),
      ],
      child: const _QuanLyTaiLieuHocTapView(),
    );
  }
}

class _QuanLyTaiLieuHocTapView extends StatefulWidget {
  const _QuanLyTaiLieuHocTapView();

  @override
  State<_QuanLyTaiLieuHocTapView> createState() =>
      _QuanLyTaiLieuHocTapViewState();
}

class _QuanLyTaiLieuHocTapViewState extends State<_QuanLyTaiLieuHocTapView> {
  final TextEditingController _timKiemController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LopHocPhanProvider>().layDanhSachLopHocPhan();
      context.read<TaiLieuHocTapProvider>().layDanhSachTaiLieu();
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

  String _textNgay(DateTime? value) {
    if (value == null) return 'Chưa cập nhật';
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    return '$d/$m/$y';
  }

  Color _mauTrangThai(String trangThai) {
    switch (trangThai) {
      case 'hien_thi':
        return Colors.green;
      case 'an':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: const OutlineInputBorder(),
    );
  }

  void _timKiem(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      context.read<TaiLieuHocTapProvider>().timKiemTaiLieu(value);
    });
  }

  Future<void> _hienThiFormTaiLieu({
    TaiLieuHocTap? taiLieu,
    required List<LopHocPhan> dsLopHocPhan,
  }) async {
    if (dsLopHocPhan.isEmpty) {
      _showSnackBar('Chưa có lớp học phần để gắn tài liệu', Colors.red);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final tieuDeController = TextEditingController(text: taiLieu?.tieuDe ?? '');
    final moTaController = TextEditingController(text: taiLieu?.moTa ?? '');
    final fileController = TextEditingController(
      text: taiLieu?.duongDanFile ?? '',
    );

    int lopHocPhanId = taiLieu?.lopHocPhanId ?? dsLopHocPhan.first.id;
    if (!dsLopHocPhan.any((lop) => lop.id == lopHocPhanId)) {
      lopHocPhanId = dsLopHocPhan.first.id;
    }

    String trangThai = taiLieu?.trangThai ?? 'hien_thi';
    if (!['hien_thi', 'an'].contains(trangThai)) trangThai = 'hien_thi';

    bool dangLuu = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                taiLieu == null
                    ? 'Thêm tài liệu học tập'
                    : 'Cập nhật tài liệu học tập',
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: tieuDeController,
                          decoration: _inputDecoration(
                            label: 'Tiêu đề tài liệu',
                            icon: Icons.title,
                            hint: 'Ví dụ: Slide Flutter buổi 1',
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty)
                              return 'Tiêu đề không được để trống';
                            if (text.length < 3) return 'Tiêu đề quá ngắn';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: lopHocPhanId,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'Lớp học phần',
                            icon: Icons.class_,
                          ),
                          items: dsLopHocPhan.map((lop) {
                            return DropdownMenuItem<int>(
                              value: lop.id,
                              child: Text(
                                '${lop.maLopHocPhan} - ${lop.tenLop} (${lop.tenMonHienThi})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setDialogState(() => lopHocPhanId = value);
                                },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: fileController,
                          decoration: _inputDecoration(
                            label: 'Đường dẫn file',
                            icon: Icons.link,
                            hint: 'Ví dụ: uploads/tailieu/flutter_buoi1.pdf',
                          ),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty)
                              return 'Đường dẫn file không được để trống';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: moTaController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            label: 'Mô tả',
                            icon: Icons.description,
                            hint: 'Nhập mô tả ngắn về tài liệu',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: trangThai,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            label: 'Trạng thái',
                            icon: Icons.toggle_on,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'hien_thi',
                              child: Text('Hiển thị'),
                            ),
                            DropdownMenuItem(value: 'an', child: Text('Ẩn')),
                          ],
                          onChanged: dangLuu
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    trangThai = value ?? 'hien_thi';
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
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: dangLuu
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false))
                            return;
                          setDialogState(() => dangLuu = true);

                          final provider = context
                              .read<TaiLieuHocTapProvider>();
                          final result = taiLieu == null
                              ? await provider.themTaiLieu(
                                  tieuDe: tieuDeController.text.trim(),
                                  moTa: moTaController.text.trim(),
                                  duongDanFile: fileController.text.trim(),
                                  lopHocPhanId: lopHocPhanId,
                                  trangThai: trangThai,
                                )
                              : await provider.suaTaiLieu(
                                  id: taiLieu.id,
                                  tieuDe: tieuDeController.text.trim(),
                                  moTa: moTaController.text.trim(),
                                  duongDanFile: fileController.text.trim(),
                                  lopHocPhanId: lopHocPhanId,
                                  trangThai: trangThai,
                                );

                          if (!mounted) return;
                          setDialogState(() => dangLuu = false);

                          final success = result['success'] == true;
                          final message =
                              result['message']?.toString() ??
                              (success
                                  ? 'Thao tác thành công'
                                  : 'Thao tác thất bại');
                          if (success) Navigator.pop(dialogContext);
                          _showSnackBar(
                            message,
                            success ? Colors.green : Colors.red,
                          );
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

    tieuDeController.dispose();
    moTaController.dispose();
    fileController.dispose();
  }

  Future<void> _doiTrangThai(TaiLieuHocTap taiLieu) async {
    final trangThaiMoi = taiLieu.hienThi ? 'an' : 'hien_thi';
    final result = await context
        .read<TaiLieuHocTapProvider>()
        .capNhatTrangThaiTaiLieu(id: taiLieu.id, trangThai: trangThaiMoi);

    if (!mounted) return;
    final success = result['success'] == true;
    final message = result['message']?.toString() ?? 'Đã cập nhật trạng thái';
    _showSnackBar(message, success ? Colors.green : Colors.red);
  }

  Widget _buildBoLoc({
    required TaiLieuHocTapProvider provider,
    required List<LopHocPhan> dsLopHocPhan,
  }) {
    final dangCoBoLoc =
        provider.lopHocPhanId != 0 ||
        provider.trangThai.isNotEmpty ||
        _timKiemController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
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
                        labelText: 'Tìm kiếm tài liệu',
                        hintText: 'Tiêu đề, mô tả, file, lớp, môn học...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _timKiemController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _timKiemController.clear();
                                  provider.timKiemTaiLieu('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear, size: 20),
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
                    onPressed: () =>
                        _hienThiFormTaiLieu(dsLopHocPhan: dsLopHocPhan),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Thêm'),
                  ),
                ),
              ],
            ),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                dense: true,
                initiallyExpanded: false,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                leading: Icon(
                  dangCoBoLoc ? Icons.filter_alt : Icons.filter_alt_outlined,
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
                          width: 330,
                          child: DropdownButtonFormField<int>(
                            value: provider.lopHocPhanId,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              label: 'Lớp học phần',
                              icon: Icons.class_,
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text('Tất cả lớp học phần'),
                              ),
                              ...dsLopHocPhan.map((lop) {
                                return DropdownMenuItem<int>(
                                  value: lop.id,
                                  child: Text(
                                    '${lop.maLopHocPhan} - ${lop.tenLop}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) =>
                                provider.locTheoLopHocPhan(value ?? 0),
                          ),
                        ),
                        SizedBox(
                          width: 240,
                          child: DropdownButtonFormField<String>(
                            value: provider.trangThai,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              label: 'Trạng thái',
                              icon: Icons.toggle_on,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '',
                                child: Text('Tất cả trạng thái'),
                              ),
                              DropdownMenuItem(
                                value: 'hien_thi',
                                child: Text('Hiển thị'),
                              ),
                              DropdownMenuItem(
                                value: 'an',
                                child: Text('Đã ẩn'),
                              ),
                            ],
                            onChanged: (value) =>
                                provider.locTheoTrangThai(value ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipTrangThai(TaiLieuHocTap taiLieu) {
    final color = _mauTrangThai(taiLieu.trangThai);
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
          Icon(
            taiLieu.hienThi ? Icons.visibility : Icons.visibility_off,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            taiLieu.tenTrangThai,
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

  Widget _dongThongTin(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
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

  Widget _buildDanhSach({
    required TaiLieuHocTapProvider provider,
    required List<LopHocPhan> dsLopHocPhan,
  }) {
    if (provider.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Expanded(
        child: Center(
          child: Text(
            provider.error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (provider.dsTaiLieu.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Chưa có tài liệu học tập')),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        itemCount: provider.dsTaiLieu.length,
        itemBuilder: (context, index) {
          final taiLieu = provider.dsTaiLieu[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(
                          taiLieu.duongDanFile.toLowerCase().endsWith('.pdf')
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          taiLieu.tieuDe,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _dongThongTin('Lớp HP', taiLieu.tenLopHienThi),
                  _dongThongTin('Môn học', taiLieu.tenMonHienThi),
                  _dongThongTin('File', taiLieu.duongDanFile),
                  _dongThongTin('Người tạo', taiLieu.tenNguoiTaoHienThi),
                  _dongThongTin('Ngày tạo', _textNgay(taiLieu.ngayTao)),
                  if (taiLieu.moTa.isNotEmpty)
                    _dongThongTin('Mô tả', taiLieu.moTa),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChipTrangThai(taiLieu),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Sửa',
                        onPressed: () => _hienThiFormTaiLieu(
                          taiLieu: taiLieu,
                          dsLopHocPhan: dsLopHocPhan,
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: taiLieu.hienThi
                            ? 'Ẩn tài liệu'
                            : 'Hiển thị tài liệu',
                        onPressed: () => _doiTrangThai(taiLieu),
                        icon: Icon(
                          taiLieu.hienThi
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tài liệu học tập')),
      body: Consumer2<TaiLieuHocTapProvider, LopHocPhanProvider>(
        builder: (context, taiLieuProvider, lopHpProvider, _) {
          return Column(
            children: [
              _buildBoLoc(
                provider: taiLieuProvider,
                dsLopHocPhan: lopHpProvider.dsLopHocPhan,
              ),
              _buildDanhSach(
                provider: taiLieuProvider,
                dsLopHocPhan: lopHpProvider.dsLopHocPhan,
              ),
            ],
          );
        },
      ),
    );
  }
}
