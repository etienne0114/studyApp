// lib/data/database/database_manager.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

/// A centralized manager for database operations to prevent duplicate table creation
class DatabaseManager {
  // Singleton pattern
  static final DatabaseManager _instance = DatabaseManager._internal();
  static DatabaseManager get instance => _instance;

  // Database instance
  static Database? _database;
  
  // Flag to track if AI tables initialization has been attempted
  bool _aiTablesInitialized = false;
  
  // Private constructor
  DatabaseManager._internal();
  
  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize the database
  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'study_scheduler.db');
      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          if (kDebugMode) {
            print('Database opened successfully');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }
  
  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      if (kDebugMode) {
        print('Creating database for the first time, version $version');
      }
      
      // Create schedules table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedules(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          color INTEGER,
          isActive INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');

      // Create activities table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS activities(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          scheduleId INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          location TEXT,
          dayOfWeek INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          notifyBefore INTEGER DEFAULT 30,
          isRecurring INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (scheduleId) REFERENCES schedules (id) ON DELETE CASCADE
        )
      ''');

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
      
      // Create indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_scheduleId ON activities(scheduleId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_dayOfWeek ON activities(dayOfWeek)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_study_materials_category ON study_materials(category)');
      
      // Create AI tables at initial creation
      await _createAITables(db);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error during database creation: $e');
      }
      rethrow;
    }
  }
  
  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (kDebugMode) {
        print('Upgrading database from version $oldVersion to $newVersion');
      }
      
      if (oldVersion < 2 && newVersion >= 2) {
        // Add study materials table for upgrading from version 1 to 2
        if (kDebugMode) {
          print('Adding study_materials table in upgrade from v1 to v2');
        }
        
        final materialTableExists = await _tableExists(db, 'study_materials');
        if (!materialTableExists) {
          await db.execute('''
            CREATE TABLE study_materials(
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
          await db.execute('CREATE INDEX idx_study_materials_category ON study_materials(category)');
        } else {
          if (kDebugMode) {
            print('study_materials table already exists, skipping creation');
          }
        }
      }
      
      if (oldVersion < 3 && newVersion >= 3) {
        // Add AI tables in upgrade from v2 to v3
        if (kDebugMode) {
          print('Adding AI tables in upgrade from v2 to v3');
        }
        
        await _createAITables(db);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during database upgrade: $e');
      }
      // Don't rethrow - allow app to continue even with upgrade error
    }
  }
  
  // Check if a table exists
  Future<bool> _tableExists(Database db, String tableName) async {
    try {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]
      );
      return result.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if table $tableName exists: $e');
      }
      return false;
    }
  }
  
  // Create AI tables safely
  Future<void> _createAITables(Database db) async {
    try {
      // Only proceed if we haven't already tried to initialize
      if (_aiTablesInitialized) {
        if (kDebugMode) {
          print('AI tables initialization already attempted, skipping');
        }
        return;
      }
      
      _aiTablesInitialized = true;
      
      // Check if ai_usage_tracking table already exists
      final aiTableExists = await _tableExists(db, 'ai_usage_tracking');
      
      if (!aiTableExists) {
        if (kDebugMode) {
          print('Creating ai_usage_tracking table');
        }
        
        // Create AI usage tracking table
        await db.execute('''
          CREATE TABLE ai_usage_tracking(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            materialId INTEGER,
            aiService TEXT NOT NULL,
            queryText TEXT,
            usageDate TEXT NOT NULL,
            FOREIGN KEY (materialId) REFERENCES study_materials (id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('CREATE INDEX idx_ai_usage_materialId ON ai_usage_tracking(materialId)');
        
        if (kDebugMode) {
          print('AI tables created successfully');
        }
      } else {
        if (kDebugMode) {
          print('ai_usage_tracking table already exists, skipping creation');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating AI tables: $e');
      }
      // Don't rethrow - allow app to continue even with AI table error
    }
  }
  
  // Ensure AI tables exist - public method that can be called safely from anywhere
  Future<void> ensureAITablesExist() async {
    try {
      final db = await database;
      await _createAITables(db);
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring AI tables exist: $e');
      }
      // Don't throw - allow app to continue even with error
    }
  }
  
  // Execute a database operation with proper error handling
  Future<T> executeDbOperation<T>(Future<T> Function(Database) operation) async {
    try {
      final db = await database;
      return await operation(db);
    } catch (e) {
      if (kDebugMode) {
        print('Error executing database operation: $e');
      }
      rethrow;
    }
  }
  
  // Reset AI tables (for testing/debugging)
  Future<void> resetAITables() async {
    try {
      final db = await database;
      
      // Drop AI tables if they exist
      final aiTableExists = await _tableExists(db, 'ai_usage_tracking');
      if (aiTableExists) {
        await db.execute('DROP TABLE ai_usage_tracking');
        if (kDebugMode) {
          print('AI tables dropped');
        }
      }
      
      // Reset flag
      _aiTablesInitialized = false;
      
      // Recreate tables
      await _createAITables(db);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting AI tables: $e');
      }
    }
  }
}