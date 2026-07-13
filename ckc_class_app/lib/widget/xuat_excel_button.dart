import 'package:flutter/material.dart';

import '../screen/admin/xuat_excel/xuat_excel_screen.dart';

class XuatExcelButton extends StatelessWidget {
  final String loaiXuat;
  final Map<String, dynamic> boLoc;
  final List<int> selectedIds;
  final bool iconOnly;

  const XuatExcelButton({
    super.key,
    required this.loaiXuat,
    this.boLoc = const {},
    this.selectedIds = const [],
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    void open() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => XuatExcelScreen(
            showAppBar: true,
            loaiMacDinh: loaiXuat,
            boLocMacDinh: boLoc,
            selectedIds: selectedIds,
          ),
        ),
      );
    }

    if (iconOnly) {
      return IconButton(
        tooltip: 'Xuất Excel',
        onPressed: open,
        icon: const Icon(Icons.file_download_rounded),
      );
    }

    return OutlinedButton.icon(
      onPressed: open,
      icon: const Icon(Icons.file_download_rounded),
      label: const Text('Xuất Excel'),
    );
  }
}
