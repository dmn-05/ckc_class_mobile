import 'package:ckc_class_app/screen/sinh_vien/chi_tiet_lop_sv.dart';
import 'package:ckc_class_app/provider/xac_thuc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';
import 'lop_hoc_phan_sv.dart';

class DashboardSinhVien extends StatefulWidget {
  const DashboardSinhVien({super.key});

  @override
  State<DashboardSinhVien> createState() => _DashboardSinhVienState();
}

class _DashboardSinhVienState extends State<DashboardSinhVien> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final sv = context.read<SinhVienProvider>();

      final nguoiDungId = auth.user?.id ?? 0;

      if (nguoiDungId <= 0) return;

      sv.reset();

      final result = await sv.khoiTaoTuNguoiDungId(nguoiDungId);

      if (!mounted) return;

      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lỗi khởi tạo sinh viên'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(
      builder: (context, provider, _) {
        return ColoredBox(
          color: _bg,
          child: RefreshIndicator(
            onRefresh: provider.khoiTaoDuLieu,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChaoHoi(provider),
                  const SizedBox(height: 18),
                  _buildThongKe(provider),
                  const SizedBox(height: 18),
                  _buildThaoTacNhanh(),
                  const SizedBox(height: 22),
                  _buildBaiTapChuaNop(provider),
                  const SizedBox(height: 22),
                  _buildLopGanDay(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Chào hỏi ─────────────────────────────────────────────────
  Widget _buildChaoHoi(SinhVienProvider provider) {
    final hoSo = provider.hoSo;
    final tk = hoSo?.thongKe;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [_primaryDark, _primary, Color(0xFF38BDF8)],
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
            top: -28,
            child: _DecorCircle(size: 110, opacity: 0.16),
          ),
          Positioned(
            right: 36,
            bottom: -44,
            child: _DecorCircle(size: 96, opacity: 0.10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.22),
                    ),
                    child: hoSo != null
                        ? AvatarTen(ten: hoSo.hoTen, radius: 27)
                        : const CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: _primary),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hoSo?.hoTen ?? 'Sinh viên',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            height: 1.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (hoSo != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${hoSo.maSinhVien} • ${hoSo.tenLop ?? 'Chưa cập nhật lớp'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn có ${tk?.soBaiChuaNop ?? 0} bài cần nộp và ${tk?.soLopDangHoc ?? 0} lớp đang học.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Thống kê ─────────────────────────────────────────────────
  Widget _buildThongKe(SinhVienProvider provider) {
    if (provider.hoSoLoading) {
      return const SizedBox(
        height: 128,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final tk = provider.hoSo?.thongKe;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          label: 'Lớp đang học',
          value: '${tk?.soLopDangHoc ?? 0}',
          icon: Icons.class_rounded,
          color: _primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
          ),
        ),
        _StatCard(
          label: 'Bài đã nộp',
          value: '${tk?.soBaiDaNop ?? 0}',
          icon: Icons.cloud_done_rounded,
          color: const Color(0xFF16A34A),
        ),
        _StatCard(
          label: 'Chờ nộp',
          value: '${tk?.soBaiChuaNop ?? 0}',
          icon: Icons.pending_actions_rounded,
          color: const Color(0xFFF97316),
        ),
        _StatCard(
          label: 'Điểm TB',
          value: tk?.diemTrungBinh != null
              ? tk!.diemTrungBinh!.toStringAsFixed(1)
              : '--',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF9333EA),
        ),
      ],
    );
  }

  // ── Thao tác nhanh ───────────────────────────────────────────
  Widget _buildThaoTacNhanh() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Truy cập nhanh', icon: Icons.bolt_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Lớp của tôi',
                subtitle: 'Xem tất cả lớp học phần',
                icon: Icons.grid_view_rounded,
                color: _primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Bài tập',
                subtitle: 'Theo dõi hạn nộp',
                icon: Icons.assignment_turned_in_rounded,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Bài tập chờ nộp ──────────────────────────────────────────
  Widget _buildBaiTapChuaNop(SinhVienProvider provider) {
    if (provider.bcnLoading) return const SizedBox.shrink();
    if (provider.dsBaiChuaNop.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Bài tập cần nộp',
          icon: Icons.pending_actions_rounded,
          trailing: '${provider.dsBaiChuaNop.length} bài',
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: provider.dsBaiChuaNop.take(5).map((bt) {
              final sapHet = bt.sapHetHan;
              final quaHan = bt.daQuaHan;
              final mau = quaHan
                  ? Colors.red
                  : sapHet
                  ? Colors.orange
                  : _primary;

              return _PendingAssignmentTile(
                title: bt.tieuDe,
                subtitle: bt.tenMon ?? bt.tenLop ?? bt.maLopHocPhan ?? '',
                deadline: bt.hanNop == null
                    ? 'Không có hạn nộp'
                    : quaHan
                    ? 'Đã qua hạn: ${dinhDangNgayGio(bt.hanNop)}'
                    : 'Hạn nộp: ${dinhDangNgayGio(bt.hanNop)}',
                color: mau,
                onTap: () {
                  final dsPhuHop = provider.dsLop
                      .where((lop) => lop.id == bt.lopHocPhanId)
                      .toList();

                  if (dsPhuHop.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChiTietLopSV(
                        lop: dsPhuHop.first,
                        tabBanDau: 1, // 1 = Bài tập
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        if (provider.dsBaiChuaNop.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('Xem thêm ${provider.dsBaiChuaNop.length - 5} bài'),
              ),
            ),
          ),
      ],
    );
  }

  // ── Lớp gần đây ──────────────────────────────────────────────
  Widget _buildLopGanDay(SinhVienProvider provider) {
    if (provider.lopLoading || provider.dsLop.isEmpty) {
      return const SizedBox.shrink();
    }

    final dsHienThi = provider.dsLop
        .where((lop) => !lop.isDaLuu)
        .take(3)
        .toList();
    if (dsHienThi.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Lớp học phần',
          icon: Icons.class_rounded,
          actionText: 'Xem tất cả',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LopHocPhanSV()),
          ),
        ),
        const SizedBox(height: 10),
        ...dsHienThi.map(
          (lop) => _CourseCard(
            lop: lop,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChiTietLopSV(lop: lop)),
            ),
          ),
        ),
      ],
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.trailing,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _DashboardSinhVienState._primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: Color(0xFFC2410C),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (actionText != null)
          TextButton(onPressed: onAction, child: Text(actionText!)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingAssignmentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String deadline;
  final Color color;
  final VoidCallback onTap;

  const _PendingAssignmentTile({
    required this.title,
    required this.subtitle,
    required this.deadline,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.assignment_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deadline,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic lop;
  final VoidCallback onTap;

  const _CourseCard({
    required this.lop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hocKy = lop.hocKy?.toString().trim() ?? '';
    final namHoc = lop.namHoc?.toString().trim() ?? '';
    final thoiGian = [hocKy, namHoc].where((e) => e.isNotEmpty).join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarTen(
                ten: lop.tenHienThi,
                mauNen: _DashboardSinhVienState._primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lop.tenHienThi,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lop.tenMon ?? lop.maMon ?? '',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (thoiGian.isNotEmpty)
                          ChipTrangThai(nhan: thoiGian, mau: Colors.blue),
                        ChipTrangThai(
                          nhan: '${lop.soBaiTap} bài tập',
                          mau: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
