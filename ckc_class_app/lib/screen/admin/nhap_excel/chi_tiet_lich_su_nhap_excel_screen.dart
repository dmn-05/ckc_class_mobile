import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/nhap_excel_model.dart';
import '../../../services/nhap_excel_service.dart';

class ChiTietLichSuNhapExcelScreen extends StatefulWidget {
  final int dotNhapId;
  final Future<NhapExcelChiTietLichSu> Function(int dotNhapId) taiChiTiet;

  const ChiTietLichSuNhapExcelScreen({
    super.key,
    required this.dotNhapId,
    required this.taiChiTiet,
  });

  @override
  State<ChiTietLichSuNhapExcelScreen> createState() =>
      _ChiTietLichSuNhapExcelScreenState();
}

class _ChiTietLichSuNhapExcelScreenState
    extends State<ChiTietLichSuNhapExcelScreen> {
  late Future<NhapExcelChiTietLichSu> _future;
  bool _chiHienThiVanDe = true;

  @override
  void initState() {
    super.initState();
    _future = widget.taiChiTiet(widget.dotNhapId);
  }

  String _tenLoai(String ma) {
    for (final item in NhapExcelService.loaiNhapList) {
      if (item.ma == ma) return item.ten;
    }
    return ma;
  }

  String _ngayGio(DateTime? value) {
    if (value == null) return 'Không xác định';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  Color _mauTrangThai(String status) {
    switch (status) {
      case 'hop_le':
        return Colors.green;
      case 'canh_bao':
        return Colors.orange;
      case 'loi':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _duLieuChinh(Map<String, dynamic> data) {
    const keys = <String, String>{
      'ma_lop_hoc_phan': 'Mã lớp học phần',
      'ma_lop': 'Mã lớp',
      'ma_sinh_vien': 'Mã sinh viên',
      'ma_giang_vien': 'Mã giảng viên',
      'ma_mon': 'Mã môn học',
      'ma_bo_mon': 'Mã bộ môn',
      'ma_khoa': 'Mã khoa',
      'email': 'Email',
      'ho_ten': 'Họ tên',
      'ten_lop': 'Tên lớp',
      'ten_mon': 'Tên môn học',
    };

    for (final entry in keys.entries) {
      final value = data[entry.key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return '${entry.value}: $value';
      }
    }

    for (final entry in data.entries) {
      if (entry.key.startsWith('_')) continue;
      final value = entry.value?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return '${entry.key}: $value';
      }
    }

    return 'Không có dữ liệu nhận diện';
  }

  Widget _summaryItem(
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhập Excel'),
      ),
      body: FutureBuilder<NhapExcelChiTietLichSu>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _future = widget.taiChiTiet(widget.dotNhapId);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final dot = data.dotNhap;
          final rows = _chiHienThiVanDe
              ? data.dong.where((e) => e.trangThai != 'hop_le').toList()
              : data.dong;

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dot.tenFile.isEmpty ? 'Không có tên file' : dot.tenFile,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Loại nhập: ${_tenLoai(dot.loaiNhap)}'),
                      Text('Thời gian: ${_ngayGio(dot.ngayTao)}'),
                      if ((dot.tenNguoiNhap ?? '').trim().isNotEmpty)
                        Text('Người nhập: ${dot.tenNguoiNhap}'),
                      Text('Trạng thái: ${dot.trangThaiHienThi}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryItem(
                            'Tổng',
                            dot.tongDong,
                            Colors.blueGrey,
                            Icons.table_rows,
                          ),
                          const SizedBox(width: 8),
                          _summaryItem(
                            'Hợp lệ',
                            dot.soHopLe,
                            Colors.green,
                            Icons.check_circle,
                          ),
                          const SizedBox(width: 8),
                          _summaryItem(
                            'Cảnh báo',
                            dot.soCanhBao,
                            Colors.orange,
                            Icons.warning_amber,
                          ),
                          const SizedBox(width: 8),
                          _summaryItem(
                            'Lỗi',
                            dot.soLoi,
                            Colors.red,
                            Icons.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile(
                  value: _chiHienThiVanDe,
                  onChanged: (value) {
                    setState(() => _chiHienThiVanDe = value);
                  },
                  title: const Text('Chỉ hiển thị cảnh báo và lỗi'),
                  subtitle: Text(
                    _chiHienThiVanDe
                        ? 'Ẩn các dòng hợp lệ để dễ kiểm tra trên điện thoại.'
                        : 'Đang hiển thị toàn bộ các dòng đã kiểm tra.',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (rows.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _chiHienThiVanDe
                              ? 'Đợt nhập này không có cảnh báo hoặc lỗi.'
                              : 'Không có dữ liệu chi tiết.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...rows.take(300).map((row) {
                  final color = _mauTrangThai(row.trangThai);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: color.withOpacity(0.12),
                                child: Text(
                                  row.soDong.toString(),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _duLieuChinh(row.duLieu),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  row.trangThaiHienThi,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (row.thongBao.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(row.thongBao),
                          ],
                          if (row.hanhDong.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Xử lý: ${row.hanhDongHienThi}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              if (rows.length > 300)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Chỉ hiển thị 300 dòng đầu để đảm bảo hiệu năng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
