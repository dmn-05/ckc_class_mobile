import 'package:ckc_class_app/screen/giang_vien/chi_tiet_lop_hoc_phan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/giang_vien_provider.dart';
import '../../widget/widget_chung_giangvien.dart';
import 'danh_sach_lop_hoc_phan.dart';
import '../../provider/xac_thuc.dart';

class DashboardGiangVien extends StatefulWidget {
  const DashboardGiangVien({super.key});

  @override
  State<DashboardGiangVien> createState() => _DashboardGiangVienState();
}

class _DashboardGiangVienState extends State<DashboardGiangVien> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final gv = context.read<GiangVienProvider>();

      final nguoiDungId = auth.user?.id ?? 0;

      if (nguoiDungId <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy ID người dùng đăng nhập'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Map<String, dynamic> result;
      if (gv.nguoiDungId != nguoiDungId) {
        gv.reset();
        result = await gv.khoiTaoTuNguoiDungId(nguoiDungId);
      } else if (gv.giangVienId > 0) {
        await gv.khoiTaoDuLieu();
        result = {
          'success': true,
          'message': 'Đã cập nhật dữ liệu giảng viên',
        };
      } else {
        result = await gv.khoiTaoTuNguoiDungId(nguoiDungId);
      }

      if (!mounted) return;

      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lỗi khởi tạo giảng viên'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GiangVienProvider>(
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
                  _buildHero(provider),
                  const SizedBox(height: 18),
                  _buildThaoTacNhanh(),
                  const SizedBox(height: 18),
                  _buildThongKe(provider),
                  const SizedBox(height: 22),
                  _buildDanhSachLopGanDay(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(GiangVienProvider provider) {
    final tk = provider.thongKe;
    final tenTaiKhoan = context.watch<AuthProvider>().user?.hoTen.trim();

    final loiChao = tenTaiKhoan != null && tenTaiKhoan.isNotEmpty
        ? 'Xin chào, $tenTaiKhoan'
        : 'Xin chào, giảng viên';
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
            color: _primary.withOpacity(0.26),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -30,
            child: _DecorCircle(size: 110, opacity: 0.15),
          ),
          Positioned(
            right: 48,
            bottom: -46,
            child: _DecorCircle(size: 92, opacity: 0.10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.20)),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
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
                          loiChao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Quản lý lớp học hôm nay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
                      Icons.insights_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bạn đang quản lý ${tk?.tongLopHocPhan ?? 0} lớp học phần, ${tk?.tongSinhVien ?? 0} sinh viên và ${tk?.chooCham ?? 0} bài chờ chấm.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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

  Widget _buildThaoTacNhanh() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Truy cập nhanh', icon: Icons.bolt_rounded),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickCard(
                title: 'Lớp học phần',
                subtitle: 'Xem và quản lý lớp',
                icon: Icons.class_rounded,
                color: _primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachLopHocPhan()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickCard(
                title: 'Theo dõi bài nộp',
                subtitle: 'Chấm điểm nhanh hơn',
                icon: Icons.grading_rounded,
                color: const Color(0xFFF97316),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachLopHocPhan()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThongKe(GiangVienProvider provider) {
    if (provider.tkLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final tk = provider.thongKe;

    if (tk == null) {
      return TrangThaiLoi(
        loi: provider.tkError ?? 'Không tải được thống kê',
        onTaiLai: provider.layThongKe,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Tổng quan hệ thống',
          icon: Icons.dashboard_customize_rounded,
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.65,
          children: [
            _StatCard(
              label: 'Lớp học phần',
              value: '${tk.tongLopHocPhan}',
              sub: '${tk.lopDangMo} đang mở',
              icon: Icons.class_rounded,
              color: _primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DanhSachLopHocPhan()),
              ),
            ),
            _StatCard(
              label: 'Tổng sinh viên',
              value: '${tk.tongSinhVien}',
              icon: Icons.groups_rounded,
              color: const Color(0xFF16A34A),
            ),
            _StatCard(
              label: 'Bài tập đã giao',
              value: '${tk.tongBaiTap}',
              sub: tk.chooCham > 0 ? '${tk.chooCham} chờ chấm' : 'Đã cập nhật',
              icon: Icons.assignment_rounded,
              color: const Color(0xFFF97316),
            ),
            _StatCard(
              label: 'Tài liệu',
              value: '${tk.tongTaiLieu}',
              icon: Icons.folder_rounded,
              color: const Color(0xFF9333EA),
            ),
            _StatCard(
              label: 'Bài viết',
              value: '${tk.tongBaiViet}',
              icon: Icons.campaign_rounded,
              color: const Color(0xFF0D9488),
            ),
            _StatCard(
              label: 'Điểm TB',
              value: tk.diemTrungBinh != null
                  ? tk.diemTrungBinh!.toStringAsFixed(1)
                  : '--',
              sub: '/10',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF4F46E5),
            ),
          ],
        ),
        if (tk.chooCham > 0) ...[
          const SizedBox(height: 12),
          _AlertCard(
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF97316),
            title: 'Có ${tk.chooCham} bài nộp chờ chấm điểm',
            subtitle: 'Nhấn để mở danh sách lớp học phần và xử lý bài nộp.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DanhSachLopHocPhan()),
            ),
          ),
        ],
        if (tk.binhLuanMoi > 0) ...[
          const SizedBox(height: 10),
          _AlertCard(
            icon: Icons.comment_rounded,
            color: _primary,
            title: '${tk.binhLuanMoi} bình luận mới trong 7 ngày',
            subtitle: 'Theo dõi phản hồi của sinh viên trong các lớp học phần.',
          ),
        ],
      ],
    );
  }

  Widget _buildDanhSachLopGanDay(GiangVienProvider provider) {
    if (provider.lopLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dsLop = provider.dsLopHocPhan
        .where((lop) => !lop.isDaLuu)
        .take(3)
        .toList();
    if (dsLop.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Lớp học phần gần đây',
          icon: Icons.history_edu_rounded,
          actionText: 'Xem tất cả',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DanhSachLopHocPhan()),
          ),
        ),
        const SizedBox(height: 10),
        ...dsLop.map(
          (lop) => _CourseCard(
            title: lop.tenHienThi,
            subtitle:
                '${lop.tenMon ?? lop.maMon ?? ''} • ${lop.soSinhVien} sinh viên',
            status: lop.tenTrangThai,
            isOpen: lop.isDangMo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChiTietLopHocPhan(lop: lop)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    required this.icon,
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
          child: Icon(icon, color: _DashboardGiangVienState._primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _DashboardGiangVienState._text,
            ),
          ),
        ),
        if (actionText != null)
          TextButton(onPressed: onAction, child: Text(actionText!)),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
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
                  fontWeight: FontWeight.w900,
                  color: _DashboardGiangVienState._text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _DashboardGiangVienState._muted,
                  fontSize: 12,
                ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
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
          padding: const EdgeInsets.all(14),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _DashboardGiangVienState._text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: _DashboardGiangVienState._muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AlertCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
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
            border: Border.all(color: color.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _DashboardGiangVienState._text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _DashboardGiangVienState._muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
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

class _CourseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isOpen;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF16A34A) : const Color(0xFF64748B);
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _DashboardGiangVienState._primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.class_rounded,
                  color: _DashboardGiangVienState._primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _DashboardGiangVienState._text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _DashboardGiangVienState._muted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ChipTrangThai(
                nhan: status,
                mau: color,
                icon: isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
              ),
            ],
          ),
        ),
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
