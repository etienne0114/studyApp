// lib/data/models/activity.dart

import 'package:flutter/material.dart';

class Activity {
  final int? id;
  final int scheduleId;
  final String title;
  final String? description;
  final String category;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isCompleted;
  final bool notificationEnabled;
  final int notificationMinutesBefore;
  int? scheduleColor;
  String? scheduleTitle;
  final String? location;
  final int dayOfWeek;
  final bool isRecurring;
  final int notifyBefore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String type;

  Activity({
    this.id,
    required this.scheduleId,
    required this.title,
    this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.notificationEnabled = true,
    this.notificationMinutesBefore = 15,
    this.scheduleColor,
    this.scheduleTitle,
    this.location,
    required this.dayOfWeek,
    this.isRecurring = true,
    this.notifyBefore = 30,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.type,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Activity copyWith({
    int? id,
    int? scheduleId,
    String? title,
    String? description,
    String? category,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isCompleted,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    int? scheduleColor,
    String? scheduleTitle,
    String? location,
    int? dayOfWeek,
    bool? isRecurring,
    int? notifyBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
  }) {
    return Activity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationMinutesBefore: notificationMinutesBefore ?? this.notificationMinutesBefore,
      scheduleColor: scheduleColor ?? this.scheduleColor,
      scheduleTitle: scheduleTitle ?? this.scheduleTitle,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isRecurring: isRecurring ?? this.isRecurring,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'title': title,
      'description': description,
      'category': category,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'isCompleted': isCompleted ? 1 : 0,
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'notificationMinutesBefore': notificationMinutesBefore,
      'scheduleColor': scheduleColor,
      'scheduleTitle': scheduleTitle,
      'location': location,
      'dayOfWeek': dayOfWeek,
      'isRecurring': isRecurring ? 1 : 0,
      'notifyBefore': notifyBefore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    final startTimeParts = (map['startTime'] as String).split(':');
    final endTimeParts = (map['endTime'] as String).split(':');
    
    return Activity(
      id: map['id'] as int?,
      scheduleId: map['scheduleId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      isCompleted: map['isCompleted'] == 1,
      notificationEnabled: map['notificationEnabled'] == 1,
      notificationMinutesBefore: map['notificationMinutesBefore'] as int? ?? 15,
      scheduleColor: map['scheduleColor'] as int?,
      scheduleTitle: map['scheduleTitle'] as String?,
      location: map['location'] as String?,
      dayOfWeek: map['dayOfWeek'] as int? ?? DateTime.now().weekday,
      isRecurring: map['isRecurring'] == 1,
      notifyBefore: map['notifyBefore'] as int? ?? 30,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      type: map['type'] ?? 'study',
    );
  }

  String get formattedStartTime => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  String get formattedEndTime => '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  String get formattedDuration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  DateTime getStartDateTime() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
  }

  DateTime getEndDateTime() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );
  }
}