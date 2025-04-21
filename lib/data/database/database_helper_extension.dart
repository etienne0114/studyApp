// lib/data/database/database_helper_extension.dart
// Extensions for the database helper to manage AI tables

import 'package:study_scheduler/data/database/database_helper.dart';

extension DatabaseHelperAIExtension on DatabaseHelper {
  // Create AI tables if they don't exist
  Future<void> ensureAITablesExist() async {
    final db = await database;
    
    // Check if ai_usage_tracking table exists
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
    );
    
    if (tables.isEmpty) {
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
    }
  }
  
  // Insert AI usage record
  Future<int> insertAIUsage(int? materialId, String aiService, String? query) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    return await db.insert('ai_usage_tracking', {
      'materialId': materialId,
      'aiService': aiService,
      'queryText': query,
      'usageDate': now,
    });
  }
  
  // Get most used AI services
  Future<List<Map<String, dynamic>>> getMostUsedAIServices() async {
    final db = await database;
    
    // Check if table exists first
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
    );
    
    if (tables.isEmpty) {
      return [];
    }
    
    return await db.rawQuery('''
      SELECT aiService, COUNT(*) as count
      FROM ai_usage_tracking
      GROUP BY aiService
      ORDER BY count DESC
      LIMIT 5
    ''');
  }
  
  // Get user's most used AI service
  Future<String?> getMostUsedAIService() async {
    final db = await database;
    
    // Check if table exists first
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
    );
    
    if (tables.isEmpty) {
      return null;
    }
    
    final result = await db.rawQuery('''
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
  }
  
  // Get recommended AI services for a category
  Future<List<String>> getRecommendedAIServicesForCategory(String category) async {
    final db = await database;
    
    // Check if table exists first
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
    );
    
    if (tables.isEmpty) {
      return _getDefaultAIServicesForCategory(category);
    }
    
    final maps = await db.rawQuery('''
      SELECT t.aiService, COUNT(*) as count
      FROM ai_usage_tracking t
      JOIN study_materials m ON t.materialId = m.id
      WHERE m.category = ?
      GROUP BY t.aiService
      ORDER BY count DESC
      LIMIT 3
    ''', [category]);
    
    if (maps.isEmpty) {
      return _getDefaultAIServicesForCategory(category);
    }
    
    return maps.map((map) => map['aiService'] as String).toList();
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
}