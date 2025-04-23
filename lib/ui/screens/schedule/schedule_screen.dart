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
  
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  
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
    
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;
    
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
      final db = DatabaseHelper.instance;
      
      // Load schedules
      _schedules = await db.getSchedules();
      
      // Load activities based on selected schedule and day
      if (_selectedScheduleId != null) {
        _activities = await db.getActivitiesForSchedule(_selectedScheduleId!);
      } else {
        _activities = await db.getActivitiesForDay(_selectedDay);
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      _logger.error('Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<List<Activity>> _loadActivitiesForSelectedDay() async {
    try {
      final db = DatabaseHelper.instance;
      return await db.getActivitiesForDay(_selectedDay);
    } catch (e) {
      _logger.error('Error loading activities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading activities: $e')),
        );
      }
      return [];
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    // Reload activities for the new selected day
    _loadActivitiesForSelectedDay().then((activities) {
      setState(() {
        _activities = activities;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Schedule'),
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
          : SafeArea(
              child: Column(
                children: [
                  _buildCalendar(),
                  _buildScheduleHeader(),
                  Expanded(
                    child: _activities.isEmpty
                        ? _buildEmptyState()
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildActivitiesList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddActivity,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonShowsNext: false,
        ),
      ),
    );
  }

  Widget _buildScheduleHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDay),
            style: AppStyles.heading2,
          ),
          Text(
            '${_activities.length} Activities',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Activities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: _navigateToAddActivity,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        UpcomingActivities(
          activities: _activities,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No activities scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add activities to your schedule to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
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
                          );
                        },
                        child: const Text('Create Schedule'),
                      ),
                    ],
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityScreen(
                    scheduleId: widget.selectedSchedule?.id ?? _schedules.first.id!,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddActivity() {
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
                );
              },
              child: const Text('Create Schedule'),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(
          scheduleId: widget.selectedSchedule?.id ?? _schedules.first.id!,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadActivitiesForSelectedDay().then((activities) {
          setState(() {
            _activities = activities;
          });
        });
      }
    });
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
}