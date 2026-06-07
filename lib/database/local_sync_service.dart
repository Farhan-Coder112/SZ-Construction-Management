import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';

/// Background sync service to keep local SQLite in sync with Firebase Firestore
/// Processes a sync queue when connectivity is restored
class LocalSyncService {
  static LocalSyncService? _instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isOnline = false;

  // External sync handler — set by the app layer
  Future<void> Function(String collection, String docId, String operation, Map<String, dynamic>? data)? onSyncItem;

  LocalSyncService._internal();

  factory LocalSyncService() {
    _instance ??= LocalSyncService._internal();
    return _instance!;
  }

  static LocalSyncService get instance {
    _instance ??= LocalSyncService._internal();
    return _instance!;
  }

  /// Start listening to connectivity changes and periodic sync
  void startSync() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) async {
        final wasOnline = _isOnline;
        _isOnline = results.any((r) => r != ConnectivityResult.none);
        if (!wasOnline && _isOnline) {
          // Just came online - trigger immediate sync
          await _processSyncQueue();
        }
      },
    );

    // Periodic sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (_isOnline) await _processSyncQueue();
    });

    // Initial connectivity check
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline) await _processSyncQueue();
  }

  /// Process all pending sync items in queue
  Future<void> _processSyncQueue() async {
    if (_isSyncing || onSyncItem == null) return;
    _isSyncing = true;

    try {
      final pending = await _db.getPendingSyncQueue();

      for (final item in pending) {
        final id = item['id'] as int;
        final collection = item['collection'] as String;
        final docId = item['document_id'] as String;
        final operation = item['operation'] as String;
        final dataStr = item['data'] as String?;

        Map<String, dynamic>? data;
        if (dataStr != null) {
          data = jsonDecode(dataStr) as Map<String, dynamic>;
        }

        try {
          await onSyncItem!(collection, docId, operation, data);
          await _db.removeSyncQueueItem(id);
        } catch (e) {
          await _db.incrementSyncAttempt(id);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Queue an operation for sync when online
  Future<void> queueSync({
    required String collection,
    required String documentId,
    required String operation,
    Map<String, dynamic>? data,
  }) async {
    await _db.addToSyncQueue(
      collection,
      documentId,
      operation,
      data != null ? jsonEncode(data) : null,
    );

    // If online, process immediately
    if (_isOnline) {
      await _processSyncQueue();
    }
  }

  /// Force sync now
  Future<void> syncNow() async {
    if (_isOnline) await _processSyncQueue();
  }

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
