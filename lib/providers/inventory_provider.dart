import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/inventory_model.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<InventoryModel> _allItems = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<InventoryModel> get items {
    if (_searchQuery.isEmpty) return _allItems;
    final q = _searchQuery.toLowerCase();
    return _allItems.where((i) => i.materialName.toLowerCase().contains(q) || i.supplier.toLowerCase().contains(q)).toList();
  }

  List<InventoryModel> get lowStockItems => _allItems.where((i) => i.isLowStock && !i.isOutOfStock).toList();
  List<InventoryModel> get outOfStockItems => _allItems.where((i) => i.isOutOfStock).toList();
  double get totalInventoryValue => _allItems.fold(0.0, (s, i) => s + i.totalCost);

  Future<void> loadInventory({String? projectId}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      String where = 'pending_delete = 0';
      List<dynamic>? args;
      if (projectId != null) { where += ' AND project_id = ?'; args = [projectId]; }
      final rows = await _db.getAll('inventory', where: where, whereArgs: args, orderBy: 'material_name ASC');
      _allItems = rows.map((r) => InventoryModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addItem(InventoryModel item) async {
    await _db.insert('inventory', item.toMap());
    _allItems.add(item);
    _allItems.sort((a, b) => a.materialName.compareTo(b.materialName));
    notifyListeners();
  }

  Future<void> updateItem(InventoryModel item) async {
    await _db.update('inventory', item.toMap(), item.id);
    final idx = _allItems.indexWhere((i) => i.id == item.id);
    if (idx >= 0) { _allItems[idx] = item; notifyListeners(); }
  }

  Future<void> deleteItem(String id) async {
    await _db.update('inventory', {'pending_delete': 1}, id);
    _allItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  InventoryModel? getById(String id) {
    try { return _allItems.firstWhere((i) => i.id == id); }
    catch (_) { return null; }
  }

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
}
