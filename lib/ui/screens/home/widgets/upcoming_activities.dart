import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/activity.dart';

/// Extension to convert time strings (HH:MM) to TimeOfDay objects
extension TimeStringExtension on String {
  TimeOfDay toTimeOfDay() {
    final parts = split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class UpcomingActivities extends StatelessWidget {
  final List<Activity> activities;

  const UpcomingActivities({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No upcoming activities'),
      );
    }

    // Sort activities by start time
    final sortedActivities = List<Activity>.from(activities)
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedActivities.length,
      itemBuilder: (context, index) {
        final activity = sortedActivities[index];
        return _buildActivityCard(context, activity);
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.scheduleColorAsColor,
          child: Text(
            activity.title[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(activity.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${activity.formattedStartTime} - ${activity.formattedEndTime}'),
            if (activity.location != null)
              Text(
                activity.location!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: activity.notificationEnabled
            ? const Icon(Icons.notifications_active, color: Colors.blue)
            : const Icon(Icons.notifications_off, color: Colors.grey),
        onTap: () {
          // Navigate to activity details
        },
      ),
    );
  }
}