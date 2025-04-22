import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/constants/app_styles.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/ui/screens/schedule/add_activity_screen.dart';
import 'package:study_scheduler/ui/screens/schedule/add_schedule_screen.dart';
import 'package:study_scheduler/ui/screens/home/widgets/upcoming_activities.dart';
import 'package:intl/intl.dart';
import 'package:study_scheduler/data/helpers/logger.dart';

// Extension to convert TimeOfDay to and from string format
extension TimeOfDayExtension on TimeOfDay {
  String toTimeString() {
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}

extension StringToTimeOfDay on String {
  TimeOfDay toTimeOfDay() {
    final parts = split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  final Schedule? selectedSchedule;

  const ScheduleScreen({
    super.key,
    this.selectedSchedule,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  Map<DateTime, List<Activity>> _activitiesByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Schedule> _schedules = [];
  List<Activity> _activities = [];
  int? _selectedScheduleId;
  bool _isLoading = true;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _logger = Logger();
  
  @override
  void initState() {
    super.initState();
    _loadActivities();
    
    if (widget.selectedSchedule != null) {
      _selectedScheduleId = widget.selectedSchedule!.id;
    }
    
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _logger.info('Starting to load data...');
      final db = DatabaseHelper.instance;
      
      // Load schedules
      _logger.info('Loading schedules...');
      _schedules = await db.getSchedules();
      _logger.info('Loaded ${_schedules.length} schedules');
      
      // Load activities based on selected schedule and day
      if (_selectedScheduleId != null) {
        _activities = await db.getActivitiesForSchedule(_selectedScheduleId!);
      } else {
        _activities = await db.getActivitiesForDay(_selectedDay);
      }

      // Group activities by day for calendar highlighting
      _activitiesByDay.clear();
      final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // Load all activities for the current month
      final monthActivities = await db.getActivitiesForMonth(firstDayOfMonth, lastDayOfMonth);
      
      for (var activity in monthActivities) {
        // For each activity, find all matching days in the month
        var currentDate = firstDayOfMonth;
        while (!currentDate.isAfter(lastDayOfMonth)) {
          if (currentDate.weekday == activity.dayOfWeek) {
            final key = DateTime(currentDate.year, currentDate.month, currentDate.day);
            if (!_activitiesByDay.containsKey(key)) {
              _activitiesByDay[key] = [];
            }
            _activitiesByDay[key]!.add(activity);
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
      
      setState(() => _isLoading = false);
      _logger.info('Data loading completed successfully');
    } catch (e, stackTrace) {
      _logger.error('Error loading data: $e\n$stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadActivities() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final activities = await _databaseHelper.getActivitiesForMonth(firstDay, lastDay);
    
    final Map<DateTime, List<Activity>> newActivitiesByDay = {};
    
    for (var activity in activities) {
      // Calculate the actual date for this activity based on its day of week
      final activityDate = _getActivityDate(activity.dayOfWeek);
      if (activityDate != null) {
        if (!newActivitiesByDay.containsKey(activityDate)) {
          newActivitiesByDay[activityDate] = [];
        }
        newActivitiesByDay[activityDate]!.add(activity);
      }
    }

    setState(() {
      _activitiesByDay = newActivitiesByDay;
    });
  }

  Future<void> _loadActivitiesForMonth() async {
    try {
      _logger.info('Loading activities for month: ${_focusedDay.toString()}');
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final activities = await _databaseHelper.getActivitiesForMonth(firstDay, lastDay);
      _logger.info('Retrieved ${activities.length} activities from database');
      
      final Map<DateTime, List<Activity>> newActivitiesByDay = {};
      
      for (var activity in activities) {
        // Parse the creation date
        final createdAt = DateTime.parse(activity.createdAt);
        
        // Only add the activity to its specific creation date
        if (createdAt.year == _focusedDay.year && createdAt.month == _focusedDay.month) {
          final key = DateTime(createdAt.year, createdAt.month, createdAt.day);
          if (!newActivitiesByDay.containsKey(key)) {
            newActivitiesByDay[key] = [];
          }
          newActivitiesByDay[key]!.add(activity);
          _logger.info('Added activity ${activity.title} to date ${key.toString()}');
        }
      }

      if (mounted) {
        setState(() {
          _activitiesByDay = newActivitiesByDay;
          // Update activities list for the selected day
          final selectedKey = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          _activities = _activitiesByDay[selectedKey] ?? [];
          _logger.info('Updated activities for selected day $_selectedDay: ${_activities.length} activities');
        });
      }
    } catch (e, stackTrace) {
      _logger.error('Error loading activities for month: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activities: $e')),
        );
      }
    }
  }

  DateTime? _getActivityDate(int dayOfWeek) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    DateTime current = firstDayOfMonth;
    while (current.isBefore(lastDayOfMonth) || current == lastDayOfMonth) {
      if (current.weekday == dayOfWeek) {
        return current;
      }
      current = current.add(const Duration(days: 1));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showScheduleFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
                children: [
          TableCalendar<Activity>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
            currentDay: DateTime.now(),
        calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return _activitiesByDay[key] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  _focusedDay = focusedDay;
                  
                  // Get activities only for the exact selected date
                  final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                  _activities = _activitiesByDay[key] ?? [];
                  _logger.info('Selected day changed to $_selectedDay with ${_activities.length} activities');
                });
                
                // Show bottom sheet with options
                _showDateOptionsSheet(selectedDay);
              }
            },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
              setState(() {
          _focusedDay = focusedDay;
                // When changing months, keep the day the same if possible
                _selectedDay = DateTime(focusedDay.year, focusedDay.month, _selectedDay.day);
              });
              _loadActivitiesForMonth();
        },
        calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markerSize: 8.0,
              markersAlignment: Alignment.bottomCenter,
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
          todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
              formatButtonVisible: true,
          titleCentered: true,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildActivityList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_schedules.isEmpty) {
            // Show dialog to create a schedule first
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('No Schedule'),
                content: const Text('Please create a schedule first before adding activities.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to create schedule screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddScheduleScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: const Text('Create Schedule'),
                  ),
                ],
              ),
            );
            return;
          }
          // Pass the actual selected date to AddActivityScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddActivityScreen(
                scheduleId: widget.selectedSchedule?.id ?? _schedules.first.id!,
                selectedDate: _selectedDay,
                initialDayOfWeek: _selectedDay.weekday, // Pass the weekday of selected date
              ),
            ),
          ).then((_) {
            _loadData();
            // Ensure we stay on the selected date after adding activity
            setState(() {
              _selectedDay = _selectedDay;
              _focusedDay = _selectedDay;
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActivityList() {
    if (_activities.isEmpty) {
      return const Center(
        child: Text('No activities for this day'),
      );
    }

    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        Color scheduleColor;
        try {
          scheduleColor = activity.scheduleColor != null 
            ? Color(int.parse(activity.scheduleColor!.replaceFirst('#', '0xFF')))
            : Theme.of(context).primaryColor;
        } catch (e) {
          // If color parsing fails, use the default primary color
          scheduleColor = Theme.of(context).primaryColor;
        }
        
        return Dismissible(
          key: Key(activity.id?.toString() ?? UniqueKey().toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Activity'),
                content: const Text('Are you sure you want to delete this activity?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
          ),
        ],
      ),
    );
          },
          onDismissed: (direction) async {
            if (activity.id != null) {
              await _databaseHelper.deleteActivity(activity.id!);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity deleted')),
                );
              }
            }
          },
          child: ListTile(
            title: Text(activity.title),
            subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Text('${activity.startTime.format(context)} - ${activity.endTime.format(context)}'),
                if (activity.description?.isNotEmpty == true)
              Text(
                    activity.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: scheduleColor,
                shape: BoxShape.circle,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activity.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () async {
                      if (activity.id != null) {
                        final updatedActivity = Activity(
                          id: activity.id,
                          scheduleId: activity.scheduleId,
                          title: activity.title,
                          description: activity.description,
                          category: activity.category,
                          startTime: activity.startTime,
                          endTime: activity.endTime,
                          dayOfWeek: activity.dayOfWeek,
                          isCompleted: true,
                          notificationEnabled: activity.notificationEnabled,
                          notificationMinutesBefore: activity.notificationMinutesBefore,
                          location: activity.location,
                          isRecurring: activity.isRecurring,
                          notifyBefore: activity.notifyBefore,
                          createdAt: activity.createdAt,
                          updatedAt: DateTime.now().toIso8601String(),
                          type: activity.type,
                          scheduleTitle: activity.scheduleTitle,
                          scheduleColor: activity.scheduleColor,
                        );
                        await _databaseHelper.updateActivity(updatedActivity);
                        _loadData();
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddActivityScreen(
                          scheduleId: activity.scheduleId,
                          selectedDate: _selectedDay,
                          initialDayOfWeek: activity.dayOfWeek,
                          activity: activity,
                        ),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Activity'),
                        content: const Text('Are you sure you want to delete this activity?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true && activity.id != null && mounted) {
                      await _databaseHelper.deleteActivity(activity.id!);
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Activity deleted')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Material(
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: scheduleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(activity.title),
                          subtitle: Text(activity.scheduleTitle ?? 'No Schedule'),
                        ),
                        const Divider(),
                        if (activity.description?.isNotEmpty == true)
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: Text(activity.description!),
                          ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text('${activity.startTime.format(context)} - ${activity.endTime.format(context)}'),
                        ),
                        if (activity.location?.isNotEmpty == true)
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(activity.location!),
                          ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: Text('Category: ${activity.category}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Activity'),
                          onTap: () {
                            Navigator.pop(context); // Close bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityScreen(
                                  scheduleId: activity.scheduleId,
                                  selectedDate: _selectedDay,
                                  initialDayOfWeek: activity.dayOfWeek,
                                  activity: activity,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Delete Activity'),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Activity'),
                                content: const Text('Are you sure you want to delete this activity?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true && activity.id != null && mounted) {
                              Navigator.pop(context); // Close bottom sheet
                              await _databaseHelper.deleteActivity(activity.id!);
                              _loadData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Activity deleted')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showScheduleFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Schedules'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  setState(() {
                    _selectedScheduleId = null;
                  });
                  Navigator.pop(context);
                  _loadData();
                },
              ),
              ..._schedules.map((schedule) => ListTile(
                title: Text(schedule.title),
                leading: Icon(Icons.circle,
                    color: Color(int.parse('0xFF${schedule.color.substring(1)}'))),
                onTap: () {
                  setState(() {
                    _selectedScheduleId = schedule.id;
                  });
                  Navigator.pop(context);
                  _loadData();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateOptionsSheet(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Selected Date: ${DateFormat('EEEE, MMMM d, y').format(selectedDate)}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Activity'),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  if (_schedules.isEmpty) {
                    // Show dialog to create a schedule first
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No Schedule'),
                        content: const Text('Please create a schedule first before adding activities.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to create schedule screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddScheduleScreen(),
                                ),
                              ).then((_) => _loadData());
                            },
                            child: const Text('Create Schedule'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  
                  // Navigate to add activity screen with selected date
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddActivityScreen(
                        scheduleId: widget.selectedSchedule?.id ?? _schedules.first.id!,
                        selectedDate: selectedDate,
                        initialDayOfWeek: selectedDate.weekday,
                      ),
                    ),
                  ).then((_) {
                    _loadData();
                    setState(() {
                      _selectedDay = selectedDate;
                      _focusedDay = selectedDate;
                    });
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_agenda),
                title: Text('View Activities (${_activities.length})'),
                onTap: () {
                  Navigator.pop(context);
                  // Scroll to activities list
                  // You could add a ScrollController to implement this
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}