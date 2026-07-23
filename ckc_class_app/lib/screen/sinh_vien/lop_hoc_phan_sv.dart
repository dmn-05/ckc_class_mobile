import 'dart:async';
import 'package:ckc_class_app/provider/xac_thuc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';
import 'chi_tiet_lop_sv.dart';

class LopHocPhanSV extends StatefulWidget {
  final bool chiLuuTru;

  const LopHocPhanSV({super.key, this.chiLuuTru = false});

  @override
  State<LopHocPhanSV> createState() => _LopHocPhanSVState();
}

class _LopHocPhanSVState extends State<LopHocPhanSV> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _tkCtrl = TextEditingController();
  Timer? _debounce;
  bool _moBoLoc = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final provider = context.read<SinhVienProvider>();

      if (provider.sinhVienId <= 0) {
        final nguoiDungId = auth.user?.id ?? 0;

        if (nguoiDungId <= 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy tài khoản đăng nhập'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final result = await provider.khoiTaoTuNguoiDungId(nguoiDungId);

        if (!mounted) return;

        if (result['success'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Chưa khởi tạo ID sinh viên'),
              backgroundColor: Colors.red,
            ),
          );
        }

        return;
      }

      await provider.layDanhSachLop(trangThai: '');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          widget.chiLuuTru ? 'Lưu trữ' : 'Lớp học phần',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: _bg,
        surfaceTintColor: _bg,
        elevation: 0,
        actions: [
          Consumer<SinhVienProvider>(
            builder: (_, provider, __) => IconButton(
              tooltip: 'Tải lại',
              onPressed: provider.lopLoading
                  ? null
                  : () => provider.layDanhSachLop(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<SinhVienProvider>(
        builder: (ctx, provider, _) => Column(
          children: [
            _buildBoLoc(provider),
            Expanded(child: _buildDanhSach(provider)),
          ],
        ),
      ),
    );
  }

  int _demBoLoc(SinhVienProvider provider) {
    var count = 0;
    if (provider.lopNamHoc.isNotEmpty) count++;
    if (provider.lopHocKy.isNotEmpty) count++;
    return count;
  }

  void _timKiem(SinhVienProvider provider, String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      provider.layDanhSachLop(tuKhoa: value.trim());
    });
  }

  Widget _buildBoLoc(SinhVienProvider provider) {
    final soBoLoc = _demBoLoc(provider);
    final dangCoBoLoc = soBoLoc > 0 || _tkCtrl.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.manage_search_rounded, color: _primary),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tìm kiếm & lọc',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _text,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tìm nhanh, mở bộ lọc khi cần',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _tkCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    hintText: 'Tìm kiếm lớp, mã lớp hoặc môn học',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _tkCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _tkCtrl.clear();
                              provider.layDanhSachLop(tuKhoa: '');
                              setState(() {});
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: _primary, width: 1.4),
                    ),
                  ),
                  onChanged: (v) => _timKiem(provider, v),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _moBoLoc = !_moBoLoc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: _moBoLoc ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _moBoLoc ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded, color: _moBoLoc ? _primary : _muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _moBoLoc ? 'Đóng bộ lọc' : 'Mở bộ lọc',
                            style: TextStyle(
                              color: _moBoLoc ? _primary : _text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (soBoLoc > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$soBoLoc',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _moBoLoc ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _moBoLoc ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildNoiDungBoLoc(provider, dangCoBoLoc),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiDungBoLoc(SinhVienProvider provider, bool dangCoBoLoc) {
    final dsNamHoc = [...provider.dsNamHocLop];
    final dsHocKy = [...provider.dsHocKyLop];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          _dropdown(
            value: provider.lopNamHoc,
            label: 'Năm học',
            icon: Icons.school_outlined,
            allLabel: 'Tất cả năm học',
            values: dsNamHoc,
            onChanged: (v) => provider.layDanhSachLop(namHoc: v ?? ''),
          ),
          const SizedBox(height: 10),
          _dropdown(
            value: provider.lopHocKy,
            label: 'Học kỳ',
            icon: Icons.calendar_month_rounded,
            allLabel: 'Tất cả học kỳ',
            values: dsHocKy.isEmpty
                ? const ['HK1', 'HK2', 'HK3', 'HK4', 'HK5', 'HK6']
                : dsHocKy,
            onChanged: (v) => provider.layDanhSachLop(hocKy: v ?? ''),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: dangCoBoLoc
                  ? () {
                      _tkCtrl.clear();
                      provider.xoaBoLocLop();
                      setState(() {});
                    }
                  : null,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Xóa bộ lọc'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required String label,
    required IconData icon,
    required String allLabel,
    required List<String> values,
    required ValueChanged<String?> onChanged,
    Map<String, String> labels = const {},
  }) {
    final unique = <String>{
      ...values.where((item) => item.trim().isNotEmpty),
      if (value.trim().isNotEmpty) value,
    }.toList();
    unique.sort((a, b) => _soSanhGiaTriBoLoc(label, a, b));

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      menuMaxHeight: 360,
      borderRadius: BorderRadius.circular(18),
      decoration: _dropDecoration(label, icon),
      items: [
        DropdownMenuItem(
          value: '',
          child: _dropdownItem(icon, allLabel, laTatCa: true),
        ),
        ...unique.map(
          (item) => DropdownMenuItem(
            value: item,
            child: _dropdownItem(icon, labels[item] ?? item),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  int _soSanhGiaTriBoLoc(String label, String a, String b) {
    if (label == 'Năm học') {
      final namA = int.tryParse(a.split(RegExp(r'[-–]')).first.trim()) ?? 0;
      final namB = int.tryParse(b.split(RegExp(r'[-–]')).first.trim()) ?? 0;
      return namB.compareTo(namA);
    }
    if (label == 'Học kỳ') {
      final hkA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 99;
      final hkB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 99;
      return hkA.compareTo(hkB);
    }
    return a.compareTo(b);
  }

  Widget _dropdownItem(IconData icon, String text, {bool laTatCa = false}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: laTatCa
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            laTatCa ? Icons.apps_rounded : icon,
            size: 16,
            color: laTatCa ? _muted : _primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontWeight: laTatCa ? FontWeight.w700 : FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _dropDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
    );
  }

  Widget _buildDanhSach(SinhVienProvider provider) {
    final danhSach = provider.dsLop
        .where((lop) => lop.isDaLuu == widget.chiLuuTru)
        .toList();
    if (provider.lopLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.lopError != null) {
      return TrangLoi(
        loi: provider.lopError!,
        onTaiLai: provider.layDanhSachLop,
      );
    }
    if (danhSach.isEmpty) {
      return TrangRong(
        thongDiep: widget.chiLuuTru
            ? 'Chưa có lớp học phần đã lưu'
            : 'Bạn chưa có lớp học phần đang hoạt động',
        icon: widget.chiLuuTru ? Icons.archive_outlined : Icons.class_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.layDanhSachLop,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: danhSach.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.chiLuuTru ? 'Lớp đã lưu' : 'Danh sách lớp',
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${danhSach.length} lớp',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildTheLop(danhSach[i - 1]);
        },
      ),
    );
  }

  Widget _buildTheLop(LopHocPhanSVModel lop) {
    final soChuaNop = (lop.soBaiTap - lop.soBaiDaNop).clamp(0, 999);
    final coVieclam = soChuaNop > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChiTietLopSV(lop: lop)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        ),
                      ),
                      child: AvatarTen(ten: lop.tenHienThi, mauNen: _primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lop.tenHienThi,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: _text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            lop.tenMon ?? lop.maMon ?? lop.maLopHocPhan,
                            style: const TextStyle(color: _muted, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              if (lop.hocKy != null)
                                _InfoPill(
                                  icon: Icons.calendar_month_rounded,
                                  label: lop.hocKy!,
                                  color: _primary,
                                ),
                              if (lop.namHoc != null)
                                _InfoPill(
                                  icon: Icons.date_range_rounded,
                                  label: lop.namHoc!,
                                  color: const Color(0xFF7C3AED),
                                ),
                              if (lop.isDaLuu)
                                const _InfoPill(
                                  icon: Icons.archive_outlined,
                                  label: 'Chỉ xem',
                                  color: Color(0xFF64748B),
                                ),
                              _InfoPill(
                                icon: Icons.badge_rounded,
                                label: lop.maLopHocPhan,
                                color: const Color(0xFF0F766E),
                              ),
                              if (coVieclam)
                                _InfoPill(
                                  icon: Icons.warning_amber_rounded,
                                  label: '$soChuaNop chờ nộp',
                                  color: const Color(0xFFF97316),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: _muted),
                  ],
                ),
                if (lop.tenGiangVien != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: _muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Giảng viên: ${lop.tenGiangVien!}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _text,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        icon: Icons.folder_open_rounded,
                        value: '${lop.soTaiLieu}',
                        label: 'Tài liệu',
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        icon: Icons.assignment_rounded,
                        value: '${lop.soBaiTap}',
                        label: 'Bài tập',
                        color: const Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        icon: Icons.cloud_done_rounded,
                        value: '${lop.soBaiDaNop}',
                        label: 'Đã nộp',
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        icon: Icons.campaign_rounded,
                        value: '${lop.soBaiViet}',
                        label: 'Tin',
                        color: const Color(0xFF0891B2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
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
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
