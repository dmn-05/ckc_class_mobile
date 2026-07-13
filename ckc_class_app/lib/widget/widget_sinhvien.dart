import 'package:flutter/material.dart';

// ─── FORMAT ──────────────────────────────────────────────────
String dinhDangNgay(DateTime? dt) {
  if (dt == null) return 'Chưa có';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

String dinhDangNgayGio(DateTime? dt) {
  if (dt == null) return 'Chưa có';
  final ngay = dinhDangNgay(dt);
  final gio =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  return '$ngay $gio';
}

String thoiGianTuongDoi(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Vừa xong';
  if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return dinhDangNgay(dt);
}

void snack(BuildContext ctx, String msg, {bool ok = true}) {
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: ok ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ─── WIDGETS ─────────────────────────────────────────────────

class TrangRong extends StatelessWidget {
  final String thongDiep;
  final IconData icon;
  final String? nhanNut;
  final VoidCallback? onNut;

  const TrangRong({
    super.key,
    required this.thongDiep,
    this.icon = Icons.inbox_outlined,
    this.nhanNut,
    this.onNut,
  });

  @override
  Widget build(BuildContext context) {
    // Trạng thái rỗng có thể nằm trong TabBarView/NestedScrollView nên phải
    // cho cuộn an toàn, tránh overflow khi màn hình thấp hoặc header quá cao.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight - 56
                  : 220,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 58, color: Colors.grey.shade300),
                  const SizedBox(height: 14),
                  Text(
                    thongDiep,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                  if (nhanNut != null && onNut != null) ...[
                    const SizedBox(height: 14),
                    ElevatedButton(onPressed: onNut, child: Text(nhanNut!)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TrangLoi extends StatelessWidget {
  final String loi;
  final VoidCallback onTaiLai;

  const TrangLoi({super.key, required this.loi, required this.onTaiLai});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight - 56
                  : 220,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 52, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    loi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: onTaiLai,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChipTrangThai extends StatelessWidget {
  final String nhan;
  final Color mau;
  final IconData? icon;

  const ChipTrangThai({
    super.key,
    required this.nhan,
    required this.mau,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: mau.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mau.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: mau),
            const SizedBox(width: 4),
          ],
          Text(
            nhan,
            style: TextStyle(
              fontSize: 11,
              color: mau,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Thẻ thống kê dashboard
class TheSoLieuSV extends StatelessWidget {
  final String nhan;
  final String giaTri;
  final IconData icon;
  final Color mauNen;
  final Color mauChu;
  final VoidCallback? onTap;

  const TheSoLieuSV({
    super.key,
    required this.nhan,
    required this.giaTri,
    required this.icon,
    required this.mauNen,
    required this.mauChu,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: mauNen,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: mauChu, size: 28),
            const SizedBox(height: 8),
            Text(
              giaTri,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: mauChu,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              nhan,
              style: TextStyle(
                fontSize: 12,
                color: mauChu.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Avatar tên (fallback khi không có ảnh)
class AvatarTen extends StatelessWidget {
  final String ten;
  final double radius;
  final Color? mauNen;

  const AvatarTen({
    super.key,
    required this.ten,
    this.radius = 18,
    this.mauNen,
  });

  @override
  Widget build(BuildContext context) {
    final ky = ten.isNotEmpty ? ten[0].toUpperCase() : '?';
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    final mau = mauNen ?? colors[ten.codeUnitAt(0) % colors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: mau.withValues(alpha: 0.2),
      child: Text(
        ky,
        style: TextStyle(
          color: mau,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
