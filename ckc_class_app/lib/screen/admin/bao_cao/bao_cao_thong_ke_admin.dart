import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ckc_class_app/model/bao_cao_thong_ke_model.dart';
import 'package:ckc_class_app/provider/bao_cao_thong_ke_provider.dart';

class BaoCaoThongKeAdminScreen extends StatelessWidget {
  const BaoCaoThongKeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaoCaoThongKeProvider>(
      create: (_) => BaoCaoThongKeProvider()..layBaoCaoThongKe(),
      child: const _BaoCaoThongKeAdminView(),
    );
  }
}

class _BaoCaoThongKeAdminView extends StatefulWidget {
  const _BaoCaoThongKeAdminView();

  @override
  State<_BaoCaoThongKeAdminView> createState() =>
      _BaoCaoThongKeAdminViewState();
}

class _BaoCaoThongKeAdminViewState
    extends State<_BaoCaoThongKeAdminView> {

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTongQuan(BaoCaoThongKeAdmin baoCao) {
    final items = [
      ('Khoa', baoCao.getValue('khoa'), Icons.account_balance, Colors.orange),
      ('Bộ môn', baoCao.getValue('bo_mon'), Icons.business, Colors.teal),
      ('Môn học', baoCao.getValue('mon_hoc'), Icons.menu_book, Colors.blue),
      ('Lớp hành chính', baoCao.getValue('lop'), Icons.class_, Colors.indigo),
      ('Lớp học phần', baoCao.getValue('lop_hoc_phan'), Icons.groups, Colors.deepPurple),
      ('Người dùng', baoCao.getValue('nguoi_dung'), Icons.manage_accounts, Colors.brown),
      ('Giảng viên', baoCao.getValue('giang_vien'), Icons.school, Colors.green),
      ('Sinh viên', baoCao.getValue('sinh_vien'), Icons.people, Colors.purple),
      ('Tài liệu', baoCao.getValue('tai_lieu'), Icons.folder_copy, Colors.cyan),
      ('Bài tập', baoCao.getValue('bai_tap'), Icons.assignment, Colors.redAccent),
      ('Bài nộp', baoCao.getValue('bai_nop'), Icons.upload_file, Colors.blueGrey),
      ('Bình luận', baoCao.getValue('binh_luan'), Icons.comment, Colors.pink),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1000 ? 4 : width >= 650 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 92,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _statCard(
              title: item.$1,
              value: item.$2,
              icon: item.$3,
              color: item.$4,
            );
          },
        );
      },
    );
  }

  Widget _buildBangLopHocPhan(List<BaoCaoLopHocPhan> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Chưa có dữ liệu lớp học phần'),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Lớp học phần')),
            DataColumn(label: Text('Môn học')),
            DataColumn(label: Text('Giảng viên')),
            DataColumn(label: Text('SV')),
            DataColumn(label: Text('Tài liệu')),
            DataColumn(label: Text('Bài tập')),
            DataColumn(label: Text('Bài nộp')),
            DataColumn(label: Text('Đã chấm')),
            DataColumn(label: Text('Nộp muộn')),
            DataColumn(label: Text('Điểm TB')),
          ],
          rows: data.map((item) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 180, child: Text(item.tenLopHienThi))),
                DataCell(SizedBox(width: 170, child: Text(item.tenMonHienThi))),
                DataCell(SizedBox(width: 170, child: Text(item.tenGiangVienHienThi))),
                DataCell(Text(item.soSinhVienDangHoc.toString())),
                DataCell(Text(item.soTaiLieu.toString())),
                DataCell(Text(item.soBaiTap.toString())),
                DataCell(Text(item.soBaiNop.toString())),
                DataCell(Text(item.soBaiDaCham.toString())),
                DataCell(Text(item.soBaiNopMuon.toString())),
                DataCell(Text(item.diemTrungBinh?.toStringAsFixed(2) ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBangMonHoc(List<BaoCaoMonHoc> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Chưa có dữ liệu môn học'),
        ),
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Môn học')),
            DataColumn(label: Text('Lớp HP')),
            DataColumn(label: Text('SV tham gia')),
            DataColumn(label: Text('Tài liệu')),
            DataColumn(label: Text('Bài tập')),
            DataColumn(label: Text('Điểm TB')),
          ],
          rows: data.map((item) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: 220, child: Text(item.tenMonHienThi))),
                DataCell(Text(item.soLopHocPhan.toString())),
                DataCell(Text(item.soSinhVienThamGia.toString())),
                DataCell(Text(item.soTaiLieu.toString())),
                DataCell(Text(item.soBaiTap.toString())),
                DataCell(Text(item.diemTrungBinh?.toStringAsFixed(2) ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thống kê'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: () => context.read<BaoCaoThongKeProvider>().layBaoCaoThongKe(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<BaoCaoThongKeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.baoCao == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          final baoCao = provider.baoCao;
          if (baoCao == null) {
            return const Center(child: Text('Chưa có dữ liệu báo cáo'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.layBaoCaoThongKe(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text(
                  'Tổng quan hệ thống',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTongQuan(baoCao),
                const SizedBox(height: 16),
                const Text(
                  'Báo cáo theo lớp học phần',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBangLopHocPhan(baoCao.baoCaoLopHocPhan),
                const SizedBox(height: 16),
                const Text(
                  'Báo cáo theo môn học',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildBangMonHoc(baoCao.baoCaoMonHoc),
              ],
            ),
          );
        },
      ),
    );
  }
}
