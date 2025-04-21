// lib/constants/app_styles.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/constants/app_colors.dart';

class AppStyles {
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontStyle: FontStyle.italic,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: _createColorWithOpacity(Colors.grey, 0.1),
        spreadRadius: 1,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Button Styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  );
  
  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: AppColors.primary),
    ),
    elevation: 0,
  );
  
  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  
  // Input Decoration
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  
  // Avatar Style
  static BoxDecoration avatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: _createColorWithOpacity(AppColors.primary, 0.2),
    border: Border.all(color: AppColors.primary, width: 2),
  );
  
  // Tag Style
  static BoxDecoration tagDecoration = BoxDecoration(
    color: AppColors.primaryLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: _createColorWithOpacity(AppColors.primary, 0.3),
    ),
  );
  
  // Search Bar Style
  static InputDecoration searchInputDecoration = InputDecoration(
    hintText: 'Search...',
    prefixIcon: const Icon(Icons.search),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        color: _createColorWithOpacity(AppColors.primary, 0.3),
      ),
    ),
  );
  
  // Helper method to create a color with opacity
  // This works with any Flutter version and avoids deprecated methods
  static Color _createColorWithOpacity(Color color, double opacity) {
    final int alpha = (opacity * 255).round();
    return Color.fromARGB(alpha, color.red, color.green, color.blue);
  }
  
  // Empty State Style
  static Widget buildEmptyState({
    required IconData icon,
    required String message,
    String? subMessage,
    Widget? actionButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}