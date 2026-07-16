import 'package:flutter/material.dart';

import '../../model/giang_vien_model.dart';
import '../../widget/widget_chung_giangvien.dart';

class ChiTietBaiTapGiangVien extends StatelessWidget {
  final LopHocPhan lop;
  final BaiTap baiTap;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onViewSubmissions;

  const ChiTietBaiTapGiangVien({
    super.key,
    required this.lop,
    required this.baiTap,
    this.onEdit,
    this.onDelete,
    this.onViewSubmissions,
  });

  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final typeColor = baiTap.laQuiz ? const Color(0xFF9333EA) : const Color(0xFFF97316);
    final hanColor = baiTap.daQuaHan ? Colors.red : const Color(0xFF16A34A);
    final guiColor = baiTap.daHenGio ? const Color(0xFFF97316) : const Color(0xFF16A34A);

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
        actions: [
          if (onEdit != null || onDelete != null) PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'sua') {
                await onEdit?.call();
              } else if (value == 'xoa') {
                await onDelete?.call();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'sua',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'xoa',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: FilledButton.icon(
            onPressed: onViewSubmissions == null
                ? null
                : () async {
                    await onViewSubmissions!.call();
                  },
            icon: Icon(baiTap.laQuiz ? Icons.bar_chart_rounded : Icons.upload_file_rounded),
            label: Text(baiTap.laQuiz ? 'Xem kết quả quiz' : 'Xem bài nộp'),
            style: FilledButton.styleFrom(
              backgroundColor: typeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _HeroCard(
            title: baiTap.tieuDe,
            subtitle: lop.tenHienThi,
            icon: baiTap.laQuiz ? Icons.quiz_rounded : Icons.assignment_rounded,
            color: typeColor,
            tags: [
              _InfoChip(
                icon: baiTap.laQuiz ? Icons.quiz_rounded : Icons.upload_file_rounded,
                text: baiTap.tenLoaiBaiTap,
                color: typeColor,
              ),
              _InfoChip(
                icon: baiTap.daHenGio ? Icons.schedule_send_rounded : Icons.visibility_rounded,
                text: baiTap.tenTrangThaiGui,
                color: guiColor,
              ),
              _InfoChip(
                icon: baiTap.isDangMo ? Icons.lock_open_rounded : Icons.lock_rounded,
                text: baiTap.tenTrangThai,
                color: baiTap.isDangMo ? const Color(0xFF16A34A) : _muted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: baiTap.laQuiz ? Icons.people_alt_rounded : Icons.upload_file_rounded,
                  label: baiTap.laQuiz ? 'Đã làm' : 'Đã nộp',
                  value: '${baiTap.soBaiNop}',
                  color: _primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: baiTap.laQuiz ? Icons.help_outline_rounded : Icons.grading_rounded,
                  label: baiTap.laQuiz ? 'Số câu' : 'Đã chấm',
                  value: baiTap.laQuiz ? '${baiTap.soCauHoi}' : '${baiTap.soDaCham}',
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  icon: baiTap.laQuiz ? Icons.score_rounded : Icons.pending_actions_rounded,
                  label: baiTap.laQuiz ? 'Đã chấm' : 'Chờ chấm',
                  value: baiTap.laQuiz ? '${baiTap.soDaCham}' : '${baiTap.soChooCham}',
                  color: baiTap.laQuiz ? const Color(0xFF9333EA) : const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Thông tin thời gian',
            icon: Icons.schedule_rounded,
            children: [
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Hạn nộp',
                value: baiTap.hanNop == null
                    ? 'Không giới hạn'
                    : '${dinhDangNgayGio(baiTap.hanNop)}${baiTap.daQuaHan ? ' · đã quá hạn' : ''}',
                color: hanColor,
              ),
              _InfoRow(
                icon: baiTap.daHenGio ? Icons.schedule_send_rounded : Icons.send_rounded,
                label: 'Thời gian gửi',
                value: baiTap.thoiGianGui == null
                    ? 'Gửi ngay'
                    : '${baiTap.tenTrangThaiGui}: ${dinhDangNgayGio(baiTap.thoiGianGui)}',
                color: guiColor,
              ),
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                label: 'Ngày tạo',
                value: dinhDangNgayGio(baiTap.ngayTao),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Yêu cầu bài tập',
            icon: Icons.description_rounded,
            children: [
              Text(
                (baiTap.moTa == null || baiTap.moTa!.trim().isEmpty)
                    ? 'Chưa có mô tả hoặc yêu cầu chi tiết.'
                    : baiTap.moTa!,
                style: const TextStyle(
                  color: _text,
                  height: 1.45,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Thông tin bổ sung',
            icon: Icons.info_outline_rounded,
            children: [
              _InfoRow(
                icon: Icons.topic_rounded,
                label: 'Chủ đề',
                value: (baiTap.tenChuDe == null || baiTap.tenChuDe!.trim().isEmpty)
                    ? 'Chưa phân loại'
                    : baiTap.tenChuDe!,
                color: _primary,
              ),
              _InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Người tạo',
                value: baiTap.tenNguoiTao ?? 'Chưa cập nhật',
              ),
              _InfoRow(
                icon: Icons.attach_file_rounded,
                label: 'File đính kèm',
                value: (baiTap.duongDanFile == null || baiTap.duongDanFile!.trim().isEmpty)
                    ? 'Không có file đính kèm'
                    : baiTap.duongDanFile!,
                color: const Color(0xFF0D9488),
              ),
              if (baiTap.laQuiz) ...[
                _InfoRow(
                  icon: Icons.timer_rounded,
                  label: 'Thời gian làm',
                  value: baiTap.thoiGianLam == null ? 'Không giới hạn' : '${baiTap.thoiGianLam} phút',
                  color: _primary,
                ),
                _InfoRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Số câu hỏi',
                  value: '${baiTap.soCauHoi} câu',
                  color: const Color(0xFF0D9488),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> tags;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.95), color.withOpacity(0.78), const Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: tags),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
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
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w800, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
