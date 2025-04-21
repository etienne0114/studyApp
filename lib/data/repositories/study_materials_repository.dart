// lib/data/repositories/study_materials_repository.dart

import 'package:flutter/foundation.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/database/database_helper.dart';
import 'package:study_scheduler/data/database/database_manager.dart';

class StudyMaterialsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final DatabaseManager _databaseManager = DatabaseManager.instance;

  // Get all study materials
  Future<List<StudyMaterial>> getMaterials() async {
    try {
      return await _databaseHelper.getStudyMaterials();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting materials: $e');
      }
      return [];
    }
  }

  // Get study material by ID
  Future<StudyMaterial?> getMaterialById(int id) async {
    try {
      return await _databaseHelper.getStudyMaterial(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting material by id: $e');
      }
      return null;
    }
  }

  // Get study materials by category
  Future<List<StudyMaterial>> getMaterialsByCategory(String category) async {
    try {
      return await _databaseHelper.getStudyMaterialsByCategory(category);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting materials by category: $e');
      }
      return [];
    }
  }

  // Search study materials
  Future<List<StudyMaterial>> searchMaterials(String query) async {
    try {
      return await _databaseHelper.searchStudyMaterials(query);
    } catch (e) {
      if (kDebugMode) {
        print('Error searching materials: $e');
      }
      return [];
    }
  }

  // Add new study material
  Future<int> addMaterial(StudyMaterial material) async {
    try {
      return await _databaseHelper.insertStudyMaterial(material);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding material: $e');
      }
      return -1;
    }
  }

  // Update existing study material
  Future<int> updateMaterial(StudyMaterial material) async {
    try {
      return await _databaseHelper.updateStudyMaterial(material);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating material: $e');
      }
      return -1;
    }
  }

  // Delete study material
  Future<int> deleteMaterial(int id) async {
    try {
      return await _databaseHelper.deleteStudyMaterial(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting material: $e');
      }
      return -1;
    }
  }
  
  // Get recommended materials (most recent for now)
  Future<List<StudyMaterial>> getRecommendedMaterials() async {
    try {
      final db = await _databaseManager.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'study_materials',
        orderBy: 'updatedAt DESC',
        limit: 5
      );
      return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recommended materials: $e');
      }
      return [];
    }
  }
  
  // Track AI usage with a material
  Future<int> trackAIUsage(int? materialId, String aiService, String? query) async {
    try {
      final db = await _databaseManager.database;
      final now = DateTime.now().toIso8601String();
      
      return await db.insert('ai_usage_tracking', {
        'materialId': materialId,
        'aiService': aiService,
        'queryText': query,
        'usageDate': now,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking AI usage: $e');
      }
      return -1;
    }
  }
  
  // Get most used AI services
  Future<List<Map<String, dynamic>>> getMostUsedAIServices() async {
    try {
      final db = await _databaseManager.database;
      
      // Check if table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
      );
      
      if (tables.isEmpty) {
        if (kDebugMode) {
          print('AI tracking table not found');
        }
        return [];
      }
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT aiService, COUNT(*) as count
        FROM ai_usage_tracking
        GROUP BY aiService
        ORDER BY count DESC
        LIMIT 5
      ''');
      
      return maps;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting most used AI services: $e');
      }
      return [];
    }
  }
  
  // Get materials most frequently accessed with AI
  Future<List<StudyMaterial>> getMostAccessedMaterials() async {
    try {
      final db = await _databaseManager.database;
      
      // Check if table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
      );
      
      if (tables.isEmpty) {
        return getRecommendedMaterials();
      }
      
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT m.*, COUNT(t.id) as accessCount
        FROM study_materials m
        LEFT JOIN ai_usage_tracking t ON m.id = t.materialId
        WHERE t.materialId IS NOT NULL
        GROUP BY m.id
        ORDER BY accessCount DESC
        LIMIT 10
      ''');
      
      if (maps.isEmpty) {
        return getRecommendedMaterials();
      }
      
      return List.generate(maps.length, (i) => StudyMaterial.fromMap(maps[i]));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting most accessed materials: $e');
      }
      return getRecommendedMaterials();
    }
  }
  
  // Get recommended AI services based on material category
  Future<List<String>> getRecommendedAIServicesForCategory(String category) async {
    try {
      final db = await _databaseManager.database;
      
      // Check if table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
      );
      
      if (tables.isEmpty) {
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
        return _getDefaultAIServicesForCategory(category);
      }
      
      return maps.map((map) => map['aiService'] as String).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recommended AI services for category: $e');
      }
      return _getDefaultAIServicesForCategory(category);
    }
  }
  
  // Get material view count
  Future<int> getMaterialViewCount(int materialId) async {
    try {
      final db = await _databaseManager.database;
      
      // Check if table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
      );
      
      if (tables.isEmpty) {
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
      final db = await _databaseManager.database;
      
      // Check if table exists first
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_usage_tracking';"
      );
      
      if (tables.isEmpty) {
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
  
  // Ensure AI tables exist (called during app initialization)
  Future<void> ensureAITablesExist() async {
    try {
      await _databaseManager.ensureAITablesExist();
    } catch (e) {
      if (kDebugMode) {
        print('Error ensuring AI tables exist (handled): $e');
      }
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
}