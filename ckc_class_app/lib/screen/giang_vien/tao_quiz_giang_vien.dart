import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/giang_vien_model.dart';
import '../../model/quiz_model.dart';
import '../../provider/giang_vien_provider.dart';
import '../../provider/quiz_provider.dart';
import '../../widget/widget_chung_giangvien.dart';

class TaoQuizGiangVien extends StatefulWidget {
  final LopHocPhan lop;
  final BaiTap? baiTap;

  const TaoQuizGiangVien({super.key, required this.lop, this.baiTap});

  @override
  State<TaoQuizGiangVien> createState() => _TaoQuizGiangVienState();
}

class _TaoQuizGiangVienState extends State<TaoQuizGiangVien> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _purple = Color(0xFF9333EA);

  final _formKey = GlobalKey<FormState>();
  final _tieuDeCtrl = TextEditingController();
  final _moTaCtrl = TextEditingController();
  final _thoiGianCtrl = TextEditingController(text: '15');

  DateTime? _hanNop;
  int? _chuDeId;
  bool _choXemDapAn = true;
  bool _daoCauHoi = false;
  bool _daoDapAn = false;
  String _trangThai = 'dang_mo';
  bool _dangNapChiTiet = false;
  bool _daGanDuLieuSua = false;

  final List<_CauHoiDraft> _cauHoi = [];

  bool get _laSua => widget.baiTap != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GiangVienProvider>().layDanhSachChuDe(widget.lop.id);
    });

    if (_laSua) {
      _tieuDeCtrl.text = widget.baiTap?.tieuDe ?? '';
      _moTaCtrl.text = widget.baiTap?.moTa ?? '';
      _hanNop = widget.baiTap?.hanNop;
      _chuDeId = widget.baiTap?.chuDeId;
      if (widget.baiTap?.thoiGianLam != null) {
        _thoiGianCtrl.text = widget.baiTap!.thoiGianLam.toString();
      }
      _trangThai = widget.baiTap?.trangThai ?? 'dang_mo';

      WidgetsBinding.instance.addPostFrameCallback((_) => _napChiTietQuiz());
    } else {
      _cauHoi.add(_CauHoiDraft.macDinh());
    }
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _moTaCtrl.dispose();
    _thoiGianCtrl.dispose();
    for (final c in _cauHoi) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _napChiTietQuiz() async {
    if (!_laSua || _daGanDuLieuSua) return;

    setState(() => _dangNapChiTiet = true);

    final gv = context.read<GiangVienProvider>();
    final qp = context.read<QuizProvider>();

    await qp.layChiTietQuizGiangVien(
      baiTapId: widget.baiTap!.id,
      nguoiTaoId: gv.nguoiDungId,
    );

    if (!mounted) return;

    final detail = qp.chiTietQuizGV;
    if (detail != null) {
      _ganDuLieuTuChiTiet(detail);
    }

    setState(() {
      _dangNapChiTiet = false;
      _daGanDuLieuSua = detail != null;
    });
  }

  void _ganDuLieuTuChiTiet(ChiTietQuizGV detail) {
    _tieuDeCtrl.text = detail.tieuDe;
    _moTaCtrl.text = detail.moTa ?? '';
    _hanNop = detail.hanNop;
    _chuDeId = detail.chuDeId;
    _thoiGianCtrl.text = detail.thoiGianLam?.toString() ?? '15';
    _choXemDapAn = detail.choXemDapAn;
    _daoCauHoi = detail.daoCauHoi;
    _daoDapAn = detail.daoDapAn;
    _trangThai = detail.trangThai;

    for (final c in _cauHoi) {
      c.dispose();
    }
    _cauHoi
      ..clear()
      ..addAll(detail.cauHoi.map(_CauHoiDraft.fromModel));

    if (_cauHoi.isEmpty) {
      _cauHoi.add(_CauHoiDraft.macDinh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _laSua ? 'Sửa quiz' : 'Tạo quiz';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        actions: [
          Consumer<QuizProvider>(
            builder: (_, qp, __) => TextButton.icon(
              onPressed: qp.processing || _dangNapChiTiet ? null : _luuQuiz,
              icon: qp.processing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_laSua ? 'Cập nhật' : 'Lưu'),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, qp, _) {
          if (_dangNapChiTiet) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_laSua && qp.error != null && !_daGanDuLieuSua) {
            return TrangThaiLoi(loi: qp.error!, onTaiLai: _napChiTietQuiz);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildThongTinChung(),
                const SizedBox(height: 18),
                _buildCauHoiHeader(),
                const SizedBox(height: 10),
                ...List.generate(
                  _cauHoi.length,
                  (i) => _buildCauHoiCard(i, _cauHoi[i]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dangNapChiTiet ? null : _themCauHoi,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm câu hỏi'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF581C87), _purple, Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x229333EA),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _laSua ? 'Cập nhật nội dung quiz' : 'Tạo bài tập dạng quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.lop.tenHienThi,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThongTinChung() {
    final gvProvider = context.watch<GiangVienProvider>();
    final selectedChuDeId = gvProvider.dsChuDe.any((cd) => cd.id == _chuDeId)
        ? _chuDeId
        : null;

    return _CardSection(
      title: 'Thông tin chung',
      icon: Icons.tune_rounded,
      children: [
        if (widget.lop.tenMon != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: _primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.lop.tenMon!,
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        _buildChuDeDropdown(gvProvider, selectedChuDeId),
        const SizedBox(height: 12),
        TextFormField(
          controller: _tieuDeCtrl,
          decoration: _inputDecoration(
            label: 'Tiêu đề quiz *',
            icon: Icons.title_rounded,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Vui lòng nhập tiêu đề quiz'
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _moTaCtrl,
          maxLines: 3,
          decoration: _inputDecoration(
            label: 'Mô tả / hướng dẫn',
            icon: Icons.description_rounded,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _thoiGianCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  label: 'Thời gian làm bài',
                  icon: Icons.timer_rounded,
                  suffixText: 'phút',
                ),
                validator: (v) {
                  final raw = v?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  final n = int.tryParse(raw);
                  if (n == null || n <= 0) return 'Không hợp lệ';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _chonHanNop,
                icon: const Icon(Icons.event_rounded, size: 18),
                label: Text(
                  _hanNop == null ? 'Chọn hạn nộp' : dinhDangNgayGio(_hanNop),
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_hanNop != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _hanNop = null),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Bỏ hạn nộp'),
            ),
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _trangThai,
          decoration: _inputDecoration(
            label: 'Trạng thái',
            icon: Icons.flag_rounded,
          ),
          items: const [
            DropdownMenuItem(value: 'dang_mo', child: Text('Đang mở')),
            DropdownMenuItem(value: 'da_dong', child: Text('Đã đóng')),
          ],
          onChanged: (v) => setState(() => _trangThai = v ?? 'dang_mo'),
        ),
        const SizedBox(height: 8),
        _SwitchCard(
          value: _choXemDapAn,
          icon: Icons.visibility_rounded,
          title: 'Cho sinh viên xem đáp án sau khi nộp',
          onChanged: (v) => setState(() => _choXemDapAn = v),
        ),
        _SwitchCard(
          value: _daoCauHoi,
          icon: Icons.shuffle_rounded,
          title: 'Đảo thứ tự câu hỏi',
          onChanged: (v) => setState(() => _daoCauHoi = v),
        ),
        _SwitchCard(
          value: _daoDapAn,
          icon: Icons.swap_vert_rounded,
          title: 'Đảo thứ tự đáp án',
          onChanged: (v) => setState(() => _daoDapAn = v),
        ),
      ],
    );
  }

  Widget _buildChuDeDropdown(
    GiangVienProvider gvProvider,
    int? selectedChuDeId,
  ) {
    return DropdownButtonFormField<int?>(
      value: selectedChuDeId,
      isExpanded: true,
      decoration: _inputDecoration(label: 'Chủ đề', icon: Icons.topic_rounded),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
      menuMaxHeight: 360,
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: _ChuDeMenuItem(
            icon: Icons.inbox_rounded,
            title: 'Chưa phân loại',
            subtitle: 'Không gắn vào chủ đề nào',
            color: _muted,
          ),
        ),
        ...gvProvider.dsChuDe.map(
          (cd) => DropdownMenuItem<int?>(
            value: cd.id,
            child: _ChuDeMenuItem(
              icon: Icons.folder_rounded,
              title: cd.tenChuDe,
              subtitle: 'Chủ đề bài học',
              color: _primary,
            ),
          ),
        ),
      ],
      selectedItemBuilder: (context) {
        return [
          const _ChuDeSelectedItem(
            icon: Icons.inbox_rounded,
            title: 'Chưa phân loại',
            color: _muted,
          ),
          ...gvProvider.dsChuDe.map(
            (cd) => _ChuDeSelectedItem(
              icon: Icons.folder_rounded,
              title: cd.tenChuDe,
              color: _primary,
            ),
          ),
        ];
      },
      onChanged: _dangNapChiTiet
          ? null
          : (v) {
              setState(() => _chuDeId = v);
            },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      suffixText: suffixText,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  Widget _buildCauHoiHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.help_rounded, color: _primary, size: 20),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Danh sách câu hỏi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),
        ),
        Chip(
          label: Text('${_cauHoi.length} câu'),
          backgroundColor: const Color(0xFFEFF6FF),
          labelStyle: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildCauHoiCard(int index, _CauHoiDraft cauHoi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
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
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Câu ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: _text,
                    ),
                  ),
                ),
                if (_cauHoi.length > 1)
                  IconButton(
                    tooltip: 'Xóa câu hỏi',
                    onPressed: () => _xoaCauHoi(index),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: cauHoi.noiDungCtrl,
              maxLines: 2,
              decoration: _inputDecoration(
                label: 'Nội dung câu hỏi *',
                icon: Icons.question_answer_rounded,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập nội dung câu hỏi'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: cauHoi.loaiCauHoi,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: 'Loại câu hỏi',
                      icon: Icons.rule_rounded,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'mot_dap_an',
                        child: Text('Một đáp án'),
                      ),
                      DropdownMenuItem(
                        value: 'nhieu_dap_an',
                        child: Text('Nhiều đáp án'),
                      ),
                      DropdownMenuItem(
                        value: 'dung_sai',
                        child: Text('Đúng / Sai'),
                      ),
                      DropdownMenuItem(
                        value: 'tu_luan',
                        child: Text('Tự luận'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        cauHoi.loaiCauHoi = v ?? 'mot_dap_an';
                        if (cauHoi.loaiCauHoi == 'dung_sai') {
                          cauHoi.chuyenThanhDungSai();
                        } else if (cauHoi.loaiCauHoi == 'tu_luan') {
                          cauHoi.chuyenThanhTuLuan();
                        } else if (cauHoi.dapAn.isEmpty) {
                          cauHoi.themDapAn();
                          cauHoi.themDapAn();
                          cauHoi.dapAn.first.laDung = true;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: cauHoi.diemCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Điểm',
                      icon: Icons.score_rounded,
                    ),
                    validator: (v) {
                      final d = double.tryParse((v ?? '').trim());
                      if (d == null || d <= 0) return 'Sai';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (cauHoi.loaiCauHoi == 'tu_luan')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: const Text(
                  'Câu tự luận không cần đáp án. Sinh viên sẽ nhập nội dung trả lời, giảng viên chấm sau.',
                  style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w700),
                ),
              )
            else
              ...List.generate(
                cauHoi.dapAn.length,
                (i) => _buildDapAnRow(cauHoi, i),
              ),
            if (cauHoi.loaiCauHoi != 'dung_sai' && cauHoi.loaiCauHoi != 'tu_luan')
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => cauHoi.themDapAn()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Thêm đáp án'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDapAnRow(_CauHoiDraft cauHoi, int index) {
    final dapAn = cauHoi.dapAn[index];
    final laMotDapAn =
        cauHoi.loaiCauHoi == 'mot_dap_an' || cauHoi.loaiCauHoi == 'dung_sai';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          laMotDapAn
              ? Radio<int>(
                  value: index,
                  groupValue: cauHoi.indexDapAnDungDauTien,
                  onChanged: (v) {
                    setState(() {
                      for (var i = 0; i < cauHoi.dapAn.length; i++) {
                        cauHoi.dapAn[i].laDung = i == v;
                      }
                    });
                  },
                )
              : Checkbox(
                  value: dapAn.laDung,
                  onChanged: (v) => setState(() => dapAn.laDung = v ?? false),
                ),
          Expanded(
            child: TextFormField(
              controller: dapAn.noiDungCtrl,
              enabled: cauHoi.loaiCauHoi != 'dung_sai',
              decoration: InputDecoration(
                labelText: 'Đáp án ${index + 1}',
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
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Đáp án không được trống'
                  : null,
            ),
          ),
          if (cauHoi.loaiCauHoi != 'dung_sai' && cauHoi.dapAn.length > 2)
            IconButton(
              onPressed: () => setState(() => cauHoi.xoaDapAn(index)),
              icon: const Icon(Icons.close_rounded, color: Colors.red),
            ),
        ],
      ),
    );
  }

  void _themCauHoi() {
    setState(() => _cauHoi.add(_CauHoiDraft.macDinh()));
  }

  void _xoaCauHoi(int index) {
    final c = _cauHoi.removeAt(index);
    c.dispose();
    setState(() {});
  }

  Future<void> _chonHanNop() async {
    final now = DateTime.now();
    final initial = _hanNop ?? now.add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _hanNop ?? DateTime(now.year, now.month, now.day, 23, 59),
      ),
    );
    if (time == null) return;

    setState(() {
      _hanNop = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String? _kiemTraLogicQuiz() {
    if (_cauHoi.isEmpty) return 'Quiz phải có ít nhất 1 câu hỏi';

    for (var i = 0; i < _cauHoi.length; i++) {
      final c = _cauHoi[i];
      if (c.loaiCauHoi == 'tu_luan') continue;
      if (c.dapAn.length < 2) return 'Câu ${i + 1} phải có ít nhất 2 đáp án';
      final soDung = c.dapAn.where((d) => d.laDung).length;
      if (c.loaiCauHoi == 'mot_dap_an' || c.loaiCauHoi == 'dung_sai') {
        if (soDung != 1) return 'Câu ${i + 1} phải chọn đúng 1 đáp án đúng';
      } else {
        if (soDung < 1) return 'Câu ${i + 1} phải có ít nhất 1 đáp án đúng';
      }
    }
    return null;
  }

  Future<void> _luuQuiz() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final loiLogic = _kiemTraLogicQuiz();
    if (loiLogic != null) {
      hienThiSnackBar(context, loiLogic, laThanh: false);
      return;
    }

    final gv = context.read<GiangVienProvider>();
    if (gv.nguoiDungId <= 0) {
      hienThiSnackBar(context, 'Không tìm thấy ID người tạo', laThanh: false);
      return;
    }

    final cauHoi = List<CauHoiQuiz>.generate(
      _cauHoi.length,
      (i) => _cauHoi[i].toModel(thuTu: i + 1),
    );

    final qp = context.read<QuizProvider>();
    final thoiGianLamRaw = _thoiGianCtrl.text.trim();
    final thoiGianLam = thoiGianLamRaw.isEmpty
        ? null
        : int.tryParse(thoiGianLamRaw);

    final result = _laSua
        ? await qp.suaQuiz(
            baiTapId: widget.baiTap!.id,
            tieuDe: _tieuDeCtrl.text,
            moTa: _moTaCtrl.text,
            chuDeId: _chuDeId,
            nguoiTaoId: gv.nguoiDungId,
            hanNop: _hanNop,
            thoiGianLam: thoiGianLam,
            choXemDapAn: _choXemDapAn,
            daoCauHoi: _daoCauHoi,
            daoDapAn: _daoDapAn,
            trangThai: _trangThai,
            cauHoi: cauHoi,
          )
        : await qp.taoQuiz(
            tieuDe: _tieuDeCtrl.text,
            moTa: _moTaCtrl.text,
            lopHocPhanId: widget.lop.id,
            chuDeId: _chuDeId,
            nguoiTaoId: gv.nguoiDungId,
            hanNop: _hanNop,
            thoiGianLam: thoiGianLam,
            choXemDapAn: _choXemDapAn,
            daoCauHoi: _daoCauHoi,
            daoDapAn: _daoDapAn,
            trangThai: _trangThai,
            cauHoi: cauHoi,
          );

    if (!mounted) return;
    hienThiSnackBar(
      context,
      result['message'] ?? '',
      laThanh: result['success'] == true,
    );

    if (result['success'] == true) {
      await context.read<GiangVienProvider>().layDanhSachBaiTap(widget.lop.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}

class _ChuDeMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ChuDeMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChuDeSelectedItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ChuDeSelectedItem({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CardSection({
    required this.title,
    required this.icon,
    required this.children,
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
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _TaoQuizGiangVienState._primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: _TaoQuizGiangVienState._text,
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

class _SwitchCard extends StatelessWidget {
  final bool value;
  final IconData icon;
  final String title;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.value,
    required this.icon,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.only(left: 12, right: 8),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: _TaoQuizGiangVienState._primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _TaoQuizGiangVienState._text,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CauHoiDraft {
  final int id;
  final TextEditingController noiDungCtrl;
  final TextEditingController diemCtrl;
  String loaiCauHoi;
  final List<_DapAnDraft> dapAn;

  _CauHoiDraft({
    this.id = 0,
    required this.noiDungCtrl,
    required this.diemCtrl,
    required this.loaiCauHoi,
    required this.dapAn,
  });

  factory _CauHoiDraft.macDinh() => _CauHoiDraft(
    noiDungCtrl: TextEditingController(),
    diemCtrl: TextEditingController(text: '1'),
    loaiCauHoi: 'mot_dap_an',
    dapAn: [
      _DapAnDraft(id: 0, noiDungCtrl: TextEditingController(), laDung: true),
      _DapAnDraft(id: 0, noiDungCtrl: TextEditingController(), laDung: false),
    ],
  );

  factory _CauHoiDraft.fromModel(CauHoiQuiz c) => _CauHoiDraft(
    id: c.id,
    noiDungCtrl: TextEditingController(text: c.noiDung),
    diemCtrl: TextEditingController(
      text: c.diem.toStringAsFixed(c.diem.truncateToDouble() == c.diem ? 0 : 1),
    ),
    loaiCauHoi: c.loaiCauHoi,
    dapAn: c.laTuLuan
        ? <_DapAnDraft>[]
        : c.dapAn
            .map(
              (d) => _DapAnDraft(
                id: d.id,
                noiDungCtrl: TextEditingController(text: d.noiDung),
                laDung: d.laDapAnDung,
              ),
            )
            .toList(),
  );

  int? get indexDapAnDungDauTien {
    final idx = dapAn.indexWhere((d) => d.laDung);
    return idx == -1 ? null : idx;
  }

  void themDapAn() {
    dapAn.add(
      _DapAnDraft(id: 0, noiDungCtrl: TextEditingController(), laDung: false),
    );
  }

  void xoaDapAn(int index) {
    final d = dapAn.removeAt(index);
    d.dispose();
    if (!dapAn.any((e) => e.laDung) && dapAn.isNotEmpty) {
      dapAn.first.laDung = true;
    }
  }

  void chuyenThanhTuLuan() {
    for (final d in dapAn) {
      d.dispose();
    }
    dapAn.clear();
  }

  void chuyenThanhDungSai() {
    for (final d in dapAn) {
      d.dispose();
    }
    dapAn
      ..clear()
      ..add(
        _DapAnDraft(
          id: 0,
          noiDungCtrl: TextEditingController(text: 'Đúng'),
          laDung: true,
        ),
      )
      ..add(
        _DapAnDraft(
          id: 0,
          noiDungCtrl: TextEditingController(text: 'Sai'),
          laDung: false,
        ),
      );
  }

  CauHoiQuiz toModel({required int thuTu}) => CauHoiQuiz(
    id: id,
    noiDung: noiDungCtrl.text.trim(),
    loaiCauHoi: loaiCauHoi,
    diem: double.tryParse(diemCtrl.text.trim()) ?? 1,
    thuTu: thuTu,
    dapAn: List<DapAnQuiz>.generate(
      dapAn.length,
      (i) => DapAnQuiz(
        id: dapAn[i].id,
        noiDung: dapAn[i].noiDungCtrl.text.trim(),
        laDapAnDung: dapAn[i].laDung,
        thuTu: i + 1,
      ),
    ),
  );

  void dispose() {
    noiDungCtrl.dispose();
    diemCtrl.dispose();
    for (final d in dapAn) {
      d.dispose();
    }
  }
}

class _DapAnDraft {
  final int id;
  final TextEditingController noiDungCtrl;
  bool laDung;

  _DapAnDraft({
    required this.id,
    required this.noiDungCtrl,
    required this.laDung,
  });

  void dispose() => noiDungCtrl.dispose();
}
