import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import 'bai_tap_sv.dart';

// Bước sau sẽ tạo 2 file này.
// Nếu chưa tạo, VS Code sẽ báo lỗi import là bình thường.
import 'bang_tin_sv.dart';
import 'moi_nguoi_sv.dart';

class ChiTietLopSV extends StatefulWidget {
  final LopHocPhanSVModel lop;

  // 0 = Bảng tin, 1 = Bài tập trên lớp, 2 = Mọi người
  final int tabBanDau;

  const ChiTietLopSV({super.key, required this.lop, this.tabBanDau = 0});

  @override
  State<ChiTietLopSV> createState() => _ChiTietLopSVState();
}

class _ChiTietLopSVState extends State<ChiTietLopSV>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Dùng TabController riêng để mở đúng tab khi truyền tabBanDau.
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.tabBanDau.clamp(0, 2),
    );

    // Load dữ liệu của lớp hiện tại.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SinhVienProvider>();

      p.layDanhSachThongBao(widget.lop.id);
      p.layDanhSachBaiTap(widget.lop.id);
      p.layThanhVienLop(widget.lop.id);
    });
  }

  @override
  void dispose() {
    // Bắt buộc dispose controller để tránh rò bộ nhớ.
    _tabController.dispose();
    super.dispose();
  }

  Future<void> taiLaiDuLieu() async {
    final p = context.read<SinhVienProvider>();

    await Future.wait([
      p.layDanhSachThongBao(widget.lop.id),
      p.layDanhSachBaiTap(widget.lop.id),
      p.layThanhVienLop(widget.lop.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar tối giản giống Google Classroom.
      appBar: AppBar(
        title: Text(
          widget.lop.tenHienThi,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: taiLaiDuLieu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.forum_outlined), text: 'Bảng tin'),
            Tab(
              icon: Icon(Icons.assignment_outlined),
              text: 'Bài tập trên lớp',
            ),
            Tab(icon: Icon(Icons.people_outline), text: 'Mọi người'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // Bảng tin: chỉ hiển thị thông báo của giảng viên.
          BangTinSVPage(lop: widget.lop, onRefresh: taiLaiDuLieu),

          // Bài tập trên lớp: dùng lại màn hình bài tập hiện có.
          BaiTapSVPage(lopHocPhanId: widget.lop.id),

          // Mọi người: hiển thị giáo viên trước, sinh viên sẽ thêm API sau.
          MoiNguoiSVPage(lop: widget.lop),
        ],
      ),
    );
  }
}
