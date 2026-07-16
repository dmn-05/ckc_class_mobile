import 'package:flutter/material.dart';

/// Đóng bàn phím trước khi đóng dialog/bottom sheet để IME không tiếp tục
/// giữ liên kết với TextField trong lúc route đang chạy animation thoát.
void unfocusCurrentInput() {
  FocusManager.instance.primaryFocus?.unfocus();
}

/// `showDialog`/`showModalBottomSheet` có thể trả Future trước khi animation
/// đóng và việc tháo widget hoàn tất. Chờ thêm một frame và hết thời lượng
/// animation mặc định trước khi dispose TextEditingController được tạo bên
/// ngoài dialog.
Future<void> waitForModalToDispose() async {
  unfocusCurrentInput();
  await WidgetsBinding.instance.endOfFrame;
  await Future<void>.delayed(
    kThemeAnimationDuration + const Duration(milliseconds: 120),
  );
}

/// Dispose một danh sách controller sau khi modal đã tháo hoàn toàn.
Future<void> disposeControllersAfterModal(
  Iterable<TextEditingController> controllers,
) async {
  await waitForModalToDispose();
  for (final controller in controllers) {
    controller.dispose();
  }
}
