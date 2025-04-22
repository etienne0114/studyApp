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
  
  try {
    // Initialize services
    _databaseHelper = DatabaseHelper.instance;
    // Initialize database by accessing it
    await _databaseHelper.database;
    appLogger.info('Database initialized successfully');
    
    _notificationService = NotificationService.instance;
    await _notificationService.initialize();
    appLogger.info('Notification service initialized successfully');
    
    _materialsRepository = StudyMaterialsRepository();
    _authService = AuthService();
    
    // Initialize AI assistant
    final aiManager = AIAssistantManager.instance;
    await aiManager.initialize();
    appLogger.info('AI assistant initialized successfully');
    
    // Start the app
    runApp(const MyApp());
  } catch (e, stackTrace) {
    appLogger.error('Error initializing app: $e\n$stackTrace');
    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error initializing app',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
        ChangeNotifierProvider<AuthService>.value(value: _authService),
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: FutureBuilder(
          future: _initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error initializing app',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}

Future<void> _initializeApp() async {
  try {
    // Initialize database
    await _databaseHelper.database;
    appLogger.info('Database initialized successfully');
    
    // Initialize notification service
    await _notificationService.initialize();
    appLogger.info('Notification service initialized successfully');
    
    // Initialize AI assistant
    final aiManager = AIAssistantManager.instance;
    await aiManager.initialize();
    appLogger.info('AI assistant initialized successfully');
  } catch (e) {
    appLogger.error('Error initializing app: $e');
    rethrow;
  }
}