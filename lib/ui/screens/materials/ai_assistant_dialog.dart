// lib/ui/screens/materials/ai_assistant_dialog.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AIAssistantDialog extends StatefulWidget {
  final StudyMaterial? material;

  const AIAssistantDialog({
    super.key,
    this.material,
  });

  @override
  State<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedAIService = 'Claude';
  bool _isProcessing = false;
  String _response = '';
  bool _showMaterialContext = true;
  
  // Available AI services
  final List<String> _services = [
    'Claude',
    'ChatGPT',
    'GitHub Copilot',
    'DeepSeek',
    'Perplexity'
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill question if material is provided
    if (widget.material != null) {
      _questionController.text = 'How can I plan my day?';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _processQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _response = '';
    });

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Generate response
      String response = _generateResponse(question);
      
      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing request: $e');
      }
      
      // Show a generic response instead of error
      if (mounted) {
        setState(() {
          _response = "I'm here to help with your studies. What would you like to know?";
          _isProcessing = false;
        });
      }
    }
  }
  
  String _generateResponse(String question) {
    // Simple response generation based on keywords
    if (question.toLowerCase().contains('plan') || 
        question.toLowerCase().contains('day') ||
        question.toLowerCase().contains('schedule')) {
      return '''
Here's a suggested daily plan:

**Morning Routine**
- 7:00 AM: Wake up and hydrate
- 7:15 AM: Quick exercise/stretching (15 min)
- 7:30 AM: Shower and get ready
- 8:00 AM: Healthy breakfast
- 8:30 AM: Review your day's goals and priorities

**Study/Work Sessions**
- 9:00 AM - 10:30 AM: Deep work session 1
- 10:30 AM - 10:45 AM: Short break
- 10:45 AM - 12:15 PM: Deep work session 2
- 12:15 PM - 1:00 PM: Lunch break

**Afternoon**
- 1:00 PM - 2:30 PM: Deep work session 3
- 2:30 PM - 2:45 PM: Short break
- 2:45 PM - 4:15 PM: Deep work session 4
- 4:15 PM - 5:00 PM: Review progress, plan tomorrow

**Evening**
- 5:00 PM - 6:00 PM: Exercise/personal time
- 6:00 PM - 7:00 PM: Dinner
- 7:00 PM - 9:00 PM: Relaxation, hobbies
- 9:00 PM - 10:00 PM: Wind down routine
- 10:00 PM: Sleep
''';
    } else if (question.toLowerCase().contains('study') || 
               question.toLowerCase().contains('learn') ||
               question.toLowerCase().contains('material')) {
      return '''
Here are effective study techniques:

1. **Active Recall**: Test yourself instead of passively rereading
   
2. **Spaced Repetition**: Review material at increasing intervals
   
3. **Pomodoro Technique**: Study in focused 25-minute blocks with 5-minute breaks
   
4. **Feynman Technique**: Explain concepts in simple terms to identify knowledge gaps
   
5. **Mind Mapping**: Create visual connections between ideas
   
6. **Interleaving**: Mix different subjects or problem types
   
7. **Concrete Examples**: Apply concepts to real-world scenarios

Which technique would you like to try first?
''';
    } else {
      return '''
I can help with your studies in many ways:

• Creating study schedules and plans
• Explaining difficult concepts
• Recommending study techniques
• Generating practice questions
• Summarizing materials
• Breaking down complex topics
• Providing motivation and tips

What specific help do you need today?
''';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 600,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.psychology_alt, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Learning Assistant',
                    style: TextStyle(
                      fontSize: 18,
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
            const SizedBox(height: 16),
            if (widget.material != null) ...[
              Row(
                children: [
                  const Text(
                    'Include material context:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showMaterialContext,
                    onChanged: (value) {
                      setState(() {
                        _showMaterialContext = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              if (_showMaterialContext) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.material!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${widget.material!.category}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (widget.material!.description != null && 
                         widget.material!.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.material!.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.help_outline),
              ),
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _processQuestion(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedAIService,
                  underline: Container(height: 1, color: Colors.grey[300]),
                  items: _services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
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
                const Spacer(),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Ask AI'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator())
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
            const SizedBox(height: 8),
            const Center(
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