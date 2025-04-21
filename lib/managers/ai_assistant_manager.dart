// lib/managers/ai_assistant_manager.dart
// This is a singleton manager to handle all AI operations seamlessly

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/models/ai_service.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'package:flutter/foundation.dart';

class AIAssistantManager extends ChangeNotifier {
  // Singleton instance
  static final AIAssistantManager _instance = AIAssistantManager._internal();
  static AIAssistantManager get instance => _instance;
  
  // Private constructor
  AIAssistantManager._internal();
  
  // Repository reference
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  
  // User's preferred AI service
  String _preferredService = 'Claude'; // Default to Claude
  String get preferredService => _preferredService;
  
  // AI service API keys
  final Map<String, String> _apiKeys = {};
  
  // Initialize manager
  Future<void> initialize() async {
    try {
      // Create AI tables if they don't exist
      await _repository.ensureAITablesExist();
      
      // Load user preferences
      final preferred = await _repository.getMostUsedAIService();
      if (preferred != null) {
        _preferredService = preferred;
      }
      
      // Load API keys from secure storage
      await _loadApiKeys();
      
      notifyListeners();
    } catch (e) {
      // Handle errors silently
      if (kDebugMode) {
        print('AI Assistant initialization issue (handled silently): $e');
      }
    }
  }
  
  // Load API keys from secure storage
  Future<void> _loadApiKeys() async {
    try {
      // In a real app, you would load these from secure storage
      // For now, we'll use placeholder values
      _apiKeys['Claude'] = 'claude_api_key_placeholder';
      _apiKeys['GPT-4'] = 'gpt4_api_key_placeholder';
      _apiKeys['Cursor AI'] = 'cursor_api_key_placeholder';
    } catch (e) {
      if (kDebugMode) {
        print('Error loading API keys: $e');
      }
    }
  }
  
  // Set API key for a service
  Future<void> setApiKey(String service, String apiKey) async {
    try {
      _apiKeys[service] = apiKey;
      // In a real app, you would save this to secure storage
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error setting API key: $e');
      }
    }
  }
  
  // Get API key for a service
  String? getApiKey(String service) {
    return _apiKeys[service];
  }
  
  // Set preferred service
  void setPreferredService(String service) {
    _preferredService = service;
    notifyListeners();
  }
  
  // Track AI usage without failing
  Future<void> trackUsage(String aiService, String? query, {StudyMaterial? material}) async {
    try {
      await _repository.trackAIUsage(material?.id, aiService, query);
    } catch (e) {
      // Silently handle errors
      if (kDebugMode) {
        print('AI usage tracking issue (handled silently): $e');
      }
    }
  }
  
  // Get response from AI (simulated)
  Future<String> getAIResponse(String query, String aiService, {StudyMaterial? material}) async {
    try {
      // Track usage first
      await trackUsage(aiService, query, material: material);
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get the AI service instance
      final service = AIService.getServiceByName(aiService);
      
      // Check if we have an API key for this service
      final apiKey = getApiKey(aiService);
      if (apiKey == null || apiKey.isEmpty) {
        return "Please set up your API key for $aiService in the settings to use this service.";
      }
      
      // Return simulated response
      return service.getSimulatedResponse(query);
    } catch (e) {
      // Return a generic response if there's an error
      if (kDebugMode) {
        print('AI response generation issue (handled silently): $e');
      }
      return "I can help you plan your day, understand study materials, or answer questions about your studies. What would you like help with?";
    }
  }
  
  // Get AI service color
  Color getServiceColor(String serviceName) {
    final service = AIService.getServiceByName(serviceName);
    return service.color;
  }

  // Get available service names
  List<String> getAvailableServiceNames() {
    return AIService.getAllServices().map((service) => service.name).toList();
  }
  
  // Check if a service is available (has API key)
  bool isServiceAvailable(String serviceName) {
    final apiKey = getApiKey(serviceName);
    return apiKey != null && apiKey.isNotEmpty;
  }
  
  // Get service description
  String getServiceDescription(String serviceName) {
    final service = AIService.getServiceByName(serviceName);
    return service.description;
  }
  
  // Get service capabilities
  List<String> getServiceCapabilities(String serviceName) {
    final service = AIService.getServiceByName(serviceName);
    return service.capabilities;
  }
}