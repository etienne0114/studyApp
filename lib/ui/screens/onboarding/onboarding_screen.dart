// lib/ui/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/constants/app_constants.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Study Scheduler',
      description: 'A simple way to organize your study time and improve your productivity.',
      imagePath: Icons.calendar_today,
    ),
    OnboardingPage(
      title: 'Create Study Schedules',
      description: 'Organize your courses, assignments, and study sessions in one place.',
      imagePath: Icons.schedule,
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description: 'Monitor your study habits and see your improvement over time.',
      imagePath: Icons.trending_up,
    ),
    OnboardingPage(
      title: 'Access Study Materials',
      description: 'Keep all your study materials organized and easily accessible.',
      imagePath: Icons.book,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefFirstLaunch, false);
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at the top
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDotIndicator(index == _currentPage),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon
          Icon(
            page.imagePath,
            size: 150,
            color: AppColors.primary,
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}