import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class MoiNguoiSVPage extends StatelessWidget {
  final LopHocPhanSVModel lop;

  const MoiNguoiSVPage({super.key, required this.lop});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8FC),
      child: Consumer<SinhVienProvider>(
        builder: (context, provider, _) {
          if (provider.tvLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tvError != null) {
            return TrangLoi(
              loi: provider.tvError!,
              onTaiLai: () => provider.layThanhVienLop(lop.id),
            );
          }

          final tongThanhVien =
              provider.dsSinhVienTrongLop.length +
              (provider.giangVienLop == null ? 0 : 1);

          return RefreshIndicator(
            onRefresh: () => provider.layThanhVienLop(lop.id),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(.76),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(.18),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thành viên lớp học',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$tongThanhVien thành viên đang hiển thị',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  icon: Icons.school_outlined,
                  title: 'Giảng viên',
                  count: provider.giangVienLop == null ? 0 : 1,
                ),
                const SizedBox(height: 10),
                if (provider.giangVienLop == null)
                  const _EmptyInline(text: 'Chưa cập nhật giảng viên')
                else
                  _ThanhVienTile(tv: provider.giangVienLop!, highlighted: true),
                const SizedBox(height: 22),
                _SectionHeader(
                  icon: Icons.people_alt_outlined,
                  title: 'Sinh viên',
                  count: provider.dsSinhVienTrongLop.length,
                ),
                const SizedBox(height: 10),
                if (provider.dsSinhVienTrongLop.isEmpty)
                  const _EmptyInline(text: 'Chưa có sinh viên trong lớp')
                else
                  ...provider.dsSinhVienTrongLop.map(
                    (tv) => _ThanhVienTile(tv: tv),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThanhVienTile extends StatelessWidget {
  final ThanhVienLopSVModel tv;
  final bool highlighted;

  const _ThanhVienTile({required this.tv, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final isTeacher = tv.vaiTro == 'giang_vien';
    final color = isTeacher ? Colors.blue : Colors.green;
    final sub = [
      if ((tv.maSo ?? '').isNotEmpty) tv.maSo!,
      if ((tv.email ?? '').isNotEmpty) tv.email!,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted ? color.withOpacity(.22) : const Color(0xFFE8EEF8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarTen(ten: tv.hoTen, radius: 24, mauNen: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tv.hoTen,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          ChipTrangThai(
            nhan: isTeacher ? 'Giảng viên' : 'Sinh viên',
            mau: color,
            icon: isTeacher ? Icons.verified_outlined : Icons.person_outline,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
        ChipTrangThai(
          nhan: '$count',
          mau: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String text;

  const _EmptyInline({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
