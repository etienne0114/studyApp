// lib/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary color and variants
  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFFC5CAE9);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color accent = Color(0xFFFF4081); // Pink A200

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Schedule type colors
  static const List<Color> scheduleColors = [
    Color(0xFF3F51B5), // Indigo
    Color(0xFFE91E63), // Pink
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFF607D8B), // Blue Grey
  ];

  // Get a schedule color by index with wrapping
  static Color getScheduleColor(int index) {
    return scheduleColors[index % scheduleColors.length];
  }

  // Create a color with transparency
  // This method works with any Flutter version and avoids deprecated methods
  static Color withOpacity(Color color, double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    
    final int alpha = (opacity * 255).round();
    return Color.fromARGB(alpha, color.red, color.green, color.blue);
  }
  
  // Lighten a color by a percentage (amount between 0 and 1)
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  // Darken a color by a percentage (amount between 0 and 1)
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }

  // Convert color to material color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  
  // Determine if a color is light (useful for choosing contrasting text colors)
  static bool isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }
  
  // Choose a contrasting text color (black or white) based on background
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? textPrimary : textLight;
  }
}