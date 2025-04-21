// lib/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  
  LocalStorageService._internal();
  
  // Auth token methods
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Refresh token methods
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }
  
  Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }
  
  // Clear tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
  
  // Theme mode
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false;
  }
  
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }
  
  // Notification settings
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }
  
  // User profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson == null) {
      return null;
    }
    
    try {
      return Map<String, dynamic>.from(
        Map<String, dynamic>.from(prefs.get('user_profile') as Map),
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> setUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', profile.toString());
  }
  
  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}