// lib/ui/screens/schedule/add_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/services/notification_service.dart';
<<<<<<< HEAD
=======
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
>>>>>>> parent of f1a0110 (errors 2)

class AddActivityScreen extends StatefulWidget {
  final int scheduleId;
  final Activity? activity;

  const AddActivityScreen({
<<<<<<< HEAD
    super.key,
=======
    Key? key,
>>>>>>> parent of f1a0110 (errors 2)
    required this.scheduleId,
    this.activity,
  }) : super(key: key);

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  late DatabaseHelper _databaseHelper;
  late NotificationService _notificationService;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedType;
  bool _notificationEnabled = false;
  int _notificationMinutesBefore = 15;
=======
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final Logger _logger = Logger();
  
  final _titleController = TextEditingController(text: 'New Activity');
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedDayOfWeek;
  bool _notificationEnabled = true;
  int _notificationMinutesBefore = 15;
  bool _isRecurring = true;
  String _selectedCategory = 'study';
>>>>>>> parent of f1a0110 (errors 2)

  final List<String> _activityTypes = ['study', 'break', 'exercise', 'other'];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _databaseHelper = DatabaseHelper.instance;
    _notificationService = NotificationService.instance;
    
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descriptionController = TextEditingController(text: widget.activity?.description ?? '');
    _locationController = TextEditingController(text: widget.activity?.location ?? '');
    
    _startTime = widget.activity?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.activity?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _selectedType = widget.activity?.type ?? 'study';
    _notificationEnabled = widget.activity?.notificationEnabled ?? false;
    _notificationMinutesBefore = widget.activity?.notificationMinutesBefore ?? 15;
=======
    
    // Initialize with existing activity data if provided
    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description ?? '';
      _locationController.text = widget.activity!.location ?? '';
      _startTime = widget.activity!.startTime;
      _endTime = widget.activity!.endTime;
      _selectedDayOfWeek = widget.activity!.dayOfWeek;
      _notificationEnabled = widget.activity!.notificationEnabled;
      _notificationMinutesBefore = widget.activity!.notificationMinutesBefore ?? 15;
      _isRecurring = widget.activity!.isRecurring;
      _selectedCategory = widget.activity!.type ?? 'study';
    } else {
      // Initialize time values for new activity
      final now = TimeOfDay.now();
      _startTime = now;
      _endTime = TimeOfDay(
        hour: now.hour + 1 >= 24 ? 23 : now.hour + 1,
        minute: now.minute,
      );
      
      // Initialize selected day of week from widget parameter
      _selectedDayOfWeek = widget.initialDayOfWeek;
    }
>>>>>>> parent of f1a0110 (errors 2)
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final activity = Activity(
        id: widget.activity?.id,
        scheduleId: widget.scheduleId,
        title: _titleController.text.isNotEmpty ? _titleController.text : 'New Activity',
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
<<<<<<< HEAD
        category: _selectedType,
        startTime: _startTime,
        endTime: _endTime,
        type: _selectedType,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        notificationEnabled: _notificationEnabled,
        notificationMinutesBefore: _notificationMinutesBefore,
        dayOfWeek: DateTime.now().weekday,
      );

      if (widget.activity == null) {
        await _databaseHelper.insertActivity(activity);
        if (_notificationEnabled) {
          await _notificationService.scheduleActivityNotification(activity);
        }
      } else {
        await _databaseHelper.updateActivity(activity);
        if (_notificationEnabled) {
          await _notificationService.scheduleActivityNotification(activity);
        } else {
          await _notificationService.cancelActivityNotification(activity.id!);
        }
=======
        category: _selectedCategory,
        type: _selectedCategory,
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        notificationEnabled: _notificationEnabled,
        notificationMinutesBefore: _notificationMinutesBefore,
        dayOfWeek: _selectedDayOfWeek,
        activityDate: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
        isRecurring: _isRecurring,
        createdAt: widget.activity?.createdAt ?? now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      _logger.d('Creating activity for date: ${widget.selectedDate}');
      if (widget.activity?.id != null) {
        await _databaseHelper.updateActivity(activity);
      } else {
        await _databaseHelper.insertActivity(activity);
      }
      
      if (_notificationEnabled) {
        await _notificationService.scheduleActivityNotification(activity);
>>>>>>> parent of f1a0110 (errors 2)
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _logger.e('Error saving activity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving activity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
<<<<<<< HEAD
=======
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Selected Date'),
                subtitle: Text(
                  DateFormat('EEEE, MMMM d, y').format(widget.selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
>>>>>>> parent of f1a0110 (errors 2)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Activity Type',
                border: OutlineInputBorder(),
              ),
              items: _activityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type[0].toUpperCase() + type.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationEnabled,
              onChanged: (value) {
                setState(() => _notificationEnabled = value);
              },
            ),
            if (_notificationEnabled) ...[
              ListTile(
                title: const Text('Notify Before'),
                subtitle: Text('$_notificationMinutesBefore minutes'),
                trailing: DropdownButton<int>(
                  value: _notificationMinutesBefore,
                  items: [5, 10, 15, 30, 60].map((minutes) {
                    return DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes minutes'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _notificationMinutesBefore = value);
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveActivity,
              child: Text(widget.activity == null ? 'Add Activity' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}