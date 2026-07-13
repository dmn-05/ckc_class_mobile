import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/giang_vien_model.dart';
import '../../model/sinh_vien_model.dart' show BinhLuanModel;
import '../../services/sinh_vien_service.dart';
import '../../widget/widget_chung_giangvien.dart';

class ChiTietThongBaoGiangVien extends StatelessWidget {
  final LopHocPhan lop;
  final ThongBao thongBao;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;

  const ChiTietThongBaoGiangVien({
    super.key,
    required this.lop,
    required this.thongBao,
    this.onEdit,
    this.onDelete,
  });

  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  Future<void> _openFile(ThongBaoFile file, BuildContext context) async {
    final uri = Uri.tryParse(file.duongDan);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được file đính kèm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guiColor = thongBao.daHenGio ? const Color(0xFFF97316) : const Color(0xFF16A34A);
    final guiIcon = thongBao.daHenGio ? Icons.schedule_send_rounded : Icons.visibility_rounded;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        title: const Text(
          'Chi tiết thông báo',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'sua') {
                await onEdit?.call();
              } else if (value == 'xoa') {
                await onDelete?.call();
              }
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
                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit == null
                      ? null
                      : () async {
                          await onEdit!.call();
                        },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Sửa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDelete == null
                      ? null
                      : () async {
                          await onDelete!.call();
                        },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Xóa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x260D9488), blurRadius: 24, offset: Offset(0, 12)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thongBao.tieuDe,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lop.tenHienThi,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WhiteChip(
                      icon: thongBao.isHienThi ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      text: thongBao.isHienThi ? 'Hiển thị' : 'Ẩn',
                    ),
                    _WhiteChip(icon: guiIcon, text: thongBao.tenTrangThaiGui),
                    _WhiteChip(icon: Icons.comment_outlined, text: '${thongBao.soBinhLuan} bình luận'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Nội dung thông báo',
            icon: Icons.article_rounded,
            children: [
              Text(
                (thongBao.noiDung == null || thongBao.noiDung!.trim().isEmpty)
                    ? 'Thông báo này chưa có nội dung chi tiết.'
                    : thongBao.noiDung!,
                style: const TextStyle(
                  color: _text,
                  height: 1.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (thongBao.files.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionCard(
              title: 'File đính kèm',
              icon: Icons.attach_file_rounded,
              children: thongBao.files
                  .map((f) => _FileTile(file: f, onTap: () => _openFile(f, context)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Thông tin gửi',
            icon: Icons.schedule_rounded,
            children: [
              _InfoRow(
                icon: guiIcon,
                label: 'Trạng thái gửi',
                value: thongBao.thoiGianGui == null
                    ? 'Gửi ngay'
                    : '${thongBao.tenTrangThaiGui}: ${dinhDangNgayGio(thongBao.thoiGianGui)}',
                color: guiColor,
              ),
              _InfoRow(
                icon: thongBao.isHienThi ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                label: 'Trạng thái hiển thị',
                value: thongBao.isHienThi ? 'Hiển thị với sinh viên' : 'Đang ẩn với sinh viên',
                color: thongBao.isHienThi ? const Color(0xFF16A34A) : _muted,
              ),
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                label: 'Ngày tạo',
                value: dinhDangNgayGio(thongBao.ngayTao),
              ),
              _InfoRow(
                icon: Icons.update_rounded,
                label: 'Cập nhật lần cuối',
                value: dinhDangNgayGio(thongBao.ngayCapNhat),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Người đăng',
            icon: Icons.person_outline_rounded,
            children: [
              _InfoRow(
                icon: Icons.account_circle_rounded,
                label: 'Tác giả',
                value: thongBao.tenNguoiTao ?? 'Chưa cập nhật',
                color: _primary,
              ),
              _InfoRow(
                icon: Icons.comment_outlined,
                label: 'Bình luận',
                value: '${thongBao.soBinhLuan} bình luận về thông báo',
                color: const Color(0xFF0D9488),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CommentsSection(thongBaoId: thongBao.id),
        ],
      ),
    );
  }
}


class _FileTile extends StatelessWidget {
  final ThongBaoFile file;
  final VoidCallback onTap;
  const _FileTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF2563EB)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.tenFile, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (file.kichThuocHienThi.isNotEmpty) Text(file.kichThuocHienThi, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  final int thongBaoId;
  const _CommentsSection({required this.thongBaoId});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Bình luận của sinh viên',
      icon: Icons.forum_rounded,
      children: [
        FutureBuilder<List<BinhLuanModel>>(
          future: SinhVienService().layDanhSachBinhLuanThongBao(thongBaoId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text('Không tải được bình luận: ${snapshot.error}', style: const TextStyle(color: Colors.red));
            }
            final ds = snapshot.data ?? const <BinhLuanModel>[];
            if (ds.isEmpty) {
              return const Text('Chưa có bình luận nào.', style: TextStyle(color: Color(0xFF64748B)));
            }
            return Column(
              children: ds.map((bl) => _CommentTile(bl: bl)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final BinhLuanModel bl;
  const _CommentTile({required this.bl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFDBEAFE),
            child: Text(bl.tenNguoiDung.isNotEmpty ? bl.tenNguoiDung[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bl.tenNguoiDung, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text(bl.noiDung, style: const TextStyle(color: Color(0xFF334155), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WhiteChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w800, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
