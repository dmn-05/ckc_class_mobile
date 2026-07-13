import 'package:ckc_class_app/screen/sinh_vien/chi_tiet_bai_tap_sv.dart';
import 'package:ckc_class_app/screen/sinh_vien/ket_qua_quiz_sv.dart';
import 'package:ckc_class_app/screen/sinh_vien/lam_quiz_sv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class BaiTapSVPage extends StatefulWidget {
  final int lopHocPhanId;

  const BaiTapSVPage({super.key, required this.lopHocPhanId});

  @override
  State<BaiTapSVPage> createState() => _BaiTapSVPageState();
}

class _BaiTapSVPageState extends State<BaiTapSVPage> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const int _chuDeChuaPhanLoaiId = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<SinhVienProvider>();
      p.layDanhSachChuDe(widget.lopHocPhanId);
      p.layDanhSachBaiTap(widget.lopHocPhanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SinhVienProvider>(
      builder: (_, p, __) {
        return ColoredBox(
          color: _bg,
          child: Column(
            children: [
              _buildBoLocChuDe(p),
              Expanded(child: _buildDanhSach(p)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoLocChuDe(SinhVienProvider p) {
    final soDaChon = p.btChuDeIds.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bài tập của lớp',
                  style: TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  soDaChon == 0
                      ? 'Đang hiển thị tất cả chủ đề'
                      : 'Đang lọc $soDaChon chủ đề',
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _hienThiDanhSachChuDe(p),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Chủ đề'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hienThiDanhSachChuDe(SinhVienProvider provider) async {
    await provider.layDanhSachChuDe(widget.lopHocPhanId);

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
        return Consumer<SinhVienProvider>(
          builder: (context, p, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.topic_rounded,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lọc theo chủ đề',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Chọn một hoặc nhiều chủ đề để xem bài tập',
                                style: TextStyle(color: _muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _TopicTile(
                      selected: p.btChuDeIds.isEmpty,
                      title: 'Tất cả chủ đề',
                      subtitle: 'Hiển thị toàn bộ bài tập và quiz',
                      icon: Icons.select_all_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        p.xoaLocChuDeBaiTap(widget.lopHocPhanId);
                      },
                      onChanged: (_) {
                        Navigator.pop(context);
                        p.xoaLocChuDeBaiTap(widget.lopHocPhanId);
                      },
                    ),
                    _TopicTile(
                      selected: p.btChuDeIds.contains(_chuDeChuaPhanLoaiId),
                      title: 'Chưa phân loại / bài kiểm tra',
                      subtitle: 'Bài chưa gắn chủ đề và quiz theo mô hình Web',
                      icon: Icons.inbox_rounded,
                      onTap: () {
                        p.toggleChuDeBaiTap(
                          widget.lopHocPhanId,
                          _chuDeChuaPhanLoaiId,
                        );
                      },
                      onChanged: (_) {
                        p.toggleChuDeBaiTap(
                          widget.lopHocPhanId,
                          _chuDeChuaPhanLoaiId,
                        );
                      },
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: p.dsChuDe.length,
                        itemBuilder: (_, i) {
                          final cd = p.dsChuDe[i];
                          final selected = p.btChuDeIds.contains(cd.id);

                          return _TopicTile(
                            selected: selected,
                            title: cd.tenChuDe,
                            subtitle: '${cd.soBaiTap} bài tập',
                            icon: Icons.folder_special_rounded,
                            onTap: () {
                              p.toggleChuDeBaiTap(widget.lopHocPhanId, cd.id);
                            },
                            onChanged: (_) {
                              p.toggleChuDeBaiTap(widget.lopHocPhanId, cd.id);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDanhSach(SinhVienProvider p) {
    if (p.btLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (p.btError != null) {
      return TrangLoi(
        loi: p.btError!,
        onTaiLai: () async {
          await p.layDanhSachChuDe(widget.lopHocPhanId);
          await p.layDanhSachBaiTap(widget.lopHocPhanId);
        },
      );
    }

    if (p.dsBaiTap.isEmpty) {
      return const TrangRong(
        thongDiep: 'Chưa có bài tập',
        icon: Icons.assignment_outlined,
      );
    }

    final nhom = p.baiTapTheoChuDe;

    return RefreshIndicator(
      onRefresh: () async {
        await p.layDanhSachChuDe(widget.lopHocPhanId);
        await p.layDanhSachBaiTap(widget.lopHocPhanId);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: nhom.entries.map((entry) {
          return _NhomChuDeSV(
            tenChuDe: entry.key,
            dsBaiTap: entry.value,
            lopHocPhanId: widget.lopHocPhanId,
          );
        }).toList(),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final ValueChanged<bool?> onChanged;

  const _TopicTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: selected,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
}

class _NhomChuDeSV extends StatelessWidget {
  final String tenChuDe;
  final List<BaiTapSVModel> dsBaiTap;
  final int lopHocPhanId;

  const _NhomChuDeSV({
    required this.tenChuDe,
    required this.dsBaiTap,
    required this.lopHocPhanId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.topic_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenChuDe,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
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
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '${dsBaiTap.length} bài',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...dsBaiTap.map(
            (bt) => _BaiTapCard(bt: bt, lopHocPhanId: lopHocPhanId),
          ),
        ],
      ),
    );
  }
}

class _BaiTapCard extends StatelessWidget {
  final BaiTapSVModel bt;
  final int lopHocPhanId;

  const _BaiTapCard({required this.bt, required this.lopHocPhanId});

  Color _mauTrangThai() {
    if (bt.laQuiz) {
      if (bt.daLamQuiz) return Colors.green;
      if (bt.daQuaHan) return Colors.red;
      return Colors.purple;
    }

    if (bt.daDuocNop) return Colors.green;
    if (bt.daQuaHan) return Colors.red;
    return Colors.orange;
  }

  Future<void> _moChiTiet(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChiTietBaiTapSV(baiTap: bt, lopHocPhanId: lopHocPhanId),
      ),
    );

    if (result == true && context.mounted) {
      await context.read<SinhVienProvider>().layDanhSachBaiTap(lopHocPhanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _mauTrangThai();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _moChiTiet(context),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        bt.laQuiz
                            ? Icons.quiz_rounded
                            : Icons.assignment_rounded,
                        color: color,
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
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              ChipTrangThai(
                                nhan: bt.tenTrangThaiNop,
                                mau: color,
                              ),
                              ChipTrangThai(
                                nhan: bt.tenLoaiBaiTap,
                                mau: bt.laQuiz ? Colors.purple : Colors.orange,
                              ),
                              if (bt.tenChuDe != null &&
                                  bt.tenChuDe!.isNotEmpty)
                                ChipTrangThai(
                                  nhan: bt.tenChuDe!,
                                  mau: Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                if (bt.moTa != null && bt.moTa!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    bt.moTa!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.event_available_rounded,
                        label: 'Hạn nộp',
                        value: dinhDangNgayGio(bt.hanNop),
                        color: bt.daQuaHan
                            ? Colors.red
                            : const Color(0xFF2563EB),
                      ),
                      if (bt.laQuiz && bt.thoiGianLam != null)
                        _InfoRow(
                          icon: Icons.timer_rounded,
                          label: 'Thời gian làm',
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
                      if (bt.laNopFile)
                        _InfoRow(
                          icon: Icons.rule_folder_rounded,
                          label: 'Yêu cầu',
                          value: bt.cauHinhNopFileTomTat,
                          color: const Color(0xFF7C3AED),
                        ),
                      if (!bt.laQuiz && bt.dsFileDaNopHienThi.isNotEmpty)
                        _InfoRow(
                          icon: Icons.attach_file_rounded,
                          label: 'File đã nộp',
                          value: _moTaFileDaNop(),
                          color: Colors.green,
                        ),
                      if (!bt.laQuiz && bt.diem != null)
                        _InfoRow(
                          icon: Icons.grade_rounded,
                          label: 'Điểm',
                          value:
                              '${bt.diem} • ${bt.nhanXet ?? 'Không có nhận xét'}',
                          color: Colors.green,
                        ),
                      if (bt.laQuiz && bt.diemQuiz != null)
                        _InfoRow(
                          icon: Icons.bar_chart_rounded,
                          label: 'Điểm quiz',
                          value: bt.diemQuiz!.toStringAsFixed(1),
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MiniMetric(
                      icon: bt.laQuiz
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      value: bt.laQuiz
                          ? (bt.daLamQuiz ? '1' : '0')
                          : (bt.daDuocNop ? '1' : '0'),
                      label: bt.laQuiz ? 'Đã làm' : 'Đã nộp',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _MiniMetric(
                      icon: bt.laQuiz
                          ? Icons.help_outline_rounded
                          : Icons.grade_rounded,
                      value: bt.laQuiz
                          ? '${bt.soCauHoi}'
                          : (bt.diem != null
                                ? bt.diem!.toStringAsFixed(1)
                                : '--'),
                      label: bt.laQuiz ? 'Số câu' : 'Điểm',
                      color: Colors.blue,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _moChiTiet(context),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Chi tiết'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Consumer<SinhVienProvider>(
                    builder: (context, provider, _) {
                      if (bt.laQuiz) {
                        return FilledButton.icon(
                          onPressed: bt.daDong || provider.btProcessing
                              ? null
                              : () async {
                                  if (bt.daLamQuiz) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => KetQuaQuizSV(
                                          baiTapId: bt.id,
                                          tieuDe: bt.tieuDe,
                                        ),
                                      ),
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LamQuizSV(
                                          baiTapId: bt.id,
                                          tieuDe: bt.tieuDe,
                                          thoiGianLam: bt.thoiGianLam,
                                          lopHocPhanId: lopHocPhanId,
                                        ),
                                      ),
                                    );

                                    if (result == true && context.mounted) {
                                      await context
                                          .read<SinhVienProvider>()
                                          .layDanhSachBaiTap(lopHocPhanId);
                                    }
                                  }
                                },
                          icon: Icon(
                            bt.daLamQuiz
                                ? Icons.bar_chart_rounded
                                : Icons.quiz_rounded,
                          ),
                          label: Text(
                            bt.daLamQuiz ? 'Xem kết quả' : 'Làm quiz',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        );
                      }

                      return FilledButton.icon(
                        onPressed: provider.btProcessing || !bt.coTheNopFile
                            ? null
                            : () => _chonVaNopFile(context),
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(
                          provider.btProcessing
                              ? 'Đang nộp...'
                              : bt.coTheNopFile
                              ? (bt.daDuocNop
                                    ? 'Nộp lại file'
                                    : 'Chọn file nộp')
                              : (bt.lyDoKhongTheNopFile ?? 'Không thể nộp'),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _moTaFileDaNop() {
    final files = bt.dsFileDaNopHienThi;
    if (files.isEmpty) return 'Chưa có file';
    if (files.length == 1) return files.first.tenHienThi;
    return '${files.length} file • ${files.first.tenHienThi}...';
  }

  String _dungLuongHienThi(int bytes) {
    if (bytes <= 0) return '';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 100 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 100 ? 1 : 0)} MB';
  }

  String _layDuoiFile(String nameOrPath) {
    final clean = nameOrPath.split('/').last.split('\\').last;
    final idx = clean.lastIndexOf('.');
    if (idx == -1 || idx == clean.length - 1) return '';
    return clean.substring(idx + 1).toLowerCase();
  }

  void _baoLoi(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<bool> _xacNhanDanhSachFile(
    BuildContext context,
    List<PlatformFile> files,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xác nhận nộp bài',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn sẽ nộp ${files.length}/${bt.soFileToiDa} file cho bài tập này.',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (_, i) {
                      final f = files[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.insert_drive_file_rounded,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    _dungLuongHienThi(f.size),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: const Text('Nộp bài'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return ok == true;
  }

  Future<void> _chonVaNopFile(BuildContext context) async {
    if (!bt.coTheNopFile) {
      _baoLoi(context, bt.lyDoKhongTheNopFile ?? 'Không thể nộp bài');
      return;
    }

    final allowed = bt.dsDinhDangChoPhep;
    // CSDL host Web đã gộp bai_nop_file vào bai_nop, nên mỗi bài nộp chỉ lưu 1 file.
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: allowed.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: allowed.isEmpty ? null : allowed,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final files = result.files.where((f) => f.path != null).toList();
    if (files.isEmpty) {
      if (context.mounted) _baoLoi(context, 'Không lấy được đường dẫn file');
      return;
    }

    if (files.length > 1) {
      if (context.mounted) {
        _baoLoi(context, 'Hệ thống hiện chỉ hỗ trợ nộp 1 file cho mỗi bài.');
      }
      return;
    }

    final maxBytes = bt.dungLuongToiDaMb * 1024 * 1024;
    for (final f in files) {
      if (allowed.isNotEmpty && !allowed.contains(_layDuoiFile(f.name))) {
        if (context.mounted) {
          _baoLoi(
            context,
            'File ${f.name} không đúng định dạng cho phép: ${bt.dinhDangChoPhepHienThi}',
          );
        }
        return;
      }

      if (f.size > maxBytes) {
        if (context.mounted) {
          _baoLoi(context, 'File ${f.name} vượt quá ${bt.dungLuongToiDaMb}MB');
        }
        return;
      }
    }

    if (!context.mounted) return;
    final confirmed = await _xacNhanDanhSachFile(context, files);
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final rs = await context.read<SinhVienProvider>().nopBaiNhieuFile(
      baiTapId: bt.id,
      filePaths: files.map((e) => e.path!).toList(),
      lopHocPhanId: lopHocPhanId,
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(rs['message'].toString()),
        backgroundColor: rs['success'] == true ? Colors.green : Colors.red,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
