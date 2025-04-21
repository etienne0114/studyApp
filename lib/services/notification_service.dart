import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/helpers/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  
  NotificationService._internal() {
    _logger.info('Notification service initialized (placeholder)');
  }

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _logger.info('Notification service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Error initializing notification service', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final androidGranted = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final iosGranted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return (androidGranted ?? false) || (iosGranted ?? false);
    } catch (e, stackTrace) {
      _logger.error('Error requesting notification permissions', e, stackTrace);
      return false;
    }
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    try {
      if (!activity.notificationEnabled) return;

      final now = DateTime.now();
      final notificationTime = DateTime(
        now.year, now.month, now.day,
        activity.startTime.hour, activity.startTime.minute,
      ).subtract(Duration(minutes: activity.notificationMinutesBefore));

      final scheduledTime = notificationTime.isBefore(now) 
          ? notificationTime.add(const Duration(days: 1)) 
          : notificationTime;

      await _scheduleNotification(activity, scheduledTime);
    } catch (e, stackTrace) {
      _logger.error('Error scheduling notification for activity: ${activity.title}', e, stackTrace);
    }
  }

  Future<void> _scheduleNotification(Activity activity, DateTime scheduledTime) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'study_scheduler_channel', 'Study Scheduler Notifications',
        channelDescription: 'Notifications for study activities',
        importance: Importance.high, priority: Priority.high,
        enableVibration: true, enableLights: true,
        color: Color(activity.scheduleColor ?? 0xFF2196F3),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails, iOS: iosDetails,
      );

              await _notifications.zonedSchedule(
        activity.id ?? 0, activity.title,
        'Starting in ${activity.notificationMinutesBefore} minutes',
        tz.TZDateTime.from(scheduledTime, tz.local), details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Updated to use the correct enum
        
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      _logger.info('Scheduled notification for activity: ${activity.title} at $scheduledTime');
    } catch (e, stackTrace) {
      _logger.error('Error scheduling notification', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelActivityNotification(int activityId) async {
    try {
      await _notifications.cancel(activityId);
      _logger.info('Cancelled notification for activity: $activityId');
    } catch (e, stackTrace) {
      _logger.error('Error cancelling notification for activity: $activityId', e, stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('Cancelled all notifications');
    } catch (e, stackTrace) {
      _logger.error('Error cancelling all notifications', e, stackTrace);
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
  }
}