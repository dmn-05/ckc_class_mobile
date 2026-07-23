import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../model/giang_vien_model.dart';
import '../../provider/giang_vien_provider.dart';
import '../../widget/widget_chung_giangvien.dart';
import 'chi_tiet_thong_bao_giang_vien.dart';

class QuanLyThongBao extends StatefulWidget {
  final LopHocPhan lop;
  final bool chiDoc;

  const QuanLyThongBao({
    super.key,
    required this.lop,
    this.chiDoc = false,
  });

  @override
  State<QuanLyThongBao> createState() => _QuanLyThongBaoState();
}

class _QuanLyThongBaoState extends State<QuanLyThongBao> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GiangVienProvider>().layDanhSachBaiViet(widget.lop.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Consumer<GiangVienProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildHeader(provider),
              Expanded(child: _buildDanhSach(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(GiangVienProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.article_rounded, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bảng tin & bài viết',
                  style: TextStyle(fontWeight: FontWeight.w900, color: _text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${provider.dsBaiViet.length} bài viết',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.chiDoc)
            FilledButton.icon(
              onPressed: provider.tbProcessing
                ? null
                : () => _hienThiForm(provider),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Đăng'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDanhSach(GiangVienProvider provider) {
    if (provider.tbLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.tbError != null) {
      return TrangThaiLoi(
        loi: provider.tbError!,
        onTaiLai: () => provider.layDanhSachBaiViet(widget.lop.id),
      );
    }

    if (provider.dsBaiViet.isEmpty) {
      return TrangThaiRong(
        thongDiep: 'Chưa có bài viết nào',
        icon: Icons.article_outlined,
        nhanNut: widget.chiDoc ? null : 'Đăng bài viết',
        onNutNhan: widget.chiDoc ? null : () => _hienThiForm(provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.layDanhSachBaiViet(widget.lop.id),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: provider.dsBaiViet.length,
        itemBuilder: (_, i) =>
            _buildTheThongBao(provider.dsBaiViet[i], provider),
      ),
    );
  }

  Future<void> _moChiTietThongBao(
    ThongBao tb,
    GiangVienProvider provider,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietThongBaoGiangVien(
          lop: widget.lop,
          thongBao: tb,
          onEdit: widget.chiDoc
              ? null
              : () async => _hienThiForm(provider, thongBao: tb),
          onDelete: widget.chiDoc
              ? null
              : () async => _xacNhanXoa(tb, provider),
        ),
      ),
    );
  }

  Widget _buildTheThongBao(ThongBao tb, GiangVienProvider provider) {
    const mauGui = Color(0xFF16A34A);
    const iconGui = Icons.public_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _moChiTietThongBao(tb, provider),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tb.tieuDe,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: _text,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Tạo lúc: ${dinhDangNgayGio(tb.ngayTao)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(iconGui, size: 14, color: mauGui),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Đã đăng lên bảng tin',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mauGui,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!widget.chiDoc)
                    PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (v) {
                      if (v == 'sua') _hienThiForm(provider, thongBao: tb);
                      if (v == 'xoa') _xacNhanXoa(tb, provider);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'sua',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'xoa',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (tb.noiDung != null && tb.noiDung!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tb.noiDung!,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 13,
                      height: 1.35,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TrangThaiBadge(
                    text: tb.isHienThi ? 'Hiển thị' : 'Ẩn',
                    color: tb.isHienThi
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    icon: tb.isHienThi
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  _TrangThaiBadge(
                    text: '${tb.soBinhLuan} bình luận',
                    color: _primary,
                    icon: Icons.comment_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _hienThiForm(
    GiangVienProvider provider, {
    ThongBao? thongBao,
  }) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ThongBaoFormDialog(thongBao: thongBao),
    );

    if (data == null || !mounted) return;

    final result = thongBao == null
        ? await provider.themBaiViet(
            tieuDe: data['tieu_de']?.toString() ?? '',
            lopHocPhanId: widget.lop.id,
            noiDung: data['noi_dung']?.toString() ?? '',
            trangThai: data['trang_thai']?.toString() ?? 'hien_thi',
            tepTinMoi: List<PlatformFile>.from(data['tep_tin_moi'] as List? ?? const []),
          )
        : await provider.suaBaiViet(
            id: thongBao.id,
            tieuDe: data['tieu_de']?.toString() ?? '',
            lopHocPhanId: widget.lop.id,
            noiDung: data['noi_dung']?.toString() ?? '',
            trangThai: data['trang_thai']?.toString() ?? 'hien_thi',
            tepTinMoi: List<PlatformFile>.from(data['tep_tin_moi'] as List? ?? const []),
            tepTinXoa: List<int>.from(data['tep_tin_xoa'] as List? ?? const []),
          );

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message']?.toString() ?? '',
      laThanh: result['success'] == true,
    );
  }

  Future<void> _xacNhanXoa(ThongBao tb, GiangVienProvider provider) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Text(
          'Xóa bài viết',
          style: TextStyle(fontWeight: FontWeight.w900, color: _text),
        ),
        content: Text(
          'Bạn có chắc muốn xóa bài viết "${tb.tieuDe}" không?\n\nBài viết sẽ được ẩn khỏi sinh viên nhưng dữ liệu vẫn được giữ lại.',
          style: const TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (dongY != true || !mounted) return;

    final result = await provider.xoaBaiViet(tb.id, widget.lop.id);

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message']?.toString() ?? '',
      laThanh: result['success'] == true,
    );
  }
}

class _ThongBaoFormDialog extends StatefulWidget {
  final ThongBao? thongBao;

  const _ThongBaoFormDialog({this.thongBao});

  @override
  State<_ThongBaoFormDialog> createState() => _ThongBaoFormDialogState();
}

class _ThongBaoFormDialogState extends State<_ThongBaoFormDialog> {
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tieuDeCtrl;
  late final TextEditingController _noiDungCtrl;

  String _trangThai = 'hien_thi';
  final List<PlatformFile> _tepTinMoi = [];
  final Set<int> _tepTinXoa = <int>{};

  @override
  void initState() {
    super.initState();
    _tieuDeCtrl = TextEditingController(text: widget.thongBao?.tieuDe ?? '');
    _noiDungCtrl = TextEditingController(text: widget.thongBao?.noiDung ?? '');
    _trangThai = widget.thongBao?.trangThai ?? 'hien_thi';
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _noiDungCtrl.dispose();
    super.dispose();
  }

  Future<void> _chonTepTin() async {
    final conLai = 10 -
        ((widget.thongBao?.files.length ?? 0) - _tepTinXoa.length) -
        _tepTinMoi.length;
    if (conLai <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mỗi bài viết chỉ được đính kèm tối đa 10 file')),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final hopLe = result.files.where((file) {
      if ((file.path == null || file.path!.trim().isEmpty) &&
          (file.bytes == null || file.bytes!.isEmpty)) {
        return false;
      }
      if (file.size > 50 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File ${file.name} vượt quá 50MB')),
        );
        return false;
      }
      return true;
    }).take(conLai);

    setState(() {
      for (final file in hopLe) {
        final daCo = _tepTinMoi.any(
          (item) => item.name == file.name && item.size == file.size,
        );
        if (!daCo) _tepTinMoi.add(file);
      }
    });
  }

  Widget _buildTepTinBox() {
    final tepTinCu = widget.thongBao?.files
            .where((file) => !_tepTinXoa.contains(file.id))
            .toList() ??
        const [];
    final tongSo = tepTinCu.length + _tepTinMoi.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file_rounded, color: _primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'File đính kèm ($tongSo/10)',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: _text),
                ),
              ),
              OutlinedButton.icon(
                onPressed: tongSo >= 10 ? null : _chonTepTin,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Chọn file'),
              ),
            ],
          ),
          if (tongSo == 0) ...[
            const SizedBox(height: 8),
            const Text(
              'Có thể chọn nhiều file, tối đa 10 file và 50MB mỗi file.',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
          ...tepTinCu.map(
            (file) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined, color: _primary),
              title: Text(file.tenFile, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: file.kichThuocHienThi.isEmpty ? null : Text(file.kichThuocHienThi),
              trailing: IconButton(
                tooltip: 'Bỏ file',
                onPressed: () => setState(() => _tepTinXoa.add(file.id)),
                icon: const Icon(Icons.close_rounded, color: Colors.red),
              ),
            ),
          ),
          ..._tepTinMoi.asMap().entries.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.upload_file_rounded, color: Color(0xFF16A34A)),
              title: Text(entry.value.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${(entry.value.size / 1024 / 1024).toStringAsFixed(2)} MB'),
              trailing: IconButton(
                tooltip: 'Bỏ file',
                onPressed: () => setState(() => _tepTinMoi.removeAt(entry.key)),
                icon: const Icon(Icons.close_rounded, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _luu() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(context, {
      'tieu_de': _tieuDeCtrl.text.trim(),
      'noi_dung': _noiDungCtrl.text.trim(),
      'trang_thai': _trangThai,
      'tep_tin_moi': List<PlatformFile>.from(_tepTinMoi),
      'tep_tin_xoa': _tepTinXoa.toList(),
    });
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laSua = widget.thongBao != null;

    return AlertDialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.article_rounded, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              laSua ? 'Cập nhật bài viết' : 'Đăng bài viết',
              style: const TextStyle(fontWeight: FontWeight.w900, color: _text),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.68,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            4,
            16,
            4,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tieuDeCtrl,
                  scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 160,
                  ),
                  decoration: _inputDecoration(
                    'Tiêu đề *',
                    Icons.title_rounded,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Tiêu đề không được trống'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noiDungCtrl,
                  maxLines: 6,
                  scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 180,
                  ),
                  decoration:
                      _inputDecoration(
                        'Nội dung',
                        Icons.article_rounded,
                      ).copyWith(
                        hintText: 'Nhập nội dung bài viết...',
                        alignLabelWithHint: true,
                      ),
                ),
                const SizedBox(height: 14),
                _buildTepTinBox(),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _trangThai,
                  decoration: _inputDecoration(
                    'Trạng thái',
                    Icons.toggle_on_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'hien_thi',
                      child: Text('Hiển thị'),
                    ),
                    DropdownMenuItem(value: 'an', child: Text('Ẩn')),
                  ],
                  onChanged: (v) =>
                      setState(() => _trangThai = v ?? 'hien_thi'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton.icon(
          onPressed: _luu,
          icon: Icon(laSua ? Icons.save_rounded : Icons.send_rounded, size: 18),
          label: Text(laSua ? 'Lưu' : 'Đăng'),
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrangThaiBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _TrangThaiBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
