import 'package:flutter/foundation.dart';

/// ChangeNotifier an toàn cho những provider được tạo theo từng màn hình.
///
/// Một request có thể hoàn thành sau khi người dùng đã rời màn hình và provider
/// đã bị dispose. Khi đó ChangeNotifier mặc định sẽ ném lỗi nếu code còn gọi
/// notifyListeners(). Lớp này giữ nguyên toàn bộ logic khi provider còn sống và
/// chỉ bỏ qua lần thông báo đến widget tree đã bị tháo.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
