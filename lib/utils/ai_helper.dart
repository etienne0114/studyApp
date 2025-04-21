// lib/utils/ai_helper.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/ui/screens/materials/ai_assistant_dialog.dart';
import 'package:study_scheduler/constants/hero_tags.dart';

/// Simple utility to show the AI Assistant dialog from anywhere in the app
class AIHelper {
  
  /// Shows the AI assistant dialog
  static void showAIAssistant(BuildContext context, {StudyMaterial? material}) {
    showDialog(
      context: context,
      builder: (context) => AIAssistantDialog(material: material),
    );
  }
  
  /// Creates a floating action button for the AI assistant
  static Widget createAIButton(BuildContext context, {double size = 56.0}) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: HeroTags.aiAssistantButton,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.psychology_alt, color: Colors.white),
        onPressed: () => showAIAssistant(context),
      ),
    );
  }
  
  /// Creates an app bar action for the AI assistant
  static IconButton createAppBarAction(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.psychology_alt),
      tooltip: 'AI Assistant',
      onPressed: () => showAIAssistant(context),
    );
  }
}