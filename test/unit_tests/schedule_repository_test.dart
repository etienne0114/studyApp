import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/data/repositories/schedule_repository.dart';
import 'package:study_scheduler/services/notification_service.dart';

// Generate mock classes
@GenerateMocks([DatabaseHelper, NotificationService])
import 'schedule_repository_test.mocks.dart';

void main() {
  late ScheduleRepository repository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockNotificationService mockNotificationService;

  setUp(() {
  mockDatabaseHelper = MockDatabaseHelper();
  mockNotificationService = MockNotificationService();

  repository = ScheduleRepository(
    dbHelper: mockDatabaseHelper,
    notificationService: mockNotificationService,
  );
});


  group('ScheduleRepository', () {
    final testSchedule = Schedule(
      id: 1,
      title: 'Test Schedule',
      description: 'Test Description',
      color: Colors.blue.value.toString(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final testSchedules = [
      testSchedule,
      Schedule(
        id: 2,
        title: 'Test Schedule 2',
        description: 'Test Description 2',
        color: Colors.red.value.toString(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];

    final testActivities = <Activity>[];

    test('getAllSchedules should return a list of schedules', () async {
      when(mockDatabaseHelper.getSchedules()).thenAnswer((_) async => testSchedules);

      final result = await repository.getAllSchedules();

      expect(result, equals(testSchedules));
      verify(mockDatabaseHelper.getSchedules()).called(1);
    });

    test('getScheduleById should return schedule when found', () async {
      when(mockDatabaseHelper.getSchedule(1)).thenAnswer((_) async => testSchedule);

      final result = await repository.getScheduleById(1);

      expect(result, equals(testSchedule));
      verify(mockDatabaseHelper.getSchedule(1)).called(1);
    });

    test('getScheduleById should return null when not found', () async {
      when(mockDatabaseHelper.getSchedule(999)).thenAnswer((_) async => null);

      final result = await repository.getScheduleById(999);

      expect(result, isNull);
      verify(mockDatabaseHelper.getSchedule(999)).called(1);
    });

    test('createSchedule should return the ID of created schedule', () async {
      when(mockDatabaseHelper.insertSchedule(testSchedule)).thenAnswer((_) async => 1);

      final result = await repository.createSchedule(testSchedule);

      expect(result, equals(1));
      verify(mockDatabaseHelper.insertSchedule(testSchedule)).called(1);
    });

    test('updateSchedule should return number of rows affected', () async {
      when(mockDatabaseHelper.updateSchedule(testSchedule)).thenAnswer((_) async => 1);

      final result = await repository.updateSchedule(testSchedule);

      expect(result, equals(1));
      verify(mockDatabaseHelper.updateSchedule(testSchedule)).called(1);
    });

    test('deleteSchedule should return true on success', () async {
      when(mockDatabaseHelper.getActivitiesByScheduleId(1)).thenAnswer((_) async => testActivities);
      when(mockDatabaseHelper.deleteSchedule(1)).thenAnswer((_) async => 1);

      final result = await repository.deleteSchedule(1);

      expect(result, isTrue);
      verify(mockDatabaseHelper.getActivitiesByScheduleId(1)).called(1);
      verify(mockDatabaseHelper.deleteSchedule(1)).called(1);
    });
  });
}