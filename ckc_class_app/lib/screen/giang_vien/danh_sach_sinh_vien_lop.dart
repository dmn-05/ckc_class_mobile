import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/giang_vien_model.dart';
import '../../provider/giang_vien_provider.dart';
import '../../widget/widget_chung_giangvien.dart';

class DanhSachSinhVienLop extends StatefulWidget {
  final LopHocPhan lop;
  const DanhSachSinhVienLop({super.key, required this.lop});

  @override
  State<DanhSachSinhVienLop> createState() => _DanhSachSinhVienLopState();
}

class _DanhSachSinhVienLopState extends State<DanhSachSinhVienLop> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _timKiemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GiangVienProvider>().layDanhSachSinhVien(widget.lop.id);
    });
  }

  @override
  void dispose() {
    _timKiemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: Consumer<GiangVienProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTimKiem(provider),
              Expanded(child: _buildDanhSach(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimKiem(GiangVienProvider provider) {
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.people_alt_rounded, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _timKiemController,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tìm họ tên, mã SV, email...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _timKiemController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _timKiemController.clear();
                          provider.layDanhSachSinhVien(widget.lop.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _primary, width: 1.3),
                ),
              ),
              onChanged: (v) {
                setState(() {});
                provider.layDanhSachSinhVien(widget.lop.id, tuKhoa: v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanhSach(GiangVienProvider provider) {
    if (provider.svLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.svError != null) {
      return TrangThaiLoi(
        loi: provider.svError!,
        onTaiLai: () => provider.layDanhSachSinhVien(widget.lop.id),
      );
    }
    if (provider.dsSinhVienLop.isEmpty) {
      return const TrangThaiRong(
        thongDiep: 'Chưa có sinh viên nào trong lớp này',
        icon: Icons.people_outline,
      );
    }

    final daCoDiem = provider.dsSinhVienLop
        .where((e) => e.diemTrungBinh != null)
        .length;
    final tongDaNop = provider.dsSinhVienLop.fold<int>(
      0,
      (sum, sv) => sum + sv.soBaiDaNop,
    );

    return RefreshIndicator(
      onRefresh: () => provider.layDanhSachSinhVien(widget.lop.id),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: provider.dsSinhVienLop.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SummaryCard(
              count: provider.dsSinhVienLop.length,
              submitted: tongDaNop,
              scored: daCoDiem,
            );
          }
          final sv = provider.dsSinhVienLop[index - 1];
          return _buildTheSinhVien(sv, index);
        },
      ),
    );
  }

  Widget _buildTheSinhVien(SinhVienLop sv, int stt) {
    final tenGioiTinh = switch (sv.gioiTinh) {
      'nam' => 'Nam',
      'nu' => 'Nữ',
      _ => null,
    };

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
                      '$stt',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
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
                        sv.hoTen,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sv.maSinhVien} • ${sv.email}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Xem chi tiết',
                  icon: const Icon(Icons.info_outline_rounded, color: _primary),
                  onPressed: () => _hienChiTiet(sv),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (sv.tenLop != null)
                  _TinyChip(
                    icon: Icons.groups_rounded,
                    label: sv.tenLop!,
                    color: _primary,
                  ),
                if (tenGioiTinh != null)
                  _TinyChip(
                    icon: Icons.person_rounded,
                    label: tenGioiTinh,
                    color: const Color(0xFF0D9488),
                  ),
                _TinyChip(
                  icon: Icons.assignment_turned_in_rounded,
                  label: 'Đã nộp ${sv.soBaiDaNop}',
                  color: const Color(0xFF16A34A),
                ),
                if (sv.diemTrungBinh != null)
                  _TinyChip(
                    icon: Icons.star_rounded,
                    label: 'TB ${sv.diemTrungBinh!.toStringAsFixed(1)}',
                    color: const Color(0xFFF97316),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _hienChiTiet(SinhVienLop sv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _primary.withOpacity(0.10),
              child: Text(
                sv.hoTen.isNotEmpty ? sv.hoTen[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sv.hoTen,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dongInfo('Mã sinh viên', sv.maSinhVien),
            _dongInfo('Email', sv.email),
            if (sv.tenLop != null) _dongInfo('Lớp', sv.tenLop!),
            if (sv.soDienThoai != null)
              _dongInfo('Điện thoại', sv.soDienThoai!),
            _dongInfo('Ngày đăng ký', dinhDangNgay(sv.ngayDangKy)),
            _dongInfo('Bài đã nộp', '${sv.soBaiDaNop}'),
            if (sv.diemTrungBinh != null)
              _dongInfo(
                'Điểm trung bình',
                sv.diemTrungBinh!.toStringAsFixed(2),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _dongInfo(String nhan, String giaTri) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              '$nhan:',
              style: const TextStyle(fontWeight: FontWeight.w800, color: _text),
            ),
          ),
          Expanded(
            child: Text(
              giaTri,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final int submitted;
  final int scored;

  const _SummaryCard({
    required this.count,
    required this.submitted,
    required this.scored,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              value: '$count',
              label: 'Sinh viên',
              color: _DanhSachSinhVienLopState._primary,
              icon: Icons.people_alt_rounded,
            ),
          ),
          Expanded(
            child: _MiniStat(
              value: '$submitted',
              label: 'Bài nộp',
              color: const Color(0xFF16A34A),
              icon: Icons.cloud_done_rounded,
            ),
          ),
          Expanded(
            child: _MiniStat(
              value: '$scored',
              label: 'Có điểm',
              color: const Color(0xFFF97316),
              icon: Icons.star_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _DanhSachSinhVienLopState._muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TinyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TinyChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
