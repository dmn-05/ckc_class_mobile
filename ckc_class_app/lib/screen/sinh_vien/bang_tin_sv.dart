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

        final thongBao = [...provider.dsThongBao]
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
                () => provider.layDanhSachThongBao(widget.lop.id),
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
                        'Thông báo mới nhất',
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
                        '${thongBao.length} thông báo',
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
                if (thongBao.isEmpty)
                  const TrangRong(
                    thongDiep: 'Chưa có thông báo nào',
                    icon: Icons.forum_outlined,
                  )
                else
                  ...thongBao.map(
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
              'Theo dõi các thông báo mới từ giảng viên trong lớp học.',
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
              Icons.notifications_active_rounded,
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
                    label: 'Thông báo',
                    icon: Icons.campaign_rounded,
                    color: Colors.green,
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
                  style: const TextStyle(color: Color(0xFF334155), height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════

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

