// lib/ui/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/constants/app_styles.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/managers/ai_assistant_manager.dart';
import 'package:study_scheduler/ui/dialogs/ai_assistant_dialog.dart';
import 'package:study_scheduler/ui/screens/profile/profile_screen.dart';
import 'package:study_scheduler/ui/screens/schedule/add_activity_screen.dart';
import 'package:study_scheduler/ui/screens/schedule/add_schedule_screen.dart';
import 'package:study_scheduler/ui/screens/schedule/schedule_screen.dart';
import 'package:study_scheduler/ui/screens/home/widgets/schedule_card.dart';
import 'package:study_scheduler/ui/screens/materials/materials_screen.dart';
import 'package:study_scheduler/ui/screens/materials/add_material_screen.dart';
import 'package:study_scheduler/ui/screens/materials/material_detail_screen.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/helpers/ai_helper.dart';
import 'package:study_scheduler/data/helpers/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<Activity> _upcomingActivities = [];
  List<Schedule> _schedules = [];
  List<Activity> _completedActivities = [];
  List<StudyMaterial> _recentMaterials = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _priorityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();
  final _logger = Logger('HomeScreen');
  Schedule? _selectedSchedule;
  
  late AIAssistantManager _aiManager;
  
  @override
  void initState() {
    super.initState();
    _aiManager = Provider.of<AIAssistantManager>(context, listen: false);
    _loadData();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _difficultyController.dispose();
    _priorityController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _logger.info('Starting to load data...');
      final db = DatabaseHelper.instance;
      final now = DateTime.now();
      
      // Load schedules
      _logger.info('Loading schedules...');
      _schedules = await db.getSchedules();
      _logger.info('Loaded ${_schedules.length} schedules');
      
      // Load upcoming activities for today
      _logger.info('Loading upcoming activities...');
      _upcomingActivities = await db.getUpcomingActivities(now);
      _logger.info('Loaded ${_upcomingActivities.length} upcoming activities');
      
      // Load completed activities for today
      _logger.info('Loading completed activities...');
      _completedActivities = await db.getCompletedActivities();
      _logger.info('Loaded ${_completedActivities.length} completed activities');
      
      // Load recent materials
      _logger.info('Loading recent materials...');
      _recentMaterials = await db.getRecentMaterials();
      _logger.info('Loaded ${_recentMaterials.length} recent materials');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _logger.info('Data loading completed successfully');
      }
    } catch (e, stackTrace) {
      _logger.error('Error loading data: $e\n$stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),
      const MaterialsScreen(),
      const ScheduleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Materials',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
              const SizedBox(height: 24),
            _buildUpcomingActivitiesSection(),
              const SizedBox(height: 24),
              _buildCompletedActivitiesSection(),
              const SizedBox(height: 24),
            _buildSchedulesSection(),
              const SizedBox(height: 24),
            _buildRecentMaterialsSection(),
          ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    if (_schedules.isEmpty && _upcomingActivities.isEmpty && _recentMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
            const Icon(Icons.school, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
        Text(
              'Welcome to Study Scheduler',
              style: AppStyles.heading2,
        ),
        const SizedBox(height: 8),
            const Text(
              'Get started by creating your first schedule',
              textAlign: TextAlign.center,
              style: AppStyles.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                        context,
                  MaterialPageRoute(
                    builder: (context) => const AddScheduleScreen(),
                  ),
                );
                if (result == true && mounted) {
                  _loadData();
                }
              },
              child: const Text('Create Schedule'),
            ),
          ],
      ),
    );
  }
    return const SizedBox.shrink();
  }
  
  Widget _buildUpcomingActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Switch to Schedule tab
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_upcomingActivities.isEmpty)
          _buildEmptyCard(
            'No upcoming activities',
            'Add activities to your schedule to see them here',
            Icons.event,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingActivities.length > 3 ? 3 : _upcomingActivities.length,
            itemBuilder: (context, index) {
              final activity = _upcomingActivities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(int.parse(activity.scheduleColor?.substring(1) ?? '2196F3', radix: 16) + 0xFF000000),
                    child: Text(
                      activity.scheduleTitle?[0] ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(
                    '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editActivity(activity),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => _markActivityAsCompleted(activity),
                      ),
                    ],
                  ),
                  onTap: () => _editActivity(activity),
                ),
              );
            },
          ),
      ],
    );
  }
  
  void _editActivity(Activity activity) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityScreen(
          scheduleId: activity.scheduleId,
          activity: activity,
          selectedDate: DateTime.now().subtract(
            Duration(days: DateTime.now().weekday - activity.dayOfWeek),
          ),
          initialDayOfWeek: activity.dayOfWeek,
        ),
      ),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }
  
  Widget _buildCompletedActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Completed Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_completedActivities.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear All Completed'),
                      content: const Text('Are you sure you want to delete all completed activities?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete All'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await DatabaseHelper.instance.deleteAllCompletedActivities();
                    _loadData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All completed activities deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_completedActivities.isEmpty)
          _buildEmptyCard(
            'No completed activities',
            'Complete some activities to see them here',
            Icons.check_circle,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _completedActivities.length,
            itemBuilder: (context, index) {
              final activity = _completedActivities[index];
              return Dismissible(
                key: Key('completed_activity_${activity.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) async {
                  if (activity.id != null) {
                    await DatabaseHelper.instance.deleteCompletedActivity(activity.id!);
                    setState(() {
                      _completedActivities.removeAt(index);
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${activity.title} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              _loadData(); // Reload all data to restore the activity
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(int.parse(activity.scheduleColor?.substring(1) ?? '2196F3', radix: 16) + 0xFF000000),
                      child: Text(
                        activity.scheduleTitle?[0] ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activity.startTime.format(context)} - ${activity.endTime.format(context)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Completed on ${activity.activityDate}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  Future<List<Activity>> _getUpcomingActivities() async {
    try {
      return await DatabaseHelper.instance.getUpcomingActivities();
    } catch (e) {
      _logger.error('Error getting upcoming activities: $e');
      return [];
    }
  }
  
  Future<List<Activity>> _getCompletedActivities() async {
    try {
      return await DatabaseHelper.instance.getCompletedActivities();
    } catch (e) {
      _logger.error('Error getting completed activities: $e');
      return [];
    }
  }
  
  Future<void> _markActivityAsCompleted(Activity activity) async {
    try {
      activity.isCompleted = true;
      await DatabaseHelper.instance.updateActivity(activity);
      
      // Refresh both upcoming and completed activities
      final db = DatabaseHelper.instance;
      final completedActivities = await db.getCompletedActivities();
      final upcomingActivities = await db.getUpcomingActivities();
      
      if (mounted) {
        setState(() {
          _completedActivities = completedActivities;
          _upcomingActivities = upcomingActivities;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.error('Error marking activity as completed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildSchedulesSection() {
    if (_schedules.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text('Your Schedules', style: AppStyles.heading2),
            const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _schedules.length,
          itemBuilder: (context, index) {
            final schedule = _schedules[index];
            return _buildScheduleCard(schedule);
          },
        ),
      ],
    );
  }
  
  Widget _buildRecentMaterialsSection() {
    if (_recentMaterials.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Materials', style: AppStyles.heading2),
        const SizedBox(height: 16),
        ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentMaterials.length,
                itemBuilder: (context, index) {
                  final material = _recentMaterials[index];
                  return _buildMaterialCard(material);
                },
              ),
      ],
    );
  }
  
  Widget _buildScheduleCard(Schedule schedule) {
    return ScheduleCard(schedule: schedule);
  }
  
  Widget _buildMaterialCard(StudyMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialDetailScreen(material: material),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(material.category).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(material.category),
                  color: _getCategoryColor(material.category),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: AppStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      material.category,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.psychology_alt),
                color: _aiManager.getServiceColor(_aiManager.preferredService),
                onPressed: () {
                  AIHelper.showExplanationAssistant(context, material);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'document':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'article':
        return Colors.green;
      case 'quiz':
        return Colors.orange;
      case 'practice':
        return Colors.purple;
      case 'reference':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'practice':
        return Icons.edit;
      case 'reference':
        return Icons.book;
      default:
        return Icons.folder;
    }
  }
  
  Widget _buildEmptyCard(String title, String message, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
                  Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    await _loadData();
  }
  
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Add Schedule'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddScheduleScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Add Activity'),
                onTap: () async {
                  Navigator.pop(context);
                  if (_schedules.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please create a schedule first'),
                      ),
                    );
                    return;
                  }
                  final now = DateTime.now();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddActivityScreen(
                        scheduleId: _schedules.first.id!,
                        selectedDate: now,
                        initialDayOfWeek: now.weekday,
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Add Study Material'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMaterialScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadData();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showAIAssistant() {
    AIAssistantDialog.show(context);
  }
}
