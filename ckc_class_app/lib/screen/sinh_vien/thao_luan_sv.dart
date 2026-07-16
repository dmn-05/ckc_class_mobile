import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../utils/modal_lifecycle.dart';
import '../../widget/widget_sinhvien.dart';

class ThaoLuanSVPage extends StatefulWidget {
  final int lopHocPhanId;
  final bool chiDoc;
  const ThaoLuanSVPage({
    super.key,
    required this.lopHocPhanId,
    this.chiDoc = false,
  });

  @override
  State<ThaoLuanSVPage> createState() => _ThaoLuanSVPageState();
}

class _ThaoLuanSVPageState extends State<ThaoLuanSVPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _guiBinhLuan(SinhVienProvider p) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || p.blProcessing) return;

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final r = await p.dangBinhLuan(
      lopHocPhanId: widget.lopHocPhanId,
      noiDung: text,
    );
    if (r['success'] == true) _ctrl.clear();
    messenger.showSnackBar(
      SnackBar(
        content: Text(r['message'].toString()),
        backgroundColor: r['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8FC),
      child: Consumer<SinhVienProvider>(
        builder: (_, p, __) {
          return Column(
            children: [
              Expanded(child: _buildList(p)),
              if (!widget.chiDoc)
                SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 18,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Trao đổi với lớp...',
                            prefixIcon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE8EEF8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FilledButton(
                          onPressed: p.blProcessing
                              ? null
                              : () => _guiBinhLuan(p),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: p.blProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(SinhVienProvider p) {
    if (p.blLoading) return const Center(child: CircularProgressIndicator());
    if (p.blError != null) {
      return TrangLoi(
        loi: p.blError!,
        onTaiLai: () => p.layDanhSachBinhLuan(widget.lopHocPhanId),
      );
    }
    if (p.dsBinhLuan.isEmpty) {
      return const TrangRong(
        thongDiep:
            'Chưa có thảo luận\nHãy là người đầu tiên đặt câu hỏi hoặc chia sẻ ý kiến.',
        icon: Icons.forum_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () => p.layDanhSachBinhLuan(widget.lopHocPhanId),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        itemCount: p.dsBinhLuan.length,
        itemBuilder: (_, i) => _BinhLuanTile(
          bl: p.dsBinhLuan[i],
          chiDoc: widget.chiDoc,
        ),
      ),
    );
  }
}

class _BinhLuanTile extends StatelessWidget {
  final BinhLuanModel bl;
  final bool chiDoc;

  const _BinhLuanTile({
    required this.bl,
    required this.chiDoc,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.read<SinhVienProvider>();
    final mine = bl.laCuaToi(p.nguoiDungId);
    final color = mine
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade700;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .9,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine
              ? Theme.of(context).colorScheme.primary.withOpacity(.08)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(mine ? 22 : 6),
            bottomRight: Radius.circular(mine ? 6 : 22),
          ),
          border: Border.all(
            color: mine
                ? Theme.of(context).colorScheme.primary.withOpacity(.18)
                : const Color(0xFFE8EEF8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarTen(
              ten: bl.tenNguoiDung,
              radius: 19,
              mauNen: mine
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bl.tenNguoiDung,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ChipTrangThai(nhan: bl.tenVaiTroHienThi, mau: color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(bl.noiDung, style: const TextStyle(height: 1.35)),
                  const SizedBox(height: 8),
                  Text(
                    dinhDangNgayGio(bl.ngayTao),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (mine && !chiDoc)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade600,
                ),
                onSelected: (v) {
                  if (v == 'sua') _showEdit(context, p);
                  if (v == 'xoa') _confirmDelete(context, p);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'sua', child: Text('Sửa')),
                  PopupMenuItem(value: 'xoa', child: Text('Xóa')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SinhVienProvider p,
  ) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xóa bình luận'),
        content: const Text('Bạn chắc chắn muốn xóa bình luận này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (dongY == true) {
      await p.xoaBinhLuan(bl.id);
    }
  }

  Future<void> _showEdit(BuildContext context, SinhVienProvider p) async {
    final ctrl = TextEditingController(text: bl.noiDung);
    final noiDungMoi = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sửa bình luận'),
        content: TextField(
          controller: ctrl,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintText: 'Nhập nội dung...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              unfocusCurrentInput();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              unfocusCurrentInput();
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    await disposeControllersAfterModal([ctrl]);
    if (noiDungMoi == null || noiDungMoi.isEmpty) return;
    await p.suaBinhLuan(binhLuanId: bl.id, noiDung: noiDungMoi);
  }
}
