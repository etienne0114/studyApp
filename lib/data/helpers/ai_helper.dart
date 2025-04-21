import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/ui/dialogs/ai_assistant_dialog.dart';

class AIHelper {
  static Widget createAppBarAction(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.psychology_alt),
      onPressed: () => showAssistant(context),
    );
  }

  static void showAssistant(BuildContext context, {String? initialQuestion}) {
    AIAssistantDialog.show(context, initialQuestion: initialQuestion);
  }

  static void showExplanationAssistant(BuildContext context, StudyMaterial material) {
    final question = 'Can you help me understand this ${material.category.toLowerCase()}: ${material.title}?';
    showAssistant(context, initialQuestion: question);
  }

  static void showStudyPlanningAssistant(BuildContext context) {
    const question = 'Can you help me create a study plan?';
    showAssistant(context, initialQuestion: question);
  }
} 