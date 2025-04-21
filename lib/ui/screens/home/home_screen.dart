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
import 'package:study_scheduler/ui/screens/home/widgets/upcoming_activities.dart';
import 'package:study_scheduler/ui/screens/home/widgets/schedule_card.dart';
import 'package:study_scheduler/ui/screens/materials/materials_screen.dart';
import 'package:study_scheduler/ui/screens/materials/add_material_screen.dart';
import 'package:study_scheduler/ui/screens/materials/material_detail_screen.dart';
import 'package:study_scheduler/data/helpers/database_helper.dart';
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
      final db = DatabaseHelper.instance;
      _schedules = await db.getSchedules();
      _upcomingActivities = await db.getUpcomingActivities();
      _completedActivities = await db.getCompletedActivities();
      _recentMaterials = await db.getRecentMaterials();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ScheduleScreen();
      case 2:
        return const MaterialsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }
  
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 16),
            _buildAIAssistantCard(),
            const SizedBox(height: 16),
            _buildUpcomingActivitiesSection(),
            const SizedBox(height: 16),
            _buildSchedulesSection(),
            const SizedBox(height: 16),
            _buildRecentMaterialsSection(),
            const SizedBox(height: 16),
            _buildCompletedActivitiesSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppStyles.heading1,
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your study overview for today',
          style: AppStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAIAssistantCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _showAIAssistant,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _aiManager.getServiceColor(_aiManager.preferredService).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology_alt,
                      color: _aiManager.getServiceColor(_aiManager.preferredService),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Learning Assistant',
                          style: AppStyles.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get help with your studies',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildAIActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Study Tips',
                    onTap: () {
                      AIAssistantDialog.show(
                        context,
                        initialQuestion: 'Give me some study tips for today',
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildAIActionButton(
                    icon: Icons.calendar_today,
                    label: 'Schedule Help',
                    onTap: () {
                      AIAssistantDialog.show(
                        context,
                        initialQuestion: 'Help me plan my study schedule',
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildAIActionButton(
                    icon: Icons.code,
                    label: 'Code Help',
                    onTap: () {
                      AIAssistantDialog.show(
                        context,
                        initialQuestion: 'Help me with programming',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAIActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: _aiManager.getServiceColor(_aiManager.preferredService),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildUpcomingActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Activities',
              style: AppStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1; // Switch to schedule tab
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _upcomingActivities.isEmpty
            ? _buildEmptyActivitiesCard()
            : UpcomingActivities(activities: _upcomingActivities),
      ],
    );
  }
  
  Widget _buildEmptyActivitiesCard() {
    final hasSchedules = _schedules.isNotEmpty;
    final schedule = _selectedSchedule ?? (hasSchedules ? _schedules.first : null);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hasSchedules ? 'No activities scheduled for today' : 'No schedules created yet',
              style: AppStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSchedules 
                ? 'Add activities to your schedule to see them here'
                : 'Create a schedule to start adding activities',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => hasSchedules 
                      ? AddActivityScreen(scheduleId: schedule!.id!)
                      : const AddScheduleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(hasSchedules ? 'Add Activity' : 'Create Schedule'),
              style: AppStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSchedulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Schedules',
              style: AppStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1; // Switch to schedule tab
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _schedules.isEmpty
            ? _buildEmptySchedulesCard()
            : SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _schedules.length - 1 ? 16 : 0,
                      ),
                      child: ScheduleCard(schedule: schedule),
                    );
                  },
                ),
              ),
      ],
    );
  }
  
  Widget _buildEmptySchedulesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No schedules created yet',
              style: AppStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a schedule to organize your study activities',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddScheduleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Schedule'),
              style: AppStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Materials',
              style: AppStyles.heading2,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Switch to materials tab
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _recentMaterials.isEmpty
            ? _buildEmptyMaterialsCard()
            : ListView.builder(
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
  
  Widget _buildEmptyMaterialsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.book,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No study materials added yet',
              style: AppStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add study materials to keep track of your resources',
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMaterialScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Material'),
              style: AppStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
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
  
  Widget _buildCompletedActivitiesSection() {
    if (_completedActivities.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed Today',
          style: AppStyles.heading2,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _completedActivities.length,
          itemBuilder: (context, index) {
            final activity = _completedActivities[index];
            return _buildCompletedActivityCard(activity);
          },
        ),
      ],
    );
  }
  
  Widget _buildCompletedActivityCard(Activity activity) {
    final schedule = _schedules.firstWhere(
      (s) => s.id == activity.scheduleId,
      orElse: () => Schedule(
        id: 0,
        title: 'Unknown Schedule',
        color: '#000000',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${schedule.color.substring(1)}')).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(int.parse('0xFF${schedule.color.substring(1)}')),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity.startTime} - ${activity.endTime}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: _showAIAssistant,
        backgroundColor: _aiManager.getServiceColor(_aiManager.preferredService),
        child: const Icon(Icons.psychology_alt),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddActivityScreen(
                scheduleId: _selectedSchedule?.id ?? _schedules.first.id!,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 2) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMaterialScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Materials',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
  
  void _showAIAssistant() {
    AIAssistantDialog.show(context);
  }



}
