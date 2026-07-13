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

  const BangTinSVPage({super.key, required this.lop, this.onRefresh});

  @override
  State<BangTinSVPage> createState() => _BangTinSVPageState();
}

class _BangTinSVPageState extends State<BangTinSVPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(
      builder: (context, provider, _) {
        final dangTai = provider.tbLoading;

        if (dangTai) {
          return const ColoredBox(
            color: _bg,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = List<ThongBaoSVModel>.from(provider.dsThongBao);

        return ColoredBox(
          color: _bg,
          child: RefreshIndicator(
            onRefresh:
                widget.onRefresh ??
                () async {
                  await provider.layDanhSachThongBao(widget.lop.id);
                },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
              children: [
                _BannerLop(lop: widget.lop),
                const SizedBox(height: 14),
                _OThongBaoMoi(
                  tenNguoiDung: provider.hoSo?.hoTen ?? 'Sinh viên',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thông báo của giảng viên',
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
                        '${items.length} tin',
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
                if (items.isEmpty)
                  const TrangRong(
                    thongDiep: 'Chưa có thông báo nào',
                    icon: Icons.campaign_outlined,
                  )
                else
                  ...items.map((item) => _CardThongBaoBangTin(thongBao: item)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BANNER LỚP
// ═══════════════════════════════════════════════════════════════

class _BannerLop extends StatelessWidget {
  final LopHocPhanSVModel lop;

  const _BannerLop({required this.lop});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 178),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -30,
            child: _CircleBlur(size: 112, opacity: 0.15),
          ),
          Positioned(
            right: 42,
            bottom: -48,
            child: _CircleBlur(size: 96, opacity: 0.11),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 92,
                    ),
                    child: Text(
                      lop.maLopHocPhan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  lop.tenHienThi,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  lop.tenMon ?? lop.maLopHocPhan,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'GV: ${lop.tenGiangVien ?? 'Chưa cập nhật'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBlur extends StatelessWidget {
  final double size;
  final double opacity;

  const _CircleBlur({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
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
              'Theo dõi thông báo mới từ giảng viên. Bài tập được tách riêng ở tab Bài tập.',
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

  const _CardThongBaoBangTin({required this.thongBao});

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
            builder: (_) => ChiTietThongBaoSV(thongBao: thongBao),
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

              if (thongBao.files.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: thongBao.files
                      .map((f) => _TypeBadge(
                            label: f.tenFile,
                            icon: Icons.attach_file_rounded,
                            color: _primary,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: _muted,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${thongBao.soBinhLuan} bình luận',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CARD BÀI TẬP HIỂN THỊ TRÊN BẢNG TIN
// ═══════════════════════════════════════════════════════════════

class _CardBaiTapBangTin extends StatelessWidget {
  final BaiTapSVModel baiTap;
  final VoidCallback onTap;

  const _CardBaiTapBangTin({required this.baiTap, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mau = baiTap.daDuocNop
        ? Colors.green
        : baiTap.daQuaHan
        ? Colors.red
        : Colors.orange;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mau.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  baiTap.laQuiz
                      ? Icons.quiz_rounded
                      : Icons.assignment_outlined,
                  color: mau,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baiTap.tenNguoiTao != null
                          ? '${baiTap.tenNguoiTao} đã đăng một bài tập mới'
                          : 'Giảng viên đã đăng một bài tập mới',
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      baiTap.tieuDe,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((baiTap.moTa ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        baiTap.moTa!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        ChipTrangThai(nhan: baiTap.tenTrangThaiNop, mau: mau),
                        ChipTrangThai(
                          nhan: baiTap.tenLoaiBaiTap,
                          mau: baiTap.laQuiz ? Colors.purple : Colors.orange,
                        ),
                        if (baiTap.hanNop != null)
                          ChipTrangThai(
                            nhan: 'Hạn: ${dinhDangNgayGio(baiTap.hanNop)}',
                            mau: Colors.blue,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
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

// ═══════════════════════════════════════════════════════════════
// KHU VỰC BÌNH LUẬN / NHẬN XÉT CUỐI BẢNG TIN
// ═══════════════════════════════════════════════════════════════

class _KhuVucBinhLuan extends StatelessWidget {
  final SinhVienProvider provider;
  final TextEditingController controller;
  final VoidCallback onGui;

  const _KhuVucBinhLuan({
    required this.provider,
    required this.controller,
    required this.onGui,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                  child: const Icon(
                    Icons.forum_rounded,
                    color: _primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nhận xét trong lớp học',
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Trao đổi nhanh với giảng viên và bạn học',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (provider.dsBinhLuan.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Chưa có nhận xét nào',
                  style: TextStyle(color: _muted),
                ),
              )
            else
              ...provider.dsBinhLuan.map(
                (bl) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AvatarTen(
                        ten: bl.tenNguoiDung,
                        radius: 17,
                        mauNen: Colors.grey,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bl.tenNguoiDung,
                                style: const TextStyle(
                                  color: _text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bl.noiDung,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Thêm bình luận...',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: provider.blProcessing ? null : onGui,
                  icon: provider.blProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
