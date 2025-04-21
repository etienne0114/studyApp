// lib/constants/app_constants.dart

class AppConstants {
  // API URL
  static const String apiBaseUrl = 'https://api.studyscheduler.com/v1';
  
  // Shared Preferences Keys
  static const String prefAuthToken = 'auth_token';
  static const String prefRefreshToken = 'refresh_token';
  static const String prefUser = 'user_profile';
  static const String prefDarkMode = 'dark_mode';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLanguage = 'app_language';
  
  // Notification Channels
  static const String notificationChannelId = 'study_scheduler_channel';
  static const String notificationChannelName = 'Study Scheduler Notifications';
  static const String notificationChannelDescription = 'Notifications for scheduled study activities';
  
  // Database
  static const String databaseName = 'study_scheduler.db';
  static const int databaseVersion = 1;
  
  // Activity Default Values
  static const int defaultNotifyBefore = 30; // 30 minutes before
  static const bool defaultIsRecurring = true;
  
  // User Roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';
  
  // Study Material Types
  static const List<String> materialTypes = [
    'Document',
    'Video',
    'Article',
    'Quiz',
    'Practice',
    'Reference',
  ];
  
  // Activity Days
  static const Map<int, String> dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  
  // Notification Times
  static const List<int> notificationTimes = [5, 10, 15, 30, 60, 120];
  
  // App Version
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}