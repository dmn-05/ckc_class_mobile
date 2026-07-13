import 'package:flutter/foundation.dart';

import '../model/xuat_excel_model.dart';
import '../services/xuat_excel_service.dart';

class XuatExcelProvider extends ChangeNotifier {
  final XuatExcelService _service = XuatExcelService();

  final String? loaiMacDinh;
  final Map<String, dynamic> boLocMacDinh;
  final List<int> selectedIds;

  XuatExcelProvider({
    this.loaiMacDinh,
    this.boLocMacDinh = const {},
    this.selectedIds = const [],
  });

  List<XuatExcelLoai> _types = [];
  XuatExcelDanhMuc _catalog = XuatExcelDanhMuc.empty;
  XuatExcelLoai? _selectedType;
  String _scope = 'theo_bo_loc';
  Map<String, dynamic> _filters = {};
  Set<String> _selectedColumns = {};
  XuatExcelXemTruoc? _preview;
  bool _loading = false;
  bool _previewing = false;
  bool _exporting = false;
  String? _error;

  List<XuatExcelLoai> get types => _types;
  XuatExcelDanhMuc get catalog => _catalog;
  XuatExcelLoai? get selectedType => _selectedType;
  String get scope => _scope;
  Map<String, dynamic> get filters => Map.unmodifiable(_filters);
  Set<String> get selectedColumns => Set.unmodifiable(_selectedColumns);
  XuatExcelXemTruoc? get preview => _preview;
  bool get loading => _loading;
  bool get previewing => _previewing;
  bool get exporting => _exporting;
  String? get error => _error;
  bool get hasSelectedIds => selectedIds.isNotEmpty;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.layDanhSachLoai(),
        _service.layDanhMuc(),
      ]);
      _types = results[0] as List<XuatExcelLoai>;
      _catalog = results[1] as XuatExcelDanhMuc;

      if (_types.isNotEmpty) {
        final index = _types.indexWhere((e) => e.key == loaiMacDinh);
        _selectedType = index >= 0 ? _types[index] : _types.first;
        _selectedColumns = _selectedType!.cotMacDinh;
        _filters = Map<String, dynamic>.from(boLocMacDinh);
        if (hasSelectedIds) _scope = 'da_chon';
      }
    } catch (e) {
      _error = _cleanError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setType(String key) {
    final type = _types.where((e) => e.key == key).firstOrNull;
    if (type == null) return;
    _selectedType = type;
    _selectedColumns = type.cotMacDinh;
    _filters = {};
    if (_scope == 'da_chon' && key != loaiMacDinh) {
      _scope = 'theo_bo_loc';
    }
    _preview = null;
    _error = null;
    notifyListeners();
  }

  void setScope(String value) {
    if (value == 'da_chon' && !hasSelectedIds) return;
    _scope = value;
    _preview = null;
    notifyListeners();
  }

  void setFilter(String key, dynamic value) {
    if (value == null || value == '' || value == 0) {
      _filters.remove(key);
    } else {
      _filters[key] = value;
    }

    if (key == 'khoa_id') {
      _filters.remove('bo_mon_id');
      if (_selectedType?.key == 'sinh_vien') {
        _filters.remove('lop_id');
      }
    }
    _preview = null;
    notifyListeners();
  }

  void toggleColumn(String key, bool selected) {
    if (selected) {
      _selectedColumns.add(key);
    } else if (_selectedColumns.length > 1) {
      _selectedColumns.remove(key);
    }
    _preview = null;
    notifyListeners();
  }

  void selectDefaultColumns() {
    _selectedColumns = _selectedType?.cotMacDinh ?? {};
    _preview = null;
    notifyListeners();
  }

  void selectAllColumns() {
    _selectedColumns = _selectedType?.columns.map((e) => e.key).toSet() ?? {};
    _preview = null;
    notifyListeners();
  }

  void clearFilters() {
    _filters = {};
    _preview = null;
    notifyListeners();
  }

  Future<bool> previewData() async {
    if (_selectedType == null) return false;
    _previewing = true;
    _error = null;
    notifyListeners();
    try {
      _preview = await _service.xemTruoc(
        loaiXuat: _selectedType!.key,
        phamVi: _scope,
        boLoc: _filters,
        cotXuat: _selectedColumns,
        selectedIds: selectedIds,
      );
      return true;
    } catch (e) {
      _preview = null;
      _error = _cleanError(e);
      return false;
    } finally {
      _previewing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> exportData({required String tenFile}) async {
    if (_selectedType == null) {
      return {'success': false, 'message': 'Chưa chọn loại dữ liệu xuất'};
    }

    if (tenFile.trim().isEmpty) {
      return {'success': false, 'message': 'Tên file không được để trống'};
    }
    _exporting = true;
    _error = null;
    notifyListeners();
    try {
      final fileName = await _service.taoVaTaiFile(
        loaiXuat: _selectedType!.key,
        phamVi: _scope,
        boLoc: _filters,
        cotXuat: _selectedColumns,
        selectedIds: selectedIds,
        tenFile: tenFile.trim(),
      );
      return {
        'success': true,
        'message': 'Đã tạo file $fileName. Trình tải file đang được mở.',
      };
    } catch (e) {
      final message = _cleanError(e);
      _error = message;
      return {'success': false, 'message': message};
    } finally {
      _exporting = false;
      notifyListeners();
    }
  }

  String _cleanError(dynamic error) {
    var text = error.toString();
    if (text.startsWith('Exception: ')) {
      text = text.replaceFirst('Exception: ', '');
    }
    return text;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
