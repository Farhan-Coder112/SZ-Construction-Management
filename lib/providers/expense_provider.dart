import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<ExpenseModel> _allExpenses = [];
  bool _isLoading = false;
  String? _error;
  ExpenseCategory? _categoryFilter;
  String? _projectIdFilter;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  /// Callback to notify other providers (e.g. DashboardProvider) when data changes
  VoidCallback? onDataChanged;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExpenseModel> get expenses {
    return _allExpenses.where((e) {
      if (_categoryFilter != null && e.category != _categoryFilter) return false;
      if (_projectIdFilter != null && e.projectId != _projectIdFilter) return false;
      if (_dateFrom != null && e.date.isBefore(_dateFrom!)) return false;
      if (_dateTo != null && e.date.isAfter(_dateTo!)) return false;
      return true;
    }).toList();
  }

  double get totalAmount => expenses.fold(0.0, (s, e) => s + e.amount);

  Map<ExpenseCategory, double> get amountByCategory {
    final map = <ExpenseCategory, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> loadExpenses({String? projectId}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      String where = 'pending_delete = 0';
      List<dynamic>? args;
      if (projectId != null) { where += ' AND project_id = ?'; args = [projectId]; }
      final rows = await _db.getAll('expenses', where: where, whereArgs: args, orderBy: 'date DESC');
      _allExpenses = rows.map((r) => ExpenseModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _db.insert('expenses', expense.toMap());
    _allExpenses.insert(0, expense);
    notifyListeners();
    onDataChanged?.call();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _db.update('expenses', expense.toMap(), expense.id);
    final idx = _allExpenses.indexWhere((e) => e.id == expense.id);
    if (idx >= 0) { _allExpenses[idx] = expense; notifyListeners(); }
    onDataChanged?.call();
  }

  Future<void> deleteExpense(String id) async {
    await _db.update('expenses', {'pending_delete': 1}, id);
    _allExpenses.removeWhere((e) => e.id == id);
    notifyListeners();
    onDataChanged?.call();
  }

  void setFilters({ExpenseCategory? category, String? projectId, DateTime? from, DateTime? to}) {
    _categoryFilter = category; _projectIdFilter = projectId;
    _dateFrom = from; _dateTo = to;
    notifyListeners();
  }

  void clearFilters() {
    _categoryFilter = null; _projectIdFilter = null; _dateFrom = null; _dateTo = null;
    notifyListeners();
  }
}
