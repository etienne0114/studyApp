// lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Keys
  static const String _userDataKey = 'user_data';

  // Save user data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear user data (logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  // Legacy methods to maintain compatibility
  Future<String?> getAuthToken() async {
    // In our offline mode, we'll consider having userData as having a token
    final userData = await getUserData();
    return userData != null ? 'offline-token' : null;
  }

  Future<String?> getRefreshToken() async {
    final userData = await getUserData();
    return userData != null ? 'offline-refresh-token' : null;
  }

  Future<void> setAuthToken(String token) async {
    // This is handled by setUserData now
  }

  Future<void> setRefreshToken(String token) async {
    // This is handled by setUserData now
  }

  Future<void> clearTokens() async {
    await clearUserData();
  }
}