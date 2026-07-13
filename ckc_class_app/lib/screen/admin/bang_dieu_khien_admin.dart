import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/bang_dieu_khien.dart';
import 'bao_cao/bao_cao_thong_ke_admin.dart';
import 'quan_ly_hoc_tap/quan_ly_tai_lieu_hoc_tap.dart';

class AdminDashboard extends StatefulWidget {
  /// Callback đổi mục trong menu Quản trị hệ thống của MainScaffold.
  ///
  /// Các chỉ số đang dùng:
  /// 1: Khoa, 2: Bộ môn, 3: Môn học, 4: Người dùng,
  /// 5: Lớp, 6: Lớp học phần.
  final ValueChanged<int>? onMenuSelected;

  const AdminDashboard({
    super.key,
    this.onMenuSelected,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchAdminStats();
    });
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? destinationLabel,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (destinationLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        destinationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _moMucQuanTri(int menuIndex) {
    final callback = widget.onMenuSelected;
    if (callback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa cấu hình liên kết tới menu quản trị.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    callback(menuIndex);
  }

  Widget _buildShortcut({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _moTaiLieuHocTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuanLyTaiLieuHocTapScreen(),
      ),
    );
  }

  void _moBaoCaoThongKe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BaoCaoThongKeAdminScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final stats = dashboardProvider.adminStats;
    final isLoading = dashboardProvider.isLoading;

    if (isLoading && stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dashboardProvider.error != null && stats == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            dashboardProvider.error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    int value(String key) => stats?[key] ?? 0;

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().fetchAdminStats(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tổng quan quản trị',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 900 ? 4 : width >= 620 ? 3 : 2;
              final cards = <({
                String title,
                int value,
                IconData icon,
                Color color,
                VoidCallback onTap,
                String destinationLabel,
              })>[
                (
                  title: 'Khoa',
                  value: value('khoa'),
                  icon: Icons.account_balance,
                  color: Colors.orange,
                  onTap: () => _moMucQuanTri(1),
                  destinationLabel: 'Mở quản lý khoa',
                ),
                (
                  title: 'Bộ môn',
                  value: value('bo_mon'),
                  icon: Icons.business,
                  color: Colors.teal,
                  onTap: () => _moMucQuanTri(2),
                  destinationLabel: 'Mở quản lý bộ môn',
                ),
                (
                  title: 'Môn học',
                  value: value('mon_hoc'),
                  icon: Icons.book,
                  color: Colors.blue,
                  onTap: () => _moMucQuanTri(3),
                  destinationLabel: 'Mở quản lý môn học',
                ),
                (
                  title: 'Lớp',
                  value: value('lop'),
                  icon: Icons.groups_2,
                  color: Colors.indigo,
                  onTap: () => _moMucQuanTri(5),
                  destinationLabel: 'Mở quản lý lớp',
                ),
                (
                  title: 'Lớp học phần',
                  value: value('lop_hoc_phan'),
                  icon: Icons.groups,
                  color: Colors.deepPurple,
                  onTap: () => _moMucQuanTri(6),
                  destinationLabel: 'Mở lớp học phần',
                ),
                (
                  title: 'Giảng viên',
                  value: value('giang_vien'),
                  icon: Icons.person_pin,
                  color: Colors.green,
                  onTap: () => _moMucQuanTri(4),
                  destinationLabel: 'Mở quản lý người dùng',
                ),
                (
                  title: 'Sinh viên',
                  value: value('sinh_vien'),
                  icon: Icons.people,
                  color: Colors.purple,
                  onTap: () => _moMucQuanTri(4),
                  destinationLabel: 'Mở quản lý người dùng',
                ),
                (
                  title: 'Tài liệu',
                  value: value('tai_lieu'),
                  icon: Icons.folder_copy,
                  color: Colors.cyan,
                  onTap: _moTaiLieuHocTap,
                  destinationLabel: 'Mở quản lý tài liệu',
                ),
                (
                  title: 'Bài nộp',
                  value: value('bai_nop'),
                  icon: Icons.upload_file,
                  color: Colors.blueGrey,
                  onTap: _moBaoCaoThongKe,
                  destinationLabel: 'Mở báo cáo thống kê',
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 118,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = cards[index];
                  return _buildStatCard(
                    title: item.title,
                    value: item.value,
                    icon: item.icon,
                    color: item.color,
                    onTap: item.onTap,
                    destinationLabel: item.destinationLabel,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Chức năng học tập & báo cáo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildShortcut(
            title: 'Quản lý tài liệu học tập',
            subtitle: 'Thêm, sửa, ẩn/hiện tài liệu theo lớp học phần.',
            icon: Icons.folder_copy,
            color: Colors.cyan,
            onTap: _moTaiLieuHocTap,
          ),
          _buildShortcut(
            title: 'Báo cáo thống kê',
            subtitle: 'Tổng quan hệ thống, thống kê lớp học phần, bài tập, bài nộp và điểm trung bình.',
            icon: Icons.bar_chart,
            color: Colors.indigo,
            onTap: _moBaoCaoThongKe,
          ),
        ],
      ),
    );
  }
}
