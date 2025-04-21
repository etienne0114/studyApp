import 'package:flutter/material.dart';
import 'package:study_scheduler/ui/screens/auth/login_screen.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';
// Import other screens as needed

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    // Add more routes as needed
  };
}
