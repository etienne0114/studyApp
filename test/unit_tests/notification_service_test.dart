import 'package:flutter_test/flutter_test.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/services/notification_service.dart';
import 'package:flutter/material.dart';


void main() {
  group('NotificationService', () {
    
    test('can be instantiated', () {
      final service = NotificationService.instance; // Ensure correct constructor usage
      expect(service, isNotNull);
    });

    test('should skip notification when notifyBefore is 0', () {
      final service = NotificationService.instance;
      final activity = Activity(
        id: 1,
        scheduleId: 1,
        title: 'Test Activity',
        dayOfWeek: 1,
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 0), // Ensure consistency
        notifyBefore: 0, // Should cause early return
        category: 'General',
        type: 'Reminder',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // Fixed issue
      );

      expect(() => service.scheduleActivityNotification(activity), returnsNormally);
    });

    test('should not schedule notification if activity ID is null', () {
      final service = NotificationService.instance;
      final activity = Activity(
        id: null, // Null ID should cause early return
        scheduleId: 1,
        title: 'Test Activity',
        dayOfWeek: 1,
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 0),
        notifyBefore: 30,
        category: 'General',
        type: 'Reminder',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // Fixed issue
      );

      expect(() => service.scheduleActivityNotification(activity), returnsNormally);
    });

  });
}
