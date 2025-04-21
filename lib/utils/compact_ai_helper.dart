// lib/utils/compact_ai_helper.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/ui/screens/materials/compact_ai_assistant_dialog.dart';
import 'package:study_scheduler/constants/hero_tags.dart';

/// Singleton helper class to manage AI Assistant functionality throughout the app
class CompactAIHelper {
  // Singleton instance
  static final CompactAIHelper _instance = CompactAIHelper._internal();
  factory CompactAIHelper() => _instance;
  CompactAIHelper._internal();
  
  // The most recent question asked
  String? _lastQuestion;
  String? get lastQuestion => _lastQuestion;
  
  // The most recent material used with AI
  StudyMaterial? _lastMaterial;
  StudyMaterial? get lastMaterial => _lastMaterial;
  
  // Track if the AI Assistant is currently showing
  bool _isShowing = false;
  bool get isShowing => _isShowing;
  
  /// Show the AI Assistant dialog
  void showAssistant(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
    String? heroTag,
  }) {
    // Don't show multiple instances
    if (_isShowing) return;
    
    _isShowing = true;
    _lastMaterial = material;
    _lastQuestion = initialQuestion;
    
    showDialog(
      context: context,
      builder: (context) => CompactAIAssistantDialog(
        material: material,
        heroTag: heroTag,
      ),
    ).then((_) {
      _isShowing = false;
    });
  }
  
  /// Show the AI Assistant with a quick question about scheduling
  void showSchedulingAssistant(BuildContext context) {
    showAssistant(
      context,
      initialQuestion: 'Help me plan my schedule for studying',
    );
  }
  
  /// Show the AI Assistant with a quick question about a specific subject
  void showSubjectAssistant(BuildContext context, String subject) {
    showAssistant(
      context,
      initialQuestion: 'Help me understand $subject',
    );
  }
  
  /// Create a floating button that can be added anywhere
  Widget createFloatingButton(BuildContext context) {
    // Generate a unique hero tag
    final heroTag = HeroTags.getUniqueCompactAiFabTag();
    
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () => showAssistant(context, heroTag: heroTag),
      child: const Icon(Icons.question_mark),
    );
  }
  
  /// Create an app bar action for AI assistance
  IconButton createAppBarAction(BuildContext context, {StudyMaterial? material}) {
    return IconButton(
      icon: const Icon(Icons.psychology),
      tooltip: 'AI Assistant',
      onPressed: () => showAssistant(context, material: material),
    );
  }
  
  /// Create a standard button for AI assistance
  Widget createButton(BuildContext context, {
    StudyMaterial? material,
    String? label,
    Color? color,
  }) {
    if (label != null) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.psychology),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => showAssistant(context, material: material),
      );
    } else {
      return IconButton(
        icon: Icon(Icons.psychology, color: color ?? Colors.blue),
        tooltip: 'AI Assistant',
        onPressed: () => showAssistant(context, material: material),
      );
    }
  }
}