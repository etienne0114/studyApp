// lib/ui/screens/schedule/add_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/services/notification_service.dart';

class AddActivityScreen extends StatefulWidget {
  final int scheduleId;
  final Activity? activity;

  const AddActivityScreen({
    super.key,
    required this.scheduleId,
    this.activity,
  });

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
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

  final List<String> _activityTypes = ['study', 'break', 'exercise', 'other'];

  @override
  void initState() {
    super.initState();
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
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
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
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
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