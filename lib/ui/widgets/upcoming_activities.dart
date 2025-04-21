import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/activity.dart';

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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Icon(_getActivityIcon(activity.type)),
            title: Text(activity.title),
            subtitle: Text(
              '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
            ),
            trailing: activity.notificationEnabled
                ? const Icon(Icons.notifications_active, color: Colors.blue)
                : null,
          ),
        );
      },
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'study':
        return Icons.book;
      case 'break':
        return Icons.free_breakfast;
      case 'exercise':
        return Icons.fitness_center;
      default:
        return Icons.event;
    }
  }
} 