import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ckc_class_app/model/lop_hoc_phan_model.dart';
import 'package:ckc_class_app/provider/sinh_vien_lop_hoc_phan_provider.dart';
import 'package:ckc_class_app/provider/lop_provider.dart';

class QuanLySinhVienLopHocPhanScreen extends StatefulWidget {
  final LopHocPhan lopHocPhan;

  const QuanLySinhVienLopHocPhanScreen({super.key, required this.lopHocPhan});

  @override
  State<QuanLySinhVienLopHocPhanScreen> createState() =>
      _QuanLySinhVienLopHocPhanScreenState();
}

class _QuanLySinhVienLopHocPhanScreenState
    extends State<QuanLySinhVienLopHocPhanScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SinhVienLopHocPhanProvider>().init(widget.lopHocPhan.id);
    });
  }

  // ================= STATUS COLOR =================
  Color _statusColor(String status) {
    switch (status) {
      case 'dang_hoc':
        return Colors.green;
      case 'da_huy':
        return Colors.red;
      case 'hoan_thanh':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTrangThai(String tt) {
    switch (tt) {
      case 'dang_hoc':
        return 'Đang học';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'da_huy':
        return 'Đã hủy';
      default:
        return tt;
    }
  }

  // ================= CONFIRM DELETE =================
  void _confirmDelete(
    BuildContext context,
    int id,
    int lopId,
    SinhVienLopHocPhanProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa sinh viên này?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa"),
            onPressed: () async {
              await provider.xoaSinhVienKhoiLopHocPhan(
                id: id,
                lopHocPhanId: lopId,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context, provider, sv, int lopId) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Đổi trạng thái"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Đang học"),
                onTap: () {
                  provider.capNhatTrangThaiSinhVien(
                    id: sv.id,
                    lopHocPhanId: lopId,
                    trangThai: 'dang_hoc',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Hoàn thành"),
                onTap: () {
                  provider.capNhatTrangThaiSinhVien(
                    id: sv.id,
                    lopHocPhanId: lopId,
                    trangThai: 'hoan_thanh',
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Đã hủy"),
                onTap: () {
                  provider.capNhatTrangThaiSinhVien(
                    id: sv.id,
                    lopHocPhanId: lopId,
                    trangThai: 'da_huy',
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= ADD STUDENT =================
  void _showAddDialog(BuildContext context, int lopId) {
    final provider = context.read<SinhVienLopHocPhanProvider>();

    final search = TextEditingController();

    provider.layDanhSachSinhVienCoTheThem(lopHocPhanId: lopId);

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Thêm sinh viên"),
              content: SizedBox(
                width: 500,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      controller: search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Tìm theo tên hoặc MSSV",
                      ),
                      onChanged: (v) {
                        provider.layDanhSachSinhVienCoTheThem(
                          lopHocPhanId: lopId,
                          tuKhoa: v,
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: Consumer<SinhVienLopHocPhanProvider>(
                        builder: (context, p, _) {
                          return ListView.builder(
                            itemCount: p.dsSinhVienCoTheThem.length,
                            itemBuilder: (context, i) {
                              final sv = p.dsSinhVienCoTheThem[i];

                              return Card(
                                child: ListTile(
                                  title: Text("${sv.maSinhVien} - ${sv.hoTen}"),
                                  subtitle: Text(sv.email),
                                  trailing: ElevatedButton(
                                    child: const Text("Thêm"),
                                    onPressed: () async {
                                      await p.themSinhVienVaoLopHocPhan(
                                        lopHocPhanId: lopId,
                                        sinhVienId: sv.sinhVienId,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
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
            );
          },
        );
      },
    );
  }
// ================= Thêm sinh viên thoe lớp =================
  Future<void> _showAddByClassDialog(
  BuildContext context,
  int lopHocPhanId,
) async {
  final lopProvider = context.read<LopProvider>();
  final svLhpProvider = context.read<SinhVienLopHocPhanProvider>();

  await lopProvider.layDanhSachLop(trangThai: 'dang_hoc');

  if (!mounted) return;

  int? selectedLopId;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final dsLop = lopProvider.dsLop
              .where((lop) => lop.trangThai == 'dang_hoc')
              .toList();

          return AlertDialog(
            title: const Text("Thêm sinh viên theo lớp hành chính"),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedLopId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Chọn lớp hành chính",
                      prefixIcon: Icon(Icons.class_),
                      border: OutlineInputBorder(),
                    ),
                    items: dsLop.map((lop) {
                      return DropdownMenuItem<int>(
                        value: lop.id,
                        child: Text(
                          '${lop.maLop} - ${lop.tenLop} (${lop.soLuongSinhVien} SV)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedLopId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Chỉ thêm sinh viên đang học và tài khoản đang hoạt động. "
                    "Sinh viên đã có trong lớp học phần sẽ được bỏ qua.",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Hủy"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text("Thêm cả lớp"),
                onPressed: selectedLopId == null || svLhpProvider.isProcessing
                    ? null
                    : () async {
                        final result =
                            await svLhpProvider.themSinhVienTheoLopHanhChinh(
                          lopHocPhanId: lopHocPhanId,
                          lopId: selectedLopId!,
                        );

                        if (!mounted) return;

                        Navigator.pop(dialogContext);

                        final success = result['success'] == true;
                        final message =
                            result['message']?.toString() ??
                            (success
                                ? 'Thêm sinh viên thành công'
                                : 'Thêm sinh viên thất bại');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      },
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final lop = widget.lopHocPhan;

    return Scaffold(
      appBar: AppBar(
        title: Text("SV - ${lop.maLopHocPhan}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: "Thêm sinh viên theo lớp hành chính",
            onPressed: () {
              _showAddByClassDialog(context, lop.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Thêm sinh viên",
            onPressed: () {
              _showAddDialog(context, lop.id);
            },
          ),
        ],
      ),

      body: Consumer<SinhVienLopHocPhanProvider>(
        builder: (context, provider, _) {
          final list = provider.dsSinhVienLopHocPhan;

          return Column(
            children: [
              // ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${lop.tenLop} - ${lop.tenMon}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "GV: ${lop.tenGiangVien} | Sĩ số: ${lop.tongSoSinhVien}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // SEARCH
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Tìm tên / MSSV",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          provider.timKiemSinhVien(
                            lopHocPhanId: lop.id,
                            tuKhoa: v,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // FILTER STATUS
                    DropdownButton<String>(
                      value: provider.trangThai,
                      items: const [
                        DropdownMenuItem(value: '', child: Text("Tất cả")),
                        DropdownMenuItem(
                          value: 'dang_hoc',
                          child: Text("Đang học"),
                        ),
                        DropdownMenuItem(
                          value: 'hoan_thanh',
                          child: Text("Hoàn thành"),
                        ),
                        DropdownMenuItem(
                          value: 'da_huy',
                          child: Text("Đã hủy"),
                        ),
                      ],
                      onChanged: (v) {
                        provider.locTheoTrangThai(
                          lopHocPhanId: lop.id,
                          trangThai: v ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ================= LIST =================
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final sv = list[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(child: Text("${i + 1}")),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "${sv.maSinhVien} - ${sv.hoTen}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      sv.trangThai,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatTrangThai(sv.trangThai),
                                    style: TextStyle(
                                      color: _statusColor(sv.trangThai),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text("Email: ${sv.email}"),
                            Text("Lớp: ${sv.tenLopHienThi}"),

                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.sync,
                                    color: Colors.orange,
                                  ),
                                  label: const Text("Đổi trạng thái"),
                                  onPressed: () {
                                    _showChangeStatusDialog(
                                      context,
                                      provider,
                                      sv,
                                      lop.id,
                                    );
                                  },
                                ),

                                const SizedBox(width: 8),

                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: const Text("Xóa"),
                                  onPressed: () {
                                    _confirmDelete(
                                      context,
                                      sv.id,
                                      lop.id,
                                      provider,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
