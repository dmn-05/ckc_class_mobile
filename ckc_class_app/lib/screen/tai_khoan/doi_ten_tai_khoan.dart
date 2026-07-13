import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/nguoi_dung_model.dart';
import '../../provider/xac_thuc.dart';

class DoiTenTaiKhoanScreen extends StatefulWidget {
  const DoiTenTaiKhoanScreen({super.key});

  @override
  State<DoiTenTaiKhoanScreen> createState() => _DoiTenTaiKhoanScreenState();
}

class _DoiTenTaiKhoanScreenState extends State<DoiTenTaiKhoanScreen> {
  static const _bg = Color(0xFFF6F8FC);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDark = Color(0xFF1E40AF);
  static const _text = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  bool _loading = true;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHoSo());
  }

  Future<void> _loadHoSo() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final result = await context.read<AuthProvider>().layHoSoCaNhan();
    if (!mounted) return;

    setState(() => _loading = false);

    if (result['success'] != true) {
      _showSnack(
        result['message']?.toString() ?? 'Không tải được hồ sơ',
        error: true,
      );
    }
  }

  Future<void> _chonVaUploadAvatar() async {
    if (_uploadingAvatar) return;

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: false,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (picked == null || picked.files.isEmpty) return;

    final file = picked.files.single;
    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      _showSnack('Không lấy được đường dẫn ảnh đã chọn', error: true);
      return;
    }

    setState(() => _uploadingAvatar = true);
    final result = await context.read<AuthProvider>().capNhatAvatar(
          filePath: path,
          fileName: file.name,
        );
    if (!mounted) return;
    setState(() => _uploadingAvatar = false);

    _showSnack(
      result['message']?.toString() ??
          (result['success'] == true
              ? 'Cập nhật ảnh đại diện thành công'
              : 'Cập nhật ảnh đại diện thất bại'),
      error: result['success'] != true,
    );
  }


  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool submitting = false;
    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> submit() async {
                final current = currentController.text.trim();
                final next = newController.text.trim();
                final confirm = confirmController.text.trim();

                if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                  _showSnack('Vui lòng nhập đủ 3 dòng mật khẩu', error: true);
                  return;
                }
                if (next.length < 6) {
                  _showSnack('Mật khẩu mới phải có ít nhất 6 ký tự', error: true);
                  return;
                }
                if (next != confirm) {
                  _showSnack('Nhập lại mật khẩu mới không khớp', error: true);
                  return;
                }
                if (next == current) {
                  _showSnack('Mật khẩu mới không được trùng mật khẩu hiện tại', error: true);
                  return;
                }

                setDialogState(() => submitting = true);
                final result = await context.read<AuthProvider>().doiMatKhau(
                      matKhauHienTai: current,
                      matKhauMoi: next,
                      nhapLaiMatKhauMoi: confirm,
                    );
                if (!mounted) return;
                setDialogState(() => submitting = false);

                final success = result['success'] == true;
                if (!success) {
                  _showSnack(result['message']?.toString() ?? 'Đổi mật khẩu thất bại', error: true);
                  return;
                }

                Navigator.of(dialogContext).pop();
                await _showPasswordChangedAndLogout(
                  result['message']?.toString() ?? 'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.',
                );
              }

              InputDecoration deco(String label, IconData icon, bool visible, VoidCallback toggle) {
                return InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  suffixIcon: IconButton(
                    onPressed: submitting ? null : toggle,
                    icon: Icon(visible ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                );
              }

              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.password_rounded, color: Color(0xFF2563EB)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sau khi đổi mật khẩu thành công, hệ thống sẽ đăng xuất để bạn đăng nhập lại bằng mật khẩu mới.',
                        style: TextStyle(color: Color(0xFF64748B), height: 1.35),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: currentController,
                        enabled: !submitting,
                        obscureText: !showCurrent,
                        decoration: deco(
                          'Mật khẩu hiện tại',
                          Icons.lock_outline_rounded,
                          showCurrent,
                          () => setDialogState(() => showCurrent = !showCurrent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: newController,
                        enabled: !submitting,
                        obscureText: !showNew,
                        decoration: deco(
                          'Mật khẩu mới',
                          Icons.lock_reset_rounded,
                          showNew,
                          () => setDialogState(() => showNew = !showNew),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmController,
                        enabled: !submitting,
                        obscureText: !showConfirm,
                        decoration: deco(
                          'Nhập lại mật khẩu mới',
                          Icons.verified_user_outlined,
                          showConfirm,
                          () => setDialogState(() => showConfirm = !showConfirm),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Hủy'),
                  ),
                  FilledButton.icon(
                    onPressed: submitting ? null : submit,
                    icon: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(submitting ? 'Đang đổi...' : 'Xác nhận'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  Future<void> _showPasswordChangedAndLogout(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Đổi mật khẩu thành công', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(message),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Đăng nhập lại'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    await context.read<AuthProvider>().logout();
  }

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  String _initial(NguoiDung? user) {
    final name = user?.hoTen.trim() ?? '';
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  String _value(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null'
        ? 'Chưa cập nhật'
        : text;
  }

  String _date(DateTime? dt) {
    if (dt == null) return 'Chưa cập nhật';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  String _gender(String? gender) {
    switch ((gender ?? '').trim()) {
      case 'nam':
        return 'Nam';
      case 'nu':
        return 'Nữ';
      case 'khac':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }

  String _role(NguoiDung? user) {
    if (user?.isGiangVien == true) return 'Giảng viên';
    if (user?.isSinhVien == true) return 'Sinh viên';
    return user?.tenVaiTroHienThi.isNotEmpty == true
        ? user!.tenVaiTroHienThi
        : 'Tài khoản';
  }

  String? _code(NguoiDung? user) {
    if (user?.isGiangVien == true) return user?.maGiangVien;
    if (user?.isSinhVien == true) return user?.maSinhVien;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Cài đặt tài khoản',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        actions: [
          IconButton(
            tooltip: 'Tải lại hồ sơ',
            onPressed: _loading || _uploadingAvatar ? null : _loadHoSo,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHoSo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  children: [
                    _HeroProfile(
                      user: user,
                      initial: _initial(user),
                      role: _role(user),
                      code: _code(user),
                      uploading: _uploadingAvatar,
                      onChangeAvatar: _chonVaUploadAvatar,
                    ),
                    const SizedBox(height: 16),
                    _NoteCard(
                      text:
                          'Thông tin cá nhân, thông tin liên lạc và thông tin học vụ chỉ được xem. Nếu cần chỉnh sửa, hãy liên hệ quản trị viên hoặc phòng đào tạo. Bạn chỉ được thay đổi ảnh đại diện.',
                    ),
                    const SizedBox(height: 14),
                    _CardSection(
                      title: 'Bảo mật tài khoản',
                      subtitle: 'Đổi mật khẩu đăng nhập khi cần',
                      icon: Icons.security_rounded,
                      children: [
                        _PasswordButton(onPressed: _showChangePasswordDialog),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _CardSection(
                      title: 'Thông tin cơ bản',
                      subtitle: 'Dữ liệu định danh trong hệ thống',
                      icon: Icons.manage_accounts_rounded,
                      children: [
                        _InfoTile(
                          label: 'Họ và tên',
                          value: _value(user?.hoTen),
                          icon: Icons.person_rounded,
                        ),
                        _InfoTile(
                          label: 'Email liên hệ',
                          value: _value(user?.email),
                          icon: Icons.alternate_email_rounded,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                label: 'Ngày sinh',
                                value: _date(user?.ngaySinh),
                                icon: Icons.calendar_today_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoTile(
                                label: 'Giới tính',
                                value: _gender(user?.gioiTinh),
                                icon: Icons.wc_rounded,
                              ),
                            ),
                          ],
                        ),
                        _LockedInfo(user: user),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _CardSection(
                      title: 'Thông tin liên lạc',
                      subtitle: 'Chỉ hiển thị, không cho phép tự sửa',
                      icon: Icons.contact_phone_rounded,
                      children: [
                        _InfoTile(
                          label: 'Số điện thoại',
                          value: _value(user?.soDienThoai),
                          icon: Icons.phone_android_rounded,
                        ),
                        _InfoTile(
                          label: 'Địa chỉ liên hệ',
                          value: _value(user?.diaChi),
                          icon: Icons.location_on_outlined,
                          minHeight: 86,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HeroProfile extends StatelessWidget {
  final NguoiDung? user;
  final String initial;
  final String role;
  final String? code;
  final bool uploading;
  final VoidCallback onChangeAvatar;

  const _HeroProfile({
    required this.user,
    required this.initial,
    required this.role,
    required this.code,
    required this.uploading,
    required this.onChangeAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = user?.avatar?.trim() ?? '';
    final hasAvatar = avatar.startsWith('http://') || avatar.startsWith('https://');

    return Container(
      width: double.infinity,
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
          Positioned(right: -24, top: -26, child: _DecorCircle(size: 104)),
          Positioned(right: 54, bottom: -48, child: _DecorCircle(size: 90)),
          Column(
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFFEFF6FF),
                          backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                          child: hasAvatar
                              ? null
                              : Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: uploading
                            ? const Padding(
                                padding: EdgeInsets.all(7),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFF2563EB),
                                size: 17,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.hoTen.trim().isNotEmpty == true
                              ? user!.hoTen.trim()
                              : 'Tài khoản',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _HeroPill(icon: Icons.verified_user_rounded, text: role),
                            if (code != null && code!.trim().isNotEmpty)
                              _HeroPill(icon: Icons.badge_rounded, text: code!.trim()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: uploading ? null : onChangeAvatar,
                  icon: uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(uploading ? 'Đang tải ảnh lên...' : 'Tải ảnh đại diện'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.50)),
                    backgroundColor: Colors.white.withOpacity(0.13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PasswordButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.password_rounded),
        label: const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _CardSection({
    required this.title,
    required this.subtitle,
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
        borderRadius: BorderRadius.circular(26),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final double minHeight;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.minHeight = 62,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _LockedInfo extends StatelessWidget {
  final NguoiDung? user;
  const _LockedInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (user?.isGiangVien == true) {
      items.add(_InfoLine(icon: Icons.pin_rounded, label: 'Mã giảng viên', value: user?.maGiangVien ?? 'Chưa có'));
      items.add(_InfoLine(icon: Icons.account_tree_rounded, label: 'Bộ môn', value: user?.tenBoMon ?? 'Chưa phân công'));
      items.add(_InfoLine(icon: Icons.account_balance_rounded, label: 'Khoa', value: user?.tenKhoaGiangVien ?? 'Chưa có'));
    } else if (user?.isSinhVien == true) {
      items.add(_InfoLine(icon: Icons.pin_rounded, label: 'Mã sinh viên', value: user?.maSinhVien ?? 'Chưa có'));
      items.add(_InfoLine(icon: Icons.class_rounded, label: 'Lớp', value: user?.tenLop ?? user?.maLop ?? 'Chưa xếp lớp'));
      items.add(_InfoLine(icon: Icons.account_balance_rounded, label: 'Khoa', value: user?.tenKhoaSinhVien ?? 'Chưa có'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: items),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  const _DecorCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.13),
      ),
    );
  }
}
