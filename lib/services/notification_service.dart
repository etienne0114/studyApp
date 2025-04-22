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
    }
  }

  Future<bool> requestPermissions() async {
    try {
      // Request Android permissions
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      // Request iOS permissions
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
          
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return true;
    } catch (e, stackTrace) {
      _logger.error('Error requesting notification permissions', e, stackTrace);
      return false;
    }
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    try {
      if (!activity.notificationEnabled) return;

      // Check permissions first
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (androidImplementation != null) {
        final hasPermission = await androidImplementation.areNotificationsEnabled() ?? false;
        if (!hasPermission) {
          await requestPermissions();
          return; // Don't schedule if we don't have permission
        }
      }

      final now = DateTime.now();
      final notificationTime = DateTime(
        now.year, now.month, now.day,
        activity.startTime.hour, activity.startTime.minute,
      ).subtract(Duration(minutes: activity.notificationMinutesBefore));

      final scheduledTime = notificationTime.isBefore(now) 
          ? notificationTime.add(const Duration(days: 1)) 
          : notificationTime;

      try {
        await _scheduleNotification(activity, scheduledTime);
      } catch (e) {
        if (e.toString().contains('exact_alarms_not_permitted')) {
          // Handle exact alarm permission error gracefully
          _logger.info('Exact alarms not permitted, scheduling inexact notification');
          await _scheduleInexactNotification(activity, scheduledTime);
        } else {
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Error scheduling notification for activity: ${activity.title}', e, stackTrace);
    }
  }

  Future<void> _scheduleInexactNotification(Activity activity, DateTime scheduledTime) async {
    final androidDetails = AndroidNotificationDetails(
      'study_scheduler_channel', 'Study Scheduler Notifications',
      channelDescription: 'Notifications for study activities',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      color: activity.scheduleColorAsColor,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      activity.id ?? 0,
      activity.title,
      'Starting in ${activity.notificationMinutesBefore} minutes',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _scheduleNotification(Activity activity, DateTime scheduledTime) async {
    final androidDetails = AndroidNotificationDetails(
      'study_scheduler_channel', 'Study Scheduler Notifications',
      channelDescription: 'Notifications for study activities',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      color: activity.scheduleColorAsColor,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      activity.id ?? 0,
      activity.title,
      'Starting in ${activity.notificationMinutesBefore} minutes',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
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