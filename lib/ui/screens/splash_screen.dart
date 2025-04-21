// lib/ui/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/constants/app_constants.dart';
import 'package:study_scheduler/services/notification_service.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';
import 'package:study_scheduler/ui/screens/onboarding/onboarding_screen.dart';
import 'package:study_scheduler/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Initialize app services and check first launch
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize notification service
      final notificationService = NotificationService.instance;
      await notificationService.initialize();
      
      // Check if this is the first launch
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(AppConstants.prefFirstLaunch) ?? true;
      
      // Navigate to appropriate screen after delay
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Check if widget is still mounted before navigating
      if (!mounted) return;
      
      // Navigate to appropriate screen
      if (isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      Logger.error('Error initializing app: $e');
      
      // Handle error case - still navigate to home screen
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // App name
                    const Text(
                      'Study Scheduler',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Tagline
                    const Text(
                      'Organize your study time efficiently',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}