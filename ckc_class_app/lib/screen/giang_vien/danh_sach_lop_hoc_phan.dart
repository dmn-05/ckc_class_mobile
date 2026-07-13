import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/giang_vien_model.dart';
import '../../provider/giang_vien_provider.dart';
import 'chi_tiet_lop_hoc_phan.dart';

class DanhSachLopHocPhan extends StatefulWidget {
  const DanhSachLopHocPhan({super.key});

  @override
  State<DanhSachLopHocPhan> createState() => _DanhSachLopHocPhanState();
}

class _DanhSachLopHocPhanState extends State<DanhSachLopHocPhan> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final TextEditingController _timKiemController = TextEditingController();
  Timer? _debounce;
  bool _moBoLoc = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<GiangVienProvider>();
      _timKiemController.text = provider.lopTuKhoa;
      provider.layDanhSachLop();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _timKiemController.dispose();
    super.dispose();
  }

  void _timKiem(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<GiangVienProvider>().layDanhSachLop(tuKhoa: value.trim());
    });
  }

  Future<void> _xoaBoLoc(GiangVienProvider provider) async {
    _debounce?.cancel();
    _timKiemController.clear();
    setState(() {});
    await provider.xoaBoLocLop();
  }

  int _demBoLoc(GiangVienProvider provider) {
    var count = 0;
    if (provider.lopKhoaHoc.isNotEmpty) count++;
    if (provider.lopHocKy.isNotEmpty) count++;
    if (provider.lopTrangThai.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Lớp của tôi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<GiangVienProvider>().layDanhSachLop(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<GiangVienProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Lớp học phần',
                    style: TextStyle(
                      color: _text,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              _buildTimKiemVaBoLoc(provider),
              Expanded(child: _buildDanhSach(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimKiemVaBoLoc(GiangVienProvider provider) {
    final soBoLoc = _demBoLoc(provider);
    final dangCoBoLoc =
        soBoLoc > 0 || _timKiemController.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                      child: const Icon(
                        Icons.manage_search_rounded,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tìm kiếm & lọc',
                            style: TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tìm nhanh, sau đó mở bộ lọc khi cần',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _timKiemController,
                  onChanged: _timKiem,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm lớp, mã lớp hoặc môn học',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _timKiemController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Xóa từ khóa',
                            onPressed: () {
                              _timKiemController.clear();
                              setState(() {});
                              provider.layDanhSachLop(tuKhoa: '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
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
                      borderSide: const BorderSide(color: _primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _moBoLoc = !_moBoLoc),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _moBoLoc
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _moBoLoc
                            ? const Color(0xFFBFDBFE)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: _moBoLoc ? _primary : _muted,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
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
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _muted,
                          ),
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
            crossFadeState: _moBoLoc
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildNoiDungBoLoc(provider, dangCoBoLoc),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiDungBoLoc(
    GiangVienProvider provider,
    bool dangCoBoLoc,
  ) {
    final dsKhoaHoc = [...provider.dsKhoaHocLop];
    final dsHocKy = [...provider.dsHocKyLop];

    if (provider.lopKhoaHoc.isNotEmpty &&
        !dsKhoaHoc.contains(provider.lopKhoaHoc)) {
      dsKhoaHoc.add(provider.lopKhoaHoc);
      dsKhoaHoc.sort();
    }
    if (provider.lopHocKy.isNotEmpty &&
        !dsHocKy.contains(provider.lopHocKy)) {
      dsHocKy.add(provider.lopHocKy);
      dsHocKy.sort();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final haiCot = constraints.maxWidth >= 580;
              final width = haiCot
                  ? (constraints.maxWidth - 10) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: _dropdown(
                      value: provider.lopKhoaHoc,
                      label: 'Khóa học',
                      icon: Icons.school_outlined,
                      allLabel: 'Tất cả khóa học',
                      values: dsKhoaHoc,
                      onChanged: (value) {
                        provider.layDanhSachLop(khoaHoc: value ?? '');
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _dropdown(
                      value: provider.lopHocKy,
                      label: 'Học kỳ',
                      icon: Icons.calendar_month_rounded,
                      allLabel: 'Tất cả học kỳ',
                      values: dsHocKy,
                      onChanged: (value) {
                        provider.layDanhSachLop(hocKy: value ?? '');
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _dropdown(
                      value: provider.lopTrangThai,
                      label: 'Trạng thái',
                      icon: Icons.toggle_on_outlined,
                      allLabel: 'Tất cả trạng thái',
                      values: const ['dang_mo', 'da_khoa', 'da_ket_thuc'],
                      labels: const {
                        'dang_mo': 'Đang mở',
                        'da_khoa': 'Đã khóa',
                        'da_ket_thuc': 'Đã kết thúc',
                      },
                      onChanged: (value) {
                        provider.layDanhSachLop(trangThai: value ?? '');
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: dangCoBoLoc
                          ? () => _xoaBoLoc(provider)
                          : null,
                      icon: const Icon(Icons.filter_alt_off_rounded),
                      label: const Text('Xóa bộ lọc'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      items: [
        DropdownMenuItem<String>(value: '', child: Text(allLabel)),
        ...values.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              labels[item] ?? item,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildDanhSach(GiangVienProvider provider) {
    if (provider.lopLoading && provider.dsLopHocPhan.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.lopError != null && provider.dsLopHocPhan.isEmpty) {
      return _TrangThaiThongBao(
        icon: Icons.error_outline_rounded,
        title: 'Không tải được lớp học phần',
        message: provider.lopError!,
        buttonLabel: 'Thử lại',
        onPressed: provider.layDanhSachLop,
      );
    }

    if (provider.dsLopHocPhan.isEmpty) {
      return _TrangThaiThongBao(
        icon: Icons.class_outlined,
        title: 'Không có lớp phù hợp',
        message: 'Hãy thử thay đổi từ khóa hoặc xóa bộ lọc.',
        buttonLabel: 'Xóa bộ lọc',
        onPressed: () => _xoaBoLoc(provider),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.layDanhSachLop,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
        itemCount: provider.dsLopHocPhan.length,
        itemBuilder: (context, index) {
          return _buildTheLop(provider.dsLopHocPhan[index]);
        },
      ),
    );
  }

  Widget _buildTheLop(LopHocPhan lop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietLopHocPhan(lop: lop),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (lop.hocKy?.replaceAll('HK', 'H') ?? 'L'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lop.tenHienThi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lop.tenMon ?? lop.maMon ?? 'Chưa cập nhật môn học',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _muted),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    Icons.calendar_month_rounded,
                    lop.hocKy ?? 'Chưa có học kỳ',
                    const Color(0xFF2563EB),
                    const Color(0xFFEFF6FF),
                  ),
                  _chip(
                    Icons.school_outlined,
                    lop.khoaHocHienThi,
                    const Color(0xFF0F766E),
                    const Color(0xFFECFDF5),
                  ),
                  _chip(
                    lop.isDangMo
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    lop.tenTrangThai,
                    lop.isDangMo
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    lop.isDangMo
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF1F5F9),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _chiSo(Icons.people_outline_rounded, '${lop.soSinhVien}', 'Sinh viên'),
                    _vach(),
                    _chiSo(Icons.folder_outlined, '${lop.soTaiLieu}', 'Tài liệu'),
                    _vach(),
                    _chiSo(Icons.assignment_outlined, '${lop.soBaiTap}', 'Bài tập'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
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

  Widget _chiSo(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: _primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _vach() {
    return Container(
      width: 1,
      height: 42,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _TrangThaiThongBao extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _TrangThaiThongBao({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
