// lib/data/models/activity.dart

import 'package:flutter/material.dart';

class Activity {
  final int? id;
  final int scheduleId;
  final String title;
  final String? description;
  final String category;
  final String type;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  bool _isCompleted;
  final bool notificationEnabled;
  final int notificationMinutesBefore;
  final String? location;
  final int dayOfWeek;
  final bool isRecurring;
  final int notifyBefore;
  final String createdAt;
  final String updatedAt;
  String? scheduleTitle;
  String? scheduleColor;

  bool get isCompleted => _isCompleted;
  set isCompleted(bool value) => _isCompleted = value;

  Activity({
    this.id,
    required this.scheduleId,
    required this.title,
    this.description,
    required this.category,
    required this.type,
    required this.startTime,
    required this.endTime,
    bool isCompleted = false,
    this.notificationEnabled = true,
    this.notificationMinutesBefore = 15,
    this.location,
    required this.dayOfWeek,
    this.isRecurring = true,
    this.notifyBefore = 30,
    String? createdAt,
    String? updatedAt,
    this.scheduleTitle,
    this.scheduleColor,
  }) : 
    _isCompleted = isCompleted,
    createdAt = createdAt ?? DateTime.now().toIso8601String(),
    updatedAt = updatedAt ?? DateTime.now().toIso8601String();

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
    String? scheduleColor,
    String? scheduleTitle,
    String? location,
    int? dayOfWeek,
    bool? isRecurring,
    int? notifyBefore,
    String? createdAt,
    String? updatedAt,
    String? type,
  }) {
    return Activity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this._isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationMinutesBefore: notificationMinutesBefore ?? this.notificationMinutesBefore,
      location: location ?? this.location,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isRecurring: isRecurring ?? this.isRecurring,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduleTitle: scheduleTitle ?? this.scheduleTitle,
      scheduleColor: scheduleColor ?? this.scheduleColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'scheduleId': scheduleId,
      'title': title,
      'description': description,
      'category': category,
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'isCompleted': isCompleted ? 1 : 0,
      'notificationEnabled': notificationEnabled ? 1 : 0,
      'notificationMinutesBefore': notificationMinutesBefore,
      'location': location,
      'dayOfWeek': dayOfWeek,
      'isRecurring': isRecurring ? 1 : 0,
      'notifyBefore': notifyBefore,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'type': type,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    final startTimeStr = map['startTime']?.toString() ?? '00:00';
    final endTimeStr = map['endTime']?.toString() ?? '00:00';
    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');

    return Activity(
      id: map['id'] as int?,
      scheduleId: map['scheduleId'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      type: map['type']?.toString() ?? 'study',
      startTime: TimeOfDay(
        hour: int.tryParse(startTimeParts[0]) ?? 0,
        minute: int.tryParse(startTimeParts[1]) ?? 0,
      ),
      endTime: TimeOfDay(
        hour: int.tryParse(endTimeParts[0]) ?? 0,
        minute: int.tryParse(endTimeParts[1]) ?? 0,
      ),
      isCompleted: (map['isCompleted'] as int?) == 1,
      notificationEnabled: (map['notificationEnabled'] as int?) == 1,
      notificationMinutesBefore: (map['notificationMinutesBefore'] as int?) ?? 15,
      location: map['location'] as String?,
      dayOfWeek: (map['dayOfWeek'] as int?) ?? DateTime.now().weekday,
      isRecurring: (map['isRecurring'] as int?) == 1,
      notifyBefore: (map['notifyBefore'] as int?) ?? 30,
      createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      scheduleTitle: map['scheduleTitle'] as String?,
      scheduleColor: map['scheduleColor'] as String?,
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

  Color get scheduleColorAsColor {
    if (scheduleColor == null) return const Color(0xFF2196F3);
    try {
      return Color(int.parse('0xFF${scheduleColor!.substring(1)}'));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
}