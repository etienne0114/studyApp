// lib/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:study_scheduler/services/local_storage_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthService extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  AuthStatus _status = AuthStatus.unknown;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor - Check if user is already authenticated
  AuthService() {
    try {
      _checkAuthStatus();
    } catch (e) {
      print('Error initializing AuthService: $e');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Check auth status from stored token
  Future<void> _checkAuthStatus() async {
    try {
      final userData = await _storageService.getUserData();
      
      if (userData != null) {
        _userData = userData;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      // Handle any error during auth check
      print('Error checking auth status: $e');
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _errorMessage = null;
      
      // In offline mode, we'll accept any valid-looking credentials
      if (email.contains('@') && password.length >= 6) {
        final user = {
          'id': 1,
          'name': email.split('@')[0],
          'email': email,
        };
        
        // Save user data
        await _storageService.setUserData(user);
        _userData = user;
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to sign in: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register(String name, String email, String password) async {
    try {
      _errorMessage = null;
      
      // Simple validation
      if (name.isEmpty || !email.contains('@') || password.length < 6) {
        _errorMessage = 'Please provide valid name, email and password';
        notifyListeners();
        return false;
      }
      
      // In offline mode, just create the user
      final user = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name,
        'email': email,
      };
      
      // Save user data and authenticate
      await _storageService.setUserData(user);
      _userData = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear user data
      await _storageService.clearUserData();
      _userData = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      // Ignore errors during sign out
      if (kDebugMode) {
        print('Error during sign out: $e');
      }
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      // Merge with existing data
      final updatedData = {...?_userData, ...userData};
      await _storageService.setUserData(updatedData);
      _userData = updatedData;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      return false;
    }
  }

  // Reset password (mock implementation)
  Future<bool> resetPassword(String email) async {
    try {
      // Just pretend we sent a reset email
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      return false;
    }
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}