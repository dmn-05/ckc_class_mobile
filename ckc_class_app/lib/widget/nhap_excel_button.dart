import 'package:flutter/material.dart';

import '../screen/admin/nhap_excel/nhap_excel_screen.dart';

class NhapExcelButton extends StatelessWidget {
  final String? loaiNhap;
  final Map<String, dynamic> doiTuongDich;
  final String label;

  const NhapExcelButton({super.key, this.loaiNhap, this.doiTuongDich = const {}, this.label = 'Nhập Excel'});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => NhapExcelScreen(loaiNhapMacDinh: loaiNhap, doiTuongDichMacDinh: doiTuongDich)));
      },
      icon: const Icon(Icons.upload_file),
      label: Text(label),
    );
  }
}
