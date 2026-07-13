import 'dart:convert';
import 'package:ckc_class_app/screen/giang_vien/ket_qua_quiz_giang_vien.dart';
import 'package:ckc_class_app/screen/giang_vien/chi_tiet_bai_tap_giang_vien.dart';
import 'package:ckc_class_app/screen/giang_vien/tao_quiz_giang_vien.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../model/giang_vien_model.dart';
import '../../provider/giang_vien_provider.dart';
import '../../provider/quiz_provider.dart';
import '../../services/ket_noi_api_service.dart';
import '../../widget/widget_chung_giangvien.dart';


String _gvFileBackendOrigin() => ApiService().origin;

String _gvFileBackendBaseUrl() => ApiService().baseUrl;

String _gvNormalizeFileUrl(String rawPath) {
  final raw = rawPath.trim().replaceAll('\\', '/');
  if (raw.isEmpty) return '';
  final lower = raw.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return raw;
  if (raw.startsWith('//')) return 'https:$raw';
  if (raw.startsWith('/backend/')) return '${_gvFileBackendOrigin()}$raw';
  if (raw.startsWith('/')) return '${_gvFileBackendBaseUrl()}$raw';
  return '${_gvFileBackendBaseUrl()}/$raw';
}

String _gvFmtDiem(double value) {
  if (value == value.truncateToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

String _gvB64Url(String value) {
  return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}

String _gvDownloadProxyUrl({
  required String url,
  required String fileName,
}) {
  return '${_gvFileBackendBaseUrl()}/upload/tai_file.php?u=${_gvB64Url(url)}&f=${_gvB64Url(fileName)}';
}

Future<void> _gvMoFileBaiNop(BuildContext context, BaiNopFile file) async {
  final url = _gvNormalizeFileUrl(file.duongDanFile);
  if (url.isEmpty) {
    hienThiSnackBar(context, 'Không có đường dẫn file', laThanh: false);
    return;
  }

  final tenGoc = file.tenFileGoc?.trim();
  final urlMo = (tenGoc != null && tenGoc.isNotEmpty)
      ? _gvDownloadProxyUrl(url: url, fileName: tenGoc)
      : url;

  final uri = Uri.tryParse(urlMo);
  if (uri == null || !uri.hasScheme) {
    hienThiSnackBar(context, 'Đường dẫn file không hợp lệ', laThanh: false);
    return;
  }

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      hienThiSnackBar(context, 'Không mở được file', laThanh: false);
    }
  } catch (e) {
    if (context.mounted) {
      hienThiSnackBar(context, 'Lỗi mở file: $e', laThanh: false);
    }
  }
}

class QuanLyBaiTap extends StatefulWidget {
  final LopHocPhan lop;
  const QuanLyBaiTap({super.key, required this.lop});

  @override
  State<QuanLyBaiTap> createState() => _QuanLyBaiTapState();
}

class _QuanLyBaiTapState extends State<QuanLyBaiTap> {
  static const int _chuDeChuaPhanLoaiId = -1;
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  static String _fmtSo(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String get _uploadBaiTapUrl =>
      '${ApiService().baseUrl}/giang_vien/upload_bai_tap_file.php';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<GiangVienProvider>();
      p.layDanhSachChuDe(widget.lop.id);
      p.layDanhSachBaiTap(widget.lop.id);
    });
  }

  Future<DateTime?> _chonNgayGioGui({
    required BuildContext context,
    required DateTime? giaTriHienTai,
    Duration macDinhSau = const Duration(minutes: 15),
  }) async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 1));
    final lastDate = now.add(const Duration(days: 365 * 5));
    final initialRaw = giaTriHienTai ?? now.add(macDinhSau);
    final initial = initialRaw.isBefore(firstDate) ? now : initialRaw;

    final ngay = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (ngay == null) return null;

    final gio = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (gio == null) return null;

    return DateTime(ngay.year, ngay.month, ngay.day, gio.hour, gio.minute);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Consumer<GiangVienProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildHeader(provider),
              Expanded(child: _buildDanhSach(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(GiangVienProvider provider) {
    final soChuDe = provider.dsChuDe.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bài tập trên lớp',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${provider.dsBaiTap.length} bài tập · $soChuDe chủ đề',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _hienThiDanhSachChuDe(provider),
                  icon: const Icon(Icons.topic_rounded, size: 18),
                  label: const Text('Chủ đề'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaoQuizGiangVien(lop: widget.lop),
                      ),
                    );
                    if (ok == true && mounted) {
                      await provider.layDanhSachBaiTap(widget.lop.id);
                    }
                  },
                  icon: const Icon(Icons.quiz_rounded, size: 18),
                  label: const Text('Tạo quiz'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9333EA),
                    side: const BorderSide(color: Color(0xFFE9D5FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _hienThiFormBaiTap(provider),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Giao bài tập'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanhSach(GiangVienProvider provider) {
    if (provider.btLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.btError != null) {
      return TrangThaiLoi(
        loi: provider.btError!,
        onTaiLai: () => provider.layDanhSachBaiTap(widget.lop.id),
      );
    }

    if (provider.dsBaiTap.isEmpty) {
      return TrangThaiRong(
        thongDiep: 'Chưa có bài tập nào',
        icon: Icons.assignment_outlined,
        nhanNut: 'Giao bài tập',
        onNutNhan: () => _hienThiFormBaiTap(provider),
      );
    }

    final nhom = provider.baiTapTheoChuDe;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.layDanhSachChuDe(widget.lop.id);
        await provider.layDanhSachBaiTap(widget.lop.id);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: nhom.entries.map((entry) {
          return _buildNhomChuDe(
            tenChuDe: entry.key,
            dsBaiTap: entry.value,
            provider: provider,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNhomChuDe({
    required String tenChuDe,
    required List<BaiTap> dsBaiTap,
    required GiangVienProvider provider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.topic_rounded,
                    color: _primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenChuDe,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${dsBaiTap.length} bài',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    final cd = provider.dsChuDe.firstWhere(
                      (e) => e.tenChuDe == tenChuDe,
                      orElse: () => ChuDe(
                        id: 0,
                        tenChuDe: tenChuDe,
                        lopHocPhanId: widget.lop.id,
                      ),
                    );

                    if (cd.id <= 0) return;

                    if (v == 'sua') {
                      _hienThiFormChuDe(provider, chuDe: cd);
                    } else if (v == 'xoa') {
                      _xacNhanXoaChuDe(provider, cd);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'sua', child: Text('Sửa chủ đề')),
                    PopupMenuItem(value: 'xoa', child: Text('Xóa chủ đề')),
                  ],
                ),
              ],
            ),
          ),
          ...dsBaiTap.map((bt) => _buildTheBaiTap(bt, provider)),
        ],
      ),
    );
  }

  Future<void> _moChiTietBaiTap(BaiTap bt, GiangVienProvider provider) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietBaiTapGiangVien(
          lop: widget.lop,
          baiTap: bt,
          onEdit: () async => _suaBaiTapHoacQuiz(provider, bt),
          onDelete: () async => _xacNhanXoa(bt, provider),
          onViewSubmissions: () async {
            if (bt.laQuiz) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      KetQuaQuizGiangVien(baiTapId: bt.id, tieuDe: bt.tieuDe),
                ),
              );
            } else {
              await _xemBaiNop(bt, provider);
            }
          },
        ),
      ),
    );
  }

  Future<void> _suaBaiTapHoacQuiz(GiangVienProvider provider, BaiTap bt) async {
    if (bt.laQuiz) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TaoQuizGiangVien(lop: widget.lop, baiTap: bt),
        ),
      );

      if (ok == true && mounted) {
        await provider.layDanhSachBaiTap(widget.lop.id);
      }
      return;
    }

    await _hienThiFormBaiTap(provider, baiTap: bt);
  }

  Widget _buildTheBaiTap(BaiTap bt, GiangVienProvider provider) {
    final quaHan = bt.daQuaHan;
    final mauHan = quaHan ? Colors.red : const Color(0xFF16A34A);
    final typeColor = bt.laQuiz
        ? const Color(0xFF9333EA)
        : const Color(0xFFF97316);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _moChiTietBaiTap(bt, provider),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      bt.laQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bt.tieuDe,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _text,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (bt.moTa != null && bt.moTa!.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            bt.moTa!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Tùy chọn',
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 10,
                    offset: const Offset(0, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'sua') {
                        _suaBaiTapHoacQuiz(provider, bt);
                      } else if (value == 'xoa') {
                        _xacNhanXoa(bt, provider);
                      } else if (value == 'nop') {
                        if (bt.laQuiz) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KetQuaQuizGiangVien(
                                baiTapId: bt.id,
                                tieuDe: bt.tieuDe,
                              ),
                            ),
                          );
                        } else {
                          _xemBaiNop(bt, provider);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'sua',
                        child: _MenuActionItem(
                          icon: Icons.edit_rounded,
                          title: 'Chỉnh sửa',
                          color: Colors.blue,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'nop',
                        child: _MenuActionItem(
                          icon: bt.laQuiz
                              ? Icons.bar_chart_rounded
                              : Icons.folder_open_rounded,
                          title: bt.laQuiz ? 'Kết quả quiz' : 'Xem bài nộp',
                          color: Colors.green,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'xoa',
                        child: _MenuActionItem(
                          icon: Icons.delete_rounded,
                          title: 'Xóa',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallBadge(
                    icon: Icons.access_time_rounded,
                    text: bt.hanNop != null
                        ? 'Hạn: ${dinhDangNgayGio(bt.hanNop)}${quaHan ? ' · quá hạn' : ''}'
                        : 'Không giới hạn',
                    color: mauHan,
                  ),
                  _SmallBadge(
                    icon: bt.daHenGio
                        ? Icons.schedule_send_rounded
                        : Icons.visibility_rounded,
                    text: bt.thoiGianGui == null
                        ? 'Gửi ngay'
                        : '${bt.tenTrangThaiGui}: ${dinhDangNgayGio(bt.thoiGianGui)}',
                    color: bt.daHenGio
                        ? const Color(0xFFF97316)
                        : const Color(0xFF16A34A),
                  ),
                  _SmallBadge(
                    icon: bt.laQuiz
                        ? Icons.quiz_rounded
                        : Icons.upload_file_rounded,
                    text: bt.tenLoaiBaiTap,
                    color: typeColor,
                  ),
                  if (bt.laNopFile)
                    _SmallBadge(
                      icon: Icons.rule_folder_rounded,
                      text: bt.cauHinhNopFileTomTat,
                      color: const Color(0xFF0D9488),
                    ),
                  if (bt.laNopFile && bt.yeuCauNopFile)
                    _SmallBadge(
                      icon: Icons.extension_rounded,
                      text: bt.dinhDangFileHienThi,
                      color: const Color(0xFF64748B),
                    ),
                  if (bt.tenChuDe != null && bt.tenChuDe!.isNotEmpty)
                    _SmallBadge(
                      icon: Icons.topic_rounded,
                      text: bt.tenChuDe!,
                      color: _primary,
                    ),
                  if (bt.laQuiz && bt.thoiGianLam != null)
                    _SmallBadge(
                      icon: Icons.timer_rounded,
                      text: '${bt.thoiGianLam} phút',
                      color: _primary,
                    ),
                  if (bt.laQuiz)
                    _SmallBadge(
                      icon: Icons.help_outline_rounded,
                      text: '${bt.soCauHoi} câu',
                      color: const Color(0xFF0D9488),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildChiSoBaiNop(
                        icon: bt.laQuiz
                            ? Icons.people_alt_rounded
                            : Icons.upload_file_rounded,
                        giaTri: '${bt.soBaiNop}',
                        nhan: bt.laQuiz ? 'Đã làm' : 'Đã nộp',
                        mau: _primary,
                      ),
                    ),
                    Expanded(
                      child: _buildChiSoBaiNop(
                        icon: bt.laQuiz
                            ? Icons.quiz_rounded
                            : Icons.grading_rounded,
                        giaTri: bt.laQuiz ? '${bt.soCauHoi}' : '${bt.soDaCham}',
                        nhan: bt.laQuiz ? 'Số câu' : 'Đã chấm',
                        mau: const Color(0xFF16A34A),
                      ),
                    ),
                    Expanded(
                      child: _buildChiSoBaiNop(
                        icon: bt.laQuiz
                            ? Icons.score_rounded
                            : Icons.pending_actions_rounded,
                        giaTri: bt.laQuiz
                            ? '${bt.soDaCham}'
                            : '${bt.soChooCham}',
                        nhan: bt.laQuiz ? 'Đã chấm' : 'Chờ chấm',
                        mau: bt.laQuiz
                            ? const Color(0xFF9333EA)
                            : (bt.soChooCham > 0
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChiSoBaiNop({
    required IconData icon,
    required String giaTri,
    required String nhan,
    required Color mau,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: mau),
        const SizedBox(height: 4),
        Text(
          giaTri,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: mau,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          nhan,
          style: const TextStyle(
            fontSize: 11,
            color: _muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _xemBaiNop(BaiTap bt, GiangVienProvider provider) async {
    await provider.layDanhSachBaiNop(bt);
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => _BaiNopSheet(bt: bt, scrollController: ctrl),
      ),
    );
  }

  Future<void> _hienThiDanhSachChuDe(GiangVienProvider provider) async {
    await provider.layDanhSachChuDe(widget.lop.id);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Consumer<GiangVienProvider>(
          builder: (context, p, _) {
            final daChonTatCa = p.btChuDeIds.isEmpty;
            final daChonChuaPhanLoai = p.btChuDeIds.contains(
              _chuDeChuaPhanLoaiId,
            );

            final soChuaPhanLoai = p.dsBaiTap.where((bt) {
              return bt.chuDeId == null || bt.chuDeId == 0;
            }).length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.78,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chủ đề',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _hienThiFormChuDe(provider);
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Thêm'),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Tất cả chủ đề
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: daChonTatCa
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CheckboxListTile(
                          value: daChonTatCa,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF2563EB),
                          secondary: const Icon(
                            Icons.select_all_rounded,
                            color: Color(0xFF2563EB),
                          ),
                          title: const Text(
                            'Tất cả chủ đề',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          onChanged: (_) {
                            Navigator.pop(context);
                            p.xoaLocChuDeBaiTap(widget.lop.id);
                          },
                        ),
                      ),

                      // Chưa phân loại
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: daChonChuaPhanLoai
                              ? const Color(0xFFF1F5F9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CheckboxListTile(
                          value: daChonChuaPhanLoai,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF64748B),
                          secondary: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.inbox_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Chưa phân loại',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          subtitle: Text(
                            '$soChuaPhanLoai bài',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (_) {
                            p.toggleChuDeBaiTap(
                              widget.lop.id,
                              _chuDeChuaPhanLoaiId,
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: p.dsChuDe.length,
                          itemBuilder: (_, i) {
                            final cd = p.dsChuDe[i];
                            final selected = p.btChuDeIds.contains(cd.id);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFEFF6FF)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                leading: Checkbox(
                                  value: selected,
                                  activeColor: const Color(0xFF2563EB),
                                  onChanged: (_) {
                                    p.toggleChuDeBaiTap(widget.lop.id, cd.id);
                                  },
                                ),
                                title: Text(
                                  cd.tenChuDe,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  '${cd.soBaiTap} bài',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  tooltip: 'Tùy chọn',
                                  color: Colors.white,
                                  surfaceTintColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  onSelected: (v) {
                                    Navigator.pop(context);

                                    if (v == 'sua') {
                                      _hienThiFormChuDe(provider, chuDe: cd);
                                    } else if (v == 'xoa') {
                                      _xacNhanXoaChuDe(provider, cd);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'sua',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_rounded,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Sửa chủ đề'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'xoa',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_rounded,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Xóa chủ đề'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  p.toggleChuDeBaiTap(widget.lop.id, cd.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _uploadFileBaiTap(PlatformFile file) async {
    final path = file.path;
    if (path == null || path.isEmpty) {
      return {
        'success': false,
        'message': 'Không lấy được đường dẫn file đã chọn',
      };
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: file.name),
      });

      final response = await Dio().post(
        _uploadBaiTapUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final data = response.data;
      if (data is Map) {
        final status = data['status']?.toString();
        final thanhCong = status == 'success' || data['success'] == true;

        if (thanhCong) {
          final rawPath =
              data['duong_dan_file'] ??
              data['path'] ??
              (data['data'] is Map ? data['data']['duong_dan_file'] : null);

          return {
            'success': true,
            'message': data['message']?.toString() ?? 'Upload file thành công',
            'duong_dan_file': rawPath?.toString() ?? '',
          };
        }

        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Upload file thất bại',
        };
      }

      return {'success': false, 'message': 'Phản hồi upload không hợp lệ'};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi upload file: $e'};
    }
  }

  Future<void> _hienThiFormBaiTap(
    GiangVienProvider provider, {
    BaiTap? baiTap,
  }) async {
    final formKey = GlobalKey<FormState>();
    final tieuDeCtrl = TextEditingController(text: baiTap?.tieuDe ?? '');
    final moTaCtrl = TextEditingController(text: baiTap?.moTa ?? '');
    PlatformFile? fileDaChon;
    String? duongDanFile = baiTap?.duongDanFile;
    final diemToiDaCtrl = TextEditingController(
      text: _fmtSo(baiTap?.diemToiDa ?? 10),
    );

    bool yeuCauNopFile = baiTap?.yeuCauNopFile ?? true;
    final Set<String> dinhDangDaChon = {...?baiTap?.dsDinhDangChoPhep};
    int soFileToiDa = baiTap?.soFileToiDa ?? 1;
    int dungLuongToiDaMb = baiTap?.dungLuongToiDaMb ?? 25;
    bool choPhepNopLai = baiTap?.choPhepNopLai ?? true;
    bool choPhepNopMuon = baiTap?.choPhepNopMuon ?? true;

    const dinhDangPhoBien = <String>[
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'zip',
      'rar',
      'jpg',
      'jpeg',
      'png',
      'txt',
      'sql',
    ];

    DateTime? hanNop = baiTap?.hanNop;
    DateTime? thoiGianGui = baiTap?.thoiGianGui;
    String trangThai = baiTap?.trangThai ?? 'dang_mo';
    int? chuDeId = baiTap?.chuDeId;
    bool dangLuu = false;

    if (provider.dsChuDe.isEmpty) {
      await provider.layDanhSachChuDe(widget.lop.id);
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(baiTap == null ? 'Giao bài tập' : 'Cập nhật bài tập'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int?>(
                      value: chuDeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Chủ đề',
                        prefixIcon: Icon(Icons.topic),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Chưa phân loại'),
                        ),
                        ...provider.dsChuDe.map(
                          (cd) => DropdownMenuItem<int?>(
                            value: cd.id,
                            child: Text(cd.tenChuDe),
                          ),
                        ),
                      ],
                      onChanged: dangLuu
                          ? null
                          : (v) => setS(() => chuDeId = v),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: tieuDeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề *',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Tiêu đề không được trống'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: moTaCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả / Yêu cầu',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FilePickerBox(
                      fileDaChon: fileDaChon,
                      duongDanFile: duongDanFile,
                      enabled: !dangLuu,
                      onChonFile: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowedExtensions: const [
                            'pdf',
                            'doc',
                            'docx',
                            'ppt',
                            'pptx',
                            'xls',
                            'xlsx',
                            'zip',
                            'rar',
                            'png',
                            'jpg',
                            'jpeg',
                            'txt',
                            'sql',
                          ],
                        );

                        if (result == null || result.files.isEmpty) return;

                        setS(() {
                          fileDaChon = result.files.single;
                          duongDanFile = null;
                        });
                      },
                      onXoaFile: () {
                        setS(() {
                          fileDaChon = null;
                          duongDanFile = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _CaiDatNopBaiBox(
                      yeuCauNopFile: yeuCauNopFile,
                      dinhDangPhoBien: dinhDangPhoBien,
                      dinhDangDaChon: dinhDangDaChon,
                      soFileToiDa: soFileToiDa,
                      dungLuongToiDaMb: dungLuongToiDaMb,
                      choPhepNopLai: choPhepNopLai,
                      choPhepNopMuon: choPhepNopMuon,
                      diemToiDaCtrl: diemToiDaCtrl,
                      dangLuu: dangLuu,
                      onDoiYeuCauNopFile: (v) => setS(() => yeuCauNopFile = v),
                      onToggleDinhDang: (ext, selected) {
                        setS(() {
                          if (selected) {
                            dinhDangDaChon.add(ext);
                          } else {
                            dinhDangDaChon.remove(ext);
                          }
                        });
                      },
                      onDoiSoFile: (v) => setS(() => soFileToiDa = v),
                      onDoiDungLuong: (v) => setS(() => dungLuongToiDaMb = v),
                      onDoiNopLai: (v) => setS(() => choPhepNopLai = v),
                      onDoiNopMuon: (v) => setS(() => choPhepNopMuon = v),
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        hanNop != null
                            ? 'Hạn nộp: ${dinhDangNgayGio(hanNop)}'
                            : 'Chưa đặt hạn nộp',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hanNop != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setS(() => hanNop = null),
                            ),
                          TextButton(
                            onPressed: () async {
                              final ngay = await showDatePicker(
                                context: ctx,
                                initialDate:
                                    hanNop ??
                                    DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (ngay == null) return;

                              final gio = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.now(),
                              );
                              if (gio == null) return;

                              setS(
                                () => hanNop = DateTime(
                                  ngay.year,
                                  ngay.month,
                                  ngay.day,
                                  gio.hour,
                                  gio.minute,
                                ),
                              );
                            },
                            child: Text(
                              hanNop == null ? 'Chọn hạn' : 'Đổi hạn',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        thoiGianGui == null ? Icons.send : Icons.schedule_send,
                        color: thoiGianGui == null
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text(
                        thoiGianGui == null
                            ? 'Thời gian gửi: Gửi ngay'
                            : 'Thời gian gửi: ${dinhDangNgayGio(thoiGianGui)}',
                      ),
                      subtitle: Text(
                        thoiGianGui == null
                            ? 'Sinh viên sẽ thấy bài tập ngay sau khi lưu'
                            : 'Sinh viên chỉ thấy bài tập khi đến thời gian này',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (thoiGianGui != null)
                            IconButton(
                              tooltip: 'Gửi ngay',
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: dangLuu
                                  ? null
                                  : () => setS(() => thoiGianGui = null),
                            ),
                          TextButton(
                            onPressed: dangLuu
                                ? null
                                : () async {
                                    final picked = await _chonNgayGioGui(
                                      context: ctx,
                                      giaTriHienTai: thoiGianGui,
                                    );
                                    if (picked == null) return;
                                    setS(() => thoiGianGui = picked);
                                  },
                            child: Text(
                              thoiGianGui == null ? 'Hẹn giờ' : 'Đổi giờ',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: trangThai,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        prefixIcon: Icon(Icons.toggle_on),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'dang_mo',
                          child: Text('Đang mở'),
                        ),
                        DropdownMenuItem(
                          value: 'da_dong',
                          child: Text('Đã đóng'),
                        ),
                      ],
                      onChanged: dangLuu
                          ? null
                          : (v) => setS(() => trangThai = v ?? 'dang_mo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: dangLuu ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: dangLuu
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setS(() => dangLuu = true);

                      String duongDanFileCuoi = duongDanFile?.trim() ?? '';

                      if (fileDaChon != null) {
                        final uploadResult = await _uploadFileBaiTap(
                          fileDaChon!,
                        );

                        if (!mounted || !ctx.mounted) return;

                        if (uploadResult['success'] != true) {
                          setS(() => dangLuu = false);
                          hienThiSnackBar(
                            context,
                            uploadResult['message']?.toString() ??
                                'Không upload được file',
                            laThanh: false,
                          );
                          return;
                        }

                        duongDanFileCuoi =
                            uploadResult['duong_dan_file']?.toString() ?? '';
                      }

                      final result = baiTap == null
                          ? await provider.themBaiTap(
                              tieuDe: tieuDeCtrl.text,
                              lopHocPhanId: widget.lop.id,
                              chuDeId: chuDeId,
                              moTa: moTaCtrl.text,
                              duongDanFile: duongDanFileCuoi,
                              hanNop: hanNop,
                              yeuCauNopFile: yeuCauNopFile,
                              dinhDangFileChoPhep: dinhDangDaChon.join(','),
                              soFileToiDa: soFileToiDa,
                              dungLuongToiDaMb: dungLuongToiDaMb,
                              choPhepNopLai: choPhepNopLai,
                              choPhepNopMuon: choPhepNopMuon,
                              diemToiDa:
                                  double.tryParse(diemToiDaCtrl.text.trim()) ??
                                  10,
                              thoiGianGui: thoiGianGui,
                              trangThai: trangThai,
                            )
                          : await provider.suaBaiTap(
                              id: baiTap.id,
                              tieuDe: tieuDeCtrl.text,
                              lopHocPhanId: widget.lop.id,
                              chuDeId: chuDeId,
                              moTa: moTaCtrl.text,
                              duongDanFile: duongDanFileCuoi,
                              hanNop: hanNop,
                              yeuCauNopFile: yeuCauNopFile,
                              dinhDangFileChoPhep: dinhDangDaChon.join(','),
                              soFileToiDa: soFileToiDa,
                              dungLuongToiDaMb: dungLuongToiDaMb,
                              choPhepNopLai: choPhepNopLai,
                              choPhepNopMuon: choPhepNopMuon,
                              diemToiDa:
                                  double.tryParse(diemToiDaCtrl.text.trim()) ??
                                  10,
                              thoiGianGui: thoiGianGui,
                              trangThai: trangThai,
                            );

                      if (!mounted) return;

                      if (result['success'] == true) {
                        Navigator.pop(ctx);
                        hienThiSnackBar(
                          context,
                          result['message'] ?? '',
                          laThanh: true,
                        );
                        return;
                      }

                      setS(() => dangLuu = false);
                      hienThiSnackBar(
                        context,
                        result['message'] ?? '',
                        laThanh: false,
                      );
                    },
              icon: dangLuu
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(dangLuu ? 'Đang lưu...' : 'Lưu'),
            ),
          ],
        ),
      ),
    );

    // Không dispose controller ngay sau showDialog.
    // Route dialog vẫn có thể render thêm vài frame khi đóng, nếu dispose sớm
    // sẽ gây lỗi: A TextEditingController was used after being disposed.
    Future.delayed(const Duration(milliseconds: 400), () {
      tieuDeCtrl.dispose();
      moTaCtrl.dispose();
      diemToiDaCtrl.dispose();
    });
  }

  Future<void> _hienThiFormChuDe(
    GiangVienProvider provider, {
    ChuDe? chuDe,
  }) async {
    final ctrl = TextEditingController(text: chuDe?.tenChuDe ?? '');
    bool dangLuu = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(chuDe == null ? 'Thêm chủ đề' : 'Sửa chủ đề'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên chủ đề',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.topic),
            ),
          ),
          actions: [
            TextButton(
              onPressed: dangLuu ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: dangLuu
                  ? null
                  : () async {
                      final ten = ctrl.text.trim();
                      if (ten.isEmpty) {
                        hienThiSnackBar(
                          context,
                          'Tên chủ đề không được trống',
                          laThanh: false,
                        );
                        return;
                      }

                      setS(() => dangLuu = true);

                      final result = chuDe == null
                          ? await provider.themChuDe(
                              lopHocPhanId: widget.lop.id,
                              tenChuDe: ten,
                            )
                          : await provider.suaChuDe(
                              lopHocPhanId: widget.lop.id,
                              chuDeId: chuDe.id,
                              tenChuDe: ten,
                            );

                      if (!mounted || !ctx.mounted) return;

                      if (result['success'] == true) {
                        Navigator.pop(ctx);
                        hienThiSnackBar(
                          context,
                          result['message'] ?? '',
                          laThanh: true,
                        );
                      } else {
                        setS(() => dangLuu = false);
                        hienThiSnackBar(
                          context,
                          result['message'] ?? '',
                          laThanh: false,
                        );
                      }
                    },
              icon: dangLuu
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(dangLuu ? 'Đang lưu...' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _xacNhanXoaChuDe(GiangVienProvider provider, ChuDe chuDe) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa chủ đề'),
        content: Text(
          'Xóa chủ đề "${chuDe.tenChuDe}"? Các bài tập trong chủ đề này sẽ chuyển về "Chưa phân loại".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (dongY != true || !mounted) return;

    final result = await provider.xoaChuDe(
      lopHocPhanId: widget.lop.id,
      chuDeId: chuDe.id,
    );

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message'] ?? '',
      laThanh: result['success'] == true,
    );
  }

  Future<void> _xacNhanXoa(BaiTap bt, GiangVienProvider provider) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa bài tập'),
        content: Text(
          'Xóa "${bt.tieuDe}"? Bài tập sẽ được ẩn khỏi sinh viên nhưng dữ liệu bài nộp/kết quả vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (dongY != true || !mounted) return;

    final result = bt.laQuiz
        ? await context.read<QuizProvider>().xoaQuizGiangVien(
            baiTapId: bt.id,
            nguoiTaoId: provider.nguoiDungId,
          )
        : await provider.xoaBaiTap(bt.id, widget.lop.id);

    if (bt.laQuiz && result['success'] == true) {
      await provider.layDanhSachBaiTap(widget.lop.id);
    }

    if (!mounted) return;

    hienThiSnackBar(
      context,
      result['message'] ?? '',
      laThanh: result['success'] == true,
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _SmallBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaiDatNopBaiBox extends StatelessWidget {
  final bool yeuCauNopFile;
  final List<String> dinhDangPhoBien;
  final Set<String> dinhDangDaChon;
  final int soFileToiDa;
  final int dungLuongToiDaMb;
  final bool choPhepNopLai;
  final bool choPhepNopMuon;
  final TextEditingController diemToiDaCtrl;
  final bool dangLuu;
  final ValueChanged<bool> onDoiYeuCauNopFile;
  final void Function(String ext, bool selected) onToggleDinhDang;
  final ValueChanged<int> onDoiSoFile;
  final ValueChanged<int> onDoiDungLuong;
  final ValueChanged<bool> onDoiNopLai;
  final ValueChanged<bool> onDoiNopMuon;

  const _CaiDatNopBaiBox({
    required this.yeuCauNopFile,
    required this.dinhDangPhoBien,
    required this.dinhDangDaChon,
    required this.soFileToiDa,
    required this.dungLuongToiDaMb,
    required this.choPhepNopLai,
    required this.choPhepNopMuon,
    required this.diemToiDaCtrl,
    required this.dangLuu,
    required this.onDoiYeuCauNopFile,
    required this.onToggleDinhDang,
    required this.onDoiSoFile,
    required this.onDoiDungLuong,
    required this.onDoiNopLai,
    required this.onDoiNopMuon,
  });

  @override
  Widget build(BuildContext context) {
    final dungLuongValue = [5, 10, 25, 50, 100].contains(dungLuongToiDaMb)
        ? dungLuongToiDaMb
        : 25;
    final dinhDangText = dinhDangDaChon.isEmpty
        ? 'Không chọn định dạng nào = cho phép mọi định dạng an toàn'
        : "Đang cho phép: ${dinhDangDaChon.map((e) => e.toUpperCase()).join(', ')}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rule_folder_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Cài đặt nộp bài',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: yeuCauNopFile,
            title: const Text(
              'Yêu cầu sinh viên nộp file',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Tắt nếu bài tập chỉ cần đọc/xem hướng dẫn'),
            onChanged: dangLuu ? null : onDoiYeuCauNopFile,
          ),
          if (yeuCauNopFile) ...[
            const SizedBox(height: 8),
            const Text(
              'Định dạng file cho phép',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dinhDangPhoBien.map((ext) {
                final selected = dinhDangDaChon.contains(ext);
                return FilterChip(
                  label: Text(ext.toUpperCase()),
                  selected: selected,
                  showCheckmark: true,
                  onSelected: dangLuu ? null : (v) => onToggleDinhDang(ext, v),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Text(
              dinhDangText,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final soFileDropdown = DropdownButtonFormField<int>(
                  value: soFileToiDa.clamp(1, 10).toInt(),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Số file',
                    prefixIcon: Icon(Icons.file_copy_rounded),
                    border: OutlineInputBorder(),
                  ),
                  selectedItemBuilder: (_) => List.generate(
                    10,
                    (i) => Text(
                      '${i + 1} file',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  items: List.generate(
                    10,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        '${i + 1} file',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: dangLuu ? null : (v) => onDoiSoFile(v ?? 1),
                );

                final dungLuongDropdown = DropdownButtonFormField<int>(
                  value: dungLuongValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Dung lượng',
                    prefixIcon: Icon(Icons.sd_storage_rounded),
                    border: OutlineInputBorder(),
                  ),
                  selectedItemBuilder: (_) => const [
                    Text('5 MB', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('10 MB', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('25 MB', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('50 MB', maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '100 MB',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 MB')),
                    DropdownMenuItem(value: 10, child: Text('10 MB')),
                    DropdownMenuItem(value: 25, child: Text('25 MB')),
                    DropdownMenuItem(value: 50, child: Text('50 MB')),
                    DropdownMenuItem(value: 100, child: Text('100 MB')),
                  ],
                  onChanged: dangLuu ? null : (v) => onDoiDungLuong(v ?? 25),
                );

                if (constraints.maxWidth < 430) {
                  return Column(
                    children: [
                      soFileDropdown,
                      const SizedBox(height: 10),
                      dungLuongDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: soFileDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: dungLuongDropdown),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final nopLaiTile = SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: choPhepNopLai,
                  title: const Text(
                    'Cho nộp lại',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: dangLuu ? null : onDoiNopLai,
                );

                final nopMuonTile = SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: choPhepNopMuon,
                  title: const Text(
                    'Cho nộp muộn',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onChanged: dangLuu ? null : onDoiNopMuon,
                );

                if (constraints.maxWidth < 430) {
                  return Column(children: [nopLaiTile, nopMuonTile]);
                }

                return Row(
                  children: [
                    Expanded(child: nopLaiTile),
                    const SizedBox(width: 8),
                    Expanded(child: nopMuonTile),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: diemToiDaCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Điểm tối đa',
                prefixIcon: Icon(Icons.star_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final raw = v?.trim() ?? '';
                if (raw.isEmpty) return null;
                final d = double.tryParse(raw);
                if (d == null || d <= 0) return 'Điểm tối đa không hợp lệ';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FilePickerBox extends StatelessWidget {
  final PlatformFile? fileDaChon;
  final String? duongDanFile;
  final bool enabled;
  final VoidCallback onChonFile;
  final VoidCallback onXoaFile;

  const _FilePickerBox({
    required this.fileDaChon,
    required this.duongDanFile,
    required this.enabled,
    required this.onChonFile,
    required this.onXoaFile,
  });

  String get _tenHienThi {
    if (fileDaChon != null) return fileDaChon!.name;
    final path = duongDanFile?.trim() ?? '';
    if (path.isEmpty) return 'Chưa chọn file đính kèm';
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  String get _moTa {
    if (fileDaChon != null) {
      final size = fileDaChon!.size;
      if (size <= 0) return 'File mới từ máy của bạn';
      final kb = size / 1024;
      if (kb < 1024) return '${kb.toStringAsFixed(1)} KB · sẽ upload khi lưu';
      return '${(kb / 1024).toStringAsFixed(1)} MB · sẽ upload khi lưu';
    }

    final path = duongDanFile?.trim() ?? '';
    if (path.isEmpty)
      return 'Hỗ trợ PDF, Word, Excel, PowerPoint, ZIP, ảnh, TXT, SQL';
    return path;
  }

  bool get _coFile =>
      fileDaChon != null || (duongDanFile?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final color = _coFile ? const Color(0xFF2563EB) : const Color(0xFF64748B);

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onChonFile : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _coFile
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _coFile
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _coFile
                      ? Icons.insert_drive_file_rounded
                      : Icons.upload_file_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tenHienThi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _moTa,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_coFile)
                IconButton(
                  tooltip: 'Xóa file',
                  onPressed: enabled ? onXoaFile : null,
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                )
              else
                FilledButton.icon(
                  onPressed: enabled ? onChonFile : null,
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: const Text('Chọn'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── BOTTOM SHEET XEM BÀI NỘP ────────────────────────────
class _BaiNopSheet extends StatelessWidget {
  final BaiTap bt;
  final ScrollController scrollController;
  const _BaiNopSheet({required this.bt, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Consumer<GiangVienProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bài nộp: ${bt.tieuDe}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${provider.dsBaiNop.length} bài đã nộp',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.bnLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.dsBaiNop.isEmpty
                  ? const TrangThaiRong(
                      thongDiep: 'Chưa có bài nộp nào',
                      icon: Icons.inbox,
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.dsBaiNop.length,
                      itemBuilder: (_, i) => _buildTheBaiNop(
                        context,
                        provider.dsBaiNop[i],
                        provider,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTheBaiNop(
    BuildContext context,
    BaiNop bn,
    GiangVienProvider provider,
  ) {
    final mauTT = switch (bn.trangThai) {
      'da_cham' => Colors.green,
      'nop_muon' => Colors.orange,
      _ => Colors.blue,
    };

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
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    bn.tenSinhVien.isNotEmpty ? bn.tenSinhVien[0] : 'S',
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bn.tenSinhVien,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        bn.maSinhVien,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ChipTrangThai(
                  nhan: bn.tenTrangThai,
                  mau: mauTT,
                  icon: Icons.assignment,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nộp lúc: ${dinhDangNgayGio(bn.ngayNop)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            if (bn.dsFileHienThi.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'File sinh viên đã nộp (${bn.dsFileHienThi.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...bn.dsFileHienThi.map((f) {
                      final size = f.kichThuocHienThi;
                      final subtitle = size.isEmpty ? 'Bấm để mở file' : 'Bấm để mở file · $size';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.insert_drive_file_rounded,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            f.tenHienThi,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            subtitle,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                          onTap: () => _gvMoFileBaiNop(context, f),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF97316)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bài nộp này chưa có file hoặc đường dẫn file bị trống.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9A3412)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (bn.daDuocCham) ...[
              const Divider(height: 14),
              Row(
                children: [
                  Icon(Icons.star, size: 15, color: Colors.orange.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Điểm: ${bn.diem?.toStringAsFixed(1) ?? '--'}/${_gvFmtDiem(bt.diemToiDa)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  if (bn.nhanXet != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bn.nhanXet!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _hienThiChamDiem(context, bn, provider),
                icon: Icon(
                  bn.daDuocCham ? Icons.edit : Icons.grading,
                  size: 16,
                ),
                label: Text(bn.daDuocCham ? 'Chỉnh sửa điểm' : 'Chấm điểm'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _hienThiChamDiem(
    BuildContext context,
    BaiNop bn,
    GiangVienProvider provider,
  ) async {
    final formKey = GlobalKey<FormState>();
    final diemCtrl = TextEditingController(text: bn.diem?.toString() ?? '');
    final nhanXetCtrl = TextEditingController(text: bn.nhanXet ?? '');
    bool dangLuu = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Chấm điểm: ${bn.tenSinhVien}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: diemCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Điểm (0 - ${_gvFmtDiem(bt.diemToiDa)})',
                    prefixIcon: Icon(Icons.star),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final d = double.tryParse(v.trim());
                    if (d == null) return 'Điểm không hợp lệ';
                    if (d < 0 || d > bt.diemToiDa) return 'Điểm phải từ 0 đến ${_gvFmtDiem(bt.diemToiDa)}';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: nhanXetCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Nhận xét',
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: dangLuu ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: dangLuu
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setS(() => dangLuu = true);
                      final diem = diemCtrl.text.trim().isEmpty
                          ? null
                          : double.tryParse(diemCtrl.text.trim());
                      final result = await provider.chamDiem(
                        baiNopId: bn.id,
                        diem: diem,
                        nhanXet: nhanXetCtrl.text,
                      );
                      setS(() => dangLuu = false);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      hienThiSnackBar(
                        context,
                        result['message'] ?? '',
                        laThanh: result['success'] == true,
                      );
                    },
              icon: dangLuu
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(dangLuu ? 'Đang lưu...' : 'Xác nhận'),
            ),
          ],
        ),
      ),
    );

    // Trì hoãn dispose để tránh dialog còn render trong lúc animation đóng.
    Future.delayed(const Duration(milliseconds: 400), () {
      diemCtrl.dispose();
      nhanXetCtrl.dispose();
    });
  }
}

class _MenuActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _MenuActionItem({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDelete = title == 'Xóa';

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDelete ? Colors.red.shade700 : const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
