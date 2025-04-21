// lib/utils/ai_assistant_utils.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/ui/screens/materials/compact_ai_assistant_dialog.dart';

class AIAssistantUtils {
  /// Shows the AI Assistant dialog from anywhere in the app
  static void showAIAssistant(BuildContext context, {StudyMaterial? material}) {
    showDialog(
      context: context,
      builder: (context) => CompactAIAssistantDialog(material: material),
    );
  }
  
  /// Shows a quick AI Assistant tooltip with pre-filled question
  static void showQuickAssistant(BuildContext context, String question, {StudyMaterial? material}) {
    showDialog(
      context: context,
      builder: (context) {
        return CompactAIAssistantDialog(material: material);
      },
    );
  }
  
  /// Shows a floating AI button that can be added to any screen
  static Widget floatingAIButton(BuildContext context, {StudyMaterial? material}) {
    return FloatingActionButton(
      heroTag: 'ai_assistant_fab',
      backgroundColor: Colors.blue,
      child: const Icon(Icons.psychology, color: Colors.white),
      onPressed: () => showAIAssistant(context, material: material),
    );
  }
  
  /// Mini floating button that can be placed anywhere
  static Widget miniAIButton(BuildContext context, {StudyMaterial? material}) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showAIAssistant(context, material: material),
          borderRadius: BorderRadius.circular(20),
          child: const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
  
  /// AI Button that can be added to AppBar actions
  static IconButton appBarAIButton(BuildContext context, {StudyMaterial? material}) {
    return IconButton(
      icon: const Icon(Icons.psychology),
      tooltip: 'AI Assistant',
      onPressed: () => showAIAssistant(context, material: material),
    );
  }
}