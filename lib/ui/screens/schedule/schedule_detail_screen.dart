// lib/ui/screens/schedule/schedule_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/ui/screens/schedule/add_activity_screen.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;

  const ScheduleDetailScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  late DatabaseHelper _databaseHelper;
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      setState(() => _isLoading = true);
      final activities = await _databaseHelper.getActivitiesForSchedule(widget.schedule.id!);
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activities: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityScreen(scheduleId: widget.schedule.id!),
                ),
              );
              if (result == true) {
                _loadActivities();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No activities yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivityScreen(scheduleId: widget.schedule.id!),
                            ),
                          );
                          if (result == true) {
                            _loadActivities();
                          }
                        },
                        child: const Text('Add Activity'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return ListTile(
                      leading: Icon(_getActivityIcon(activity)),
                      title: Text(activity.title),
                      subtitle: Text(
                        '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivityScreen(
                                scheduleId: widget.schedule.id!,
                                activity: activity,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadActivities();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getActivityIcon(Activity activity) {
    switch (activity.type) {
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