import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/giang_vien_provider.dart';
import '../../services/ket_noi_api_service.dart';

class TaoLopHocPhanGV extends StatefulWidget {
  const TaoLopHocPhanGV({super.key});

  @override
  State<TaoLopHocPhanGV> createState() => _TaoLopHocPhanGVState();
}

class _TaoLopHocPhanGVState extends State<TaoLopHocPhanGV> {
  final _formKey = GlobalKey<FormState>();
  final _maCtrl = TextEditingController();
  final _tenCtrl = TextEditingController();
  final _namHocCtrl = TextEditingController();
  final _siSoCtrl = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _loadingMonHoc = false;
  bool _processing = false;
  String? _error;
  List<Map<String, dynamic>> _dsMonHoc = [];
  int _monHocId = 0;
  String _hocKy = 'HK1';

  @override
  void initState() {
    super.initState();
    _layDanhSachMonHoc();
  }

  @override
  void dispose() {
    _maCtrl.dispose();
    _tenCtrl.dispose();
    _namHocCtrl.dispose();
    _siSoCtrl.dispose();
    super.dispose();
  }

  Future<void> _layDanhSachMonHoc() async {
    setState(() {
      _loadingMonHoc = true;
      _error = null;
    });

    try {
      final response = await _apiService.post('/mon_hoc/danh_sach_mon_hoc.php', data: {});
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};

      if (body['status']?.toString() != 'success') {
        throw Exception(body['message']?.toString() ?? 'Không thể lấy danh sách môn học');
      }

      final raw = body['data'];
      final ds = raw is List
          ? raw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : <Map<String, dynamic>>[];

      setState(() {
        _dsMonHoc = ds;
        if (_dsMonHoc.isNotEmpty) {
          _monHocId = int.tryParse(_dsMonHoc.first['id'].toString()) ?? 0;
        }
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingMonHoc = false);
    }
  }

  Future<void> _taoLop() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GiangVienProvider>();
    if (provider.giangVienId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa khởi tạo ID giảng viên'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _processing = true);

    final result = await provider.taoLopHocPhan(
      maLopHocPhan: _maCtrl.text,
      tenLop: _tenCtrl.text,
      monHocId: _monHocId,
      hocKy: _hocKy,
      namHoc: _namHocCtrl.text,
      siSoToiDa: _siSoCtrl.text.trim().isEmpty ? null : int.tryParse(_siSoCtrl.text.trim()),
    );

    if (!mounted) return;
    setState(() => _processing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? ''),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo lớp học phần'), centerTitle: true),
      body: _loadingMonHoc
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _maCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Mã lớp học phần',
                        hintText: 'VD: LHP4 hoặc FLUTTER02',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập mã lớp học phần' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên lớp',
                        hintText: 'VD: Flutter K2',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên lớp' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _monHocId > 0 ? _monHocId : null,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Môn học', border: OutlineInputBorder()),
                      items: _dsMonHoc.map((mh) {
                        final id = int.tryParse(mh['id'].toString()) ?? 0;
                        final ten = mh['ten_mon']?.toString() ?? '';
                        final ma = mh['ma_mon']?.toString() ?? '';
                        return DropdownMenuItem(value: id, child: Text('$ten${ma.isNotEmpty ? ' ($ma)' : ''}'));
                      }).toList(),
                      onChanged: (v) => setState(() => _monHocId = v ?? 0),
                      validator: (v) => v == null || v <= 0 ? 'Chọn môn học' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _hocKy,
                      decoration: const InputDecoration(labelText: 'Học kỳ', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'HK1', child: Text('HK1')),
                        DropdownMenuItem(value: 'HK2', child: Text('HK2')),
                        DropdownMenuItem(value: 'HK3', child: Text('HK3')),
                      ],
                      onChanged: (v) => setState(() => _hocKy = v ?? 'HK1'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _namHocCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Năm học',
                        hintText: 'VD: 2026-2027',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _siSoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sĩ số tối đa',
                        hintText: 'Có thể bỏ trống',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return null;
                        final n = int.tryParse(s);
                        if (n == null || n <= 0) return 'Sĩ số phải là số lớn hơn 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _processing ? null : _taoLop,
                      icon: _processing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add),
                      label: Text(_processing ? 'Đang tạo...' : 'Tạo lớp học phần'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
