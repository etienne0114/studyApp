// lib/ui/screens/schedule/add_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/data/repositories/schedule_repository.dart';
import 'package:study_scheduler/ui/widgets/custom_button.dart';
import 'package:study_scheduler/ui/widgets/custom_textfield.dart';

class AddScheduleScreen extends StatefulWidget {
  final Schedule? schedule; // If provided, we're editing an existing schedule

  const AddScheduleScreen({
    super.key,
    this.schedule,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late int _selectedColorIndex;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If editing, populate fields with existing schedule data
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.description ?? '';

      // Find the index of the schedule color in our predefined color list
      _selectedColorIndex = AppColors.scheduleColors.indexWhere(
        (color) => color.value == widget.schedule!.color,
      );

      // If color not found in our list, default to the first color
      if (_selectedColorIndex < 0) {
        _selectedColorIndex = 0;
      }

      _isActive = widget.schedule!.isActive == 1;
    } else {
      // Default values for new schedule
      _selectedColorIndex = 0;
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final repository =
            Provider.of<ScheduleRepository>(context, listen: false);
        final schedule = Schedule(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          color: '#${AppColors.scheduleColors[_selectedColorIndex].value.toRadixString(16).substring(2)}',
          isActive: _isActive ? 1 : 0,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        if (widget.schedule == null) {
          await repository.createSchedule(schedule);
        } else {
          await repository.updateSchedule(schedule);
        }

        if (!mounted) return;

        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        print('Error saving schedule: $e');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Schedule' : 'Create Schedule'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter schedule title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Enter schedule description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Color selection
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildColorSelector(),
                    const SizedBox(height: 24),

                    // Active toggle
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: const Text('Enable or disable this schedule'),
                      value: _isActive,
                      activeColor:
                          AppColors.scheduleColors[_selectedColorIndex],
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    CustomButton(
                      text: isEditing ? 'Update Schedule' : 'Create Schedule',
                      onPressed: _saveSchedule,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        AppColors.scheduleColors.length,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              _selectedColorIndex = index;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.scheduleColors[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColorIndex == index
                    ? Colors.black
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (_selectedColorIndex == index)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: _selectedColorIndex == index
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text(
          'Are you sure you want to delete this schedule? This will also delete all activities associated with this schedule.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _deleteSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule() async {
    if (widget.schedule == null || widget.schedule!.id == null) {
      Navigator.pop(context); // Close dialog
      return;
    }

    Navigator.pop(context); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      final repository =
          Provider.of<ScheduleRepository>(context, listen: false);
      final success = await repository.deleteSchedule(widget.schedule!.id!);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true); // Return to previous screen
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error deleting schedule: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }
}
