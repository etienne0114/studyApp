// lib/helpers/ai_helper.dart
// This provides a simple way to access AI functionality across the app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/managers/ai_assistant_manager.dart';
import 'package:study_scheduler/ui/dialogs/ai_assistant_dialog.dart';

class AIHelper {
  // Private constructor to prevent instantiation
  AIHelper._();
  
  // Show AI assistant dialog
  static void showAssistant(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) {
    try {
      final manager = Provider.of<AIAssistantManager>(context, listen: false);
      final serviceColor = manager.getServiceColor(manager.preferredService);
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: serviceColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AIAssistantDialog(
              material: material,
              initialQuestion: initialQuestion,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing AI assistant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open AI assistant. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Create a floating action button for AI
  static Widget createFloatingButton(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) {
    return Consumer<AIAssistantManager>(
      builder: (context, manager, _) {
        final serviceColor = manager.getServiceColor(manager.preferredService);
        final isAvailable = manager.isServiceAvailable(manager.preferredService);
        
        return FloatingActionButton(
          onPressed: isAvailable
              ? () => showAssistant(
                  context,
                  material: material,
                  initialQuestion: initialQuestion,
                )
              : null,
          backgroundColor: serviceColor,
          child: Icon(
            _getServiceIcon(manager.preferredService),
            color: Colors.white,
          ),
        );
      },
    );
  }
  
  // Create an AppBar action for AI assistant
  static Widget createAppBarAction(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) {
    return Consumer<AIAssistantManager>(
      builder: (context, manager, _) {
        final serviceColor = manager.getServiceColor(manager.preferredService);
        final isAvailable = manager.isServiceAvailable(manager.preferredService);
        
        return IconButton(
          onPressed: isAvailable
              ? () => showAssistant(
                  context,
                  material: material,
                  initialQuestion: initialQuestion,
                )
              : null,
          icon: Icon(
            _getServiceIcon(manager.preferredService),
            color: isAvailable ? serviceColor : Colors.grey,
          ),
          tooltip: 'Ask ${manager.preferredService}',
        );
      },
    );
  }
  
  // Create a text button with AI icon
  static Widget createTextButton(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) {
    return Consumer<AIAssistantManager>(
      builder: (context, manager, _) {
        final serviceColor = manager.getServiceColor(manager.preferredService);
        final isAvailable = manager.isServiceAvailable(manager.preferredService);
        
        return TextButton.icon(
          onPressed: isAvailable
              ? () => showAssistant(
                  context,
                  material: material,
                  initialQuestion: initialQuestion,
                )
              : null,
          icon: Icon(
            _getServiceIcon(manager.preferredService),
            size: 16,
            color: isAvailable ? serviceColor : Colors.grey,
          ),
          label: Text(
            'Ask ${manager.preferredService}',
            style: TextStyle(
              color: isAvailable ? serviceColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
  
  // Create a mini-button that can be placed anywhere
  static Widget createMiniButton(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.blue,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: () => showAssistant(
            context,
            material: material,
            initialQuestion: initialQuestion,
          ),
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.psychology_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
  
  // Show assistant for study planning
  static void showStudyPlanningAssistant(BuildContext context) {
    showAssistant(
      context,
      initialQuestion: 'Help me create a study plan',
    );
  }
  
  // Show assistant for material explanation
  static void showExplanationAssistant(BuildContext context, StudyMaterial material) {
    showAssistant(
      context,
      material: material,
      initialQuestion: 'Explain the concepts in ${material.title}',
    );
  }

  static IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'cursor ai':
        return Icons.code;
      case 'claude':
        return Icons.psychology;
      case 'gpt-4':
        return Icons.auto_awesome;
      default:
        return Icons.smart_toy;
    }
  }
}