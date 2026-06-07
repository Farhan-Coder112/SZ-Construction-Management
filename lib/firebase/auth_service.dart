// lib/firebase/auth_service.dart
//
// SZ Construction Management - Authentication Service
// -----------------------------------------------------
// Provides a singleton wrapper around Firebase Auth for all authentication
// operations: sign-in, sign-out, password reset, user creation, profile
// updates, and role-based access control via Firestore user documents.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_service.dart';

// ---------------------------------------------------------------------------
// UserRole enum
// ---------------------------------------------------------------------------

/// Roles available in SZ Construction Management.
enum UserRole {
  /// Full system administrator.
  admin,

  /// Project manager — can manage projects, workers, and expenses.
  manager,

  /// Site supervisor — can post daily updates and manage attendance.
  supervisor,

  /// View-only access for clients.
  client,

  /// Default role assigned when the role is unknown or not yet set.
  unknown;

  /// Returns a [UserRole] from its string representation.
  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'supervisor':
        return UserRole.supervisor;
      case 'client':
        return UserRole.client;
      default:
        return UserRole.unknown;
    }
  }

  /// Returns the display-friendly label.
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Project Manager';
      case UserRole.supervisor:
        return 'Site Supervisor';
      case UserRole.client:
        return 'Client';
      case UserRole.unknown:
        return 'Unknown';
    }
  }
}

// ---------------------------------------------------------------------------
// AuthException
// ---------------------------------------------------------------------------

/// Thrown by [AuthService] when an authentication operation fails.
class AuthException implements Exception {
  const AuthException({
    required this.message,
    required this.code,
    this.originalException,
  });

  /// Human-readable message suitable for display in the UI.
  final String message;

  /// Short machine-readable code (mirrors Firebase Auth error codes).
  final String code;

  /// The underlying [FirebaseAuthException] or other exception, if any.
  final Object? originalException;

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}

// ---------------------------------------------------------------------------
// AppUser value object
// ---------------------------------------------------------------------------

/// Lightweight user object that combines Firebase Auth data with Firestore
/// profile data.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.phoneNumber,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? createdAt;

  /// Creates an [AppUser] from a Firestore document map plus the Firebase
  /// [User] object.
  factory AppUser.fromMap(Map<String, dynamic> map, {User? firebaseUser}) {
    return AppUser(
      uid: map['uid'] as String? ?? firebaseUser?.uid ?? '',
      email: map['email'] as String? ?? firebaseUser?.email ?? '',
      name: map['name'] as String? ?? firebaseUser?.displayName ?? 'Unknown',
      role: UserRole.fromString(map['role'] as String?),
      avatarUrl:
          map['avatarUrl'] as String? ?? firebaseUser?.photoURL,
      phoneNumber:
          map['phoneNumber'] as String? ?? firebaseUser?.phoneNumber,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate?.call() as DateTime?
          : null,
    );
  }

  /// Converts this [AppUser] to a Firestore-compatible map.
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role.name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? avatarUrl,
    String? phoneNumber,
  }) =>
      AppUser(
        uid: uid,
        email: email,
        name: name ?? this.name,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt,
      );
}

// ---------------------------------------------------------------------------
// AuthService singleton
// ---------------------------------------------------------------------------

/// Provides all authentication operations for SZ Construction Management.
///
/// Obtain the instance via [AuthService.instance].
///
/// Example:
/// ```dart
/// await AuthService.instance.signInWithEmail(email, password);
/// final user = AuthService.instance.currentAppUser;
/// ```
class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  /// The singleton instance.
  static AuthService get instance => _instance;

  /// Underlying Firebase Auth client. Override in tests.
  @visibleForTesting
  FirebaseAuth auth = FirebaseAuth.instance;

  /// Firestore service used to read/write user profiles.
  final FirestoreService _firestoreService = FirestoreService.instance;

  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------

  /// The currently signed-in [AppUser], or null if signed out.
  AppUser? _currentAppUser;

  /// Returns the cached [AppUser], if any.
  AppUser? get currentAppUser => _currentAppUser;

  /// Returns the raw Firebase [User], or null if signed out.
  User? get currentUser => auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => auth.currentUser != null;

  // -------------------------------------------------------------------------
  // Auth state stream
  // -------------------------------------------------------------------------

  /// Emits the raw Firebase [User] whenever auth state changes.
  Stream<User?> get authStateStream => auth.authStateChanges();

  /// Emits an [AppUser] (with Firestore profile) or null whenever auth state
  /// changes.
  Stream<AppUser?> get appUserStream => auth.authStateChanges().asyncMap(
        (firebaseUser) async {
          if (firebaseUser == null) {
            _currentAppUser = null;
            return null;
          }
          _currentAppUser = await _fetchAppUser(firebaseUser);
          return _currentAppUser;
        },
      );

  // -------------------------------------------------------------------------
  // Sign in
  // -------------------------------------------------------------------------

  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [AppUser] on success.
  /// Throws [AuthException] on failure.
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Sign-in succeeded but no user was returned.',
          code: 'no-user',
        );
      }

      _currentAppUser = await _fetchAppUser(firebaseUser);
      return _currentAppUser!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'An unexpected error occurred during sign-in.',
        code: 'unknown',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Sign out
  // -------------------------------------------------------------------------

  /// Signs the current user out of Firebase Auth.
  Future<void> signOut() async {
    try {
      await auth.signOut();
      _currentAppUser = null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to sign out.',
        code: 'sign-out-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Password reset
  // -------------------------------------------------------------------------

  /// Sends a password-reset email to [email].
  ///
  /// Throws [AuthException] on failure.
  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to send password reset email.',
        code: 'reset-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // User creation
  // -------------------------------------------------------------------------

  /// Creates a new Firebase Auth user and writes the profile to Firestore.
  ///
  /// [role] defaults to [UserRole.unknown] if omitted.
  /// Returns the created [AppUser].
  Future<AppUser> createUser({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.unknown,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'User creation succeeded but no user was returned.',
          code: 'no-user',
        );
      }

      // Update display name in Firebase Auth.
      await firebaseUser.updateDisplayName(name);

      // Build and persist the Firestore user profile.
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name,
        role: role,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setDocument(
        FirestoreCollections.users,
        firebaseUser.uid,
        appUser.toMap(),
        merge: false,
      );

      _currentAppUser = appUser;
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on FirestoreException catch (e) {
      throw AuthException(
        message: 'User created but profile could not be saved: ${e.message}',
        code: 'profile-save-failed',
        originalException: e,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'An unexpected error occurred during user creation.',
        code: 'unknown',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Profile update
  // -------------------------------------------------------------------------

  /// Updates the display name and optional avatar URL for the current user.
  ///
  /// Updates both Firebase Auth and the Firestore user document.
  Future<AppUser> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException(
        message: 'No user is currently signed in.',
        code: 'no-user',
      );
    }

    try {
      await firebaseUser.updateDisplayName(name);
      if (avatarUrl != null) {
        await firebaseUser.updatePhotoURL(avatarUrl);
      }

      final updateData = <String, dynamic>{'name': name};
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      await _firestoreService.updateDocument(
        FirestoreCollections.users,
        firebaseUser.uid,
        updateData,
      );

      _currentAppUser = _currentAppUser?.copyWith(
            name: name,
            avatarUrl: avatarUrl ?? _currentAppUser?.avatarUrl,
          ) ??
          AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: name,
            role: UserRole.unknown,
            avatarUrl: avatarUrl,
          );

      return _currentAppUser!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to update profile.',
        code: 'update-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Role management
  // -------------------------------------------------------------------------

  /// Returns the [UserRole] for the currently signed-in user by reading from
  /// Firestore. Returns [UserRole.unknown] when no user is signed in or the
  /// Firestore document is missing.
  Future<UserRole> getUserRole() async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) return UserRole.unknown;

    try {
      final doc = await _firestoreService.getDocument(
        FirestoreCollections.users,
        firebaseUser.uid,
      );
      return UserRole.fromString(doc?['role'] as String?);
    } catch (_) {
      return UserRole.unknown;
    }
  }

  /// Updates the Firestore role for a given [uid].
  ///
  /// Should only be called by an admin.
  Future<void> setUserRole(String uid, UserRole role) async {
    try {
      await _firestoreService.updateDocument(
        FirestoreCollections.users,
        uid,
        {'role': role.name},
      );
    } on FirestoreException catch (e) {
      throw AuthException(
        message: 'Failed to update user role: ${e.message}',
        code: 'role-update-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Account deletion
  // -------------------------------------------------------------------------

  /// Permanently deletes the currently signed-in user's Firebase Auth account
  /// and their Firestore user document.
  ///
  /// Note: For sensitive operations Firebase may require recent sign-in.
  /// Consider calling [reauthenticate] first if needed.
  Future<void> deleteAccount() async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException(
        message: 'No user is currently signed in.',
        code: 'no-user',
      );
    }

    try {
      // Remove Firestore profile first (if auth deletion fails, the profile
      // can still be cleaned up later via a Cloud Function).
      await _firestoreService.deleteDocument(
        FirestoreCollections.users,
        firebaseUser.uid,
      );

      await firebaseUser.delete();
      _currentAppUser = null;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Failed to delete account.',
        code: 'delete-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Re-authentication
  // -------------------------------------------------------------------------

  /// Re-authenticates the current user using [email] and [password].
  ///
  /// Required before sensitive operations like [deleteAccount] or email change
  /// when the user has been signed in for a long time.
  Future<void> reauthenticate(String email, String password) async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException(
        message: 'No user is currently signed in.',
        code: 'no-user',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Re-authentication failed.',
        code: 'reauth-failed',
        originalException: e,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Email & password change
  // -------------------------------------------------------------------------

  /// Updates the current user's email address.
  Future<void> updateEmail(String newEmail) async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException(
        message: 'No user is currently signed in.',
        code: 'no-user',
      );
    }
    try {
      await firebaseUser.verifyBeforeUpdateEmail(newEmail.trim());
      await _firestoreService.updateDocument(
        FirestoreCollections.users,
        firebaseUser.uid,
        {'email': newEmail.trim()},
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Changes the current user's password.
  Future<void> updatePassword(String newPassword) async {
    final firebaseUser = auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthException(
        message: 'No user is currently signed in.',
        code: 'no-user',
      );
    }
    try {
      await firebaseUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  /// Fetches and builds an [AppUser] from Firestore for the given Firebase [user].
  Future<AppUser> _fetchAppUser(User user) async {
    try {
      final doc = await _firestoreService.getDocument(
        FirestoreCollections.users,
        user.uid,
      );

      if (doc != null) {
        return AppUser.fromMap(doc, firebaseUser: user);
      }

      // If no Firestore document exists yet, build a minimal user from Auth data.
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        role: UserRole.unknown,
        avatarUrl: user.photoURL,
      );
    } catch (_) {
      // Fallback: return a minimal user based on Auth data only.
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
        role: UserRole.unknown,
        avatarUrl: user.photoURL,
      );
    }
  }

  /// Maps a [FirebaseAuthException] to a user-friendly [AuthException].
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    final message = _friendlyAuthMessage(e.code);
    return AuthException(
      message: message,
      code: e.code,
      originalException: e,
    );
  }

  /// Returns a user-friendly error message for a Firebase Auth error code.
  String _friendlyAuthMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Contact support.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again before performing this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but a different sign-in method.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later or reset your password.';
      case 'expired-action-code':
        return 'The link has expired. Please request a new one.';
      case 'invalid-action-code':
        return 'The link is invalid. It may have already been used.';
      default:
        return 'Authentication failed. (code: $code)';
    }
  }
}
