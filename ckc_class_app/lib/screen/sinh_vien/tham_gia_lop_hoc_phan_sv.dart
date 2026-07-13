import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sinh_vien_provider.dart';

class ThamGiaLopHocPhanSV extends StatefulWidget {
  const ThamGiaLopHocPhanSV({super.key});

  @override
  State<ThamGiaLopHocPhanSV> createState() => _ThamGiaLopHocPhanSVState();
}

class _ThamGiaLopHocPhanSVState extends State<ThamGiaLopHocPhanSV> {
  final _formKey = GlobalKey<FormState>();
  final _maCtrl = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _maCtrl.dispose();
    super.dispose();
  }

  Future<void> _thamGia() async {
    if (_processing) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<SinhVienProvider>();

    if (provider.sinhVienId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa khởi tạo ID sinh viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _processing = true;
    });

    final maLop = _maCtrl.text.trim();

    final result = await provider.thamGiaLopHocPhan(maLop);

    if (!mounted) return;

    final success = result['success'] == true;
    final message = result['message']?.toString() ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_processing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tham gia lớp học phần'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Nhập mã lớp học phần do giảng viên cung cấp. Ví dụ: LHP3, FLUTTER02.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maCtrl,
                  enabled: !_processing,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã lớp học phần',
                    prefixIcon: Icon(Icons.key),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập mã lớp học phần';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _processing ? null : _thamGia,
                  icon: _processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _processing ? 'Đang tham gia...' : 'Tham gia lớp',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
