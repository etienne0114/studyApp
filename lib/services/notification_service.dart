import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:study_scheduler/data/helpers/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final _logger = Logger('NotificationService');
  static NotificationService get instance => _instance;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
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
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _logger.info('Notification clicked: ${response.payload}');
        },
      );

      await _requestPermissions();

      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.error('Error initializing notification service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final iosPlugin =
          _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      _logger.info('Notification permissions requested successfully');
    } catch (e) {
      _logger.error('Error requesting notification permissions: $e');
    }
  }

  Future<void> scheduleActivityNotification(Activity activity, String title, String s, {
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool isRecurring = false,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'activity_channel',
        'Activity Notifications',
        channelDescription: 'Notifications for scheduled activities',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
            isRecurring ? DateTimeComponents.dayOfWeekAndTime : null,
      );

      _logger.info('Scheduled notification for ${scheduledDate.toIso8601String()}');
    } catch (e) {
      _logger.error('Error scheduling notification: $e');
    }
  }

  Future<void> scheduleRecurringActivityNotification({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'recurring_activity_channel',
        'Recurring Activity Notifications',
        channelDescription: 'Notifications for recurring scheduled activities',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      _logger.info('Scheduled recurring notification for ${scheduledDate.toIso8601String()}');
    } catch (e) {
      _logger.error('Error scheduling recurring notification: $e');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
      _logger.info('Cancelled notification with ID: $notificationId');
    } catch (e) {
      _logger.error('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('Cancelled all notifications');
    } catch (e) {
      _logger.error('Error cancelling all notifications: $e');
    }
  }
}
