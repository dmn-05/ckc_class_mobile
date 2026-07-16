import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/quiz_model.dart';
import '../../provider/quiz_provider.dart';
import '../../utils/modal_lifecycle.dart';
import '../../widget/widget_chung_giangvien.dart';

class KetQuaQuizGiangVien extends StatefulWidget {
  final int baiTapId;
  final String tieuDe;
  final bool chiDoc;

  const KetQuaQuizGiangVien({
    super.key,
    required this.baiTapId,
    required this.tieuDe,
    this.chiDoc = false,
  });

  @override
  State<KetQuaQuizGiangVien> createState() => _KetQuaQuizGiangVienState();
}

class _KetQuaQuizGiangVienState extends State<KetQuaQuizGiangVien> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().layKetQuaQuizGiangVien(widget.baiTapId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        title: Text(
          widget.tieuDe,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.loading)
            return const Center(child: CircularProgressIndicator());
          if (provider.error != null) {
            return TrangThaiLoi(
              loi: provider.error!,
              onTaiLai: () => provider.layKetQuaQuizGiangVien(widget.baiTapId),
            );
          }
          if (provider.ketQuaGV.isEmpty) {
            return const TrangThaiRong(
              thongDiep: 'Chưa có sinh viên làm quiz',
              icon: Icons.quiz_outlined,
            );
          }
          return _buildDanhSach(provider.ketQuaGV);
        },
      ),
    );
  }

  Widget _buildDanhSach(List<KetQuaQuizGV> ds) {
    final daNop = ds
        .where((e) =>
            e.trangThai == 'da_nop' ||
            e.trangThai == 'da_cham' ||
            e.trangThai == 'qua_han')
        .length;
    final coDiem = ds.where((e) => e.diem != null).toList();
    final diemTB = coDiem.isEmpty
        ? null
        : coDiem.map((e) => e.diem!).reduce((a, b) => a + b) / coDiem.length;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<QuizProvider>().layKetQuaQuizGiangVien(widget.baiTapId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _HeroResultCard(daNop: daNop, tong: ds.length, diemTB: diemTB),
          const SizedBox(height: 14),
          const Text(
            'Danh sách bài làm',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: _text,
            ),
          ),
          const SizedBox(height: 10),
          ...ds.map(_buildTheKetQua),
        ],
      ),
    );
  }

  Widget _buildTheKetQua(KetQuaQuizGV kq) {
    final mau = kq.trangThai == 'qua_han'
        ? const Color(0xFFF97316)
        : (kq.trangThai == 'da_nop' || kq.trangThai == 'da_cham')
        ? const Color(0xFF16A34A)
        : const Color(0xFF64748B);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      kq.hoTen.isNotEmpty ? kq.hoTen[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kq.hoTen,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kq.maSinhVien,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ChipTrangThai(
                  nhan: kq.tenTrangThai,
                  mau: mau,
                  icon: Icons.info_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _mini(
                    '${kq.soCauDung}/${kq.tongCau}',
                    'Đúng',
                    Icons.check_circle_rounded,
                    const Color(0xFF16A34A),
                  ),
                ),
                Expanded(
                  child: _mini(
                    kq.diem == null
                        ? '--'
                        : '${kq.diem!.toStringAsFixed(1)}/${kq.diemToiDa.toStringAsFixed(1)}',
                    'Điểm',
                    Icons.star_rounded,
                    const Color(0xFFF97316),
                  ),
                ),
                Expanded(
                  child: _mini(
                    kq.thoiGianNop == null
                        ? '--'
                        : dinhDangNgayGio(kq.thoiGianNop),
                    'Nộp lúc',
                    Icons.schedule_rounded,
                    _primary,
                  ),
                ),
              ],
            ),
            if (kq.soCauTuLuan > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, color: _primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tự luận: ${kq.diemTuLuan.toStringAsFixed(1)} điểm'
                        '${kq.canChamTuLuan ? ' · cần chấm' : ''}',
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _moChamTuLuan(kq),
                      child: Text(widget.chiDoc ? 'Xem' : (kq.canChamTuLuan ? 'Chấm' : 'Xem')),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Future<void> _moChamTuLuan(KetQuaQuizGV kq) async {
    final provider = context.read<QuizProvider>();
    await provider.layChiTietBaiLamQuizGiangVien(kq.baiLamQuizId);
    if (!mounted) return;
    final detail = provider.chiTietBaiLamGV;
    if (detail == null) {
      final msg = provider.error ?? 'Không lấy được chi tiết tự luận';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final controllers = <int, TextEditingController>{};
    for (final q in detail.cauHoiTuLuan) {
      controllers[q.cauHoiId] = TextEditingController(
        text: q.diemDat.toStringAsFixed(q.diemDat == q.diemDat.roundToDouble() ? 0 : 1),
      );
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.86,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chấm tự luận - ${detail.hoTen}',
                    style: const TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${detail.maSinhVien} · Trắc nghiệm ${detail.diemTracNghiem.toStringAsFixed(1)} điểm',
                    style: const TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 14),
                  if (detail.cauHoiTuLuan.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Bài làm này không có câu tự luận')),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: detail.cauHoiTuLuan.length,
                        itemBuilder: (_, i) {
                          final q = detail.cauHoiTuLuan[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Câu ${i + 1}: ${q.noiDung}',
                                  style: const TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  q.dapAnTuLuan?.isNotEmpty == true
                                      ? q.dapAnTuLuan!
                                      : 'Sinh viên chưa nhập câu trả lời',
                                  style: const TextStyle(color: Color(0xFF334155), height: 1.35),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: controllers[q.cauHoiId],
                                  readOnly: widget.chiDoc,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Điểm / ${q.diemToiDa.toStringAsFixed(1)}',
                                    prefixIcon: const Icon(Icons.grade_rounded),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.chiDoc || detail.cauHoiTuLuan.isEmpty
                          ? null
                          : () async {
                              final scores = <int, double>{};
                              for (final q in detail.cauHoiTuLuan) {
                                final text = controllers[q.cauHoiId]?.text.trim() ?? '0';
                                final score = double.tryParse(text.replaceAll(',', '.'));
                                if (score == null || score < 0 || score > q.diemToiDa) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Điểm câu ${q.cauHoiId} phải từ 0 đến ${q.diemToiDa}',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                scores[q.cauHoiId] = score;
                              }
                              final res = await provider.chamTuLuan(
                                baiLamQuizId: detail.baiLamQuizId,
                                diemTheoCauHoi: scores,
                              );
                              if (!mounted || !ctx.mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(res['message']?.toString() ?? 'Đã xử lý')),
                              );
                              if (res['success'] == true) {
                                unfocusCurrentInput();
                                Navigator.of(ctx).pop(true);
                              }
                            },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Lưu điểm tự luận'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await disposeControllersAfterModal(controllers.values);

    if (saved == true && mounted) {
      await context.read<QuizProvider>().layKetQuaQuizGiangVien(widget.baiTapId);
    }
  }

  Widget _mini(String giaTri, String nhan, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          giaTri,
          style: const TextStyle(fontWeight: FontWeight.w900, color: _text),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
}

class _HeroResultCard extends StatelessWidget {
  final int daNop;
  final int tong;
  final double? diemTB;

  const _HeroResultCard({
    required this.daNop,
    required this.tong,
    required this.diemTB,
  });

  @override
  Widget build(BuildContext context) {
    final tiLe = tong == 0 ? 0.0 : daNop / tong;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kết quả quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: tiLe,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroMini(value: '$daNop/$tong', label: 'Đã nộp'),
              ),
              Expanded(
                child: _HeroMini(
                  value: diemTB == null ? '--' : diemTB!.toStringAsFixed(1),
                  label: 'Điểm TB',
                ),
              ),
              Expanded(
                child: _HeroMini(value: '$tong', label: 'Bài làm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMini({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
