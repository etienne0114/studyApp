// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/constants/app_colors.dart';
import 'package:study_scheduler/routes.dart';
import 'package:study_scheduler/services/auth_service.dart';
import 'package:study_scheduler/ui/screens/auth/login_screen.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';


class StudySchedulerApp extends StatelessWidget {
  const StudySchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Scheduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: AppColors.accent,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Add custom AI-specific theming
        extensions: const [
          AIThemeExtension(
            aiPrimaryColor: Colors.blue,
            aiSecondaryColor: Colors.purple,
            aiBackgroundColor: Color(0xFFF5F7FA),
          ),
        ],
      ),
      routes: AppRoutes.routes,
      // Use the auth state to determine the initial route
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          // Check if the user is authenticated
          if (authService.isAuthenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      builder: (context, child) {
        // Add a global overlay for the AI assistant
        return Stack(
          children: [
            child!,
            // Conditionally show the global AI assistant button
            // only when on non-login screens and when the keyboard is not showing
            if (Provider.of<AuthService>(context).isAuthenticated &&
                MediaQuery.of(context).viewInsets.bottom == 0)
              const Positioned(
                right: 16,
                bottom: 80, child: SizedBox(), // Position above the bottom navigation bar
                
              ),
          ],
        );
      },
    );
  }
}

// Custom theme extension for AI-specific styling
class AIThemeExtension extends ThemeExtension<AIThemeExtension> {
  final Color aiPrimaryColor;
  final Color aiSecondaryColor;
  final Color aiBackgroundColor;

  const AIThemeExtension({
    required this.aiPrimaryColor,
    required this.aiSecondaryColor,
    required this.aiBackgroundColor,
  });

  @override
  ThemeExtension<AIThemeExtension> copyWith({
    Color? aiPrimaryColor,
    Color? aiSecondaryColor,
    Color? aiBackgroundColor,
  }) {
    return AIThemeExtension(
      aiPrimaryColor: aiPrimaryColor ?? this.aiPrimaryColor,
      aiSecondaryColor: aiSecondaryColor ?? this.aiSecondaryColor,
      aiBackgroundColor: aiBackgroundColor ?? this.aiBackgroundColor,
    );
  }

  @override
  ThemeExtension<AIThemeExtension> lerp(
    ThemeExtension<AIThemeExtension>? other,
    double t,
  ) {
    if (other is! AIThemeExtension) {
      return this;
    }
    return AIThemeExtension(
      aiPrimaryColor: Color.lerp(aiPrimaryColor, other.aiPrimaryColor, t)!,
      aiSecondaryColor: Color.lerp(aiSecondaryColor, other.aiSecondaryColor, t)!,
      aiBackgroundColor: Color.lerp(aiBackgroundColor, other.aiBackgroundColor, t)!,
    );
  }
}