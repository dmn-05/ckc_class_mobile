import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/sinh_vien_lop_model.dart';
import '../../../provider/sinh_vien_lop_provider.dart';

class SinhVienLopScreen extends StatefulWidget {
  final int lopId;

  const SinhVienLopScreen({super.key, required this.lopId});

  @override
  State<SinhVienLopScreen> createState() => _SinhVienLopScreenState();
}

class _SinhVienLopScreenState extends State<SinhVienLopScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SinhVienLopProvider>().init(widget.lopId);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Color _statusColor(String value) {
    switch (value) {
      case 'dang_hoc':
        return Colors.green;
      case 'tam_nghi':
        return Colors.orange;
      case 'da_tot_nghiep':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String value) {
    switch (value) {
      case 'dang_hoc':
        return 'Đang học';
      case 'tam_nghi':
        return 'Tạm nghỉ';
      case 'da_tot_nghiep':
        return 'Đã tốt nghiệp';
      default:
        return value;
    }
  }

  String _avatarText(SinhVienLop sv) {
    final text = sv.maSinhVien.isNotEmpty ? sv.maSinhVien : sv.hoTen;
    if (text.isEmpty) return 'SV';
    return text.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên lớp hành chính'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => context.read<SinhVienLopProvider>().loadDanhSach(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Thêm sinh viên',
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Consumer<SinhVienLopProvider>(
        builder: (context, p, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Tìm theo tên, email hoặc MSSV',
                    border: const OutlineInputBorder(),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              p.search('');
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    p.search(value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _chip(p, 'Tất cả', ''),
                    const SizedBox(width: 8),
                    _chip(p, 'Đang học', 'dang_hoc'),
                    const SizedBox(width: 8),
                    _chip(p, 'Tạm nghỉ', 'tam_nghi'),
                    const SizedBox(width: 8),
                    _chip(p, 'Đã tốt nghiệp', 'da_tot_nghiep'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      leading: const Icon(Icons.error_outline, color: Colors.red),
                      title: Text(p.error!, style: const TextStyle(color: Colors.red)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: p.xoaLoi,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (p.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (p.danhSach.isEmpty) {
                      return const Center(
                        child: Text('Chưa có sinh viên trong lớp này'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: p.loadDanhSach,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: p.danhSach.length,
                        itemBuilder: (context, i) {
                          final sv = p.danhSach[i];
                          return _cardItem(context, p, sv);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(SinhVienLopProvider p, String label, String value) {
    final selected = p.trangThai == value;

    return GestureDetector(
      onTap: () => p.filterTrangThai(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.blue),
        ),
      ),
    );
  }

  Widget _cardItem(BuildContext context, SinhVienLopProvider p, SinhVienLop sv) {
    final color = _statusColor(sv.trangThai);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(_avatarText(sv))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${sv.maSinhVien} - ${sv.hoTen}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    _statusText(sv.trangThai),
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Email: ${sv.email.isEmpty ? 'Chưa cập nhật' : sv.email}'),
            Text('Lớp: ${sv.tenLop.isEmpty ? 'Chưa cập nhật' : sv.tenLop}'),
            Text('Khóa học: ${sv.khoaHocHienThi}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.sync, color: Colors.orange),
                  label: const Text('Trạng thái'),
                  onPressed: p.processing ? null : () => _showStatusDialog(context, p, sv),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.pause_circle_outline, color: Colors.red),
                  label: const Text('Tạm nghỉ'),
                  onPressed: p.processing ? null : () => _confirmTamNghi(context, p, sv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
Future<void> _showAddDialog(BuildContext context) async {
  final provider = context.read<SinhVienLopProvider>();
  final searchThemController = TextEditingController();

  await provider.loadDanhSachThem("");

  if (!mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return ChangeNotifierProvider<SinhVienLopProvider>.value(
        value: provider,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Thêm / chuyển sinh viên vào lớp"),
              content: SizedBox(
                width: 500,
                height: 520,
                child: Column(
                  children: [
                    TextField(
                      controller: searchThemController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Tìm theo MSSV hoặc tên sinh viên",
                        border: const OutlineInputBorder(),
                        suffixIcon: searchThemController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () async {
                                  searchThemController.clear();

                                  setDialogState(() {});

                                  await provider.loadDanhSachThem("");
                                },
                              ),
                      ),
                      onChanged: (value) async {
                        setDialogState(() {});

                        await provider.loadDanhSachThem(value.trim());
                      },
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: Consumer<SinhVienLopProvider>(
                        builder: (context, p, _) {
                          if (p.loadingThem) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (p.danhSachThem.isEmpty) {
                            return const Center(
                              child: Text("Không tìm thấy sinh viên phù hợp"),
                            );
                          }

                          return ListView.separated(
                            itemCount: p.danhSachThem.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final sv = p.danhSachThem[i];

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    sv.maSinhVien.isNotEmpty
                                        ? sv.maSinhVien.substring(0, 1)
                                        : "S",
                                  ),
                                ),
                                title: Text(
                                  "${sv.maSinhVien} - ${sv.hoTen}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(sv.email),
                                trailing: ElevatedButton(
                                  child: const Text("Thêm"),
                                  onPressed: () async {
                                    final success =
                                        await p.themSinhVien(sv.sinhVienId);

                                    if (!mounted) return;

                                    Navigator.of(dialogContext).pop();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? "Thêm / chuyển sinh viên thành công"
                                              : "Thêm sinh viên thất bại",
                                        ),
                                        backgroundColor: success
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Đóng"),
                ),
              ],
            );
          },
        ),
      );
    },
  );

  searchThemController.dispose();
}
  void _showStatusDialog(BuildContext context, SinhVienLopProvider p, SinhVienLop sv) {
    Future<void> update(String status) async {
      final ok = await p.doiTrangThai(sv.id, status);
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        ok ? (p.message ?? 'Cập nhật thành công') : (p.error ?? 'Cập nhật thất bại'),
        ok ? Colors.green : Colors.red,
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi trạng thái sinh viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Đang học'),
              onTap: () => update('dang_hoc'),
            ),
            ListTile(
              title: const Text('Tạm nghỉ'),
              onTap: () => update('tam_nghi'),
            ),
            ListTile(
              title: const Text('Đã tốt nghiệp'),
              onTap: () => update('da_tot_nghiep'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmTamNghi(BuildContext context, SinhVienLopProvider p, SinhVienLop sv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Chuyển sinh viên "${sv.hoTen}" sang trạng thái tạm nghỉ?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Đồng ý'),
            onPressed: () async {
              final ok = await p.xoaSinhVien(sv.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSnackBar(
                ok ? (p.message ?? 'Đã chuyển tạm nghỉ') : (p.error ?? 'Thao tác thất bại'),
                ok ? Colors.green : Colors.red,
              );
            },
          ),
        ],
      ),
    );
  }
}
