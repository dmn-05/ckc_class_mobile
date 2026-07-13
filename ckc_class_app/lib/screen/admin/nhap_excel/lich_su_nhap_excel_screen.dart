import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/nhap_excel_model.dart';
import '../../../provider/lich_su_nhap_excel_provider.dart';
import '../../../services/nhap_excel_service.dart';
import 'chi_tiet_lich_su_nhap_excel_screen.dart';

class LichSuNhapExcelScreen extends StatelessWidget {
  const LichSuNhapExcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LichSuNhapExcelProvider()..taiDanhSach(),
      child: const _LichSuNhapExcelView(),
    );
  }
}

class _LichSuNhapExcelView extends StatefulWidget {
  const _LichSuNhapExcelView();

  @override
  State<_LichSuNhapExcelView> createState() => _LichSuNhapExcelViewState();
}

class _LichSuNhapExcelViewState extends State<_LichSuNhapExcelView> {
  final TextEditingController _timKiemController = TextEditingController();
  String _loaiNhap = '';
  DateTimeRange? _khoangNgay;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _timKiemController.dispose();
    super.dispose();
  }

  String _tenLoai(String ma) {
    for (final item in NhapExcelService.loaiNhapList) {
      if (item.ma == ma) return item.ten;
    }
    return ma;
  }

  String _ngay(DateTime value) => DateFormat('dd/MM/yyyy').format(value);

  String _ngayGio(DateTime? value) {
    if (value == null) return 'Không xác định';
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'da_nhap':
        return Colors.green;
      case 'cho_xac_nhan':
        return Colors.orange;
      case 'that_bai':
        return Colors.red;
      case 'da_huy':
        return Colors.blueGrey;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _apDungBoLoc() async {
    await context.read<LichSuNhapExcelProvider>().apDungBoLoc(
          tuKhoa: _timKiemController.text,
          loaiNhap: _loaiNhap,
          tuNgay: _khoangNgay?.start,
          denNgay: _khoangNgay?.end,
        );
  }

  Future<void> _chonKhoangNgay() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: _khoangNgay,
      helpText: 'Chọn khoảng thời gian nhập Excel',
      cancelText: 'Hủy',
      confirmText: 'Áp dụng',
      saveText: 'Áp dụng',
    );

    if (selected == null || !mounted) return;
    setState(() => _khoangNgay = selected);
    await _apDungBoLoc();
  }

  Future<void> _xoaBoLoc() async {
    _debounce?.cancel();
    _timKiemController.clear();
    setState(() {
      _loaiNhap = '';
      _khoangNgay = null;
    });
    await context.read<LichSuNhapExcelProvider>().xoaBoLoc();
  }

  Widget _buildFilter(LichSuNhapExcelProvider provider) {
    final coBoLoc = _timKiemController.text.trim().isNotEmpty ||
        _loaiNhap.isNotEmpty ||
        _khoangNgay != null;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tìm kiếm và lọc lịch sử',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (coBoLoc)
                  TextButton.icon(
                    onPressed: provider.isLoading ? null : () => _xoaBoLoc(),
                    icon: const Icon(Icons.filter_alt_off, size: 18),
                    label: const Text('Xóa lọc'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timKiemController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Tìm theo tên file',
                hintText: 'Ví dụ: mau_nhap_sinh_vien.xlsx',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _timKiemController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa từ khóa',
                        onPressed: () {
                          _timKiemController.clear();
                          setState(() {});
                          _apDungBoLoc();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    _apDungBoLoc();
                  },
                );
              },
              onSubmitted: (_) {
                _apDungBoLoc();
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _loaiNhap,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Loại dữ liệu đã nhập',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Tất cả loại nhập'),
                ),
                ...NhapExcelService.loaiNhapList.map(
                  (item) => DropdownMenuItem<String>(
                    value: item.ma,
                    child: Text(item.ten),
                  ),
                ),
              ],
              onChanged: provider.isLoading
                  ? null
                  : (value) async {
                      setState(() => _loaiNhap = value ?? '');
                      await _apDungBoLoc();
                    },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: provider.isLoading ? null : () => _chonKhoangNgay(),
                icon: const Icon(Icons.date_range),
                label: Text(
                  _khoangNgay == null
                      ? 'Chọn khoảng thời gian'
                      : '${_ngay(_khoangNgay!.start)} - ${_ngay(_khoangNgay!.end)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    LichSuNhapExcelProvider provider,
    NhapExcelLichSu item,
  ) {
    final statusColor = _statusColor(item.trangThai);

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietLichSuNhapExcelScreen(
                dotNhapId: item.id,
                taiChiTiet: provider.layChiTiet,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.tenFile.isEmpty
                              ? 'Không có tên file'
                              : item.tenFile,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_tenLoai(item.loaiNhap)} • ${_ngayGio(item.ngayTao)}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.trangThaiHienThi,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              if ((item.tenNguoiNhap ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Người nhập: ${item.tenNguoiNhap}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _statItem('Tổng', item.tongDong, Colors.blueGrey),
                  const SizedBox(width: 6),
                  _statItem('Hợp lệ', item.soHopLe, Colors.green),
                  const SizedBox(width: 6),
                  _statItem('Cảnh báo', item.soCanhBao, Colors.orange),
                  const SizedBox(width: 6),
                  _statItem('Lỗi', item.soLoi, Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Xem chi tiết ›',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(LichSuNhapExcelProvider provider) {
    if (provider.total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.coTrangTruoc && !provider.isLoading
                  ? () => provider.trangTruoc()
                  : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Trang trước'),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${provider.page}/${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.coTrangSau && !provider.isLoading
                  ? () => provider.trangSau()
                  : null,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Trang sau'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LichSuNhapExcelProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch sử nhập Excel'),
            actions: [
              IconButton(
                tooltip: 'Tải lại',
                onPressed: provider.isLoading
                    ? null
                    : () => provider.taiDanhSach(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: provider.taiDanhSach,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _buildFilter(provider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                  child: Text(
                    'Tìm thấy ${provider.total} đợt nhập Excel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => provider.taiDanhSach(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.danhSach.isEmpty)
                  const Card(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            size: 48,
                            color: Colors.black38,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Không tìm thấy lịch sử nhập Excel phù hợp.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...provider.danhSach.map(
                    (item) => _buildHistoryCard(context, provider, item),
                  ),
                _buildPagination(provider),
              ],
            ),
          ),
        );
      },
    );
  }
}
