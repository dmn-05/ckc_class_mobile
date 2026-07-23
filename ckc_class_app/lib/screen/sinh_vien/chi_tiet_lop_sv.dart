import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import 'bai_tap_sv.dart';
import 'bang_tin_sv.dart';
import 'moi_nguoi_sv.dart';

class ChiTietLopSV extends StatefulWidget {
  final LopHocPhanSVModel lop;
  final int tabBanDau;

  const ChiTietLopSV({super.key, required this.lop, this.tabBanDau = 0});

  @override
  State<ChiTietLopSV> createState() => _ChiTietLopSVState();
}

class _ChiTietLopSVState extends State<ChiTietLopSV>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  late final TabController _tabController;

  final _tabs = const [
    Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 20), text: 'Bảng tin'),
    Tab(icon: Icon(Icons.assignment_rounded, size: 20), text: 'Bài tập'),
    Tab(icon: Icon(Icons.people_outline_rounded, size: 20), text: 'Mọi người'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.tabBanDau.clamp(0, 2),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<SinhVienProvider>();
      provider.layDanhSachBaiViet(widget.lop.id);
      provider.layDanhSachBaiTap(widget.lop.id);
      provider.layThanhVienLop(widget.lop.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _taiLaiDuLieu() async {
    final provider = context.read<SinhVienProvider>();
    await Future.wait([
      provider.layDanhSachBaiViet(widget.lop.id),
      provider.layDanhSachBaiTap(widget.lop.id),
      provider.layThanhVienLop(widget.lop.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final lop = widget.lop;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        centerTitle: false,
        title: Text(
          lop.tenHienThi,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _taiLaiDuLieu,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildThongTinLop(lop),
                if (lop.isDaLuu) _buildThongBaoChiDoc(),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              height: 96,
              child: ColoredBox(
                color: _bg,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: _buildTabBox(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            BangTinSVPage(
              lop: lop,
              onRefresh: _taiLaiDuLieu,
              chiDoc: lop.isDaLuu,
            ),
            BaiTapSVPage(lopHocPhanId: lop.id, chiDoc: lop.isDaLuu),
            MoiNguoiSVPage(lop: lop),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBox() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: _tabs,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        indicator: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget _buildThongTinLop(LopHocPhanSVModel lop) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [_primaryDark, _primary, Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -28,
            top: -34,
            child: _DecorCircle(size: 110, opacity: 0.14),
          ),
          const Positioned(
            right: 40,
            bottom: -48,
            child: _DecorCircle(size: 92, opacity: 0.10),
          ),
          Column(
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.class_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lop.tenHienThi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          lop.tenMon ?? lop.maMon ?? lop.maLopHocPhan,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  _InfoPill(
                    icon: Icons.badge_rounded,
                    text: lop.maLopHocPhan,
                  ),
                  if ((lop.hocKy ?? '').trim().isNotEmpty ||
                      (lop.namHoc ?? '').trim().isNotEmpty)
                    _InfoPill(
                      icon: Icons.calendar_month_rounded,
                      text: [
                        if ((lop.hocKy ?? '').trim().isNotEmpty) lop.hocKy!,
                        if ((lop.namHoc ?? '').trim().isNotEmpty) lop.namHoc!,
                      ].join(' • '),
                    ),
                  if (lop.tinChi != null)
                    _InfoPill(
                      icon: Icons.school_rounded,
                      text: '${lop.tinChi} tín chỉ',
                    ),
                  if ((lop.tenGiangVien ?? '').trim().isNotEmpty)
                    _InfoPill(
                      icon: Icons.person_rounded,
                      text: lop.tenGiangVien!,
                    ),
                  _InfoPill(
                    icon: Icons.assignment_rounded,
                    text: '${lop.soBaiTap} bài tập',
                  ),
                  _InfoPill(
                    icon: lop.isDaLuu
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    text: _tenTrangThaiLop(lop.trangThai),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tenTrangThaiLop(String value) {
    switch (value) {
      case 'da_khoa':
        return 'Đã khóa';
      case 'da_ket_thuc':
        return 'Đã kết thúc';
      default:
        return 'Đang mở';
    }
  }

  Widget _buildThongBaoChiDoc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.archive_rounded, color: Color(0xFFC2410C)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Lớp học phần đã được lưu. Bạn vẫn xem được toàn bộ nội dung nhưng không thể bình luận, nộp bài hoặc làm quiz mới.',
              style: TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _TabHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 245),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.17),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

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
