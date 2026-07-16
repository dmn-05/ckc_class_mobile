import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/quiz_model.dart';
import '../../provider/quiz_provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';
import 'ket_qua_quiz_sv.dart';

class LamQuizSV extends StatefulWidget {
  final int baiTapId;
  final String tieuDe;
  final int? thoiGianLam;
  final int? lopHocPhanId;

  const LamQuizSV({
    super.key,
    required this.baiTapId,
    required this.tieuDe,
    this.thoiGianLam,
    this.lopHocPhanId,
  });

  @override
  State<LamQuizSV> createState() => _LamQuizSVState();
}

class _LamQuizSVState extends State<LamQuizSV> {
  final Map<int, Set<int>> _chon = {};
  final Map<int, String> _tuLuan = {};
  Timer? _dongHo;
  int? _soGiayConLai;
  bool _dangTuDongNop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _taiQuiz());
  }

  Future<void> _taiQuiz() async {
    _dongHo?.cancel();
    final sv = context.read<SinhVienProvider>();
    final provider = context.read<QuizProvider>();
    await provider.batDauVaLayQuizSinhVien(
      sinhVienId: sv.sinhVienId,
      baiTapId: widget.baiTapId,
    );
    if (!mounted || provider.deQuiz == null) return;
    _batDauDongHo(provider.deQuiz!);
  }

  void _batDauDongHo(DeQuiz de) {
    _dongHo?.cancel();
    final soGiay = de.thoiGianConLaiGiay;
    if (soGiay == null) return;
    setState(() => _soGiayConLai = soGiay.clamp(0, 864000).toInt());
    if (_soGiayConLai == 0) {
      _tuDongNopKhiHetGio();
      return;
    }
    _dongHo = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = (_soGiayConLai ?? 0) - 1;
      setState(() => _soGiayConLai = next < 0 ? 0 : next);
      if (next <= 0) {
        timer.cancel();
        _tuDongNopKhiHetGio();
      }
    });
  }

  Future<void> _tuDongNopKhiHetGio() async {
    if (_dangTuDongNop || !mounted) return;
    _dangTuDongNop = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hết thời gian. Hệ thống đang tự động nộp bài.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _nopQuiz(tuDong: true);
  }

  String _dinhDangConLai(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final hours = safe ~/ 3600;
    final minutes = (safe % 3600) ~/ 60;
    final secs = safe % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    super.dispose();
  }

  int _soCauDaLam(DeQuiz de) {
    return de.cauHoi.where((c) {
      if (c.laTuLuan) return (_tuLuan[c.id]?.trim().isNotEmpty ?? false);
      return (_chon[c.id] ?? {}).isNotEmpty;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(widget.tieuDe, overflow: TextOverflow.ellipsis),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.loading)
            return const Center(child: CircularProgressIndicator());
          if (provider.error != null) return _buildLoi(provider.error!);

          final de = provider.deQuiz;
          if (de == null) {
            return const TrangRong(
              thongDiep: 'Không tải được quiz',
              icon: Icons.quiz_outlined,
            );
          }
          return _buildNoiDung(de, provider);
        },
      ),
      bottomNavigationBar: Consumer<QuizProvider>(
        builder: (_, provider, __) {
          final de = provider.deQuiz;
          if (de == null || provider.error != null)
            return const SizedBox.shrink();
          final done = _soCauDaLam(de);
          final total = de.cauHoi.length;
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiến độ làm bài',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$done/$total câu đã chọn',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: provider.processing
                        ? null
                        : () => _xacNhanNop(de),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: provider.processing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(provider.processing ? 'Đang nộp' : 'Nộp bài'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoi(String loi) {
    final daNop =
        loi.toLowerCase().contains('đã nộp') ||
        loi.toLowerCase().contains('da nop');
    final color = daNop ? Colors.green : Colors.red;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE8EEF8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  daNop ? Icons.task_alt_rounded : Icons.error_outline_rounded,
                  size: 42,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                daNop ? 'Bạn đã nộp bài này' : 'Không thể tải quiz',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loi,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 18),
              if (daNop)
                FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KetQuaQuizSV(
                        baiTapId: widget.baiTapId,
                        tieuDe: widget.tieuDe,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Xem kết quả'),
                )
              else
                OutlinedButton.icon(
                  onPressed: _taiQuiz,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoiDung(DeQuiz de, QuizProvider provider) {
    final done = _soCauDaLam(de);
    final total = de.cauHoi.length;
    final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(.76),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.quiz_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      de.tieuDe,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (de.moTa != null && de.moTa!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  de.moTa!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Đã hoàn thành $done/$total câu',
                style: TextStyle(
                  color: Colors.white.withOpacity(.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.quiz_outlined, '${de.cauHoi.length} câu'),
                  if (_soGiayConLai != null)
                    _chip(
                      Icons.timer_rounded,
                      'Còn ${_dinhDangConLai(_soGiayConLai!)}',
                    ),
                  if (_soGiayConLai == null && de.thoiGianLam != null)
                    _chip(Icons.timer_outlined, '${de.thoiGianLam} phút'),
                  if (de.hanNop != null)
                    _chip(Icons.event_outlined, dinhDangNgayGio(de.hanNop)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          de.cauHoi.length,
          (i) => _buildCauHoi(i, de.cauHoi[i]),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCauHoi(int index, CauHoiQuiz cauHoi) {
    final selected = _chon[cauHoi.id] ?? <int>{};
    final daLam = cauHoi.laTuLuan ? (_tuLuan[cauHoi.id]?.trim().isNotEmpty ?? false) : selected.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: daLam ? Colors.blue.withOpacity(.18) : const Color(0xFFE8EEF8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: daLam
                        ? Colors.blue.withOpacity(.12)
                        : Colors.grey.withOpacity(.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: daLam
                          ? Colors.blue.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cauHoi.noiDung,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChipTrangThai(
                  nhan:
                      '${cauHoi.diem.toStringAsFixed(cauHoi.diem.truncateToDouble() == cauHoi.diem ? 0 : 1)} điểm',
                  mau: Colors.orange,
                  icon: Icons.star_rounded,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ChipTrangThai(
              nhan: cauHoi.tenLoaiCauHoi,
              mau: cauHoi.laTuLuan ? Colors.teal : (cauHoi.laNhieuDapAn ? Colors.purple : Colors.blue),
              icon: cauHoi.laTuLuan
                  ? Icons.edit_note_rounded
                  : (cauHoi.laNhieuDapAn
                      ? Icons.checklist_rounded
                      : Icons.radio_button_checked_rounded),
            ),
            const SizedBox(height: 12),
            if (cauHoi.laTuLuan)
              TextField(
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Nhập câu trả lời tự luận...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                onChanged: (v) => _tuLuan[cauHoi.id] = v,
              )
            else
            ...cauHoi.dapAn.map((da) {
              final isSelected = selected.contains(da.id);
              final selectedColor = Theme.of(context).colorScheme.primary;
              if (cauHoi.laNhieuDapAn) {
                return _AnswerContainer(
                  selected: isSelected,
                  child: CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: isSelected,
                    activeColor: selectedColor,
                    dense: true,
                    onChanged: (v) {
                      setState(() {
                        final set = _chon.putIfAbsent(cauHoi.id, () => <int>{});
                        if (v == true) {
                          set.add(da.id);
                        } else {
                          set.remove(da.id);
                        }
                      });
                    },
                    title: Text(
                      da.noiDung,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }
              return _AnswerContainer(
                selected: isSelected,
                child: RadioListTile<int>(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  value: da.id,
                  groupValue: selected.isEmpty ? null : selected.first,
                  activeColor: selectedColor,
                  dense: true,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _chon[cauHoi.id] = {v});
                  },
                  title: Text(
                    da.noiDung,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _xacNhanNop(DeQuiz de) async {
    final chuaLam = de.cauHoi.where((c) {
      if (c.laTuLuan) return _tuLuan[c.id]?.trim().isEmpty ?? true;
      return (_chon[c.id] ?? {}).isEmpty;
    }).length;
    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nộp quiz'),
        content: Text(
          chuaLam > 0
              ? 'Bạn còn $chuaLam câu chưa chọn đáp án. Vẫn nộp bài?'
              : 'Bạn chắc chắn muốn nộp bài?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (dongY == true) await _nopQuiz();
  }

  Future<void> _nopQuiz({bool tuDong = false}) async {
    final sv = context.read<SinhVienProvider>();
    final result = await context.read<QuizProvider>().nopQuizSinhVien(
      sinhVienId: sv.sinhVienId,
      baiTapId: widget.baiTapId,
      dapAnTheoCauHoi: _chon,
      dapAnTuLuanTheoCauHoi: _tuLuan,
    );

    if (!mounted) return;
    if (result['success'] != true) _dangTuDongNop = false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tuDong && result['success'] == true
              ? 'Đã hết giờ và nộp bài thành công'
              : (result['message'] ?? ''),
        ),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result['success'] == true) {
      _dongHo?.cancel();
      if (widget.lopHocPhanId != null) {
        await context.read<SinhVienProvider>().layDanhSachBaiTap(
          widget.lopHocPhanId!,
        );
        await context.read<SinhVienProvider>().layBaiTapChuaNop();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              KetQuaQuizSV(baiTapId: widget.baiTapId, tieuDe: widget.tieuDe),
        ),
      );
    }
  }
}

class _AnswerContainer extends StatelessWidget {
  final bool selected;
  final Widget child;

  const _AnswerContainer({required this.selected, required this.child});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(.08) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color.withOpacity(.35) : const Color(0xFFE8EEF8),
        ),
      ),
      child: child,
    );
  }
}
