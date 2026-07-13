import 'package:ckc_class_app/screen/sinh_vien/chi_tiet_thong_bao_sv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/sinh_vien_provider.dart';
import '../../widget/widget_sinhvien.dart';

class ThongBaoSVPage extends StatelessWidget {
  final int lopHocPhanId;
  const ThongBaoSVPage({super.key, required this.lopHocPhanId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8FC),
      child: Consumer<SinhVienProvider>(
        builder: (_, p, __) {
          if (p.tbLoading)
            return const Center(child: CircularProgressIndicator());
          if (p.tbError != null) {
            return TrangLoi(
              loi: p.tbError!,
              onTaiLai: () => p.layDanhSachThongBao(lopHocPhanId),
            );
          }
          if (p.dsThongBao.isEmpty) {
            return const TrangRong(
              thongDiep: 'Chưa có thông báo',
              icon: Icons.campaign_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => p.layDanhSachThongBao(lopHocPhanId),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: p.dsThongBao.length,
              itemBuilder: (_, i) {
                final tb = p.dsThongBao[i];
                final first = i == 0;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChiTietThongBaoSV(thongBao: tb),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: first
                              ? Colors.orange.withOpacity(.24)
                              : const Color(0xFFE8EEF8),
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
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: first
                                        ? [Colors.orange, Colors.deepOrange]
                                        : [Colors.blue, Colors.blue.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (first ? Colors.orange : Colors.blue)
                                              .withOpacity(.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.campaign_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tb.tieuDe,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15.5,
                                            ),
                                          ),
                                        ),
                                        if (first)
                                          const ChipTrangThai(
                                            nhan: 'Mới nhất',
                                            mau: Colors.orange,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${tb.tenNguoiTao ?? 'Giảng viên'} • ${dinhDangNgayGio(tb.ngayTao)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (tb.noiDung != null &&
                              tb.noiDung!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE8EEF8),
                                ),
                              ),
                              child: Text(
                                tb.noiDung!,
                                style: const TextStyle(height: 1.38),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                thoiGianTuongDoi(tb.ngayTao),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Spacer(),
                              if (tb.soBinhLuan > 0)
                                ChipTrangThai(
                                  nhan: '${tb.soBinhLuan} bình luận',
                                  mau: Colors.teal,
                                  icon: Icons.chat_bubble_outline_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
