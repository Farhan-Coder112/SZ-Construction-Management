import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/labour_model.dart';

class LabourProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<LabourModel> _entries = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<LabourModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  List<LabourModel> get todayEntries => _entries.where((e) {
    return e.date.year == _selectedDate.year &&
        e.date.month == _selectedDate.month &&
        e.date.day == _selectedDate.day;
  }).toList();

  int get presentCount => todayEntries.where((e) => e.attendanceStatus == AttendanceStatus.present).length;
  int get absentCount => todayEntries.where((e) => e.attendanceStatus == AttendanceStatus.absent).length;
  int get halfDayCount => todayEntries.where((e) => e.attendanceStatus == AttendanceStatus.halfDay).length;
  double get totalOvertimeHours => todayEntries.fold(0.0, (s, e) => s + e.overtime);

  Future<void> loadEntries({String? projectId, String? workerId}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      String where = 'pending_delete = 0';
      List<dynamic>? args;
      if (projectId != null) { where += ' AND project_id = ?'; args = [projectId]; }
      if (workerId != null) { where += (args != null ? ' AND' : ' AND') + ' worker_id = ?'; args = [...?args, workerId]; }
      final rows = await _db.getAll('labour', where: where, whereArgs: args, orderBy: 'date DESC');
      _entries = rows.map((r) => LabourModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addEntry(LabourModel entry) async {
    await _db.insert('labour', entry.toMap());
    _entries.insert(0, entry);
    notifyListeners();
  }

  Future<void> updateEntry(LabourModel entry) async {
    await _db.update('labour', entry.toMap(), entry.id);
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) { _entries[idx] = entry; notifyListeners(); }
  }

  Future<void> deleteEntry(String id) async {
    await _db.update('labour', {'pending_delete': 1}, id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) { _selectedDate = date; notifyListeners(); }
}
