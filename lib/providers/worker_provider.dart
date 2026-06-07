import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/worker_model.dart';

class WorkerProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<WorkerModel> _allWorkers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  WorkerCategory? _categoryFilter;

  List<WorkerModel> get allWorkers => _allWorkers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WorkerModel> get workers {
    return _allWorkers.where((w) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!w.name.toLowerCase().contains(q) && !w.phone.contains(q)) return false;
      }
      if (_categoryFilter != null && w.category != _categoryFilter) return false;
      return true;
    }).toList();
  }

  List<WorkerModel> get activeWorkers => _allWorkers.where((w) => w.status == WorkerStatus.active).toList();
  List<WorkerModel> get inactiveWorkers => _allWorkers.where((w) => w.status != WorkerStatus.active).toList();

  Future<void> loadWorkers() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final rows = await _db.getAll('workers', where: 'pending_delete = 0', orderBy: 'name ASC');
      _allWorkers = rows.map((r) => WorkerModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addWorker(WorkerModel worker) async {
    await _db.insert('workers', worker.toMap());
    _allWorkers.add(worker);
    _allWorkers.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> updateWorker(WorkerModel worker) async {
    await _db.update('workers', worker.toMap(), worker.id);
    final idx = _allWorkers.indexWhere((w) => w.id == worker.id);
    if (idx >= 0) { _allWorkers[idx] = worker; notifyListeners(); }
  }

  Future<void> deleteWorker(String id) async {
    await _db.update('workers', {'pending_delete': 1}, id);
    _allWorkers.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  WorkerModel? getById(String id) {
    try { return _allWorkers.firstWhere((w) => w.id == id); }
    catch (_) { return null; }
  }

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
  void setCategoryFilter(WorkerCategory? cat) { _categoryFilter = cat; notifyListeners(); }
  void clearFilters() { _searchQuery = ''; _categoryFilter = null; notifyListeners(); }
}
