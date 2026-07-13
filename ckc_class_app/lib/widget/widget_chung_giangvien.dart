import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// WIDGET DÙNG CHUNG - PHÂN HỆ GIẢNG VIÊN
// ═══════════════════════════════════════════════════════════

/// Thẻ thống kê nhỏ dùng ở dashboard
class TheSoLieu extends StatelessWidget {
  final String nhanDe;
  final String giaTri;
  final IconData icon;
  final Color mauNen;
  final Color mauChu;
  final String? nhanPhu;
  final VoidCallback? onTap;

  const TheSoLieu({
    super.key,
    required this.nhanDe,
    required this.giaTri,
    required this.icon,
    required this.mauNen,
    required this.mauChu,
    this.nhanPhu,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: mauNen,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: mauChu, size: 26),
                if (nhanPhu != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: mauChu.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(nhanPhu!, style: TextStyle(fontSize: 11, color: mauChu, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(giaTri, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: mauChu)),
            const SizedBox(height: 2),
            Text(nhanDe, style: TextStyle(fontSize: 12, color: mauChu.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }
}

/// Tiêu đề section có nút action
class TieuDeSection extends StatelessWidget {
  final String tieuDe;
  final IconData icon;
  final String? nhanNut;
  final VoidCallback? onNutNhan;

  const TieuDeSection({
    super.key,
    required this.tieuDe,
    required this.icon,
    this.nhanNut,
    this.onNutNhan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tieuDe, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          if (nhanNut != null && onNutNhan != null)
            TextButton.icon(
              onPressed: onNutNhan,
              icon: const Icon(Icons.add, size: 18),
              label: Text(nhanNut!),
            ),
        ],
      ),
    );
  }
}

/// Màn hình trạng thái rỗng
class TrangThaiRong extends StatelessWidget {
  final String thongDiep;
  final IconData icon;
  final String? nhanNut;
  final VoidCallback? onNutNhan;

  const TrangThaiRong({
    super.key,
    required this.thongDiep,
    this.icon = Icons.inbox_outlined,
    this.nhanNut,
    this.onNutNhan,
  });

  @override
  Widget build(BuildContext context) {
    // Dùng LayoutBuilder + SingleChildScrollView để trạng thái rỗng không bị
    // RenderFlex overflow khi màn hình còn ít chiều cao trong TabBarView/
    // NestedScrollView. Khi đủ cao, nội dung vẫn được căn giữa đẹp.
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
                  Icon(icon, size: 58, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  Text(
                    thongDiep,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (nhanNut != null && onNutNhan != null) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: onNutNhan,
                      icon: const Icon(Icons.add),
                      label: Text(nhanNut!),
                    ),
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

/// Màn hình lỗi
class TrangThaiLoi extends StatelessWidget {
  final String loi;
  final VoidCallback onTaiLai;

  const TrangThaiLoi({super.key, required this.loi, required this.onTaiLai});

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

/// Chip trạng thái tài liệu / bài tập
class ChipTrangThai extends StatelessWidget {
  final String nhan;
  final Color mau;
  final IconData icon;

  const ChipTrangThai({super.key, required this.nhan, required this.mau, required this.icon});

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
          Icon(icon, size: 13, color: mau),
          const SizedBox(width: 4),
          Text(nhan, style: TextStyle(fontSize: 12, color: mau, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Format ngày giờ
String dinhDangNgay(DateTime? dt) {
  if (dt == null) return 'Chưa có';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

String dinhDangNgayGio(DateTime? dt) {
  if (dt == null) return 'Chưa có';
  return '${dinhDangNgay(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

void hienThiSnackBar(BuildContext context, String thongDiep, {bool laThanh = true}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(thongDiep),
    backgroundColor: laThanh ? Colors.green : Colors.red,
  ));
}