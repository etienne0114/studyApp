// lib/data/models/schedule.dart

import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final String title;
  final String? description;
  final String color;
  final int isActive; // 1 = active, 0 = inactive
  final String createdAt;
  final String updatedAt;

  Schedule({
    this.id,
    required this.title,
    this.description,
    required this.color,
    this.isActive = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert color string to Color object
  Color get colorValue {
    try {
      if (color.startsWith('#')) {
        return Color(int.parse('0xFF${color.substring(1)}'));
      } else if (color.startsWith('0x')) {
        return Color(int.parse(color));
      } else {
        return Color(int.parse('0xFF$color'));
      }
    } catch (e) {
      return Colors.grey; // Default color if parsing fails
    }
  }

  // Alias for colorValue to maintain compatibility
  Color get scheduleColor => colorValue;

  // Create a copy of this Schedule with some fields replaced
  Schedule copyWith({
    int? id,
    String? title,
    String? description,
    String? color,
    int? isActive,
    String? createdAt,
    String? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Create a Schedule from a Map
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      color: map['color'] as String,
      isActive: map['isActive'] as int? ?? 1,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  // Convert Schedule to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Schedule{id: $id, title: $title, color: $color, isActive: $isActive}';
  }
}