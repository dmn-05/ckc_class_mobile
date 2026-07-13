import 'package:flutter/material.dart';

import '../screen/admin/nhap_excel/nhap_excel_screen.dart';

class AdminNhapExcelDrawerTile extends StatelessWidget {
  const AdminNhapExcelDrawerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.upload_file),
      title: const Text('Nhập Excel'),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NhapExcelScreen()));
      },
    );
  }
}
