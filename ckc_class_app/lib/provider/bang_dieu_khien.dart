import 'package:flutter/foundation.dart';

import '../model/bao_cao_thong_ke_model.dart';
import '../services/bao_cao_thong_ke_service.dart';

class DashboardProvider extends ChangeNotifier {
  final BaoCaoThongKeService _service = BaoCaoThongKeService();

  Map<String, int>? _adminStats;
  BaoCaoThongKeAdmin? _baoCao;
  bool _isLoading = false;
  String? _error;

  Map<String, int>? get adminStats => _adminStats;
  BaoCaoThongKeAdmin? get baoCao => _baoCao;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _xuLyLoi(dynamic error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchAdminStats() async {
    _error = null;
    _setLoading(true);
    try {
      _baoCao = await _service.layBaoCaoThongKe();
      _adminStats = _baoCao?.tongQuan;
      _error = null;
    } catch (error) {
      _error = _xuLyLoi(error);
      _adminStats = null;
      _baoCao = null;
    } finally {
      _setLoading(false);
    }
  }
}
