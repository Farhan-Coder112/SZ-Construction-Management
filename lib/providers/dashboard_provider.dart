import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DashboardProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<dynamic>? _connectivitySubscription;
  bool _isOnline = false;

  bool _isLoading = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  List<double> _monthlyExpenses = [];
  List<double> _monthlyRevenue = [];
  List<String> _monthLabels = [];

  DashboardProvider() {
    _setupConnectivityListener();
  }

  bool get isLoading => _isLoading;

  int get totalProjects => (_stats['totalProjects'] as num?)?.toInt() ?? 0;
  int get activeProjects => (_stats['activeProjects'] as num?)?.toInt() ?? 0;
  int get completedProjects => (_stats['completedProjects'] as num?)?.toInt() ?? 0;
  int get totalWorkers => (_stats['totalWorkers'] as num?)?.toInt() ?? 0;
  double get contractValue => (_stats['contractValue'] as num?)?.toDouble() ?? 0;
  double get monthlyExpensesTotal => (_stats['monthlyExpenses'] as num?)?.toDouble() ?? 0;
  double get pendingPayments => (_stats['pendingPayments'] as num?)?.toDouble() ?? 0;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<double> get monthlyExpenses => _monthlyExpenses;
  List<double> get monthlyRevenue => _monthlyRevenue;
  List<String> get monthLabels => _monthLabels;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await DatabaseHelper.instance.getDashboardStats();
      await _loadRecentActivities();
      await _loadMonthlyTrends();
    } catch (error, stackTrace) {
      debugPrint('Dashboard local load failed: $error\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (await _checkInitialConnectivity()) {
      await _loadRemoteDashboard();
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((dynamic results) {
      bool nowOnline = false;
      if (results is ConnectivityResult) {
        nowOnline = results != ConnectivityResult.none;
      } else if (results is Iterable) {
        try {
          nowOnline = results.any((r) => r != ConnectivityResult.none);
        } catch (_) {
          nowOnline = false;
        }
      }

      if (!_isOnline && nowOnline) {
        debugPrint('Dashboard connectivity restored, refreshing dashboard.');
        loadDashboard();
      }
      _isOnline = nowOnline;
    });
    _checkInitialConnectivity();
  }

  Future<bool> _checkInitialConnectivity() async {
    try {
      final dynamic result = await _connectivity.checkConnectivity();
      if (result is ConnectivityResult) {
        _isOnline = result != ConnectivityResult.none;
      } else if (result is Iterable) {
        _isOnline = result.any((r) => r != ConnectivityResult.none);
      } else {
        _isOnline = false;
      }
    } catch (_) {
      _isOnline = false;
    }
    return _isOnline;
  }

  Future<void> _loadRemoteDashboard() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final projectsSnap = await firestore.collection('projects').get();
      final workersSnap = await firestore.collection('workers').get();
      final expensesSnap = await firestore.collection('expenses').get();
      final paymentsSnap = await firestore.collection('payments').get();

      final totalProjects = projectsSnap.docs.length;
      final activeProjects = projectsSnap.docs.where((doc) => doc.data()['status'] == 'active').length;
      final completedProjects = projectsSnap.docs.where((doc) => doc.data()['status'] == 'completed').length;
      final contractValue = projectsSnap.docs.fold<double>(0.0, (total, doc) {
        final value = (doc.data()['contractValue'] as num?)?.toDouble() ?? 0.0;
        return total + value;
      });
      final paidAmount = projectsSnap.docs.fold<double>(0.0, (total, doc) {
        final value = (doc.data()['paidAmount'] as num?)?.toDouble() ?? 0.0;
        return total + value;
      });
      final totalWorkers = workersSnap.docs.length;

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthlyExpenses = expensesSnap.docs.fold<double>(0.0, (total, doc) {
        final date = _extractDate(doc.data()['date']);
        if (date != null && date.isAfter(monthStart.subtract(const Duration(seconds: 1)))) {
          final value = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
          return total + value;
        }
        return total;
      });

      final pendingPayments = paymentsSnap.docs.fold<double>(0.0, (total, doc) {
        final status = doc.data()['status'] as String? ?? '';
        if (['pending', 'partial', 'overdue'].contains(status)) {
          final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
          final paid = (doc.data()['paidAmount'] as num?)?.toDouble() ?? 0.0;
          return total + (amount - paid);
        }
        return total;
      });

      final hasRemoteData = projectsSnap.docs.isNotEmpty || workersSnap.docs.isNotEmpty || expensesSnap.docs.isNotEmpty || paymentsSnap.docs.isNotEmpty;
      if (hasRemoteData) {
        _stats = {
          'totalProjects': totalProjects,
          'activeProjects': activeProjects,
          'completedProjects': completedProjects,
          'contractValue': contractValue,
          'paidAmount': paidAmount,
          'totalWorkers': totalWorkers,
          'monthlyExpenses': monthlyExpenses,
          'pendingPayments': pendingPayments,
        };
      }

      final remoteActivities = <Map<String, dynamic>>[];
      for (final doc in expensesSnap.docs) {
        final data = doc.data();
        remoteActivities.add({
          'type': 'expense',
          'title': data['category'] ?? 'Expense',
          'subtitle': data['vendor_name']?.toString().isNotEmpty == true ? data['vendor_name'] : data['project_name'] ?? '',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0,
          'date': _extractDate(data['createdAt'])?.toIso8601String() ?? '',
        });
      }
      for (final doc in paymentsSnap.docs) {
        final data = doc.data();
        remoteActivities.add({
          'type': 'payment',
          'title': data['reference_name'] ?? 'Payment',
          'subtitle': data['payment_mode']?.toString().toUpperCase() ?? '',
          'amount': (data['paidAmount'] as num?)?.toDouble() ?? 0,
          'date': _extractDate(data['createdAt'])?.toIso8601String() ?? '',
        });
      }
      remoteActivities.sort((a, b) {
        final aDate = DateTime.tryParse(a['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      if (remoteActivities.isNotEmpty) {
        _recentActivities = remoteActivities.take(10).toList();
      }

      await _loadMonthlyTrends(fromRemote: true, expensesSnap: expensesSnap, paymentsSnap: paymentsSnap);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Dashboard remote load failed: $error\n$stackTrace');
      // Remote dashboard data is optional
    }
  }

  DateTime? _extractDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<void> _loadRecentActivities() async {
    final expenses = await DatabaseHelper.instance.getAll(
      'expenses',
      where: 'pending_delete = 0',
      orderBy: 'created_at DESC',
      limit: 5,
    );
    final payments = await DatabaseHelper.instance.getAll(
      'payments',
      where: 'pending_delete = 0',
      orderBy: 'created_at DESC',
      limit: 5,
    );

    final activities = <Map<String, dynamic>>[];
    for (final e in expenses) {
      activities.add({
        'type': 'expense',
        'title': e['category'] ?? 'Expense',
        'subtitle': e['vendor_name']?.toString().isNotEmpty == true ? e['vendor_name'] : e['project_name'] ?? '',
        'amount': e['amount'] ?? 0,
        'date': e['created_at'] ?? '',
      });
    }
    for (final p in payments) {
      activities.add({
        'type': 'payment',
        'title': p['reference_name'] ?? 'Payment',
        'subtitle': p['payment_mode']?.toString().toUpperCase() ?? '',
        'amount': p['paid_amount'] ?? 0,
        'date': p['created_at'] ?? '',
      });
    }

    activities.sort((a, b) {
      final aDate = DateTime.tryParse(a['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    _recentActivities = activities.take(10).toList();
  }

  List<double> _normalizeTrendList(dynamic values) {
    if (values is Iterable) {
      final normalized = values.map((value) => (value as num?)?.toDouble() ?? 0.0).toList();
      if (normalized.length >= 6) {
        return normalized.sublist(normalized.length - 6);
      }

      final padded = List<double>.filled(6, 0.0);
      padded.setRange(6 - normalized.length, 6, normalized);
      return padded;
    }
    return List<double>.filled(6, 0.0);
  }

  Future<void> _loadMonthlyTrends({
    bool fromRemote = false,
    QuerySnapshot<Map<String, dynamic>>? expensesSnap,
    QuerySnapshot<Map<String, dynamic>>? paymentsSnap,
  }) async {
    try {
      if (fromRemote && expensesSnap != null && paymentsSnap != null) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month - 5, 1);
        _monthlyExpenses = List<double>.filled(6, 0);
        _monthlyRevenue = List<double>.filled(6, 0);

        for (final doc in expensesSnap.docs) {
          final date = _extractDate(doc.data()['date']) ?? _extractDate(doc.data()['createdAt']);
          if (date == null) continue;
          final monthIndex = _monthIndex(date, start);
          if (monthIndex >= 0 && monthIndex < 6) {
            _monthlyExpenses[monthIndex] += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
          }
        }
        for (final doc in paymentsSnap.docs) {
          final date = _extractDate(doc.data()['date']) ?? _extractDate(doc.data()['createdAt']);
          if (date == null) continue;
          final monthIndex = _monthIndex(date, start);
          if (monthIndex >= 0 && monthIndex < 6) {
            _monthlyRevenue[monthIndex] += (doc.data()['paidAmount'] as num?)?.toDouble() ?? 0;
          }
        }
      } else {
        final trends = await DatabaseHelper.instance.getMonthlyTrends();
        _monthlyExpenses = _normalizeTrendList(trends['expenses']);
        _monthlyRevenue = _normalizeTrendList(trends['revenue']);
      }
      _monthLabels = List.generate(6, (i) {
        final d = DateTime.now();
        final month = DateTime(d.year, d.month - (5 - i), 1);
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month.month - 1];
      });
    } catch (_) {
      _monthlyExpenses = List.filled(6, 0);
      _monthlyRevenue = List.filled(6, 0);
      _monthLabels = ['M-5', 'M-4', 'M-3', 'M-2', 'M-1', 'Now'];
    }
  }

  int _monthIndex(DateTime date, DateTime start) {
    final months = (date.year - start.year) * 12 + (date.month - start.month);
    return months.clamp(0, 5).toInt();
  }

  Future<void> refresh() async {
    await loadDashboard();
  } 

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
