import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:study_scheduler/data/models/schedule.dart';
import 'package:study_scheduler/data/models/activity.dart';
import 'package:study_scheduler/data/models/study_material.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('study_scheduler.db');
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        color TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scheduleId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dayOfWeek INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        notifyBefore INTEGER DEFAULT 30,
        isRecurring INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (scheduleId) REFERENCES schedules (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE study_materials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        filePath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old tables
      await db.execute('DROP TABLE IF EXISTS schedules');
      await db.execute('DROP TABLE IF EXISTS activities');
      await db.execute('DROP TABLE IF EXISTS study_materials');
      
      // Create new tables with updated schema
      await _createDB(db, newVersion);
    }
  }

  Future<List<Schedule>> getSchedules() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('schedules');
    return List.generate(maps.length, (i) => Schedule.fromMap(maps[i]));
  }

  Future<List<Activity>> getUpcomingActivities() async {
    final db = await database;
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'dayOfWeek = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'startTime ASC',
    );
    
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getCompletedActivities() async {
    final db = await database;
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'dayOfWeek = ? AND endTime < ?',
      whereArgs: [dayOfWeek, now.toIso8601String()],
      orderBy: 'endTime DESC',
    );
    
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<StudyMaterial>> getStudyMaterials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_materials');
    return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
  }

  Future<List<StudyMaterial>> getRecentMaterials() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_materials',
      orderBy: 'created_at DESC',
      limit: 5,
    );
    return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesForDay(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'day_of_week = ?',
      whereArgs: [date.weekday],
      orderBy: 'start_time ASC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await database;
    return await db.insert(
      'schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete the database file
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'study_scheduler.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Delete existing database if it exists
    await deleteDatabase();

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }
} 