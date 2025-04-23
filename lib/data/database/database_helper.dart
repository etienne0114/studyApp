// lib/data/database/database_helper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'package:study_scheduler/data/helpers/logger.dart';
import 'package:flutter/material.dart'; // Add this import for TimeOfDay

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  static sqflite.Database? _database;
  final Logger _logger = Logger('DatabaseHelper');
  bool _isInitialized = false;
  
  Future<sqflite.Database> get database async {
    if (_database != null && _isInitialized) return _database!;
    _database = await _initDatabase();
    _isInitialized = true;
    return _database!;
  }

  DatabaseHelper._internal();

  Future<sqflite.Database> _initDatabase() async {
    try {
      String path = join(await sqflite.getDatabasesPath(), 'study_scheduler.db');
      
      return await sqflite.openDatabase(
        path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );
    } catch (e) {
      _logger.error('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        _isInitialized = false;
        _logger.info('Database closed successfully');
      }
    } catch (e) {
      _logger.error('Error closing database: $e');
    }
  }

  Future<void> _onDowngrade(sqflite.Database db, int oldVersion, int newVersion) async {
    try {
      // Drop all tables and recreate them
      await db.execute('DROP TABLE IF EXISTS activities');
      await db.execute('DROP TABLE IF EXISTS schedules');
      await db.execute('DROP TABLE IF EXISTS study_materials');
      await db.execute('DROP TABLE IF EXISTS ai_usage_tracking');
      await _onCreate(db, newVersion);
      _logger.info('Database downgraded successfully');
    } catch (e) {
      _logger.error('Error downgrading database: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(sqflite.Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 3) {
        // Drop and recreate the activities table with the new schema
        await db.execute('DROP TABLE IF EXISTS activities');
        await _createActivitiesTable(db);
      }
      
      if (oldVersion < 4) {
        // Check if category column exists, if not add it
        var table = await db.rawQuery('PRAGMA table_info(activities)');
        bool hasCategoryColumn = table.any((column) => column['name'] == 'category');
        
        if (!hasCategoryColumn) {
          await db.execute('ALTER TABLE activities ADD COLUMN category TEXT NOT NULL DEFAULT "study"');
          _logger.info('Added category column to activities table');
        }
      }
    } catch (e) {
      _logger.error('Error upgrading database: $e');
      rethrow;
    }
  }

  Future<void> _createActivitiesTable(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheduleId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL DEFAULT 'study',
        type TEXT NOT NULL DEFAULT 'study',
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        notificationEnabled INTEGER DEFAULT 1,
        notificationMinutesBefore INTEGER DEFAULT 15,
        location TEXT,
        dayOfWeek INTEGER NOT NULL,
        isRecurring INTEGER DEFAULT 1,
        notifyBefore INTEGER DEFAULT 30,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
      // Create schedules table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedules(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          color TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Create activities table
      await _createActivitiesTable(db);

      // Create study materials table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_materials(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          category TEXT NOT NULL,
          filePath TEXT,
          fileType TEXT,
          fileUrl TEXT,
          isOnline INTEGER DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      
      // Create AI usage tracking table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ai_usage_tracking(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          materialId INTEGER,
          aiService TEXT NOT NULL,
          queryText TEXT,
          usageDate TEXT NOT NULL,
          FOREIGN KEY (materialId) REFERENCES study_materials (id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for faster queries
      await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_scheduleId ON activities(scheduleId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_startTime ON activities(startTime)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_study_materials_category ON study_materials(category)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ai_usage_materialId ON ai_usage_tracking(materialId)');

      _logger.info('Database tables created successfully');
    } catch (e) {
      _logger.error('Error creating database tables: $e');
      rethrow;
    }
  }

  // Schedules operations
  Future<int> insertSchedule(Schedule schedule) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final map = schedule.toMap();
      map['createdAt'] = now;
      map['updatedAt'] = now;
      
      return await db.insert('schedules', map);
    } catch (e) {
      _logger.error('Error inserting schedule: $e');
      rethrow;
    }
  }

  Future<int> updateSchedule(Schedule schedule) async {
    try {
      final db = await database;
      final map = schedule.toMap();
      map['updatedAt'] = DateTime.now().toIso8601String();
      
      return await db.update(
        'schedules',
        map,
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
    } catch (e) {
      _logger.error('Error updating schedule: $e');
      rethrow;
    }
  }

  Future<int> deleteSchedule(int id) async {
    try {
      final sqflite.Database db = await database;
      return await db.delete(
        'schedules',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.error('Error deleting schedule: $e');
      rethrow;
    }
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        orderBy: 'createdAt DESC'
      );
      
      _logger.info('Retrieved ${maps.length} schedules');
      return List.generate(maps.length, (i) {
        final map = maps[i];
        return Schedule(
          id: map['id'] as int?,
          title: map['title']?.toString() ?? '',
          description: map['description']?.toString(),
          color: map['color']?.toString() ?? '#2196F3',
          isActive: (map['isActive'] as int?) ?? 1,
          createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
          updatedAt: map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
        );
      });
    } catch (e) {
      _logger.error('Error getting schedules: $e');
      return [];
    }
  }

  Future<Schedule?> getSchedule(int id) async {
    final sqflite.Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Schedule.fromMap(maps.first);
    }
    return null;
  }

  // Activity operations
  Future<List<Activity>> getActivitiesForDay(DateTime day) async {
    try {
      final db = await database;
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          a.id,
          a.scheduleId,
          a.title,
          a.description,
          a.category,
          a.startTime,
          a.endTime,
          a.isCompleted,
          a.notificationEnabled,
          a.notificationMinutesBefore,
          a.location,
          a.dayOfWeek,
          a.isRecurring,
          a.notifyBefore,
          a.createdAt,
          a.updatedAt,
          a.type,
          s.title as scheduleTitle,
          s.color as scheduleColor
        FROM activities a
        LEFT JOIN schedules s ON a.scheduleId = s.id
        WHERE a.dayOfWeek = ?
        AND (a.isCompleted IS NULL OR a.isCompleted = 0)
        ORDER BY a.startTime ASC
      ''', [day.weekday]);
      
      _logger.info('Retrieved ${maps.length} activities for day ${day.weekday}');
      
      return List.generate(maps.length, (i) {
        final map = maps[i];
        try {
          return Activity(
            id: map['id'] as int?,
            scheduleId: map['scheduleId'] as int? ?? 0,
            title: map['title']?.toString() ?? 'Untitled Activity',
            description: map['description']?.toString(),
            category: map['category']?.toString() ?? 'study',
            type: map['type']?.toString() ?? 'study',
            startTime: TimeOfDay(
              hour: int.tryParse(map['startTime']?.toString().split(':')[0] ?? '0') ?? 0,
              minute: int.tryParse(map['startTime']?.toString().split(':')[1] ?? '0') ?? 0,
            ),
            endTime: TimeOfDay(
              hour: int.tryParse(map['endTime']?.toString().split(':')[0] ?? '0') ?? 0,
              minute: int.tryParse(map['endTime']?.toString().split(':')[1] ?? '0') ?? 0,
            ),
            isCompleted: (map['isCompleted'] as int?) == 1,
            notificationEnabled: (map['notificationEnabled'] as int?) == 1,
            notificationMinutesBefore: (map['notificationMinutesBefore'] as int?) ?? 15,
            location: map['location']?.toString(),
            dayOfWeek: (map['dayOfWeek'] as int?) ?? day.weekday,
            isRecurring: (map['isRecurring'] as int?) == 1,
            notifyBefore: (map['notifyBefore'] as int?) ?? 30,
            createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
            updatedAt: map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
            scheduleTitle: map['scheduleTitle']?.toString(),
            scheduleColor: map['scheduleColor']?.toString() ?? '#2196F3',
          );
        } catch (e) {
          _logger.error('Error creating activity from map: $e');
          return Activity(
            scheduleId: map['scheduleId'] as int? ?? 0,
            title: 'Error Loading Activity',
            category: 'error',
            startTime: TimeOfDay(hour: 0, minute: 0),
            endTime: TimeOfDay(hour: 0, minute: 0),
            dayOfWeek: day.weekday,
            type: 'error',
          );
        }
      });
    } catch (e) {
      _logger.error('Error getting activities for day: $e');
      return [];
    }
  }

  Future<List<Activity>> getActivities() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'activities',
        orderBy: 'startTime ASC'
      );
      return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
    } catch (e) {
      _logger.error('Error getting all activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getActivitiesByScheduleId(int scheduleId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'activities',
        where: 'scheduleId = ?',
        whereArgs: [scheduleId],
        orderBy: 'startTime ASC'
      );
      
      _logger.info('Retrieved ${maps.length} activities for schedule $scheduleId');
      
      return List.generate(maps.length, (i) {
        final map = maps[i];
        try {
          return Activity.fromMap(map);
        } catch (e) {
          _logger.error('Error creating activity from map: $e');
          return Activity(
            scheduleId: scheduleId,
            title: 'Error Loading Activity',
            category: 'error',
            startTime: TimeOfDay(hour: 0, minute: 0),
            endTime: TimeOfDay(hour: 0, minute: 0),
            dayOfWeek: DateTime.now().weekday,
            type: 'error',
          );
        }
      });
    } catch (e) {
      _logger.error('Error getting activities for schedule: $e');
      return [];
    }
  }

  Future<List<Activity>> getUpcomingActivities([DateTime? fromDate]) async {
    try {
      final db = await database;
      final now = fromDate ?? DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT a.*, s.title as scheduleTitle, s.color as scheduleColor
        FROM activities a
        JOIN schedules s ON a.scheduleId = s.id
        WHERE a.startTime >= ?
        AND (a.isCompleted IS NULL OR a.isCompleted = 0)
        ORDER BY a.startTime ASC
      ''', [startOfDay]);
      
      _logger.info('Retrieved ${maps.length} upcoming activities');
      return List.generate(maps.length, (i) {
        final activity = Activity.fromMap(maps[i]);
        activity.scheduleTitle = maps[i]['scheduleTitle'] as String;
        activity.scheduleColor = maps[i]['scheduleColor'] as String;
        return activity;
      });
    } catch (e) {
      _logger.error('Error getting upcoming activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getCompletedActivities() async {
    try {
      final db = await database;
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT a.*, s.title as scheduleTitle, s.color as scheduleColor
        FROM activities a
        JOIN schedules s ON a.scheduleId = s.id
        WHERE a.isCompleted = 1
        AND a.startTime BETWEEN ? AND ?
        ORDER BY a.startTime DESC
      ''', [startOfDay, endOfDay]);
      
      _logger.info('Retrieved ${maps.length} completed activities');
      return List.generate(maps.length, (i) {
        final activity = Activity.fromMap(maps[i]);
        activity.scheduleTitle = maps[i]['scheduleTitle'] as String;
        activity.scheduleColor = maps[i]['scheduleColor'] as String;
        return activity;
      });
    } catch (e) {
      _logger.error('Error getting completed activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getActivitiesForSchedule(int scheduleId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'activities',
        where: 'scheduleId = ?',
        whereArgs: [scheduleId],
        orderBy: 'startTime ASC'
      );

      return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
    } catch (e) {
      _logger.error('Error getting activities for schedule: $e');
      return [];
    }
  }

  Future<int> insertActivity(Activity activity) async {
    try {
      final db = await database;
      final now = DateTime.now();
      
      final map = activity.toMap();
      map['createdAt'] = now.toIso8601String();
      map['updatedAt'] = now.toIso8601String();
      
      return await db.insert('activities', map);
    } catch (e) {
      _logger.error('Error inserting activity: $e');
      rethrow;
    }
  }

  Future<int> updateActivity(Activity activity) async {
    try {
      final db = await database;
      final map = activity.toMap();
      map['updatedAt'] = DateTime.now().toIso8601String();
      
      return await db.update(
        'activities',
        map,
        where: 'id = ?',
        whereArgs: [activity.id],
      );
    } catch (e) {
      _logger.error('Error updating activity: $e');
      rethrow;
    }
  }

  Future<int> deleteActivity(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'activities',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      _logger.error('Error deleting activity: $e');
      rethrow;
    }
  }

  // Study Materials operations
  Future<int> insertStudyMaterial(StudyMaterial material) async {
    try {
      final db = await database;
      final map = material.toMap();
      
      // Remove id if it's 0 or null to let SQLite auto-increment
      map.remove('id');
      
      final id = await db.insert('study_materials', map);
      _logger.info('Successfully inserted study material with id: $id');
      return id;
    } catch (e) {
      _logger.error('Error inserting study material: $e');
      rethrow;
    }
  }

  Future<int> updateStudyMaterial(StudyMaterial material) async {
    final sqflite.Database db = await database;
    return await db.update(
      'study_materials',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteStudyMaterial(int id) async {
    final sqflite.Database db = await database;
    return await db.delete(
      'study_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<StudyMaterial>> getStudyMaterials() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'study_materials',
        orderBy: 'updatedAt DESC'
      );
      return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
    } catch (e) {
      _logger.error('Error getting study materials: $e');
      return [];
    }
  }

  Future<StudyMaterial?> getStudyMaterial(int id) async {
    final sqflite.Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_materials',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudyMaterial.fromMap(maps.first);
    }
    return null;
  }
  
  Future<List<StudyMaterial>> getStudyMaterialsByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'study_materials',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'updatedAt DESC'
      );
      return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
    } catch (e) {
      _logger.error('Error getting study materials by category: $e');
      return [];
    }
  }
  
  Future<List<StudyMaterial>> searchStudyMaterials(String query) async {
    final sqflite.Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_materials',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
  }
  
  // AI Usage Tracking operations
  Future<int> trackAIUsage(int? materialId, String aiService, String? queryText) async {
    final sqflite.Database db = await database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('ai_usage_tracking', {
      'materialId': materialId,
      'aiService': aiService,
      'queryText': queryText,
      'usageDate': now,
    });
  }
  
  Future<List<Map<String, dynamic>>> getMostUsedAIServices() async {
    final sqflite.Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT aiService, COUNT(*) as count
      FROM ai_usage_tracking
      GROUP BY aiService
      ORDER BY count DESC
    ''');
    
    return maps;
  }
  
  Future<List<StudyMaterial>> getMostAccessedMaterials() async {
    final sqflite.Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, COUNT(t.id) as accessCount
      FROM study_materials m
      LEFT JOIN ai_usage_tracking t ON m.id = t.materialId
      GROUP BY m.id
      ORDER BY accessCount DESC
      LIMIT 10
    ''');
    
    return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
  }
  
  
    Future<List<StudyMaterial>> getRecentMaterials() async {
    try {
      final sqflite.Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'study_materials',
        orderBy: 'updatedAt DESC',
        limit: 1000,
      );
      return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recent materials: $e');
      }
      return [];
    }
  }
  
  // Get AI service suggestions based on material category
  Future<List<String>> getRecommendedAIServicesForCategory(String category) async {
    try {
      final sqflite.Database db = await database;
      
      final tablesExist = await _checkTableExists(db, 'ai_usage_tracking');
      if (!tablesExist) {
        return _getDefaultAIServicesForCategory(category);
      }
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT t.aiService, COUNT(*) as count
        FROM ai_usage_tracking t
        JOIN study_materials m ON t.materialId = m.id
        WHERE m.category = ?
        GROUP BY t.aiService
        ORDER BY count DESC
        LIMIT 3
      ''', [category]);
      
      if (maps.isEmpty) {
        // Default recommendations if no data
        return _getDefaultAIServicesForCategory(category);
      }
      
      return maps.map((map) => map['aiService'] as String).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recommended AI services for category: $e');
      }
      // Return default recommendations if there's an error
      return _getDefaultAIServicesForCategory(category);
    }
  }
  
  // Check if a table exists in the database
  Future<bool> _checkTableExists(sqflite.Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';"
      );
      return result.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if table exists: $e');
      }
      return false;
    }
  }
  
  // Default AI service recommendations by category
  List<String> _getDefaultAIServicesForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'document':
        return ['Claude', 'Perplexity', 'ChatGPT'];
      case 'video':
        return ['ChatGPT', 'Claude', 'Perplexity'];
      case 'article':
        return ['Perplexity', 'Claude', 'DeepSeek'];
      case 'quiz':
        return ['ChatGPT', 'Claude', 'DeepSeek'];
      case 'practice':
        return ['GitHub Copilot', 'DeepSeek', 'ChatGPT'];
      case 'reference':
        return ['Perplexity', 'Claude', 'ChatGPT'];
      default:
        return ['Claude', 'ChatGPT', 'Perplexity'];
    }
  }
  
  // Get material view count
  Future<int> getMaterialViewCount(int materialId) async {
    try {
      final sqflite.Database db = await database;
      
      final tablesExist = await _checkTableExists(db, 'ai_usage_tracking');
      if (!tablesExist) {
        return 0;
      }
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM ai_usage_tracking
        WHERE materialId = ?
      ''', [materialId]);
      
      if (result.isNotEmpty) {
        return result.first['count'] as int;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting material view count: $e');
      }
      return 0;
    }
  }
  
  // Get user's most used AI service
  Future<String?> getMostUsedAIService() async {
    try {
      final sqflite.Database db = await database;
      
      final tablesExist = await _checkTableExists(db, 'ai_usage_tracking');
      if (!tablesExist) {
        return null;
      }
      
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT aiService, COUNT(*) as count
        FROM ai_usage_tracking
        GROUP BY aiService
        ORDER BY count DESC
        LIMIT 1
      ''');
      
      if (result.isNotEmpty) {
        return result.first['aiService'] as String;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting most used AI service: $e');
      }
      return null;
    }
  }

  // Database maintenance
  Future<void> deleteDatabase() async {
    try {
      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, 'study_scheduler.db');
      await sqflite.databaseFactory.deleteDatabase(path);
      _database = null;
    } catch (e) {
      _logger.error('Error deleting database: $e');
      rethrow;
    }
  }

  Future<void> resetDatabase() async {
    try {
      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, 'study_scheduler.db');
      await sqflite.databaseFactory.deleteDatabase(path);
      _database = null;
      _isInitialized = false;
      _logger.info('Database reset successfully');
    } catch (e) {
      _logger.error('Error resetting database: $e');
      rethrow;
    }
  }
}