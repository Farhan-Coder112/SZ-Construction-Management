// lib/firebase/storage_service.dart
//
// SZ Construction Management - Firebase Storage Service
// -------------------------------------------------------
// Provides a centralised interface to Firebase Storage for all file upload,
// download-URL retrieval, and deletion operations used in the app.
//
// Domain-specific helpers are provided at the bottom of the class for
// uploading worker ID proofs, project documents, expense bills, and daily
// update images.

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

// ---------------------------------------------------------------------------
// StorageException
// ---------------------------------------------------------------------------

/// Thrown by [StorageService] when a Storage operation fails.
class StorageException implements Exception {
  const StorageException({
    required this.message,
    required this.code,
    this.originalException,
  });

  /// Human-readable message suitable for display in the UI.
  final String message;

  /// Short machine-readable code.
  final String code;

  /// The underlying exception, if any.
  final Object? originalException;

  @override
  String toString() => 'StorageException(code: $code, message: $message)';
}

// ---------------------------------------------------------------------------
// UploadProgress
// ---------------------------------------------------------------------------

/// Snapshot of an in-progress upload.
class UploadProgress {
  const UploadProgress({
    required this.bytesTransferred,
    required this.totalBytes,
  });

  final int bytesTransferred;
  final int totalBytes;

  /// Upload progress as a value between 0.0 and 1.0.
  double get fraction =>
      totalBytes > 0 ? bytesTransferred / totalBytes : 0.0;

  /// Upload progress as a percentage string, e.g. "42%".
  String get percentLabel => '${(fraction * 100).toStringAsFixed(0)}%';
}

// ---------------------------------------------------------------------------
// StorageService
// ---------------------------------------------------------------------------

/// Provides all Firebase Storage operations needed by SZ Construction Management.
///
/// Obtain the instance via [StorageService.instance].
///
/// Example:
/// ```dart
/// final url = await StorageService.instance.uploadFile(
///   file,
///   'projects/p123/documents',
/// );
/// ```
class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  /// The singleton instance.
  static StorageService get instance => _instance;

  /// Underlying [FirebaseStorage] client. Override in tests.
  @visibleForTesting
  FirebaseStorage storage = FirebaseStorage.instance;

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Returns a unique filename by appending a timestamp before the extension.
  String _uniqueFilename(String filename) {
    final ext = p.extension(filename);
    final base = p.basenameWithoutExtension(filename);
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${base}_$ts$ext';
  }

  /// Maps a [FirebaseException] to a [StorageException].
  StorageException _mapException(Object e, String operation) {
    if (e is FirebaseException) {
      final message = _friendlyMessage(e.code, operation);
      return StorageException(
        message: message,
        code: e.code,
        originalException: e,
      );
    }
    return StorageException(
      message: 'An unexpected error occurred during $operation.',
      code: 'unknown',
      originalException: e,
    );
  }

  /// Returns a user-friendly message for a Firebase Storage error code.
  String _friendlyMessage(String code, String operation) {
    switch (code) {
      case 'object-not-found':
        return 'The file does not exist in Storage.';
      case 'bucket-not-found':
        return 'The Storage bucket was not found. Check your Firebase configuration.';
      case 'project-not-found':
        return 'Firebase project not found.';
      case 'quota-exceeded':
        return 'Firebase Storage quota exceeded. Please contact support.';
      case 'unauthenticated':
        return 'You must be signed in to $operation.';
      case 'unauthorized':
        return 'You do not have permission to $operation.';
      case 'retry-limit-exceeded':
        return 'Upload failed after multiple retries. Check your connection.';
      case 'invalid-checksum':
        return 'File checksum mismatch. Please try uploading again.';
      case 'canceled':
        return 'The $operation was cancelled.';
      case 'invalid-url':
        return 'The provided Storage URL is invalid.';
      case 'no-default-bucket':
        return 'No default Firebase Storage bucket is configured.';
      case 'cannot-slice-blob':
        return 'Failed to read the file. It may be corrupt.';
      case 'server-file-wrong-size':
        return 'Upload failed: file size mismatch. Please try again.';
      default:
        return 'Failed to $operation. (code: $code)';
    }
  }

  // -------------------------------------------------------------------------
  // Core upload methods
  // -------------------------------------------------------------------------

  /// Uploads a [File] to the given [storagePath] directory.
  ///
  /// The filename is taken from the file's base name and a timestamp is
  /// appended to ensure uniqueness.
  ///
  /// [onProgress] is called during the upload with [UploadProgress] snapshots.
  ///
  /// Returns the public download URL of the uploaded file.
  Future<String> uploadFile(
    File file,
    String storagePath, {
    void Function(UploadProgress)? onProgress,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final filename = _uniqueFilename(p.basename(file.path));
      final ref = storage.ref().child('$storagePath/$filename');

      final metadata = SettableMetadata(
        contentType: _inferContentType(file.path),
        customMetadata: customMetadata,
      );

      final task = ref.putFile(file, metadata);

      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          onProgress(UploadProgress(
            bytesTransferred: snapshot.bytesTransferred,
            totalBytes: snapshot.totalBytes,
          ));
        });
      }

      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      throw _mapException(e, 'upload file');
    }
  }

  /// Uploads raw bytes ([Uint8List]) as a file.
  ///
  /// [filename] determines the name used in Storage; a timestamp is appended
  /// for uniqueness.
  ///
  /// Returns the public download URL of the uploaded file.
  Future<String> uploadBytes(
    Uint8List bytes,
    String storagePath,
    String filename, {
    String? contentType,
    void Function(UploadProgress)? onProgress,
    Map<String, String>? customMetadata,
  }) async {
    try {
      final uniqueName = _uniqueFilename(filename);
      final ref = storage.ref().child('$storagePath/$uniqueName');

      final metadata = SettableMetadata(
        contentType: contentType ?? _inferContentType(filename),
        customMetadata: customMetadata,
      );

      final task = ref.putData(bytes, metadata);

      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          onProgress(UploadProgress(
            bytesTransferred: snapshot.bytesTransferred,
            totalBytes: snapshot.totalBytes,
          ));
        });
      }

      await task;
      return await ref.getDownloadURL();
    } catch (e) {
      throw _mapException(e, 'upload bytes');
    }
  }

  /// Uploads a file and returns both the download URL and a progress stream.
  ///
  /// The returned [Stream<UploadProgress>] emits progress events.
  /// Await [downloadUrlFuture] on the returned record for the final URL.
  ///
  /// Example:
  /// ```dart
  /// final (stream, urlFuture) =
  ///     StorageService.instance.uploadFileWithProgress(file, 'projects');
  /// stream.listen((p) => setState(() => progress = p.fraction));
  /// final url = await urlFuture;
  /// ```
  ({Stream<UploadProgress> progressStream, Future<String> downloadUrl})
      uploadFileWithProgress(
    File file,
    String storagePath, {
    Map<String, String>? customMetadata,
  }) {
    final filename = _uniqueFilename(p.basename(file.path));
    final ref = storage.ref().child('$storagePath/$filename');

    final metadata = SettableMetadata(
      contentType: _inferContentType(file.path),
      customMetadata: customMetadata,
    );

    final task = ref.putFile(file, metadata);

    final progressStream = task.snapshotEvents.map((snap) => UploadProgress(
          bytesTransferred: snap.bytesTransferred,
          totalBytes: snap.totalBytes,
        ));

    final downloadUrl = task.then((_) => ref.getDownloadURL()).catchError(
          (Object e) => throw _mapException(e, 'upload with progress'),
        );

    return (progressStream: progressStream, downloadUrl: downloadUrl);
  }

  // -------------------------------------------------------------------------
  // Download URL
  // -------------------------------------------------------------------------

  /// Returns the download URL for a file at the given [storagePath].
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      return await storage.ref(storagePath).getDownloadURL();
    } catch (e) {
      throw _mapException(e, 'get download URL');
    }
  }

  // -------------------------------------------------------------------------
  // Delete
  // -------------------------------------------------------------------------

  /// Deletes the file at [downloadUrl] from Firebase Storage.
  ///
  /// Accepts a full download URL (as returned by [uploadFile]) or a Storage
  /// reference path.
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      throw _mapException(e, 'delete file');
    }
  }

  /// Deletes the file at the given Storage [path].
  Future<void> deleteByPath(String path) async {
    try {
      await storage.ref(path).delete();
    } catch (e) {
      throw _mapException(e, 'delete file by path');
    }
  }

  // -------------------------------------------------------------------------
  // Metadata
  // -------------------------------------------------------------------------

  /// Returns the metadata for a file at [storagePath].
  Future<FullMetadata> getMetadata(String storagePath) async {
    try {
      return await storage.ref(storagePath).getMetadata();
    } catch (e) {
      throw _mapException(e, 'get metadata');
    }
  }

  // -------------------------------------------------------------------------
  // Domain-specific upload helpers
  // -------------------------------------------------------------------------

  // Storage path constants — adjust to suit your bucket structure.
  static const String _workerIdProofsPath = 'workers/id_proofs';
  static const String _projectDocumentsPath = 'projects/documents';
  static const String _expenseBillsPath = 'expenses/bills';
  static const String _dailyUpdateImagesPath = 'daily_updates/images';
  static const String _avatarsPath = 'users/avatars';

  /// Uploads a worker's ID proof document.
  ///
  /// [workerId] is appended to the path so all files for a worker are grouped.
  /// Returns the download URL.
  Future<String> uploadWorkerIdProof(
    File file,
    String workerId, {
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadFile(
      file,
      '$_workerIdProofsPath/$workerId',
      onProgress: onProgress,
      customMetadata: {'workerId': workerId, 'type': 'id_proof'},
    );
  }

  /// Uploads a project-related document (PDF, image, spreadsheet, etc.).
  ///
  /// [projectId] is used to namespace the files.
  /// Returns the download URL.
  Future<String> uploadProjectDocument(
    File file,
    String projectId, {
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadFile(
      file,
      '$_projectDocumentsPath/$projectId',
      onProgress: onProgress,
      customMetadata: {'projectId': projectId, 'type': 'project_document'},
    );
  }

  /// Uploads an expense bill / receipt image or PDF.
  ///
  /// [expenseId] and [projectId] are embedded as metadata.
  /// Returns the download URL.
  Future<String> uploadExpenseBill(
    File file,
    String expenseId, {
    String? projectId,
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadFile(
      file,
      '$_expenseBillsPath/$expenseId',
      onProgress: onProgress,
      customMetadata: {
        'expenseId': expenseId,
        'type': 'expense_bill',
        if (projectId != null) 'projectId': projectId,
      },
    );
  }

  /// Uploads an image attached to a daily site update.
  ///
  /// [updateId] is used to namespace the images.
  /// Returns the download URL.
  Future<String> uploadDailyUpdateImage(
    File file,
    String updateId, {
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadFile(
      file,
      '$_dailyUpdateImagesPath/$updateId',
      onProgress: onProgress,
      customMetadata: {'updateId': updateId, 'type': 'daily_update_image'},
    );
  }

  /// Uploads raw bytes for a daily update image (useful on web/desktop where
  /// [File] may not be available).
  ///
  /// Returns the download URL.
  Future<String> uploadDailyUpdateImageBytes(
    Uint8List bytes,
    String updateId,
    String filename, {
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadBytes(
      bytes,
      '$_dailyUpdateImagesPath/$updateId',
      filename,
      onProgress: onProgress,
      customMetadata: {'updateId': updateId, 'type': 'daily_update_image'},
    );
  }

  /// Uploads a user avatar image.
  ///
  /// [userId] is used to namespace the avatar.
  /// Returns the download URL.
  Future<String> uploadAvatar(
    File file,
    String userId, {
    void Function(UploadProgress)? onProgress,
  }) async {
    return uploadFile(
      file,
      '$_avatarsPath/$userId',
      onProgress: onProgress,
      customMetadata: {'userId': userId, 'type': 'avatar'},
    );
  }

  // -------------------------------------------------------------------------
  // Private utility
  // -------------------------------------------------------------------------

  /// Infers a MIME content type from a file extension.
  String _inferContentType(String filename) {
    final ext = p.extension(filename).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.csv':
        return 'text/csv';
      case '.txt':
        return 'text/plain';
      case '.json':
        return 'application/json';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }
}
