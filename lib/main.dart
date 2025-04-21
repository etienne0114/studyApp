// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/repositories/schedule_repository.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'package:study_scheduler/services/auth_service.dart';
import 'package:study_scheduler/services/notification_service.dart';
import 'package:study_scheduler/managers/ai_assistant_manager.dart';
import 'package:study_scheduler/data/helpers/logger.dart';
import 'package:study_scheduler/ui/screens/home/home_screen.dart';

// Global logger instance
final Logger appLogger = Logger('App');

// Global variables for services
late DatabaseHelper _databaseHelper;
late NotificationService _notificationService;
late StudyMaterialsRepository _materialsRepository;
late AuthService _authService;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize services
  _notificationService = NotificationService.instance;
  await _notificationService.initialize();
  
  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>.value(value: _databaseHelper),
        Provider<NotificationService>.value(value: _notificationService),
        Provider<StudyMaterialsRepository>.value(value: _materialsRepository),
        Provider<AuthService>.value(value: _authService),
        ChangeNotifierProvider(
          create: (_) => ScheduleRepository(
            dbHelper: _databaseHelper,
            notificationService: _notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AIAssistantManager.instance,
        ),
      ],
      child: MaterialApp(
        title: 'Study Scheduler',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize core services
      _databaseHelper = DatabaseHelper.instance;
      _materialsRepository = StudyMaterialsRepository();
      _authService = AuthService();
      
      // Initialize AI assistant
      final aiManager = AIAssistantManager.instance;
      await aiManager.initialize();
      
      // App will continue normally even if AI initialization fails
    } catch (e) {
      print('Error initializing services: $e');
      // App will continue normally even if initialization fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}