// lib/utils/date_utils.dart

import 'package:flutter/material.dart';

/// Converts a TimeOfDay object to a string in the format "HH:MM"
String timeOfDayToString(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

/// Converts a string in the format "HH:MM" to a TimeOfDay object
TimeOfDay stringToTimeOfDay(String timeString) {
  final parts = timeString.split(':');
  return TimeOfDay(
    hour: int.parse(parts[0]),
    minute: int.parse(parts[1]),
  );
}

/// Get the name of a day based on its index (0-6 for Monday-Sunday)
String getDayName(int dayIndex, {bool shortName = false}) {
  final days = shortName 
      ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] 
      : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  return days[dayIndex];
}

/// Get the current day of week index (0-6 for Monday-Sunday)
int getCurrentDayIndex() {
  final now = DateTime.now();
  // Convert from DateTime's 1-7 (Mon-Sun) to our 0-6 index
  return now.weekday - 1;
}

/// Format a DateTime as a date string
String formatDate(DateTime date, {String format = 'MM/dd/yyyy'}) {
  // Simple formatting - for more complex formatting, consider using intl package
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  
  return format
      .replaceAll('yyyy', year)
      .replaceAll('MM', month)
      .replaceAll('dd', day);
}

/// Parse an ISO date string to DateTime
DateTime parseIsoDate(String isoString) {
  return DateTime.parse(isoString);
}

/// Format a DateTime to ISO 8601 string
String toIsoString(DateTime date) {
  return date.toIso8601String();
}

/// Get a DateTime for the next occurrence of a specific day of week
DateTime getNextOccurrence(int dayOfWeek) {
  final now = DateTime.now();
  int daysUntilNext = dayOfWeek - (now.weekday - 1);
  if (daysUntilNext <= 0) {
    daysUntilNext += 7; // Move to next week if day has passed
  }
  
  return DateTime(
    now.year,
    now.month,
    now.day + daysUntilNext,
  );
}