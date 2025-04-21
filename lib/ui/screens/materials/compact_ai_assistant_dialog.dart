// lib/ui/screens/materials/compact_ai_assistant_dialog.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'dart:async';
import 'package:study_scheduler/constants/hero_tags.dart';

class CompactAIAssistantDialog extends StatefulWidget {
  final StudyMaterial? material;
  final String? heroTag;

  const CompactAIAssistantDialog({
    super.key, 
    this.material,
    this.heroTag,
  });

  @override
  State<CompactAIAssistantDialog> createState() => _CompactAIAssistantDialogState();
}

class _CompactAIAssistantDialogState extends State<CompactAIAssistantDialog> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedAIService = 'Claude';
  bool _isProcessing = false;
  String _response = '';
  late String _heroTag;
  
  // Create repository instance
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  
  // Get all available AI services
  final List<String> _serviceNames = ['Claude', 'ChatGPT', 'GitHub Copilot', 'DeepSeek', 'Perplexity'];

  @override
  void initState() {
    super.initState();
    // Use provided hero tag or generate a new one
    _heroTag = widget.heroTag ?? HeroTags.getUniqueCompactAiFabTag();
    // Pre-fill question if applicable
    _loadPreferredService();
  }
  
  Future<void> _loadPreferredService() async {
    try {
      final preferredService = await _repository.getMostUsedAIService();
      if (preferredService != null && mounted) {
        setState(() {
          _selectedAIService = preferredService;
        });
      }
    } catch (e) {
      // Keep default service
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _processQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _response = '';
    });

    try {
      final question = _questionController.text.trim();
      
      // Track usage
      await _repository.trackAIUsage(
        widget.material?.id,
        _selectedAIService,
        question
      );
      
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate appropriate response based on question
      String response = _generateResponse(question);
      
      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _response = 'Error processing request. Please try again.';
          _isProcessing = false;
        });
      }
    }
  }
  
  String _generateResponse(String question) {
    // Simple day planning response for demo purposes
    if (question.toLowerCase().contains('plan my day') || 
        question.toLowerCase().contains('schedule') ||
        question.toLowerCase().contains('organize')) {
      return '''
Here's a suggested daily plan:

**Morning Routine**
- 7:00 AM: Wake up and hydrate
- 7:15 AM: Quick exercise/stretching (15 min)
- 7:30 AM: Shower and get ready
- 8:00 AM: Healthy breakfast
- 8:30 AM: Review your day's goals and priorities

**Study/Work Sessions**
- 9:00 AM - 10:30 AM: Deep work session 1 (focus on most challenging task)
- 10:30 AM - 10:45 AM: Short break (stretch, water)
- 10:45 AM - 12:15 PM: Deep work session 2
- 12:15 PM - 1:00 PM: Lunch break

**Afternoon**
- 1:00 PM - 2:30 PM: Deep work session 3
- 2:30 PM - 2:45 PM: Short break
- 2:45 PM - 4:15 PM: Deep work session 4 or meetings
- 4:15 PM - 5:00 PM: Review day's progress, plan tomorrow

**Evening**
- 5:00 PM - 6:00 PM: Exercise/personal time
- 6:00 PM - 7:00 PM: Dinner
- 7:00 PM - 9:00 PM: Relaxation, hobbies, or light review
- 9:00 PM - 10:00 PM: Wind down routine
- 10:00 PM: Sleep

Would you like me to help you customize this plan based on your specific needs?
''';
    } else {
      // Generic response
      return '''
I can help you with that! Based on your question about "$question", here are some suggestions:

1. Break down your goal into smaller, manageable tasks
2. Prioritize these tasks based on importance and urgency
3. Allocate specific time blocks in your schedule for focused work
4. Build in regular breaks using the Pomodoro technique
5. Review your progress at the end of each day and adjust as needed

Would you like more specific advice about any of these points?
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.blue;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Hero(
                    tag: _heroTag,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.withAlpha(30),
                      child: const Icon(Icons.question_mark, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI Learning Assistant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Question input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.question_answer_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          hintText: 'how can plan my day',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onSubmitted: (_) => _processQuestion(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // AI Service selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.purple,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<String>(
                          value: _selectedAIService,
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.purple),
                          items: _serviceNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedAIService = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    onPressed: () {
                      // Launch AI service in web
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening $_selectedAIService website')),
                      );
                    },
                  ),
                  
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _processQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('AI'),
                  ),
                ],
              ),
            ),
            
            // Response area
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isProcessing
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _response.isEmpty
                        ? const Center(
                            child: Text(
                              'Ask a question to get AI assistance',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _response,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
              ),
            ),
            
            // Footer
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Note: AI responses are simulated in this demo',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}