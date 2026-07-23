import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/sinh_vien_model.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';
import '../../utils/file_download_helper.dart';

class ChiTietThongBaoSV extends StatefulWidget {
  final ThongBaoSVModel thongBao;
  final bool chiDoc;

  const ChiTietThongBaoSV({
    super.key,
    required this.thongBao,
    this.chiDoc = false,
  });

  @override
  State<ChiTietThongBaoSV> createState() => _ChiTietThongBaoSVState();
}

class _ChiTietThongBaoSVState extends State<ChiTietThongBaoSV> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SinhVienProvider>().layDanhSachBinhLuanThongBao(widget.thongBao.baiVietId ?? 0);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFile(ThongBaoFileSVModel file) async {
    await taiFileVeMay(
      context,
      duongDan: file.duongDan,
      tenFile: file.tenFile,
    );
  }

  Future<void> _guiBinhLuan(SinhVienProvider p) async {
    final noiDung = _commentCtrl.text.trim();
    if (noiDung.isEmpty) return;
    final rs = await p.dangBinhLuanThongBao(
      baiVietId: widget.thongBao.baiVietId ?? 0,
      noiDung: noiDung,
    );
    if (!mounted) return;
    if (rs['success'] == true) _commentCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(rs['message']?.toString() ?? 'Đã xử lý')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tb = widget.thongBao;
    final tenNguoiTao = tb.tenNguoiTao ?? 'Giảng viên';
    final noiDung = (tb.noiDung ?? '').trim();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        title: const Text('Chi tiết thông báo', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Consumer<SinhVienProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.layDanhSachBinhLuanThongBao(tb.baiVietId ?? 0),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                _HeaderThongBao(thongBao: tb, tenNguoiTao: tenNguoiTao),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Nội dung thông báo',
                  icon: Icons.notes_rounded,
                  children: [
                    Text(
                      noiDung.isEmpty ? 'Thông báo này chưa có nội dung chi tiết.' : noiDung,
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (tb.files.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'File đính kèm',
                    icon: Icons.attach_file_rounded,
                    children: tb.files.map((f) => _FileTile(file: f, onTap: () => _openFile(f))).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Thông tin',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _InfoRow(icon: Icons.person_rounded, label: 'Người đăng', value: tenNguoiTao, color: Colors.blue),
                    _InfoRow(icon: Icons.schedule_rounded, label: 'Ngày đăng', value: dinhDangNgayGio(tb.ngayTao), color: Colors.orange),
                    if (tb.ngayCapNhat != null)
                      _InfoRow(icon: Icons.update_rounded, label: 'Cập nhật', value: dinhDangNgayGio(tb.ngayCapNhat), color: Colors.teal),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Bình luận về thông báo',
                  icon: Icons.forum_rounded,
                  children: [
                    if (provider.blLoading)
                      const Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (provider.dsBinhLuan.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Chưa có bình luận nào. Hãy là người đầu tiên phản hồi.', style: TextStyle(color: _muted)),
                      )
                    else
                      ...provider.dsBinhLuan.map((bl) => _CommentTile(bl: bl)),
                    if (widget.chiDoc)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Lớp đã lưu · Chỉ có thể xem bình luận.',
                          style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtrl,
                              minLines: 1,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Viết bình luận về thông báo...',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: provider.blProcessing
                                ? null
                                : () => _guiBinhLuan(provider),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(52, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: provider.blProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderThongBao extends StatelessWidget {
  final ThongBaoSVModel thongBao;
  final String tenNguoiTao;
  const _HeaderThongBao({required this.thongBao, required this.tenNguoiTao});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF38BDF8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: const [BoxShadow(color: Color(0x332563EB), blurRadius: 22, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withOpacity(.20), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.20))), child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 28)),
          const SizedBox(width: 12),
          Expanded(child: Text(thongBao.tieuDe, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, height: 1.15))),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withOpacity(.18))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text('$tenNguoiTao • ${dinhDangNgayGio(thongBao.ngayTao)}', style: TextStyle(color: Colors.white.withOpacity(.86), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Color(0xFFE5E7EB)), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: Color(0xFF2563EB), size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900))),
        ]),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}

class _FileTile extends StatelessWidget {
  final ThongBaoFileSVModel file;
  final VoidCallback onTap;
  const _FileTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFFE2E8F0))),
        child: Row(children: [
          const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(file.tenFile, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            if (file.kichThuocHienThi.isNotEmpty) Text(file.kichThuocHienThi, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ])),
          const Icon(Icons.download_rounded, color: Color(0xFF64748B)),
        ]),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final BinhLuanModel bl;
  const _CommentTile({required this.bl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AvatarTen(ten: bl.tenNguoiDung, mauNen: bl.tenVaiTro == 'giang_vien' ? Colors.blue : Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFFE2E8F0))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bl.tenNguoiDung, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(bl.noiDung, style: const TextStyle(color: Color(0xFF334155), height: 1.35)),
              if (bl.ngayTao != null) ...[
                const SizedBox(height: 4),
                Text(dinhDangNgayGio(bl.ngayTao), style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 17, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, height: 1.3)),
        ])),
      ]),
    );
  }
}
