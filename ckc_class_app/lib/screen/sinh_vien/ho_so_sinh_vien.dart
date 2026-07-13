import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class HoSoSinhVienPage extends StatelessWidget {
  const HoSoSinhVienPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Hồ sơ sinh viên'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<SinhVienProvider>(
        builder: (_, p, __) {
          if (p.hoSoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (p.hoSoError != null) {
            return TrangLoi(loi: p.hoSoError!, onTaiLai: p.layThongTin);
          }

          final hs = p.hoSo;
          if (hs == null) {
            return const TrangRong(thongDiep: 'Chưa có dữ liệu hồ sơ');
          }

          return RefreshIndicator(
            onRefresh: p.layThongTin,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(.76),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(.22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.22),
                          shape: BoxShape.circle,
                        ),
                        child: AvatarTen(
                          ten: hs.hoTen,
                          radius: 46,
                          mauNen: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        hs.hoTen,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          hs.maSinhVien,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.class_outlined,
                        label: 'Lớp đang học',
                        value: '${hs.thongKe.soLopDangHoc}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.assignment_turned_in_outlined,
                        label: 'Đã nộp',
                        value: '${hs.thongKe.soBaiDaNop}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.pending_actions_outlined,
                        label: 'Chờ nộp',
                        value: '${hs.thongKe.soBaiChuaNop}',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Điểm TB',
                        value: hs.thongKe.diemTrungBinh != null
                            ? hs.thongKe.diemTrungBinh!.toStringAsFixed(1)
                            : '--',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Thông tin cá nhân',
                  children: [
                    _item(Icons.email_outlined, 'Email', hs.email),
                    _item(
                      Icons.phone_outlined,
                      'Số điện thoại',
                      hs.soDienThoai ?? 'Chưa cập nhật',
                    ),
                    _item(
                      Icons.cake_outlined,
                      'Ngày sinh',
                      dinhDangNgay(hs.ngaySinh),
                    ),
                    _item(Icons.info_outline, 'Trạng thái', hs.tenTrangThaiSV),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Thông tin học tập',
                  children: [
                    _item(
                      Icons.class_outlined,
                      'Lớp',
                      _joinValue([hs.maLop, hs.tenLop]),
                    ),
                    _item(
                      Icons.account_balance_outlined,
                      'Khoa',
                      hs.tenKhoa ?? '--',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _joinValue(List<String?> values) {
    final text = values.where((e) => (e ?? '').trim().isNotEmpty).join(' - ');
    return text.isEmpty ? '--' : text;
  }

  Widget _item(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
