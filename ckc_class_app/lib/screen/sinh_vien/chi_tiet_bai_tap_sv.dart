import 'package:ckc_class_app/screen/sinh_vien/ket_qua_quiz_sv.dart';
import 'package:ckc_class_app/screen/sinh_vien/lam_quiz_sv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';
import '../../utils/file_download_helper.dart';

class ChiTietBaiTapSV extends StatefulWidget {
  final dynamic baiTap;
  final int lopHocPhanId;
  final bool chiDoc;

  const ChiTietBaiTapSV({
    super.key,
    required this.baiTap,
    required this.lopHocPhanId,
    this.chiDoc = false,
  });

  @override
  State<ChiTietBaiTapSV> createState() => _ChiTietBaiTapSVState();
}

class _ChiTietBaiTapSVState extends State<ChiTietBaiTapSV> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  dynamic _baiTapHienTai(SinhVienProvider provider) {
    for (final item in provider.dsBaiTap) {
      if (item.id == widget.baiTap.id) return item;
    }
    return widget.baiTap;
  }

  Color _mauTrangThai(dynamic bt) {
    if (bt.laQuiz) {
      if (bt.daLamQuiz) return Colors.green;
      if (bt.daQuaHan) return Colors.red;
      return Colors.purple;
    }

    if (bt.daDuocNop) return Colors.green;
    if (bt.daQuaHan) return Colors.red;
    return Colors.orange;
  }

  String _duoiFile(String name) {
    final clean = name.split('/').last.split('\\').last;
    final index = clean.lastIndexOf('.');
    return index < 0 ? '' : clean.substring(index + 1).toLowerCase();
  }

  Future<void> _chonVaNopFile(dynamic bt) async {
    final allowed = List<String>.from(bt.dsDinhDangChoPhep);
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: allowed.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: allowed.isEmpty ? null : allowed,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final files = result.files.where((f) => f.path != null).toList();
    if (files.isEmpty || !mounted) return;

    if (files.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mỗi lần chỉ được nộp 1 file')),
      );
      return;
    }

    final maxBytes = bt.dungLuongToiDaMb * 1024 * 1024;
    for (final file in files) {
      final ext = _duoiFile(file.name);
      if (allowed.isNotEmpty && !allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File ${file.name} không đúng định dạng cho phép')),
        );
        return;
      }
      if (file.size > maxBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File ${file.name} vượt quá ${bt.dungLuongToiDaMb}MB')),
        );
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<SinhVienProvider>();
    final rs = await provider.nopBai(
      baiTapId: bt.id,
      filePath: files.single.path!,
      lopHocPhanId: widget.lopHocPhanId,
    );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(rs['message'].toString()),
        backgroundColor: rs['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (rs['success'] == true) {
      await provider.layDanhSachBaiTap(widget.lopHocPhanId);
    }
  }

  Future<void> _xuLyQuiz(dynamic bt) async {
    if (bt.daLamQuiz) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KetQuaQuizSV(
            baiTapId: bt.id,
            tieuDe: bt.tieuDe,
          ),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LamQuizSV(
          baiTapId: bt.id,
          tieuDe: bt.tieuDe,
          thoiGianLam: bt.thoiGianLam,
          lopHocPhanId: widget.lopHocPhanId,
        ),
      ),
    );

    if (result == true && mounted) {
      await context.read<SinhVienProvider>().layDanhSachBaiTap(widget.lopHocPhanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(
      builder: (context, provider, _) {
        final bt = _baiTapHienTai(provider);
        final mau = _mauTrangThai(bt);

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: _text,
            title: const Text(
              'Chi tiết bài tập',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _NutHanhDong(
              bt: bt,
              chiDoc: widget.chiDoc,
              dangXuLy: provider.btProcessing,
              onQuiz: () => _xuLyQuiz(bt),
              onNopFile: () => _chonVaNopFile(bt),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              _HeaderBaiTap(bt: bt, mau: mau),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Mô tả bài tập',
                icon: Icons.description_rounded,
                child: Text(
                  (bt.moTa ?? '').toString().trim().isEmpty
                      ? 'Giảng viên chưa nhập mô tả cho bài tập này.'
                      : bt.moTa.toString(),
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Thông tin quan trọng',
                icon: Icons.info_outline_rounded,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.event_available_rounded,
                      label: 'Hạn nộp',
                      value: dinhDangNgayGio(bt.hanNop),
                      color: bt.daQuaHan ? Colors.red : _primary,
                    ),
                    _InfoRow(
                      icon: bt.laQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
                      label: 'Loại bài',
                      value: bt.tenLoaiBaiTap,
                      color: bt.laQuiz ? Colors.purple : Colors.orange,
                    ),
                    if (bt.tenChuDe != null && bt.tenChuDe!.toString().isNotEmpty)
                      _InfoRow(
                        icon: Icons.folder_special_rounded,
                        label: 'Chủ đề',
                        value: bt.tenChuDe.toString(),
                        color: Colors.blue,
                      ),
                    if (bt.laQuiz && bt.thoiGianLam != null)
                      _InfoRow(
                        icon: Icons.timer_rounded,
                        label: 'Thời gian',
                        value: '${bt.thoiGianLam} phút',
                        color: Colors.purple,
                      ),
                    if (bt.laQuiz)
                      _InfoRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Số câu',
                        value: '${bt.soCauHoi}',
                        color: Colors.blue,
                      ),
                    if (bt.duongDanFile != null && bt.duongDanFile!.toString().isNotEmpty)
                      _DownloadFileRow(
                        label: 'File đề bài',
                        tenFile: tenFileHienThi(
                          tenFile: bt.fileName?.toString(),
                          duongDan: bt.duongDanFile.toString(),
                        ),
                        color: Colors.indigo,
                        onTap: () => taiFileVeMay(
                          context,
                          duongDan: bt.duongDanFile.toString(),
                          tenFile: bt.fileName?.toString(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: bt.laQuiz ? 'Kết quả làm quiz' : 'Bài nộp của bạn',
                icon: bt.laQuiz ? Icons.fact_check_rounded : Icons.cloud_upload_rounded,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: bt.laQuiz
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      label: bt.laQuiz ? 'Trạng thái' : 'Bài nộp',
                      value: bt.tenTrangThaiNop,
                      color: mau,
                    ),
                    if (!bt.laQuiz)
                      ...bt.dsFileDaNopHienThi.map(
                        (file) => _DownloadFileRow(
                          label: 'File đã nộp',
                          tenFile: file.tenHienThi,
                          color: Colors.green,
                          onTap: () => taiFileVeMay(
                            context,
                            duongDan: file.duongDanFile,
                            tenFile: file.tenHienThi,
                          ),
                        ),
                      ),
                    if (!bt.laQuiz && bt.diem != null)
                      _InfoRow(
                        icon: Icons.grade_rounded,
                        label: 'Điểm',
                        value: bt.diem!.toStringAsFixed(1),
                        color: Colors.green,
                      ),
                    if (!bt.laQuiz && bt.nhanXet != null && bt.nhanXet!.toString().isNotEmpty)
                      _InfoRow(
                        icon: Icons.rate_review_rounded,
                        label: 'Nhận xét',
                        value: bt.nhanXet.toString(),
                        color: Colors.teal,
                      ),
                    if (bt.laQuiz && bt.diemQuiz != null)
                      _InfoRow(
                        icon: Icons.bar_chart_rounded,
                        label: 'Điểm quiz',
                        value: bt.diemQuiz!.toStringAsFixed(1),
                        color: Colors.green,
                      ),
                    if (bt.laQuiz)
                      _InfoRow(
                        icon: Icons.task_alt_rounded,
                        label: 'Đã làm',
                        value: bt.daLamQuiz ? 'Đã làm' : 'Chưa làm',
                        color: bt.daLamQuiz ? Colors.green : Colors.orange,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _HintCard(bt: bt, mau: mau),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderBaiTap extends StatelessWidget {
  final dynamic bt;
  final Color mau;

  const _HeaderBaiTap({required this.bt, required this.mau});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: bt.laQuiz
              ? const [Color(0xFF6D28D9), Color(0xFF9333EA), Color(0xFF38BDF8)]
              : const [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: mau.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -34, top: -36, child: _DecorCircle(size: 118, opacity: .14)),
          Positioned(right: 30, bottom: -52, child: _DecorCircle(size: 96, opacity: .10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(.20)),
                    ),
                    child: Icon(
                      bt.laQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            ChipTrangThai(nhan: bt.tenTrangThaiNop, mau: Colors.white),
                            ChipTrangThai(
                              nhan: bt.tenLoaiBaiTap,
                              mau: Colors.white,
                              icon: bt.laQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bt.tieuDe,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hạn nộp: ${dinhDangNgayGio(bt.hanNop)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.84),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadFileRow extends StatelessWidget {
  final String label;
  final String tenFile;
  final Color color;
  final VoidCallback onTap;

  const _DownloadFileRow({
    required this.label,
    required this.tenFile,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.download_rounded, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(tenFile, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w900, height: 1.25)),
                  ],
                ),
              ),
              Icon(Icons.download_for_offline_outlined, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutHanhDong extends StatelessWidget {
  final dynamic bt;
  final bool chiDoc;
  final bool dangXuLy;
  final VoidCallback onQuiz;
  final VoidCallback onNopFile;

  const _NutHanhDong({
    required this.bt,
    required this.chiDoc,
    required this.dangXuLy,
    required this.onQuiz,
    required this.onNopFile,
  });

  @override
  Widget build(BuildContext context) {
    if (bt.laQuiz) {
      return FilledButton.icon(
        onPressed: dangXuLy || (chiDoc && !bt.daLamQuiz) || (!bt.daLamQuiz && bt.daDong)
            ? null
            : onQuiz,
        icon: Icon(bt.daLamQuiz ? Icons.bar_chart_rounded : Icons.quiz_rounded),
        label: Text(
          bt.daLamQuiz
              ? 'Xem kết quả quiz'
              : (chiDoc ? 'Lớp đã lưu · Chỉ xem' : 'Bắt đầu làm quiz'),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );
    }

    if (chiDoc) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.visibility_rounded),
        label: const Text('Lớp đã lưu · Chỉ xem'),
      );
    }

    return FilledButton.icon(
      onPressed: bt.daDong || dangXuLy ? null : onNopFile,
      icon: const Icon(Icons.upload_file_rounded),
      label: Text(
        dangXuLy
            ? 'Đang nộp...'
            : bt.daDuocNop
                ? 'Nộp lại file'
                : 'Chọn file nộp bài',
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final dynamic bt;
  final Color mau;

  const _HintCard({required this.bt, required this.mau});

  @override
  Widget build(BuildContext context) {
    final text = bt.laQuiz
        ? 'Kiểm tra kỹ thời gian làm bài trước khi bắt đầu. Khi đã nộp quiz, bạn có thể quay lại để xem kết quả.'
        : 'Bạn có thể nộp file hoặc nộp lại file trước khi bài tập đóng. Hãy kiểm tra đúng file trước khi gửi.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mau.withOpacity(.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: mau.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: mau),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: mau.withOpacity(.92),
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
