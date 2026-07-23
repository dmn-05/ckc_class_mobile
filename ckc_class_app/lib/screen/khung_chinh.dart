import 'package:ckc_class_app/screen/admin/quan_ly_lop/quan_ly_lop.dart';
import 'package:ckc_class_app/screen/admin/quan_ly_lop/quan_ly_lop_hoc_phan.dart';
import 'package:ckc_class_app/screen/admin/nhap_excel/nhap_excel_screen.dart';
import 'package:ckc_class_app/screen/admin/xuat_excel/xuat_excel_screen.dart';
import 'package:ckc_class_app/screen/giang_vien/dasboad_giangvien.dart';
import 'package:ckc_class_app/screen/sinh_vien/dashboard_sinhvien.dart';
import 'package:ckc_class_app/screen/sinh_vien/lop_hoc_phan_sv.dart';
import 'package:ckc_class_app/screen/tai_khoan/doi_ten_tai_khoan.dart';
import 'package:ckc_class_app/provider/sinh_vien_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/xac_thuc.dart';
import '../provider/giang_vien_provider.dart';

import 'admin/bang_dieu_khien_admin.dart';
import 'admin/khoa_bo_mon/quan_ly_khoa.dart';
import 'admin/khoa_bo_mon/quan_ly_bo_mon.dart';
import 'admin/khoa_bo_mon/quan_ly_mon_hoc.dart';
import 'admin/quan_ly_nguoi_dung.dart';
import 'giang_vien/danh_sach_lop_hoc_phan.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _textDark = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);

  int _selectedIndex = 0;
  int _providerUserId = 0;

  void _chonMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  /// Chuyển màn hình từ các thẻ chức năng trên Bảng điều khiển.
  /// Không gọi Navigator.pop vì thao tác này không xuất phát từ Drawer.
  void _chuyenChucNangAdmin(int index) {
    if (!mounted || _selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _dongBoProviderTheoTaiKhoan(dynamic user) {
    if (_providerUserId == user.id) return;
    _providerUserId = user.id;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final sinhVienProvider = context.read<SinhVienProvider>();
      final giangVienProvider = context.read<GiangVienProvider>();

      // Provider được khai báo ở cấp ứng dụng nên vẫn tồn tại sau khi đổi tài
      // khoản. Phải xóa ID và dữ liệu của tài khoản trước trước khi nạp tài
      // khoản hiện tại, nếu không dashboard sẽ tiếp tục gọi API bằng ID cũ.
      sinhVienProvider.reset();
      giangVienProvider.reset();

      if (user.isSinhVien) {
        if (user.sinhVienId != null && user.sinhVienId! > 0) {
          sinhVienProvider.khoiTao(user.sinhVienId!, user.id);
          await sinhVienProvider.khoiTaoDuLieu();
        } else {
          await sinhVienProvider.khoiTaoTuNguoiDungId(user.id);
        }
      } else if (user.isGiangVien) {
        if (user.giangVienId != null && user.giangVienId! > 0) {
          giangVienProvider.khoiTaoGiangVien(user.giangVienId!, user.id);
          await giangVienProvider.khoiTaoDuLieu();
        } else {
          await giangVienProvider.khoiTaoTuNguoiDungId(user.id);
        }
      }
    });
  }

  Future<void> _xacNhanDangXuat() async {
    final dongY = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade600),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản hiện tại không?',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: _textMuted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Không',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;
    if (!mounted) return;

    context.read<SinhVienProvider>().reset();
    context.read<GiangVienProvider>().reset();
    await context.read<AuthProvider>().logout();
  }

  String _roleName(dynamic user) {
    if (user.isAdmin) return 'Quản trị viên';
    if (user.isGiangVien) return 'Giảng viên';
    return 'Sinh viên';
  }

  IconData _roleIcon(dynamic user) {
    if (user.isAdmin) return Icons.admin_panel_settings_rounded;
    if (user.isGiangVien) return Icons.workspace_premium_rounded;
    return Icons.school_rounded;
  }

  Color _roleColor(dynamic user) {
    if (user.isAdmin) return const Color(0xFF9333EA);
    if (user.isGiangVien) return const Color(0xFF0EA5E9);
    return _primary;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _dongBoProviderTheoTaiKhoan(user);

    Widget body;
    String title;

    if (user.isAdmin) {
      switch (_selectedIndex) {
        case 0:
          title = 'Quản trị viên';
          body = AdminDashboard(
            onMenuSelected: _chuyenChucNangAdmin,
          );
          break;
        case 1:
          title = 'Khoa';
          body = const QuanLyKhoaBoMonScreen();
          break;
        case 2:
          title = 'Bộ môn';
          body = const QuanLyBoMonScreen();
          break;
        case 3:
          title = 'Môn học';
          body = const QuanLyMonHocScreen();
          break;
        case 4:
          title = 'Người dùng';
          body = const QuanLyNguoiDung();
          break;
        case 5:
          title = 'Lớp';
          body = const QuanLyLop();
          break;
        case 6:
          title = 'Lớp học phần';
          body = const QuanLyLopHocPhan();
          break;
        case 7:
          title = 'Nhập Excel';
          body = const NhapExcelScreen();
          break;
        case 8:
          title = 'Xuất Excel';
          body = const XuatExcelScreen();
          break;
        default:
          title = 'Quản trị viên';
          body = AdminDashboard(
            onMenuSelected: _chuyenChucNangAdmin,
          );
      }
    } else if (user.isGiangVien) {
      switch (_selectedIndex) {
        case 0:
          title = 'Giảng viên';
          body = const DashboardGiangVien();
          break;
        case 1:
          title = 'Lớp học phần';
          body = const DanhSachLopHocPhan();
          break;
        case 2:
          title = 'Lưu trữ';
          body = const DanhSachLopHocPhan(chiLuuTru: true);
          break;
        default:
          title = 'Giảng viên';
          body = const DashboardGiangVien();
      }
    } else {
      switch (_selectedIndex) {
        case 0:
          title = 'Sinh viên';
          body = const DashboardSinhVien();
          break;
        case 1:
          title = 'Lớp học phần';
          body = const LopHocPhanSV();
          break;
        case 2:
          title = 'Lưu trữ';
          body = const LopHocPhanSV(chiLuuTru: true);
          break;
        default:
          title = 'Sinh viên';
          body = const DashboardSinhVien();
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _textDark,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 19,
            color: _textDark,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_rounded, color: _primary, size: 22),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Đăng xuất',
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 21,
                ),
              ),
              onPressed: _xacNhanDangXuat,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        backgroundColor: _bg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _DrawerHeaderModern(
                name: user.hoTen,
                email: user.email,
                roleName: _roleName(user),
                roleIcon: _roleIcon(user),
                roleColor: _roleColor(user),
                avatarUrl: user.avatar,
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  children: [
                    _DrawerSectionLabel(label: 'Tổng quan'),
                    _NavTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Bảng điều khiển',
                      selected: _selectedIndex == 0,
                      onTap: () => _chonMenu(0),
                    ),

                    if (user.isAdmin) ...[
                      const SizedBox(height: 10),
                      _DrawerSectionLabel(label: 'Quản trị hệ thống'),
                      _NavTile(
                        icon: Icons.account_balance_rounded,
                        title: 'Khoa',
                        selected: _selectedIndex == 1,
                        onTap: () => _chonMenu(1),
                      ),
                      _NavTile(
                        icon: Icons.menu_book_rounded,
                        title: 'Bộ môn',
                        selected: _selectedIndex == 2,
                        onTap: () => _chonMenu(2),
                      ),
                      _NavTile(
                        icon: Icons.book_rounded,
                        title: 'Môn học',
                        selected: _selectedIndex == 3,
                        onTap: () => _chonMenu(3),
                      ),
                      _NavTile(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Người dùng',
                        selected: _selectedIndex == 4,
                        onTap: () => _chonMenu(4),
                      ),
                      _NavTile(
                        icon: Icons.groups_2_rounded,
                        title: 'Lớp',
                        selected: _selectedIndex == 5,
                        onTap: () => _chonMenu(5),
                      ),
                      _NavTile(
                        icon: Icons.school_rounded,
                        title: 'Lớp học phần',
                        selected: _selectedIndex == 6,
                        onTap: () => _chonMenu(6),
                      ),
                      _NavTile(
                        icon: Icons.upload_file_rounded,
                        title: 'Nhập Excel',
                        selected: _selectedIndex == 7,
                        onTap: () => _chonMenu(7),
                      ),
                      _NavTile(
                        icon: Icons.download_rounded,
                        title: 'Xuất Excel',
                        selected: _selectedIndex == 8,
                        onTap: () => _chonMenu(8),
                      ),
                    ],

                    if (user.isGiangVien) ...[
                      const SizedBox(height: 10),
                      _DrawerSectionLabel(label: 'Giảng dạy'),
                      _NavTile(
                        icon: Icons.class_rounded,
                        title: 'Lớp học phần',
                        selected: _selectedIndex == 1,
                        onTap: () => _chonMenu(1),
                      ),
                      _NavTile(
                        icon: Icons.archive_outlined,
                        title: 'Lưu trữ',
                        selected: _selectedIndex == 2,
                        onTap: () => _chonMenu(2),
                      ),
                    ],

                    if (user.isSinhVien) ...[
                      const SizedBox(height: 10),
                      _DrawerSectionLabel(label: 'Học tập'),
                      _NavTile(
                        icon: Icons.school_rounded,
                        title: 'Lớp học phần',
                        selected: _selectedIndex == 1,
                        onTap: () => _chonMenu(1),
                      ),
                      _NavTile(
                        icon: Icons.archive_outlined,
                        title: 'Lưu trữ',
                        selected: _selectedIndex == 2,
                        onTap: () => _chonMenu(2),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 10),
                      color: const Color(0xFFE5E7EB),
                    ),
                    _NavTile(
                      icon: Icons.settings_rounded,
                      title: 'Cài đặt tài khoản',
                      selected: false,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoiTenTaiKhoanScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _LogoutTile(onTap: _xacNhanDangXuat),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }
}

class _DrawerHeaderModern extends StatelessWidget {
  final String name;
  final String email;
  final String roleName;
  final IconData roleIcon;
  final Color roleColor;
  final String? avatarUrl;

  const _DrawerHeaderModern({
    required this.name,
    required this.email,
    required this.roleName,
    required this.roleIcon,
    required this.roleColor,
    this.avatarUrl,
  });

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  bool get _hasAvatar {
    final value = avatarUrl?.trim() ?? '';
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
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
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -36,
            child: _DecorCircle(size: 118, opacity: 0.14),
          ),
          Positioned(
            right: 28,
            bottom: -54,
            child: _DecorCircle(size: 94, opacity: 0.10),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: _hasAvatar
                            ? Image.network(
                                avatarUrl!.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarFallback(),
                              )
                            : _avatarFallback(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon, color: Colors.white, size: 15),
                        const SizedBox(width: 5),
                        Text(
                          roleName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 15,
                    color: Colors.white.withOpacity(0.82),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String label;

  const _DrawerSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? _MainScaffoldState._primary
        : _MainScaffoldState._textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: selected
                  ? Border.all(color: const Color(0xFFBFDBFE))
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? _MainScaffoldState._textDark
                          : _MainScaffoldState._textMuted,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _MainScaffoldState._primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
