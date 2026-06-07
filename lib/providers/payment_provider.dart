import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;
  PaymentType? _typeFilter;
  PaymentStatus? _statusFilter;

  /// Callback to notify other providers (e.g. DashboardProvider) when data changes
  VoidCallback? onDataChanged;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PaymentModel> get payments {
    return _payments.where((p) {
      if (_typeFilter != null && p.type != _typeFilter) return false;
      if (_statusFilter != null && p.status != _statusFilter) return false;
      return true;
    }).toList();
  }

  List<PaymentModel> get labourPayments => _payments.where((p) => p.type == PaymentType.labourPayment).toList();
  List<PaymentModel> get clientPayments => _payments.where((p) => p.type == PaymentType.clientPayment).toList();
  double get totalPaid => _payments.fold(0.0, (s, p) => s + p.paidAmount);
  double get totalPending => _payments.fold(0.0, (s, p) => s + p.dueAmount);

  Future<void> loadPayments({String? referenceId}) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      String where = 'pending_delete = 0';
      List<dynamic>? args;
      if (referenceId != null) { where += ' AND reference_id = ?'; args = [referenceId]; }
      final rows = await _db.getAll('payments', where: where, whereArgs: args, orderBy: 'date DESC');
      _payments = rows.map((r) => PaymentModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _db.insert('payments', payment.toMap());
    _payments.insert(0, payment);
    notifyListeners();
    onDataChanged?.call();
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _db.update('payments', payment.toMap(), payment.id);
    final idx = _payments.indexWhere((p) => p.id == payment.id);
    if (idx >= 0) { _payments[idx] = payment; notifyListeners(); }
    onDataChanged?.call();
  }

  Future<void> deletePayment(String id) async {
    await _db.update('payments', {'pending_delete': 1}, id);
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
    onDataChanged?.call();
  }

  void setFilters({PaymentType? type, PaymentStatus? status}) {
    _typeFilter = type; _statusFilter = status; notifyListeners();
  }
}
