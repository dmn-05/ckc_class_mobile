import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/nhap_excel_model.dart';
import '../../../provider/nhap_excel_provider.dart';
import '../../../services/nhap_excel_service.dart';
import 'lich_su_nhap_excel_screen.dart';

class NhapExcelScreen extends StatelessWidget {
  final String? loaiNhapMacDinh;
  final Map<String, dynamic> doiTuongDichMacDinh;

  const NhapExcelScreen({super.key, this.loaiNhapMacDinh, this.doiTuongDichMacDinh = const {}});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NhapExcelProvider(),
      child: _NhapExcelView(loaiNhapMacDinh: loaiNhapMacDinh, doiTuongDichMacDinh: doiTuongDichMacDinh),
    );
  }
}

class _NhapExcelView extends StatefulWidget {
  final String? loaiNhapMacDinh;
  final Map<String, dynamic> doiTuongDichMacDinh;
  const _NhapExcelView({this.loaiNhapMacDinh, required this.doiTuongDichMacDinh});

  @override
  State<_NhapExcelView> createState() => _NhapExcelViewState();
}

class _NhapExcelViewState extends State<_NhapExcelView> {
  final TextEditingController _doiTuongDichController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NhapExcelProvider>();
      if (widget.loaiNhapMacDinh != null && widget.loaiNhapMacDinh!.isNotEmpty) {
        provider.chonLoai(widget.loaiNhapMacDinh!);
      }
      final key = provider.loaiDangChon.keyDoiTuongDich;
      if (key != null && widget.doiTuongDichMacDinh[key] != null) {
        _doiTuongDichController.text = widget.doiTuongDichMacDinh[key].toString();
      }
    });
  }

  @override
  void dispose() {
    _doiTuongDichController.dispose();
    super.dispose();
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'hop_le': return Colors.green;
      case 'canh_bao': return Colors.orange;
      case 'loi': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  String _nhanDienDong(
    NhapExcelDongKetQua row,
    NhapExcelLoai loai,
  ) {
    const uuTien = <String, String>{
      'ma_lop_hoc_phan': 'Mã lớp học phần',
      'ma_lop': 'Mã lớp',
      'ma_sinh_vien': 'Mã sinh viên',
      'ma_giang_vien': 'Mã giảng viên',
      'ma_mon': 'Mã môn học',
      'ma_bo_mon': 'Mã bộ môn',
      'ma_khoa': 'Mã khoa',
      'email': 'Email',
      'ten_lop': 'Tên lớp học phần',
      'ten_mon': 'Tên môn học',
      'ten_bo_mon': 'Tên bộ môn',
      'ten_khoa': 'Tên khoa',
      'ho_ten': 'Họ tên',
    };

    for (final entry in uuTien.entries) {
      final value = row.duLieu[entry.key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return '${entry.value}: $value';
      }
    }

    for (final header in loai.headers) {
      final key = loai.headerMap[header];
      if (key == null) continue;
      final value = row.duLieu[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return '$header: $value';
      }
    }

    return 'Không xác định được dữ liệu chính của dòng';
  }

  String _lyDoDong(NhapExcelDongKetQua row) {
    final message = row.thongBao.trim();
    if (message.isNotEmpty) return message;

    if (row.trangThai == 'canh_bao') {
      return 'Dữ liệu có cảnh báo và sẽ được xử lý theo hành động “${row.hanhDongHienThi}”.';
    }

    return 'Dữ liệu không hợp lệ. Hãy kiểm tra lại dòng này trong file Excel.';
  }

  Map<String, dynamic> _layDoiTuongDich(NhapExcelLoai loai) {
    final key = loai.keyDoiTuongDich;
    if (key == null) return {};
    return {key: _doiTuongDichController.text.trim()};
  }

  Widget _buildLoaiNhap(NhapExcelProvider provider) {
    final loai = provider.loaiDangChon;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Chọn loại dữ liệu cần nhập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: loai.ma,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Loại nhập Excel', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
              items: NhapExcelService.loaiNhapList.map((e) => DropdownMenuItem<String>(value: e.ma, child: Text(e.ten))).toList(),
              onChanged: (value) {
                if (value == null) return;
                provider.chonLoai(value);
                _doiTuongDichController.clear();
              },
            ),
            if (loai.canDoiTuongDich) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _doiTuongDichController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: loai.labelDoiTuongDich ?? 'Đối tượng đích', hintText: 'Ví dụ: CDTH26A', prefixIcon: const Icon(Icons.flag), border: const OutlineInputBorder()),
              ),
            ],
            const SizedBox(height: 10),
            Text(loai.moTa, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: loai.headers.map((h) => Chip(label: Text(h), visualDensity: VisualDensity.compact)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(NhapExcelProvider provider) {
    ButtonStyle compactButtonStyle(Color? foregroundColor) {
      return ButtonStyle(
        foregroundColor: foregroundColor == null
            ? null
            : MaterialStatePropertyAll(foregroundColor),
        minimumSize: const MaterialStatePropertyAll(Size(0, 44)),
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        ),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const MaterialStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    Widget loadingIcon() {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '2. Tải mẫu, chọn file và kiểm tra',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: compactButtonStyle(null),
                    onPressed: () async {
                      try {
                        await provider.taiFileMau();
                      } catch (e) {
                        _showSnack(e.toString(), Colors.red);
                      }
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Tải mẫu'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: compactButtonStyle(null),
                    onPressed: provider.isReading
                        ? null
                        : () async {
                            final res = await provider.chonFileVaDoc();
                            _showSnack(
                              res['message']?.toString() ?? '',
                              res['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                            );
                          },
                    icon: provider.isReading
                        ? loadingIcon()
                        : const Icon(Icons.upload_file, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Chọn file'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: compactButtonStyle(null),
                    onPressed: provider.isChecking
                        ? null
                        : () async {
                            final res = await provider.kiemTra(
                              doiTuongDich: _layDoiTuongDich(
                                provider.loaiDangChon,
                              ),
                            );
                            _showSnack(
                              res['message']?.toString() ?? '',
                              res['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                            );
                          },
                    icon: provider.isChecking
                        ? loadingIcon()
                        : const Icon(Icons.fact_check, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Kiểm tra'),
                    ),
                  ),
                ),
              ],
            ),
            if (provider.tenFile.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'File đã chọn: ${provider.tenFile}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Hệ thống chỉ kiểm tra trước, chưa ghi vào CSDL. Chỉ khi bấm “Xác nhận nhập thật” thì dữ liệu mới được thêm.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(NhapExcelKetQuaKiemTra result) {
    Widget item(
      String label,
      int value,
      Color color,
      IconData icon,
      double width,
    ) {
      return SizedBox(
        width: width,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.28)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 720
              ? (constraints.maxWidth - 24) / 4
              : (constraints.maxWidth - 8) / 2;

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              item(
                'Tổng dòng',
                result.tongDong,
                Colors.blueGrey,
                Icons.table_rows,
                itemWidth,
              ),
              item(
                'Hợp lệ',
                result.soHopLe,
                Colors.green,
                Icons.check_circle,
                itemWidth,
              ),
              item(
                'Cảnh báo',
                result.soCanhBao,
                Colors.orange,
                Icons.warning_amber_rounded,
                itemWidth,
              ),
              item(
                'Lỗi',
                result.soLoi,
                Colors.red,
                Icons.error,
                itemWidth,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewTable(NhapExcelProvider provider) {
    final result = provider.ketQuaKiemTra;
    if (result == null) return const SizedBox.shrink();

    final loai = provider.loaiDangChon;
    final rowsCoVanDe = result.ketQuaDong
        .where((row) => row.trangThai != 'hop_le')
        .toList();

    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              '3. Kết quả kiểm tra',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Text(
              'Chỉ hiển thị các dòng cảnh báo hoặc lỗi để dễ xem trên điện thoại.',
              style: TextStyle(color: Colors.black54),
            ),
          ),

          if (result.soHopLe > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${result.soHopLe} dòng hợp lệ. Các dòng này sẽ được thêm khi bạn xác nhận nhập thật.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          if (rowsCoVanDe.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không có cảnh báo hoặc lỗi. Dữ liệu đã sẵn sàng để xác nhận nhập.',
                    ),
                  ),
                ],
              ),
            )
          else ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: rowsCoVanDe.length > 200 ? 200 : rowsCoVanDe.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = rowsCoVanDe[index];
                final color = _statusColor(row.trangThai);
                final isWarning = row.trangThai == 'canh_bao';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
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
                              'Dòng ${row.soDong}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              row.trangThaiHienThi,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _nhanDienDong(row, loai),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isWarning
                                ? Icons.warning_amber_rounded
                                : Icons.error_outline,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lyDoDong(row),
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                      if (row.hanhDong.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Xử lý khi xác nhận: ${row.hanhDongHienThi}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            if (rowsCoVanDe.length > 200)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  'Đang hiển thị 200/${rowsCoVanDe.length} dòng có vấn đề. Hãy sửa file Excel và kiểm tra lại.',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirm(NhapExcelProvider provider) {
    final result = provider.ketQuaKiemTra;
    if (result == null) return const SizedBox.shrink();

    final message = result.coTheXacNhan
        ? result.soCanhBao > 0
            ? '${result.soHopLe} dòng hợp lệ sẽ được thêm; ${result.soCanhBao} dòng cảnh báo sẽ được xử lý theo nội dung bên trên.'
            : '${result.soHopLe} dòng hợp lệ đã sẵn sàng để nhập vào CSDL.'
        : 'Còn ${result.soLoi} dòng lỗi. Hãy sửa đúng các dòng được liệt kê rồi chọn file và kiểm tra lại.';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final button = ElevatedButton.icon(
              onPressed: !result.coTheXacNhan || provider.isConfirming
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xác nhận nhập thật?'),
                          content: Text(
                            '${result.soHopLe} dòng hợp lệ sẽ được ghi vào CSDL. '
                            '${result.soCanhBao > 0 ? '${result.soCanhBao} dòng cảnh báo sẽ được xử lý theo kết quả kiểm tra.' : ''}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );

                      if (ok != true) return;

                      final res = await provider.xacNhanNhap();
                      _showSnack(
                        res['message']?.toString() ?? '',
                        res['success'] == true ? Colors.green : Colors.red,
                      );
                    },
              icon: provider.isConfirming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                provider.isConfirming
                    ? 'Đang nhập...'
                    : 'Xác nhận nhập thật',
              ),
            );

            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(message),
                  const SizedBox(height: 12),
                  button,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: Text(message)),
                const SizedBox(width: 12),
                button,
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NhapExcelProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nhập dữ liệu Excel'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LichSuNhapExcelScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text('Lịch sử'),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildLoaiNhap(provider),
                _buildActions(provider),
                if (provider.error != null)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(provider.error!, style: const TextStyle(color: Colors.red))),
                if (provider.ketQuaKiemTra != null) ...[
                  _buildSummary(provider.ketQuaKiemTra!),
                  _buildPreviewTable(provider),
                  _buildConfirm(provider),
                ],
                if (provider.ketQuaXacNhan != null)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text('Đã nhập dữ liệu Excel thành công'),
                      subtitle: Text('Thêm mới: ${provider.ketQuaXacNhan!.daThemMoi} | Bỏ qua: ${provider.ketQuaXacNhan!.boQua}'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
