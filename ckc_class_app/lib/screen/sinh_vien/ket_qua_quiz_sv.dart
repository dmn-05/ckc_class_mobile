import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/quiz_model.dart';
import '../../provider/quiz_provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class KetQuaQuizSV extends StatefulWidget {
  final int baiTapId;
  final String? tieuDe;

  const KetQuaQuizSV({super.key, required this.baiTapId, this.tieuDe});

  @override
  State<KetQuaQuizSV> createState() => _KetQuaQuizSVState();
}

class _KetQuaQuizSVState extends State<KetQuaQuizSV> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taiLai();
    });
  }

  void _taiLai() {
    final sv = context.read<SinhVienProvider>();
    context.read<QuizProvider>().layKetQuaQuizSinhVien(
      sinhVienId: sv.sinhVienId,
      baiTapId: widget.baiTapId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(widget.tieuDe ?? 'Kết quả quiz'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return TrangLoi(loi: provider.error!, onTaiLai: _taiLai);
          }

          final kq = provider.ketQuaSV;
          if (kq == null) {
            return const TrangRong(
              thongDiep: 'Chưa có kết quả quiz',
              icon: Icons.quiz_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _taiLai(),
            child: _buildKetQua(kq),
          );
        },
      ),
    );
  }

  Widget _buildKetQua(KetQuaQuizSVModel kq) {
    final diemText = kq.diem == null ? '--' : kq.diem!.toStringAsFixed(1);
    final color = _mauDiem(kq.diem);
    final tyLe = kq.tongCau == 0
        ? 0.0
        : (kq.soCauDung / kq.tongCau).clamp(0.0, 1.0);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(.74)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                kq.tieuDe,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                diemText,
                style: const TextStyle(
                  fontSize: 54,
                  height: .95,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'điểm • ${kq.tenTrangThai}',
                style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: tyLe,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.check_circle_outline,
                value: '${kq.soCauDung}/${kq.tongCau}',
                label: 'Số câu đúng',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                icon: Icons.schedule_rounded,
                value: kq.thoiGianNop == null
                    ? '--'
                    : dinhDangNgayGio(kq.thoiGianNop),
                label: 'Thời gian nộp',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (!kq.choXemDapAn)
          _NoticeCard(
            icon: Icons.lock_outline,
            title: 'Chưa mở đáp án chi tiết',
            message:
                'Giảng viên chưa bật quyền xem đáp án. Bạn có thể quay lại sau khi được mở quyền.',
          )
        else ...[
          const _SectionTitle(
            title: 'Chi tiết đáp án',
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 10),
          ...List.generate(
            kq.chiTiet.length,
            (i) => _buildChiTiet(i, kq.chiTiet[i]),
          ),
        ],
      ],
    );
  }

  Color _mauDiem(double? diem) {
    if (diem == null) return Colors.blue;
    if (diem >= 8) return Colors.green;
    if (diem >= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildChiTiet(int index, CauHoiQuiz cauHoi) {
    final ok = cauHoi.dung;
    final color = ok ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ok
              ? Colors.green.withOpacity(.18)
              : Colors.red.withOpacity(.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  ok ? Icons.check_rounded : Icons.close_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Câu ${index + 1}: ${cauHoi.noiDung}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (cauHoi.laTuLuan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueGrey.withOpacity(.16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Câu trả lời tự luận của bạn',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cauHoi.dapAnTuLuan?.isNotEmpty == true
                        ? cauHoi.dapAnTuLuan!
                        : 'Bạn chưa nhập câu trả lời',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.35),
                  ),
                  if (cauHoi.giaiThich?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Gợi ý/giải thích: ${cauHoi.giaiThich}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            )
          else
            ...cauHoi.dapAn.map((da) {
              Color? answerColor;
              IconData icon = Icons.radio_button_unchecked_rounded;
              FontWeight weight = FontWeight.w500;

              if (da.laDapAnDung) {
                answerColor = Colors.green;
                icon = Icons.check_circle_rounded;
                weight = FontWeight.w700;
              } else if (da.duocChon) {
                answerColor = Colors.red;
                icon = Icons.cancel_rounded;
                weight = FontWeight.w700;
              }

              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: (answerColor ?? Colors.grey).withOpacity(
                    answerColor == null ? .06 : .1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (answerColor ?? Colors.grey).withOpacity(
                      answerColor == null ? .12 : .25,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: answerColor ?? Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        da.noiDung,
                        style: TextStyle(color: answerColor, fontWeight: weight),
                      ),
                    ),
                    if (da.duocChon)
                      ChipTrangThai(
                        nhan: 'Đã chọn',
                        mau: answerColor ?? Colors.blue,
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
