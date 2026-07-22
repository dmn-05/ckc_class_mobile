import 'package:flutter/material.dart';

import '../../../model/xuat_excel_model.dart';
import '../../../provider/xuat_excel_provider.dart';
import '../../../utils/modal_lifecycle.dart';

class XuatExcelScreen extends StatefulWidget {
  final bool showAppBar;
  final String? loaiMacDinh;
  final Map<String, dynamic> boLocMacDinh;
  final List<int> selectedIds;

  const XuatExcelScreen({
    super.key,
    this.showAppBar = false,
    this.loaiMacDinh,
    this.boLocMacDinh = const {},
    this.selectedIds = const [],
  });

  @override
  State<XuatExcelScreen> createState() => _XuatExcelScreenState();
}

class _XuatExcelScreenState extends State<XuatExcelScreen> {
  late final XuatExcelProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  static const Color _background = Color(0xFFF6F8FC);
  static const Color _primary = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _provider = XuatExcelProvider(
      loaiMacDinh: widget.loaiMacDinh,
      boLocMacDinh: widget.boLocMacDinh,
      selectedIds: widget.selectedIds,
    );
    _searchController.text = widget.boLocMacDinh['tu_khoa']?.toString() ?? '';
    _provider.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _provider.dispose();
    super.dispose();
  }


  String _defaultExportFileName() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final type = _provider.selectedType?.key ?? 'du_lieu';

    return '${type}_${now.year}${two(now.month)}${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}';
  }

  Future<String?> _showFileNameDialog() async {
    final controller = TextEditingController(text: _defaultExportFileName());
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              var value = controller.text.trim();
              value = value.replaceFirst(RegExp(r'\.xlsx$', caseSensitive: false), '');

              if (value.isEmpty) {
                setDialogState(() => errorText = 'Tên file không được để trống');
                return;
              }

              if (value.length > 120) {
                setDialogState(() => errorText = 'Tên file tối đa 120 ký tự');
                return;
              }

              if (RegExp(r'[<>:"/\\|?*\x00-\x1F]').hasMatch(value)) {
                setDialogState(
                  () => errorText = 'Tên file không được chứa: < > : " / \\ | ? *',
                );
                return;
              }

              unfocusCurrentInput();
              Navigator.of(dialogContext, rootNavigator: true).pop(value);
            }

            return AlertDialog(
              title: const Text('Đặt tên file Excel'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập tên file trước khi xuất. Hệ thống sẽ tự thêm đuôi .xlsx.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 120,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    decoration: InputDecoration(
                      labelText: 'Tên file',
                      suffixText: '.xlsx',
                      errorText: errorText,
                      prefixIcon: const Icon(Icons.drive_file_rename_outline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    unfocusCurrentInput();
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: const Text('Hủy'),
                ),
                FilledButton.icon(
                  onPressed: submit,
                  icon: const Icon(Icons.file_download_rounded),
                  label: const Text('Xuất file'),
                ),
              ],
            );
          },
        );
      },
    );

    await disposeControllersAfterModal([controller]);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final body = AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        if (_provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_provider.types.isEmpty) {
          return _EmptyState(
            icon: Icons.file_download_off_rounded,
            title: 'Chưa có cấu hình xuất Excel',
            message: _provider.error ?? 'Không thể tải danh sách loại dữ liệu.',
            onRetry: _provider.initialize,
          );
        }

        return RefreshIndicator(
          onRefresh: _provider.initialize,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTypeCard(),
              const SizedBox(height: 12),
              _buildFilterCard(),
              const SizedBox(height: 12),
              _buildColumnCard(),
              const SizedBox(height: 12),
              _buildActionCard(),
              if (_provider.error != null) ...[
                const SizedBox(height: 12),
                _buildErrorCard(_provider.error!),
              ],
              if (_provider.preview != null) ...[
                const SizedBox(height: 12),
                _buildPreviewCard(_provider.preview!),
              ],
            ],
          ),
        );
      },
    );

    if (!widget.showAppBar) {
      return ColoredBox(color: _background, child: body);
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Xuất dữ liệu Excel'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: body,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.file_download_rounded, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xuất dữ liệu Excel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chọn dữ liệu, bộ lọc và các cột trước khi tạo file.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard() {
    final type = _provider.selectedType!;
    return _SectionCard(
      title: '1. Chọn loại và phạm vi xuất',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: type.key,
            isExpanded: true,
            decoration: _decoration('Loại dữ liệu', Icons.category_rounded),
            items: _provider.types
                .map(
                  (item) => DropdownMenuItem(
                    value: item.key,
                    child: Text(item.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _searchController.clear();
                _provider.setType(value);
              }
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              type.description,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _provider.scope,
            isExpanded: true,
            decoration: _decoration('Phạm vi xuất', Icons.tune_rounded),
            items: [
              const DropdownMenuItem(
                value: 'toan_bo',
                child: Text('Xuất toàn bộ'),
              ),
              const DropdownMenuItem(
                value: 'theo_bo_loc',
                child: Text('Xuất theo bộ lọc'),
              ),
              if (_provider.hasSelectedIds)
                DropdownMenuItem(
                  value: 'da_chon',
                  child: Text(
                    'Xuất ${_provider.selectedIds.length} dòng đã chọn',
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) _provider.setScope(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final type = _provider.selectedType!;
    final filters = type.filters;

    return _SectionCard(
      title: '2. Điều kiện lọc',
      trailing: TextButton.icon(
        onPressed: () {
          _searchController.clear();
          _provider.clearFilters();
        },
        icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
        label: const Text('Xóa lọc'),
      ),
      child: _provider.scope == 'toan_bo' && type.requiredFilters.isEmpty
          ? const _InfoMessage(
              icon: Icons.info_outline_rounded,
              message: 'Đang chọn xuất toàn bộ nên các điều kiện lọc sẽ không được áp dụng.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 760
                    ? (constraints.maxWidth - 10) / 2
                    : constraints.maxWidth;
                final widgets = <Widget>[];

                if (filters.contains('tu_khoa')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        controller: _searchController,
                        decoration: _decoration(
                          'Từ khóa',
                          Icons.search_rounded,
                        ).copyWith(
                          hintText: 'Mã, tên hoặc email',
                        ),
                        onChanged: (value) {
                          _provider.setFilter('tu_khoa', value.trim());
                        },
                      ),
                    ),
                  );
                }

                if (filters.contains('khoa_id')) {
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: 'Khoa',
                      icon: Icons.account_balance_rounded,
                      value: _intFilter('khoa_id'),
                      items: _provider.catalog.khoa,
                      onChanged: (value) => _provider.setFilter('khoa_id', value),
                    ),
                  );
                }

                if (filters.contains('bo_mon_id')) {
                  final khoaId = _intFilter('khoa_id');
                  final boMon = khoaId > 0
                      ? _provider.catalog.boMon
                          .where((item) => item.parentId == khoaId)
                          .toList()
                      : _provider.catalog.boMon;
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: 'Bộ môn',
                      icon: Icons.menu_book_rounded,
                      value: _intFilter('bo_mon_id'),
                      items: boMon,
                      onChanged: (value) => _provider.setFilter('bo_mon_id', value),
                    ),
                  );
                }

                if (filters.contains('lop_id')) {
                  final khoaId = _intFilter('khoa_id');
                  final lop = khoaId > 0
                      ? _provider.catalog.lop
                          .where((item) => item.parentId == khoaId)
                          .toList()
                      : _provider.catalog.lop;
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: type.requiredFilters.contains('lop_id')
                          ? 'Lớp hành chính *'
                          : 'Lớp hành chính',
                      icon: Icons.groups_rounded,
                      value: _intFilter('lop_id'),
                      items: lop,
                      onChanged: (value) => _provider.setFilter('lop_id', value),
                    ),
                  );
                }

                if (filters.contains('mon_hoc_id')) {
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: 'Môn học',
                      icon: Icons.auto_stories_rounded,
                      value: _intFilter('mon_hoc_id'),
                      items: _provider.catalog.monHoc,
                      onChanged: (value) => _provider.setFilter('mon_hoc_id', value),
                    ),
                  );
                }

                if (filters.contains('giang_vien_id')) {
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: 'Giảng viên',
                      icon: Icons.school_rounded,
                      value: _intFilter('giang_vien_id'),
                      items: _provider.catalog.giangVien,
                      onChanged: (value) => _provider.setFilter('giang_vien_id', value),
                    ),
                  );
                }

                if (filters.contains('lop_hoc_phan_id')) {
                  widgets.add(
                    _dropdownDanhMuc(
                      width: width,
                      label: 'Lớp học phần *',
                      icon: Icons.class_rounded,
                      value: _intFilter('lop_hoc_phan_id'),
                      items: _provider.catalog.lopHocPhan,
                      onChanged: (value) =>
                          _provider.setFilter('lop_hoc_phan_id', value),
                    ),
                  );
                }

                if (filters.contains('khoa_hoc')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String>(
                        value: _stringFilter('khoa_hoc'),
                        isExpanded: true,
                        decoration: _decoration(
                          'Khóa học',
                          Icons.date_range_rounded,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả khóa'),
                          ),
                          ..._provider.catalog.khoaHoc.map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text('Khóa $item'),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            _provider.setFilter('khoa_hoc', value ?? ''),
                      ),
                    ),
                  );
                }

                if (filters.contains('nam_nhap_hoc')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<int>(
                        value: _intFilter('nam_nhap_hoc'),
                        isExpanded: true,
                        decoration: _decoration(
                          'Năm nhập học',
                          Icons.calendar_today_rounded,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 0,
                            child: Text('Tất cả năm nhập học'),
                          ),
                          ..._provider.catalog.namNhapHoc.map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.toString()),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            _provider.setFilter('nam_nhap_hoc', value ?? 0),
                      ),
                    ),
                  );
                }

                if (filters.contains('nam_hoc')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String>(
                        value: _stringFilter('nam_hoc'),
                        isExpanded: true,
                        decoration: _decoration(
                          'Năm học',
                          Icons.date_range_rounded,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả năm học'),
                          ),
                          ..._provider.catalog.namHoc.map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            _provider.setFilter('nam_hoc', value ?? ''),
                      ),
                    ),
                  );
                }

                if (filters.contains('hoc_ky')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String>(
                        value: _stringFilter('hoc_ky'),
                        isExpanded: true,
                        decoration: _decoration(
                          'Học kỳ',
                          Icons.event_note_rounded,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả học kỳ'),
                          ),
                          ..._provider.catalog.hocKy.map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(_hocKyLabel(item)),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            _provider.setFilter('hoc_ky', value ?? ''),
                      ),
                    ),
                  );
                }

                if (filters.contains('trang_thai')) {
                  widgets.add(
                    SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String>(
                        value: _stringFilter('trang_thai'),
                        isExpanded: true,
                        decoration: _decoration(
                          'Trạng thái',
                          Icons.toggle_on_rounded,
                        ),
                        items: _statusItems(type.key),
                        onChanged: (value) =>
                            _provider.setFilter('trang_thai', value ?? ''),
                      ),
                    ),
                  );
                }

                if (widgets.isEmpty) {
                  return const _InfoMessage(
                    icon: Icons.info_outline_rounded,
                    message: 'Loại dữ liệu này không có bộ lọc bổ sung.',
                  );
                }

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widgets,
                );
              },
            ),
    );
  }

  Widget _buildColumnCard() {
    final type = _provider.selectedType!;
    return _SectionCard(
      title: '3. Chọn cột cần xuất',
      trailing: PopupMenuButton<String>(
        tooltip: 'Chọn nhanh',
        onSelected: (value) {
          if (value == 'default') _provider.selectDefaultColumns();
          if (value == 'all') _provider.selectAllColumns();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'default', child: Text('Cột mặc định')),
          PopupMenuItem(value: 'all', child: Text('Chọn tất cả cột')),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rounded, size: 18),
              SizedBox(width: 5),
              Text('Chọn nhanh'),
            ],
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: type.columns.map((column) {
          final selected = _provider.selectedColumns.contains(column.key);
          return FilterChip(
            selected: selected,
            label: Text(column.label),
            avatar: selected
                ? const Icon(Icons.check_rounded, size: 16)
                : null,
            onSelected: (value) =>
                _provider.toggleColumn(column.key, value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionCard() {
    return _SectionCard(
      title: '4. Xem trước và xuất file',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 520;
          final previewButton = OutlinedButton.icon(
            onPressed: _provider.previewing || _provider.exporting
                ? null
                : () async {
                    final success = await _provider.previewData();
                    if (!mounted || success) return;
                    _showMessage(_provider.error ?? 'Không thể xem trước dữ liệu');
                  },
            icon: _provider.previewing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.preview_rounded),
            label: const Text('Xem trước'),
          );
          final exportButton = FilledButton.icon(
            onPressed: _provider.previewing || _provider.exporting
                ? null
                : () async {
                    if (_provider.preview == null) {
                      final previewed = await _provider.previewData();
                      if (!previewed) {
                        if (mounted) {
                          _showMessage(
                            _provider.error ?? 'Không thể xem trước dữ liệu',
                          );
                        }
                        return;
                      }
                    }
                    final fileName = await _showFileNameDialog();
                    if (!mounted || fileName == null) return;

                    final result = await _provider.exportData(
                      tenFile: fileName,
                    );
                    if (mounted) {
                      _showMessage(result['message']?.toString() ?? 'Đã xử lý');
                    }
                  },
            icon: _provider.exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_download_rounded),
            label: const Text('Xuất Excel'),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [previewButton, const SizedBox(height: 8), exportButton],
            );
          }
          return Row(
            children: [
              Expanded(child: previewButton),
              const SizedBox(width: 10),
              Expanded(child: exportButton),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard(XuatExcelXemTruoc preview) {
    return _SectionCard(
      title: 'Kết quả xem trước',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.table_rows_rounded,
                  label: 'Số dòng',
                  value: preview.tongDong.toString(),
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.view_column_rounded,
                  label: 'Số cột',
                  value: preview.soCot.toString(),
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Thông tin file',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          ...preview.metadata.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${entry.key}: ${entry.value}'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cột xuất: ${preview.columns.map((e) => e.label).join(', ')}',
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          if (preview.sample.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Tất cả dòng xem trước',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...preview.sample.asMap().entries.map(
              (entry) => _SampleRowCard(
                index: entry.key + 1,
                values: entry.value,
                columns: preview.columns,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownDanhMuc({
    required double width,
    required String label,
    required IconData icon,
    required int value,
    required List<XuatExcelDanhMucItem> items,
    required ValueChanged<int> onChanged,
  }) {
    final safeValue = items.any((item) => item.id == value) ? value : 0;
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<int>(
        value: safeValue,
        isExpanded: true,
        decoration: _decoration(label, icon),
        items: [
          const DropdownMenuItem(value: 0, child: Text('Tất cả')),
          ...items.map(
            (item) => DropdownMenuItem(
              value: item.id,
              child: Text(
                item.tenHienThi,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) => onChanged(value ?? 0),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 21),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.fromLTRB(12, 17, 12, 13),
    );
  }

  int _intFilter(String key) {
    return int.tryParse(_provider.filters[key]?.toString() ?? '') ?? 0;
  }

  String _stringFilter(String key) {
    return _provider.filters[key]?.toString() ?? '';
  }

  List<DropdownMenuItem<String>> _statusItems(String type) {
    final values = <String, String>{'': 'Tất cả trạng thái'};
    switch (type) {
      case 'giang_vien':
        values.addAll({'dang_day': 'Đang dạy', 'ngung_day': 'Ngừng dạy'});
        break;
      case 'sinh_vien':
      case 'sinh_vien_lop_hanh_chinh':
        values.addAll({
          'dang_hoc': 'Đang học',
          'tam_nghi': 'Tạm nghỉ',
          'da_tot_nghiep': 'Đã tốt nghiệp',
        });
        break;
      case 'lop_hanh_chinh':
        values.addAll({
          'dang_hoc': 'Đang học',
          'tam_khoa': 'Tạm khóa',
          'da_tot_nghiep': 'Đã tốt nghiệp',
        });
        break;
      case 'lop_hoc_phan':
        values.addAll({
          'dang_mo': 'Đang mở',
          'da_khoa': 'Đã khóa',
          'da_ket_thuc': 'Đã kết thúc',
        });
        break;
      case 'sinh_vien_lop_hoc_phan':
        values.addAll({
          'dang_hoc': 'Đang học',
          'da_huy': 'Đã hủy',
          'hoan_thanh': 'Hoàn thành',
        });
        break;
    }
    return values.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          ),
        )
        .toList();
  }

  String _hocKyLabel(String value) {
    const labels = {
      'HK1': 'HK1 - Năm 1 học kỳ 1',
      'HK2': 'HK2 - Năm 1 học kỳ 2',
      'HK3': 'HK3 - Năm 2 học kỳ 1',
      'HK4': 'HK4 - Năm 2 học kỳ 2',
      'HK5': 'HK5 - Năm 3 học kỳ 1',
      'HK6': 'HK6 - Năm 3 học kỳ 2',
    };
    return labels[value] ?? value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SampleRowCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> values;
  final List<XuatExcelCot> columns;

  const _SampleRowCard({
    required this.index,
    required this.values,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dòng $index',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          ...columns.map(
            (column) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${column.label}: ${values[column.key] ?? ''}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _InfoMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _XuatExcelScreenState._primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
