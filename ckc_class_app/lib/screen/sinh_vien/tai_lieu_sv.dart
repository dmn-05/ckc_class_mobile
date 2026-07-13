import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class TaiLieuSVPage extends StatefulWidget {
  final int lopHocPhanId;
  final Future<void> Function()? onRefresh;
  const TaiLieuSVPage({super.key, required this.lopHocPhanId, this.onRefresh});

  @override
  State<TaiLieuSVPage> createState() => _TaiLieuSVPageState();
}

class _TaiLieuSVPageState extends State<TaiLieuSVPage> {
  final _search = TextEditingController();

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(builder: (_, p, __) {
      if (p.tlLoading) return const Center(child: CircularProgressIndicator());
      if (p.tlError != null) return TrangLoi(loi: p.tlError!, onTaiLai: () => p.layDanhSachTaiLieu(widget.lopHocPhanId));
      return RefreshIndicator(
        onRefresh: widget.onRefresh ?? () => p.layDanhSachTaiLieu(widget.lopHocPhanId),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextField(
              controller: _search,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Tìm tài liệu', border: OutlineInputBorder(), isDense: true),
              onSubmitted: (v) => p.layDanhSachTaiLieu(widget.lopHocPhanId, tuKhoa: v),
            ),
            const SizedBox(height: 12),
            if (p.dsTaiLieu.isEmpty) const SizedBox(height: 350, child: TrangRong(thongDiep: 'Chưa có tài liệu', icon: Icons.folder_off_outlined)),
            ...p.dsTaiLieu.map((tl) => Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.insert_drive_file)),
              title: Text(tl.tieuDe, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${tl.loaiFile} • ${tl.tenNguoiTao ?? 'Giảng viên'} • ${dinhDangNgay(tl.ngayTao)}'),
              trailing: IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đường dẫn file: ${tl.duongDanFile ?? 'chưa có'}')),
                ),
              ),
            ))),
          ],
        ),
      );
    });
  }
}
