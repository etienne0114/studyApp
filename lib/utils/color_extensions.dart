// lib/utils/color_extensions.dart

import 'package:flutter/material.dart';

/// Extension methods for the Color class to provide backward compatibility
/// and additional utility methods
extension ColorExtensions on Color {
  /// Creates a color with the specified opacity while preserving RGB values
  /// This is a safe replacement for the deprecated withOpacity() method
  Color withAlpha(double opacity) {
    final int alpha = (opacity * 255).round();
    return Color.fromARGB(
      alpha,
      red,
      green,
      blue,
    );
  }
  
  /// Get the red component of this color
  int get red => (0x00FF0000 & value) >> 16;
  
  /// Get the green component of this color
  int get green => (0x0000FF00 & value) >> 8;
  
  /// Get the blue component of this color
  int get blue => 0x000000FF & value;
  
  /// Get the alpha component of this color
  int get alpha => (0xFF000000 & value) >> 24;
  
  /// Lighten this color by the given percentage
  Color lighten(double amount) {
    assert(amount >= 0.0 && amount <= 1.0);
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Darken this color by the given percentage
  Color darken(double amount) {
    assert(amount >= 0.0 && amount <= 1.0);
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Convert this color to a material color swatch
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final Map<int, Color> swatch = {};
    
    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        red + ((ds < 0 ? red : (255 - red)) * ds).round(),
        green + ((ds < 0 ? green : (255 - green)) * ds).round(),
        blue + ((ds < 0 ? blue : (255 - blue)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(value, swatch);
  }
  
  /// Returns whether this color is considered light
  bool get isLight => computeLuminance() > 0.5;
  
  /// Returns whether this color is considered dark
  bool get isDark => !isLight;
  
  /// Returns either white or black to ensure contrast with this color
  Color get contrastColor => isLight ? Colors.black : Colors.white;
}