// lib/data/repositories/schedule_repository.dart

import 'package:flutter/foundation.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/services/notification_service.dart';
import 'package:study_scheduler/data/helpers/logger.dart';

class ScheduleRepository extends ChangeNotifier {
  final DatabaseHelper dbHelper;
  final NotificationService notificationService;
  final Logger _logger = Logger('ScheduleRepository');

  ScheduleRepository({
    required this.dbHelper, 
    required this.notificationService,
  });

  // Schedule operations
  Future<List<Schedule>> getAllSchedules() async {
    return await dbHelper.getSchedules();
  }

  Future<Schedule?> getScheduleById(int id) async {
    return await dbHelper.getSchedule(id);
  }

  Future<int> createSchedule(Schedule schedule) async {
    return await dbHelper.insertSchedule(schedule);
  }

  Future<int> updateSchedule(Schedule schedule) async {
    return await dbHelper.updateSchedule(schedule);
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      // Get all activities for this schedule
      final activities = await dbHelper.getActivitiesByScheduleId(id);
      
      // Cancel notifications for activities
      for (final activity in activities) {
        if (activity.notificationEnabled && activity.id != null) {
          await notificationService.cancelNotification(activity.id!);
        }
      }
      
      // Delete the schedule
      final result = await dbHelper.deleteSchedule(id);
      return result > 0;
    } catch (e, stackTrace) {
      _logger.error('Error deleting schedule: $id', e, stackTrace);
      return false;
    }
  }

  // Activity operations
  Future<List<Activity>> getAllActivities() async {
    return await dbHelper.getActivities();
  }

  Future<List<Activity>> getActivitiesByScheduleId(int scheduleId) async {
    return await dbHelper.getActivitiesByScheduleId(scheduleId);
  }

  Future<List<Activity>> getUpcomingActivities() async {
    final dbHelper = DatabaseHelper.instance;
    final today = DateTime.now();
    return await dbHelper.getUpcomingActivities(today);
  }

  Future<int> createActivity(Activity activity) async {
    try {
      final id = await dbHelper.insertActivity(activity);
      
      // Schedule notification if needed
      if (activity.notificationEnabled) {
        await _scheduleActivityNotification(activity.copyWith(id: id));
      }
      
      return id;
    } catch (e, stackTrace) {
      _logger.error('Error creating activity: ${activity.title}', e, stackTrace);
      rethrow;
    }
  }

  Future<int> updateActivity(Activity activity) async {
    try {
      final result = await dbHelper.updateActivity(activity);
      
      // Cancel old notification and schedule new one if needed
      if (activity.id != null) {
        await notificationService.cancelNotification(activity.id!);
        
        if (activity.notificationEnabled) {
          await _scheduleActivityNotification(activity);
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      _logger.error('Error updating activity: ${activity.title}', e, stackTrace);
      rethrow;
    }
  }

  Future<int> deleteActivity(int id) async {
    try {
      // Cancel notification
      await notificationService.cancelNotification(id);
      
      return await dbHelper.deleteActivity(id);
    } catch (e, stackTrace) {
      _logger.error('Error deleting activity: $id', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _scheduleActivityNotification(Activity activity) async {
    if (activity.id == null) return;
    
    try {
      await notificationService.scheduleActivityNotification(activity);
      _logger.info('Scheduled notification for activity: ${activity.title}');
    } catch (e, stackTrace) {
      _logger.error('Error scheduling notification for activity: ${activity.title}', e, stackTrace);
    }
  }

  Future<void> rescheduleAllNotifications() async {
    // Cancel all existing notifications
    await notificationService.cancelAllNotifications();
    
    // Get all activities
    final activities = await dbHelper.getActivities();
    
    // Reschedule notifications for each activity
    for (final activity in activities) {
      if (activity.notifyBefore > 0 && activity.id != null) {
        _scheduleActivityNotification(activity);
      }
    }
  }
}