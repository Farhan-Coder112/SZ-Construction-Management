import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../firebase/firebase_options.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isManager => _currentUser?.role == UserRole.manager || isAdmin;
  bool get isEmployee => true; // all roles can access employee features

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadUserProfile(user.uid);
      }
    } catch (e) {
      // If Firebase fails (offline), proceed without user
      _currentUser = null;
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final trimmedEmail = email.trim().toLowerCase();
    
    // Demo account bypass check - allows instant sign-in without Firebase configuration
    if (trimmedEmail == 'admin@szgroup.com' && (password == 'admin123' || password == 'admin')) {
      _currentUser = UserModel(
        id: 'offline_admin',
        name: 'SZ Admin (Offline)',
        email: 'admin@szgroup.com',
        role: UserRole.admin,
        phone: '+91 99999 99999',
        createdAt: DateTime.now(),
        isActive: true,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (trimmedEmail == 'manager@szgroup.com' && (password == 'manager123' || password == 'manager')) {
      _currentUser = UserModel(
        id: 'offline_manager',
        name: 'SZ Manager (Offline)',
        email: 'manager@szgroup.com',
        role: UserRole.manager,
        phone: '+91 88888 88888',
        createdAt: DateTime.now(),
        isActive: true,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (trimmedEmail == 'employee@szgroup.com' && (password == 'employee123' || password == 'employee')) {
      _currentUser = UserModel(
        id: 'offline_employee',
        name: 'SZ Employee (Offline)',
        email: 'employee@szgroup.com',
        role: UserRole.employee,
        phone: '+91 77777 77777',
        createdAt: DateTime.now(),
        isActive: true,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // Check if Firebase is using default placeholder options
    bool isPlaceholder = true;
    try {
      isPlaceholder = DefaultFirebaseOptions.currentPlatform.apiKey.startsWith('YOUR_');
    } catch (_) {
      isPlaceholder = true;
    }

    if (isPlaceholder) {
      // If Firebase is not configured, automatically log in as Admin for demo purposes
      _currentUser = UserModel(
        id: 'offline_fallback',
        name: 'Demo Admin (Offline)',
        email: email.trim(),
        role: UserRole.admin,
        phone: '+91 99999 99999',
        createdAt: DateTime.now(),
        isActive: true,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        _currentUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? email.trim(),
          role: UserRole.employee,
          phone: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          isActive: true,
        );
        notifyListeners();
      }

      await _loadUserProfile(credential.user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user profile in Firestore
      final userDoc = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email.trim(),
        role: UserRole.employee,
        phone: phone,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set(userDoc.toFirestore());

      _currentUser = userDoc;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // Create basic user profile if doesn't exist
        final user = FirebaseAuth.instance.currentUser!;
        _currentUser = UserModel(
          id: uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          role: UserRole.employee,
          phone: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          isActive: true,
        );
      }
    } catch (_) {
      // Offline / Firestore unavailable - use Firebase auth user details if available
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUser = UserModel(
          id: uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          role: UserRole.employee,
          phone: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          isActive: true,
        );
      }
    }
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Please try again.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'user-disabled': return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Please check your connection.';
      default: return 'Authentication failed. Please try again.';
    }
  }

  void clearError() { _error = null; notifyListeners(); }
}
