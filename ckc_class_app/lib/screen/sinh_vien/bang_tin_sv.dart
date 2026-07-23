import 'package:ckc_class_app/screen/sinh_vien/chi_tiet_thong_bao_sv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

const Color _bg = Color(0xFFF6F8FC);
const Color _primary = Color(0xFF2563EB);
const Color _text = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);

class BangTinSVPage extends StatefulWidget {
  final LopHocPhanSVModel lop;
  final Future<void> Function()? onRefresh;
  final bool chiDoc;

  const BangTinSVPage({
    super.key,
    required this.lop,
    this.onRefresh,
    this.chiDoc = false,
  });

  @override
  State<BangTinSVPage> createState() => _BangTinSVPageState();
}

class _BangTinSVPageState extends State<BangTinSVPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(
      builder: (context, provider, _) {
        if (provider.tbLoading) {
          return const ColoredBox(
            color: _bg,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final baiViet = [...provider.dsBaiViet]
          ..sort((a, b) {
            final da = a.ngayTao ?? DateTime(2000);
            final db = b.ngayTao ?? DateTime(2000);
            return db.compareTo(da);
          });

        return ColoredBox(
          color: _bg,
          child: RefreshIndicator(
            onRefresh:
                widget.onRefresh ??
                () => provider.layDanhSachBaiViet(widget.lop.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
              children: [
                _OThongBaoMoi(
                  tenNguoiDung: provider.hoSo?.hoTen ?? 'Sinh viên',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Bài viết mới nhất',
                        style: TextStyle(
                          color: _text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '${baiViet.length} bài viết',
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (baiViet.isEmpty)
                  const TrangRong(
                    thongDiep: 'Chưa có bài viết nào',
                    icon: Icons.forum_outlined,
                  )
                else
                  ...baiViet.map(
                    (item) => _CardThongBaoBangTin(
                      thongBao: item,
                      chiDoc: widget.chiDoc,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Ô THÔNG BÁO MỚI
// ═══════════════════════════════════════════════════════════════

class _OThongBaoMoi extends StatelessWidget {
  final String tenNguoiDung;

  const _OThongBaoMoi({required this.tenNguoiDung});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarTen(ten: tenNguoiDung, mauNen: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Theo dõi bài viết, tài liệu và bài tập mới trong lớp học.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.dynamic_feed_rounded,
              color: _primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARD THÔNG BÁO
// ═══════════════════════════════════════════════════════════════

class _CardThongBaoBangTin extends StatelessWidget {
  final ThongBaoSVModel thongBao;
  final bool chiDoc;

  const _CardThongBaoBangTin({
    required this.thongBao,
    required this.chiDoc,
  });

  @override
  Widget build(BuildContext context) {
    final ten = thongBao.tenNguoiTao ?? 'Giảng viên';

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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChiTietThongBaoSV(
              thongBao: thongBao,
              chiDoc: chiDoc,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarTen(ten: ten, mauNen: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ten,
                          style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (thongBao.ngayTao != null)
                          Text(
                            dinhDangNgayGio(thongBao.ngayTao),
                            style: const TextStyle(color: _muted, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  _TypeBadge(
                    label: thongBao.tenLoaiBaiViet,
                    icon: thongBao.laBaiTap
                        ? Icons.assignment_rounded
                        : (thongBao.laTaiLieu
                              ? Icons.folder_copy_rounded
                              : Icons.article_rounded),
                    color: thongBao.laBaiTap
                        ? Colors.orange
                        : (thongBao.laTaiLieu ? Colors.purple : Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                thongBao.tieuDe,
                style: const TextStyle(
                  fontSize: 17,
                  color: _text,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if ((thongBao.noiDung ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  thongBao.noiDung!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF334155), height: 1.4),
                ),
              ],
              if ((thongBao.hinhAnh ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thongBao.hinhAnh!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: _muted,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetaBaiViet(
                    icon: Icons.comment_outlined,
                    text: '${thongBao.soBinhLuan} bình luận',
                  ),
                  if (thongBao.files.isNotEmpty)
                    _MetaBaiViet(
                      icon: Icons.attach_file_rounded,
                      text: '${thongBao.files.length} file',
                    ),
                  if (thongBao.hanNop != null)
                    _MetaBaiViet(
                      icon: Icons.event_rounded,
                      text: 'Hạn ${dinhDangNgayGio(thongBao.hanNop)}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════

class _MetaBaiViet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaBaiViet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TypeBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

