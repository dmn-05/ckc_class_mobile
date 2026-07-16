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

  IconData _statusIcon(String value) {
    switch (value) {
      case 'dang_hoc':
        return Icons.check_circle;
      case 'tam_nghi':
        return Icons.pause_circle;
      case 'da_tot_nghiep':
        return Icons.verified;
      default:
        return Icons.info_outline;
    }
  }

  String _avatarText(SinhVienLop sv) {
    final text = sv.maSinhVien.isNotEmpty ? sv.maSinhVien : sv.hoTen;
    if (text.isEmpty) return 'SV';
    return text.characters.first.toUpperCase();
  }

  Widget _dongThongTin(String label, String value) {
    final text = value.trim().isEmpty ? 'Chưa cập nhật' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: DefaultTextStyle.of(
            context,
          ).style.copyWith(fontSize: 13.5, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget _trangThaiNho(SinhVienLop sv) {
    final color = _statusColor(sv.trangThai);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(sv.trangThai), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _statusText(sv.trangThai),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoLoc(SinhVienLopProvider provider) {
    final dangCoBoLoc =
        provider.trangThai.isNotEmpty || searchController.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Tìm kiếm sinh viên',
                        hintText: 'MSSV, họ tên hoặc email',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: searchController.text.isEmpty
                            ? null
                            : IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  searchController.clear();
                                  provider.search('');
                                  setState(() {});
                                },
                              ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        provider.search(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: provider.processing
                        ? null
                        : () => _showAddDialog(context),
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text('Thêm'),
                  ),
                ),
              ],
            ),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                visualDensity: VisualDensity.compact,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                dense: true,
                initiallyExpanded: provider.trangThai.isNotEmpty,
                leading: Icon(
                  dangCoBoLoc ? Icons.filter_alt : Icons.filter_alt_outlined,
                  size: 20,
                ),
                title: Text(
                  dangCoBoLoc ? 'Bộ lọc đang áp dụng' : 'Bộ lọc trạng thái',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: provider.trangThai.isNotEmpty
                    ? IconButton(
                        tooltip: 'Xóa bộ lọc trạng thái',
                        icon: const Icon(Icons.filter_alt_off, size: 20),
                        onPressed: () => provider.filterTrangThai(''),
                      )
                    : const Icon(Icons.expand_more),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(provider, 'Tất cả', ''),
                          const SizedBox(width: 8),
                          _filterChip(provider, 'Đang học', 'dang_hoc'),
                          const SizedBox(width: 8),
                          _filterChip(provider, 'Tạm nghỉ', 'tam_nghi'),
                          const SizedBox(width: 8),
                          _filterChip(
                            provider,
                            'Đã tốt nghiệp',
                            'da_tot_nghiep',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    SinhVienLopProvider provider,
    String label,
    String value,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: provider.trangThai == value,
      onSelected: (_) => provider.filterTrangThai(value),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh viên lớp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => context.read<SinhVienLopProvider>().loadDanhSach(),
          ),
        ],
      ),
      body: Consumer<SinhVienLopProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildBoLoc(provider),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Material(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      title: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: provider.xoaLoi,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (provider.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.danhSach.isEmpty) {
                      return const Center(
                        child: Text('Chưa có sinh viên phù hợp trong lớp'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: provider.loadDanhSach,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: provider.danhSach.length,
                        itemBuilder: (context, index) {
                          final sv = provider.danhSach[index];
                          return _cardItem(context, provider, sv);
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

  Widget _cardItem(
    BuildContext context,
    SinhVienLopProvider provider,
    SinhVienLop sv,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Text(_avatarText(sv)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sv.hoTen.isEmpty ? 'Chưa cập nhật họ tên' : sv.hoTen,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _dongThongTin('Mã sinh viên', sv.maSinhVien),
            _dongThongTin('Email', sv.email),
            _dongThongTin('Khóa học', sv.khoaHocHienThi),
            const SizedBox(height: 8),
            Row(
              children: [
                _trangThaiNho(sv),
                const Spacer(),
                IconButton(
                  tooltip: 'Cập nhật trạng thái',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(Icons.sync, size: 22),
                  onPressed: provider.processing
                      ? null
                      : () => _showStatusDialog(context, provider, sv),
                ),
                IconButton(
                  tooltip: sv.trangThai == 'tam_nghi'
                      ? 'Sinh viên đang tạm nghỉ'
                      : 'Chuyển sang tạm nghỉ',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: Icon(
                    Icons.pause_circle_outline,
                    size: 22,
                    color: sv.trangThai == 'tam_nghi'
                        ? Colors.grey
                        : Colors.red,
                  ),
                  onPressed: provider.processing || sv.trangThai == 'tam_nghi'
                      ? null
                      : () => _confirmTamNghi(context, provider, sv),
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

    await provider.loadDanhSachThem('');

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider<SinhVienLopProvider>.value(
          value: provider,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Thêm sinh viên vào lớp'),
                content: SizedBox(
                  width: 500,
                  height: 520,
                  child: Column(
                    children: [
                      TextField(
                        controller: searchThemController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Tìm theo MSSV, tên hoặc email',
                          border: const OutlineInputBorder(),
                          suffixIcon: searchThemController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () async {
                                    searchThemController.clear();
                                    setDialogState(() {});
                                    await provider.loadDanhSachThem('');
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
                                child: Text('Không tìm thấy sinh viên phù hợp'),
                              );
                            }

                            return ListView.separated(
                              itemCount: p.danhSachThem.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final sv = p.danhSachThem[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(_avatarText(sv)),
                                  ),
                                  title: Text(
                                    sv.hoTen,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${sv.maSinhVien} • ${sv.email}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: p.processing
                                        ? null
                                        : () async {
                                            final success = await p.themSinhVien(
                                              sv.sinhVienId,
                                            );

                                            if (!mounted) return;

                                            if (success) {
                                              Navigator.of(dialogContext).pop();
                                            }

                                            _showSnackBar(
                                              success
                                                  ? (p.message ??
                                                        'Thêm sinh viên thành công')
                                                  : (p.error ??
                                                        'Thêm sinh viên thất bại'),
                                              success ? Colors.green : Colors.red,
                                            );
                                          },
                                    child: const Text('Thêm'),
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
                    child: const Text('Đóng'),
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

  void _showStatusDialog(
    BuildContext context,
    SinhVienLopProvider provider,
    SinhVienLop sv,
  ) {
    Future<void> update(String status) async {
      final ok = await provider.doiTrangThai(sv.id, status);
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        ok
            ? (provider.message ?? 'Cập nhật thành công')
            : (provider.error ?? 'Cập nhật thất bại'),
        ok ? Colors.green : Colors.red,
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cập nhật trạng thái sinh viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Đang học'),
              selected: sv.trangThai == 'dang_hoc',
              onTap: () => update('dang_hoc'),
            ),
            ListTile(
              leading: const Icon(Icons.pause_circle, color: Colors.orange),
              title: const Text('Tạm nghỉ'),
              selected: sv.trangThai == 'tam_nghi',
              onTap: () => update('tam_nghi'),
            ),
            ListTile(
              leading: const Icon(Icons.verified, color: Colors.blue),
              title: const Text('Đã tốt nghiệp'),
              selected: sv.trangThai == 'da_tot_nghiep',
              onTap: () => update('da_tot_nghiep'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmTamNghi(
    BuildContext context,
    SinhVienLopProvider provider,
    SinhVienLop sv,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          'Chuyển sinh viên "${sv.hoTen}" sang trạng thái tạm nghỉ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await provider.xoaSinhVien(sv.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              _showSnackBar(
                ok
                    ? (provider.message ?? 'Đã chuyển sang tạm nghỉ')
                    : (provider.error ?? 'Thao tác thất bại'),
                ok ? Colors.green : Colors.red,
              );
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}
