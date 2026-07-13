import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../model/giang_vien_model.dart';
import '../../provider/giang_vien_provider.dart';
import '../../services/ket_noi_api_service.dart';
import '../../widget/widget_chung_giangvien.dart';

class QuanLyTaiLieu extends StatefulWidget {
  final LopHocPhan lop;

  const QuanLyTaiLieu({super.key, required this.lop});

  @override
  State<QuanLyTaiLieu> createState() => _QuanLyTaiLieuState();
}

class _QuanLyTaiLieuState extends State<QuanLyTaiLieu> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GiangVienProvider>().layDanhSachTaiLieu(widget.lop.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GiangVienProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildHeader(provider),
            Expanded(child: _buildDanhSach(provider)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(GiangVienProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${provider.dsTaiLieu.length} tài liệu',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: provider.tlProcessing
                ? null
                : () => _hienThiForm(provider),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm tài liệu'),
          ),
        ],
      ),
    );
  }

  Widget _buildDanhSach(GiangVienProvider provider) {
    if (provider.tlLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.tlError != null) {
      return TrangThaiLoi(
        loi: provider.tlError!,
        onTaiLai: () => provider.layDanhSachTaiLieu(widget.lop.id),
      );
    }

    if (provider.dsTaiLieu.isEmpty) {
      return TrangThaiRong(
        thongDiep: 'Chưa có tài liệu nào',
        icon: Icons.folder_open,
        nhanNut: 'Thêm tài liệu',
        onNutNhan: () => _hienThiForm(provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.layDanhSachTaiLieu(widget.lop.id),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: provider.dsTaiLieu.length,
        itemBuilder: (context, i) {
          return _buildTheTaiLieu(provider.dsTaiLieu[i], provider);
        },
      ),
    );
  }

  Widget _buildTheTaiLieu(TaiLieu tl, GiangVienProvider provider) {
    final mauFile = _mauLoaiFile(tl.loaiFile);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mauFile.withValues(alpha: 0.15),
          child: Text(
            tl.loaiFile,
            style: TextStyle(
              color: mauFile,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          tl.tieuDe,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tl.moTa != null && tl.moTa!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                tl.moTa!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _TrangThaiBadge(
                  text: tl.isHienThi ? 'Hiển thị' : 'Ẩn',
                  color: tl.isHienThi ? Colors.green : Colors.grey,
                  icon: tl.isHienThi ? Icons.visibility : Icons.visibility_off,
                ),
                const SizedBox(width: 8),
                Text(
                  dinhDangNgay(tl.ngayTao),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: const Icon(Icons.edit, size: 20),
              onPressed: provider.tlProcessing
                  ? null
                  : () => _hienThiForm(provider, taiLieu: tl),
            ),
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              onPressed: provider.tlProcessing
                  ? null
                  : () => _xacNhanXoa(tl, provider),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _hienThiForm(
    GiangVienProvider provider, {
    TaiLieu? taiLieu,
  }) async {
    // Dialog chỉ trả dữ liệu. Provider xử lý sau khi dialog đã đóng.
    final data = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TaiLieuFormDialog(taiLieu: taiLieu),
    );

    if (data == null || !mounted) return;

    final result = taiLieu == null
        ? await provider.themTaiLieu(
            tieuDe: data['tieu_de'] ?? '',
            lopHocPhanId: widget.lop.id,
            moTa: data['mo_ta'] ?? '',
            duongDanFile: data['duong_dan_file'] ?? '',
            trangThai: data['trang_thai'] ?? 'hien_thi',
          )
        : await provider.suaTaiLieu(
            id: taiLieu.id,
            tieuDe: data['tieu_de'] ?? '',
            lopHocPhanId: widget.lop.id,
            moTa: data['mo_ta'] ?? '',
            duongDanFile: data['duong_dan_file'] ?? '',
            trangThai: data['trang_thai'] ?? 'hien_thi',
          );

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message']?.toString() ?? '',
      laThanh: result['success'] == true,
    );
  }

  Future<void> _xacNhanXoa(TaiLieu tl, GiangVienProvider provider) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tài liệu'),
        content: Text('Bạn có chắc muốn xóa tài liệu "${tl.tieuDe}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (dongY != true || !mounted) return;

    final result = await provider.xoaTaiLieu(tl.id, widget.lop.id);

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message']?.toString() ?? '',
      laThanh: result['success'] == true,
    );
  }

  Color _mauLoaiFile(String loai) {
    return switch (loai) {
      'PDF' => Colors.red,
      'PPT' => Colors.orange,
      'Word' => Colors.blue,
      'Excel' => Colors.green,
      'Archive' => Colors.brown,
      _ => Colors.grey,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// Dialog form riêng để TextEditingController được quản lý an toàn.
// ═══════════════════════════════════════════════════════════════

class _TaiLieuFormDialog extends StatefulWidget {
  final TaiLieu? taiLieu;

  const _TaiLieuFormDialog({this.taiLieu});

  @override
  State<_TaiLieuFormDialog> createState() => _TaiLieuFormDialogState();
}

class _TaiLieuFormDialogState extends State<_TaiLieuFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tieuDeCtrl;
  late final TextEditingController _moTaCtrl;
  late final TextEditingController _fileCtrl;

  String _trangThai = 'hien_thi';
  PlatformFile? _fileDaChon;
  bool _dangLuu = false;

  String get _uploadTaiLieuUrl =>
      '${ApiService().baseUrl}/giang_vien/upload_tai_lieu_file.php';

  @override
  void initState() {
    super.initState();

    _tieuDeCtrl = TextEditingController(text: widget.taiLieu?.tieuDe ?? '');
    _moTaCtrl = TextEditingController(text: widget.taiLieu?.moTa ?? '');
    _fileCtrl = TextEditingController(text: widget.taiLieu?.duongDanFile ?? '');
    _trangThai = widget.taiLieu?.trangThai ?? 'hien_thi';
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _moTaCtrl.dispose();
    _fileCtrl.dispose();
    super.dispose();
  }

  Future<void> _luu() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _dangLuu = true);
    String duongDanFile = _fileCtrl.text.trim();

    if (_fileDaChon != null) {
      final upload = await _uploadFileTaiLieu(_fileDaChon!);
      if (!mounted) return;
      if (upload['success'] != true) {
        setState(() => _dangLuu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(upload['message']?.toString() ?? 'Upload tài liệu thất bại')),
        );
        return;
      }
      duongDanFile = upload['duong_dan_file']?.toString() ?? '';
    }

    if (!mounted) return;
    Navigator.pop(context, {
      'tieu_de': _tieuDeCtrl.text.trim(),
      'mo_ta': _moTaCtrl.text.trim(),
      'duong_dan_file': duongDanFile,
      'trang_thai': _trangThai,
    });
  }

  Future<Map<String, dynamic>> _uploadFileTaiLieu(PlatformFile file) async {
    final path = file.path;
    if (path == null || path.isEmpty) {
      return {'success': false, 'message': 'Không lấy được đường dẫn file đã chọn'};
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: file.name),
      });

      final res = await Dio().post(
        _uploadTaiLieuUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final data = res.data;
      if (data is Map) {
        final ok = data['status']?.toString().toLowerCase() == 'success' || data['success'] == true;
        if (!ok) {
          return {'success': false, 'message': data['message']?.toString() ?? 'Upload tài liệu thất bại'};
        }
        final raw = data['duong_dan_file'] ?? data['file_url'] ??
            (data['data'] is Map ? (data['data']['duong_dan_file'] ?? data['data']['secure_url']) : null);
        return {
          'success': true,
          'message': data['message']?.toString() ?? 'Upload tài liệu thành công',
          'duong_dan_file': raw?.toString() ?? '',
        };
      }
      return {'success': false, 'message': 'Phản hồi upload không hợp lệ'};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi upload tài liệu: $e'};
    }
  }

  Future<void> _chonFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: const [
        'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip', 'rar',
        'png', 'jpg', 'jpeg', 'txt', 'sql',
      ],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _fileDaChon = result.files.single;
      _fileCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final laSua = widget.taiLieu != null;

    return AlertDialog(
      title: Text(laSua ? 'Cập nhật tài liệu' : 'Thêm tài liệu'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tieuDeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề *',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tiêu đề không được trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _moTaCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _fileCtrl,
                  enabled: !_dangLuu && _fileDaChon == null,
                  decoration: const InputDecoration(
                    labelText: 'URL file Cloudinary',
                    hintText: 'https://res.cloudinary.com/...',
                    prefixIcon: Icon(Icons.link_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _fileDaChon != null
                              ? 'Đã chọn: ${_fileDaChon!.name}'
                              : (_fileCtrl.text.trim().isNotEmpty
                                  ? 'File hiện tại: ${_fileCtrl.text.trim().split('/').last}'
                                  : 'Chọn file để upload lên Cloudinary'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _dangLuu ? null : _chonFile,
                        child: const Text('Chọn file'),
                      ),
                      if (_fileDaChon != null || _fileCtrl.text.trim().isNotEmpty)
                        IconButton(
                          tooltip: 'Xóa file',
                          onPressed: _dangLuu
                              ? null
                              : () => setState(() {
                                    _fileDaChon = null;
                                    _fileCtrl.clear();
                                  }),
                          icon: const Icon(Icons.close_rounded),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _trangThai,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    prefixIcon: Icon(Icons.toggle_on),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'hien_thi',
                      child: Text('Hiển thị'),
                    ),
                    DropdownMenuItem(value: 'an', child: Text('Ẩn')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _trangThai = v ?? 'hien_thi';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _dangLuu ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          onPressed: _dangLuu ? null : _luu,
          icon: _dangLuu
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(laSua ? Icons.save : Icons.add),
          label: Text(_dangLuu ? 'Đang lưu...' : (laSua ? 'Lưu' : 'Thêm')),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Badge trạng thái riêng, tránh lệ thuộc ChipTrangThai khác tham số.
// ═══════════════════════════════════════════════════════════════

class _TrangThaiBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _TrangThaiBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
