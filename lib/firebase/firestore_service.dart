// lib/firebase/firestore_service.dart
//
// SZ Construction Management - Firestore Service
// ------------------------------------------------
// Provides a centralised, type-safe interface to Cloud Firestore.
// All public methods throw [FirestoreException] on failure so callers
// do not need to handle raw FirebaseException instances.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Collection name constants
// ---------------------------------------------------------------------------

/// Namespace for all Firestore collection paths used in the app.
///
/// Usage:
/// ```dart
/// final service = FirestoreService.instance;
/// final docs = await service.getCollection(FirestoreCollections.projects);
/// ```
abstract class FirestoreCollections {
  FirestoreCollections._();

  static const String projects = 'projects';
  static const String workers = 'workers';
  static const String clients = 'clients';
  static const String expenses = 'expenses';
  static const String dailyUpdates = 'daily_updates';
  static const String tasks = 'tasks';
  static const String users = 'users';
  static const String payroll = 'payroll';
  static const String inventory = 'inventory';
  static const String documents = 'documents';
  static const String notifications = 'notifications';
  static const String attendance = 'attendance';
  static const String reports = 'reports';
  static const String settings = 'settings';
}

// ---------------------------------------------------------------------------
// Custom exception
// ---------------------------------------------------------------------------

/// Thrown by [FirestoreService] when a Firestore operation fails.
class FirestoreException implements Exception {
  const FirestoreException({
    required this.message,
    required this.code,
    this.originalException,
  });

  /// Human-readable error message suitable for display.
  final String message;

  /// Short machine-readable code (mirrors Firebase error codes where possible).
  final String code;

  /// The underlying exception, if any.
  final Object? originalException;

  @override
  String toString() =>
      'FirestoreException(code: $code, message: $message)';
}

// ---------------------------------------------------------------------------
// Query filter / order helpers
// ---------------------------------------------------------------------------

/// Describes a single WHERE clause for [FirestoreService.queryCollection].
class QueryFilter {
  const QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;

  /// Supported operators: '==', '!=', '<', '<=', '>', '>=',
  /// 'array-contains', 'array-contains-any', 'in', 'not-in'.
  final String operator;

  final Object? value;
}

/// Describes an ORDER BY clause for [FirestoreService.queryCollection].
class QueryOrder {
  const QueryOrder({required this.field, this.descending = false});

  final String field;
  final bool descending;
}

// ---------------------------------------------------------------------------
// FirestoreService singleton
// ---------------------------------------------------------------------------

/// Provides all Firestore operations needed by SZ Construction Management.
///
/// Obtain the instance via [FirestoreService.instance].
class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService _instance = FirestoreService._internal();

  /// The singleton instance.
  static FirestoreService get instance => _instance;

  /// Underlying [FirebaseFirestore] client. Override in tests.
  @visibleForTesting
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Returns a [CollectionReference] for the given [collection] path.
  CollectionReference<Map<String, dynamic>> _col(String collection) =>
      firestore.collection(collection);

  /// Returns a [DocumentReference] for the given [collection] and [docId].
  DocumentReference<Map<String, dynamic>> _doc(
          String collection, String docId) =>
      firestore.collection(collection).doc(docId);

  /// Maps a raw [FirebaseException] to a [FirestoreException].
  FirestoreException _mapException(Object e, String operation) {
    if (e is FirebaseException) {
      final message = _friendlyMessage(e.code, operation);
      return FirestoreException(
        message: message,
        code: e.code,
        originalException: e,
      );
    }
    return FirestoreException(
      message: 'An unexpected error occurred during $operation.',
      code: 'unknown',
      originalException: e,
    );
  }

  /// Returns a user-friendly message for a given Firebase error code.
  String _friendlyMessage(String code, String operation) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested document was not found.';
      case 'already-exists':
        return 'A document with this ID already exists.';
      case 'resource-exhausted':
        return 'Firestore quota exceeded. Please try again later.';
      case 'unavailable':
        return 'Firestore is currently unavailable. Check your internet connection.';
      case 'deadline-exceeded':
        return 'The operation timed out. Please try again.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'data-loss':
        return 'Unrecoverable data loss or corruption occurred.';
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      default:
        return 'Failed to $operation. (code: $code)';
    }
  }

  /// Applies a list of [QueryFilter]s to a [Query].
  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> query,
    List<QueryFilter> filters,
  ) {
    for (final f in filters) {
      switch (f.operator) {
        case '==':
          query = query.where(f.field, isEqualTo: f.value);
          break;
        case '!=':
          query = query.where(f.field, isNotEqualTo: f.value);
          break;
        case '<':
          query = query.where(f.field, isLessThan: f.value);
          break;
        case '<=':
          query = query.where(f.field, isLessThanOrEqualTo: f.value);
          break;
        case '>':
          query = query.where(f.field, isGreaterThan: f.value);
          break;
        case '>=':
          query = query.where(f.field, isGreaterThanOrEqualTo: f.value);
          break;
        case 'array-contains':
          query = query.where(f.field, arrayContains: f.value);
          break;
        case 'array-contains-any':
          query = query.where(f.field,
              arrayContainsAny: f.value as List<Object?>?);
          break;
        case 'in':
          query =
              query.where(f.field, whereIn: f.value as List<Object?>?);
          break;
        case 'not-in':
          query =
              query.where(f.field, whereNotIn: f.value as List<Object?>?);
          break;
        default:
          debugPrint(
              '[FirestoreService] Unknown filter operator: ${f.operator}');
      }
    }
    return query;
  }

  /// Applies a list of [QueryOrder]s to a [Query].
  Query<Map<String, dynamic>> _applyOrders(
    Query<Map<String, dynamic>> query,
    List<QueryOrder> orders,
  ) {
    for (final o in orders) {
      query = query.orderBy(o.field, descending: o.descending);
    }
    return query;
  }

  // -------------------------------------------------------------------------
  // CRUD — single document operations
  // -------------------------------------------------------------------------

  /// Adds a new document to [collection] with an auto-generated ID.
  ///
  /// Returns the newly created document ID.
  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      // Automatically stamp createdAt / updatedAt.
      final enriched = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final ref = await _col(collection).add(enriched);
      return ref.id;
    } catch (e) {
      throw _mapException(e, 'add document to $collection');
    }
  }

  /// Adds a document to [collection] with the given [docId].
  ///
  /// If [merge] is true, the document is merged with existing data;
  /// otherwise it overwrites completely.
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      final enriched = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!merge) 'createdAt': FieldValue.serverTimestamp(),
      };
      await _doc(collection, docId).set(
        enriched,
        merge ? SetOptions(merge: true) : null,
      );
    } catch (e) {
      throw _mapException(e, 'set document $docId in $collection');
    }
  }

  /// Updates specific fields in the document identified by [docId].
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _doc(collection, docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _mapException(e, 'update document $docId in $collection');
    }
  }

  /// Deletes the document identified by [docId] from [collection].
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _doc(collection, docId).delete();
    } catch (e) {
      throw _mapException(e, 'delete document $docId from $collection');
    }
  }

  /// Fetches a single document. Returns null if the document does not exist.
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      final snap = await _doc(collection, docId).get();
      if (!snap.exists) return null;
      return {'id': snap.id, ...?snap.data()};
    } catch (e) {
      throw _mapException(e, 'get document $docId from $collection');
    }
  }

  // -------------------------------------------------------------------------
  // Collection reads
  // -------------------------------------------------------------------------

  /// Fetches all documents from [collection] (use with caution on large sets).
  ///
  /// Each returned map includes an `'id'` key with the document ID.
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _col(collection);
      query = _applyFilters(query, filters);
      query = _applyOrders(query, orders);
      if (limit != null) query = query.limit(limit);

      final snap = await query.get();
      return snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(growable: false);
    } catch (e) {
      throw _mapException(e, 'get collection $collection');
    }
  }

  /// Fetches a page of documents using cursor-based pagination.
  ///
  /// Pass the last document snapshot from the previous page as
  /// [startAfterDocument] to fetch the next page.
  Future<({List<Map<String, dynamic>> items, DocumentSnapshot? lastDoc})>
      getPaginatedCollection(
    String collection, {
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    required int pageSize,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _col(collection);
      query = _applyFilters(query, filters);
      query = _applyOrders(query, orders);
      query = query.limit(pageSize);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snap = await query.get();
      final items = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(growable: false);

      final lastDoc = snap.docs.isNotEmpty ? snap.docs.last : null;
      return (items: items, lastDoc: lastDoc);
    } catch (e) {
      throw _mapException(e, 'paginate collection $collection');
    }
  }

  // -------------------------------------------------------------------------
  // Query
  // -------------------------------------------------------------------------

  /// Executes an arbitrary query against [collection] and returns the results.
  ///
  /// Example:
  /// ```dart
  /// final results = await firestoreService.queryCollection(
  ///   FirestoreCollections.projects,
  ///   filters: [QueryFilter(field: 'status', operator: '==', value: 'active')],
  ///   orders: [QueryOrder(field: 'createdAt', descending: true)],
  ///   limit: 20,
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    int? limit,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _col(collection);
      query = _applyFilters(query, filters);
      query = _applyOrders(query, orders);
      if (limit != null) query = query.limit(limit);
      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snap = await query.get();
      return snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList(growable: false);
    } catch (e) {
      throw _mapException(e, 'query collection $collection');
    }
  }

  // -------------------------------------------------------------------------
  // Real-time streams
  // -------------------------------------------------------------------------

  /// Returns a stream of all documents in [collection] matching [filters].
  ///
  /// Emits a new list whenever Firestore data changes.
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    List<QueryFilter> filters = const [],
    List<QueryOrder> orders = const [],
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = _col(collection);
      query = _applyFilters(query, filters);
      query = _applyOrders(query, orders);
      if (limit != null) query = query.limit(limit);

      return query.snapshots().map(
            (snap) => snap.docs
                .map((d) => {'id': d.id, ...d.data()})
                .toList(growable: false),
          );
    } catch (e) {
      return Stream.error(_mapException(e, 'stream collection $collection'));
    }
  }

  /// Returns a stream for a single document identified by [docId].
  ///
  /// Emits null when the document does not exist.
  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    try {
      return _doc(collection, docId).snapshots().map(
            (snap) => snap.exists ? {'id': snap.id, ...?snap.data()} : null,
          );
    } catch (e) {
      return Stream.error(_mapException(e, 'stream document $docId'));
    }
  }

  // -------------------------------------------------------------------------
  // Batch operations
  // -------------------------------------------------------------------------

  /// Executes multiple write operations in a single atomic batch.
  ///
  /// [operations] is a list of maps, each with:
  /// - `'type'`: `'set'`, `'update'`, or `'delete'`
  /// - `'collection'`: target collection
  /// - `'docId'`: target document ID
  /// - `'data'`: (for set/update) the data map
  /// - `'merge'`: (optional, for set) whether to merge
  ///
  /// Example:
  /// ```dart
  /// await firestoreService.batchWrite([
  ///   {'type': 'update', 'collection': 'projects', 'docId': 'p1',
  ///    'data': {'status': 'completed'}},
  ///   {'type': 'delete', 'collection': 'tasks',   'docId': 't5'},
  /// ]);
  /// ```
  Future<void> batchWrite(
      List<Map<String, dynamic>> operations) async {
    try {
      final batch = firestore.batch();

      for (final op in operations) {
        final type = op['type'] as String;
        final collection = op['collection'] as String;
        final docId = op['docId'] as String;
        final ref = _doc(collection, docId);

        switch (type) {
          case 'set':
            final data = Map<String, dynamic>.from(
                op['data'] as Map<String, dynamic>);
            data['updatedAt'] = FieldValue.serverTimestamp();
            final merge = op['merge'] as bool? ?? false;
            batch.set(ref, data, merge ? SetOptions(merge: true) : null);
            break;
          case 'update':
            final data = Map<String, dynamic>.from(
                op['data'] as Map<String, dynamic>);
            data['updatedAt'] = FieldValue.serverTimestamp();
            batch.update(ref, data);
            break;
          case 'delete':
            batch.delete(ref);
            break;
          default:
            debugPrint(
                '[FirestoreService] Unknown batch operation type: $type');
        }
      }

      await batch.commit();
    } catch (e) {
      throw _mapException(e, 'batch write');
    }
  }

  /// Deletes multiple documents in a single atomic batch.
  ///
  /// Each entry in [docs] must have `'collection'` and `'docId'` keys.
  Future<void> batchDelete(List<Map<String, String>> docs) async {
    try {
      final batch = firestore.batch();
      for (final doc in docs) {
        final ref = _doc(doc['collection']!, doc['docId']!);
        batch.delete(ref);
      }
      await batch.commit();
    } catch (e) {
      throw _mapException(e, 'batch delete');
    }
  }

  // -------------------------------------------------------------------------
  // Transactions
  // -------------------------------------------------------------------------

  /// Runs a Firestore transaction.
  ///
  /// [transactionHandler] receives a [Transaction] object and must return
  /// the desired result of type [T].
  ///
  /// Example:
  /// ```dart
  /// await firestoreService.runTransaction<void>((txn) async {
  ///   final ref = firestoreService.docRef('inventory', itemId);
  ///   final snap = await txn.get(ref);
  ///   final current = (snap.data()?['quantity'] as int?) ?? 0;
  ///   txn.update(ref, {'quantity': current - 1});
  /// });
  /// ```
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      return await firestore.runTransaction(transactionHandler);
    } catch (e) {
      throw _mapException(e, 'transaction');
    }
  }

  // -------------------------------------------------------------------------
  // Ref accessors (for use in transactions / advanced queries)
  // -------------------------------------------------------------------------

  /// Returns a [DocumentReference] for external use (e.g., inside transactions).
  DocumentReference<Map<String, dynamic>> docRef(
          String collection, String docId) =>
      _doc(collection, docId);

  /// Returns a [CollectionReference] for external use.
  CollectionReference<Map<String, dynamic>> collectionRef(String collection) =>
      _col(collection);

  // -------------------------------------------------------------------------
  // Utility helpers
  // -------------------------------------------------------------------------

  /// Returns the current server timestamp value for use in data maps.
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Returns an increment field value for numeric fields.
  static FieldValue increment(num value) => FieldValue.increment(value);

  /// Returns an arrayUnion field value.
  static FieldValue arrayUnion(List<Object?> elements) =>
      FieldValue.arrayUnion(elements);

  /// Returns an arrayRemove field value.
  static FieldValue arrayRemove(List<Object?> elements) =>
      FieldValue.arrayRemove(elements);

  /// Enables offline persistence (call once at app start after Firebase.initializeApp).
  Future<void> enableOfflinePersistence() async {
    try {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('[FirestoreService] Could not enable persistence: $e');
    }
  }
}
