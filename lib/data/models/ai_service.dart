// lib/data/models/ai_service.dart

import 'package:flutter/material.dart';

class AIService {
  final String name;
  final String iconPath;
  final String url;
  final Color color;
  final String description;
  final List<String> capabilities;

  AIService({
    required this.name,
    required this.iconPath,
    required this.url,
    required this.color,
    required this.description,
    required this.capabilities,
  });

  // Helper method to generate a simulated response based on the service
  String getSimulatedResponse(String question) {
    final questionLower = question.toLowerCase();
    
    // Generic responses based on question content
    if (questionLower.contains('explain') || questionLower.contains('understand')) {
      return _getExplanation(question);
    } else if (questionLower.contains('summarize') || questionLower.contains('summary')) {
      return _getSummary(question);
    } else if (questionLower.contains('example') || questionLower.contains('practice')) {
      return _getExample(question);
    } else if (questionLower.contains('compare') || questionLower.contains('difference')) {
      return _getComparison(question);
    } else if (questionLower.contains('quiz') || questionLower.contains('test')) {
      return _getQuizQuestions();
    } else if (questionLower.contains('plan') || questionLower.contains('schedule')) {
      return _getDayPlan();
    } else if (questionLower.contains('code') || questionLower.contains('programming')) {
      return _getCodeResponse(question);
    } else {
      // Generic response
      return _getGenericResponse(question);
    }
  }

  // Helper methods to generate content based on question patterns
  String _getExplanation(String topic) {
    final explanationCapabilities = [
      'Detailed explanations',
      'Step-by-step breakdowns',
      'Visual aids and diagrams',
      'Real-world examples',
      'Practice problems',
      'Concept relationships',
      'Common misconceptions',
      'Study tips',
    ];

    print('Generating explanation for: $topic');
    print('Available capabilities:');
    for (final capability in explanationCapabilities) {
      print('- $capability');
    }

    return '''
Here's a detailed explanation of $topic:

1. Core Concept
   - Fundamental principles
   - Key components
   - Basic terminology

2. Step-by-Step Breakdown
   - Initial setup
   - Main process
   - Final steps
   - Common pitfalls to avoid

3. Visual Representation
   [Diagram would be shown here]
   - Key elements labeled
   - Process flow indicated
   - Important relationships highlighted

4. Real-World Application
   - Practical examples
   - Industry use cases
   - Common scenarios

5. Related Concepts
   - Prerequisites
   - Dependencies
   - Advanced topics

6. Study Tips
   - Key points to remember
   - Memory aids
   - Practice exercises
''';
  }

  String _getSummary(String question) {
    final topic = _getTopicFromQuestion(question);
    return '''# Summary
$topic can be summarized as a systematic approach to solving complex problems through a series of well-defined steps. It involves analyzing requirements, designing solutions, implementing those solutions, and then evaluating their effectiveness.

The main points to remember are:
- It follows a structured methodology
- It emphasizes both theoretical understanding and practical application
- It requires critical thinking and analytical skills
- It continues to evolve as new research emerges''';
  }

  String _getExample(String question) {
    _getTopicFromQuestion(question);
    return '''Here's an example to help you understand:

**Scenario**: A student is trying to learn a new concept for an upcoming exam.

**Application**:
1. The student begins by reviewing the fundamental principles
2. They create visual diagrams to map relationships between key ideas
3. They solve practice problems, gradually increasing in difficulty
4. They explain the concept to a friend to test their understanding
5. They review areas where they struggled and repeat the process

This example demonstrates how the theoretical framework can be applied to achieve tangible results.''';
  }

  String _getComparison(String question) {
    final parts = question.split(' and ');
    final topicA = parts.length > 1 ? _cleanTopic(parts[0].split(' ').last) : "Approach A";
    final topicB = parts.length > 1 ? _cleanTopic(parts[1].split(' ').first) : "Approach B";
    
    return '''## Comparison
| Aspect | $topicA | $topicB |
|--------|---------|---------|
| Foundational principle | Based on structural analysis | Based on functional analysis |
| Primary focus | Emphasizes theoretical framework | Emphasizes practical application |
| Learning curve | Steeper initial learning curve | More gradual learning progression |
| Best used for | Complex conceptual understanding | Immediate practical implementation |
| Supporting evidence | Strong theoretical research base | Extensive empirical validation |

These differences highlight why you might choose one over the other depending on your specific needs.''';
  }

  String _getQuizQuestions() {
    return '''# Quiz Questions

1. What is the primary purpose of this concept?
   - A) To simplify complex processes
   - B) To provide a framework for analysis
   - C) To optimize resource allocation
   - D) To enhance user experience

2. Which of the following is NOT a key component?
   - A) Structural foundation
   - B) Process optimization
   - C) User interface design
   - D) Performance metrics

3. How does this approach differ from traditional methods?
   - A) It focuses on theoretical understanding
   - B) It emphasizes practical application
   - C) It combines both theoretical and practical aspects
   - D) It disregards traditional methodologies entirely

4. What is the recommended approach for beginners?
   - A) Start with advanced concepts
   - B) Begin with fundamental principles
   - C) Focus on practical applications only
   - D) Skip theoretical foundations

5. Which factor most influences the effectiveness of this approach?
   - A) The complexity of the problem
   - B) The user's prior knowledge
   - C) The available resources
   - D) The time constraints''';
  }

  String _getDayPlan() {
    return '''# Daily Study Plan

## Morning (8:00 AM - 12:00 PM)
- 8:00 - 8:30: Review yesterday's notes
- 8:30 - 10:00: Focus on challenging concepts
- 10:00 - 10:15: Short break
- 10:15 - 11:45: Practice problems
- 11:45 - 12:00: Summarize key points

## Afternoon (1:00 PM - 5:00 PM)
- 1:00 - 2:30: Group study session
- 2:30 - 2:45: Break
- 2:45 - 4:15: Application exercises
- 4:15 - 5:00: Review and prepare for tomorrow

## Evening (6:00 PM - 8:00 PM)
- 6:00 - 7:00: Light review
- 7:00 - 8:00: Relaxation and preparation for sleep

## Tips
- Stay hydrated throughout the day
- Take short breaks every 90 minutes
- Use active recall techniques
- Get adequate sleep (7-8 hours)''';
  }

  String _getCodeResponse(String question) {
    final topic = _getTopicFromQuestion(question);
    return '''# Code Example: $topic

Here's a simple implementation to help you understand the concept:

```dart
class ${topic.replaceAll(' ', '')} {
  final String name;
  final String description;
  final List<String> capabilities;
  
  ${topic.replaceAll(' ', '')}({
    required this.name,
    required this.description,
    required this.capabilities,
  });
  
  // Example method
  void demonstrate() {
    print('Demonstrating ' + name);
    print(description);
    
    for (final capability in capabilities) {
      print('- ' + capability);
    }
  }
}

// Usage example
void main() {
  final example = ${topic.replaceAll(' ', '')}(
    name: 'Example Implementation',
    description: 'This demonstrates the basic structure and usage.',
    capabilities: [
      'Capability 1: Basic functionality',
      'Capability 2: Extended capabilities',
      'Capability 3: Integration options',
    ],
  );
  
  example.demonstrate();
}
```

This code provides a basic structure that you can build upon. The key concepts demonstrated are:
1. Class definition with properties
2. Constructor with required parameters
3. Method implementation
4. Usage example

You can adapt this pattern to your specific needs.''';
  }

  String _getGenericResponse(String question) {
    final topic = _getTopicFromQuestion(question);
    return '''I can help you with $topic. Here are some suggestions:

1. **Review the basics**: Make sure you understand the fundamental concepts before moving to advanced topics.

2. **Practice regularly**: Consistent practice helps reinforce learning and identify areas for improvement.

3. **Use active recall**: Test yourself on the material rather than just re-reading it.

4. **Connect concepts**: Look for relationships between different ideas to build a more comprehensive understanding.

5. **Seek clarification**: Don't hesitate to ask for clarification on points you find confusing.

Would you like me to elaborate on any of these points or help you with a specific aspect of $topic?''';
  }

  String _getTopicFromQuestion(String question) {
    // Extract the main topic from the question
    final words = question.split(' ');
    if (words.length <= 3) {
      return question;
    }
    
    // Try to identify the main topic
    if (question.toLowerCase().contains('about')) {
      final parts = question.split('about');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    
    if (question.toLowerCase().contains('what is')) {
      final parts = question.split('what is');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    
    if (question.toLowerCase().contains('how to')) {
      final parts = question.split('how to');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    
    // Default to the first few words
    return words.take(3).join(' ');
  }

  String _cleanTopic(String topic) {
    // Remove question marks and other punctuation
    return topic.replaceAll(RegExp(r'[?.,!]'), '').trim();
  }

  // Static method to get a service by name
  static AIService getServiceByName(String name) {
    final services = getAllServices();
    return services.firstWhere(
      (service) => service.name.toLowerCase() == name.toLowerCase(),
      orElse: () => services.first,
    );
  }

  // Get all available AI services
  static List<AIService> getAllServices() {
    return [
      AIService(
        name: 'Claude',
        iconPath: 'assets/icons/claude.png',
        url: 'https://claude.ai',
        color: Colors.purple,
        description: 'Advanced AI assistant for complex reasoning and analysis',
        capabilities: [
          'Natural language understanding',
          'Complex reasoning',
          'Code generation',
          'Data analysis',
          'Creative writing',
        ],
      ),
      AIService(
        name: 'GPT-4',
        iconPath: 'assets/icons/gpt4.png',
        url: 'https://openai.com',
        color: Colors.green,
        description: 'Powerful language model for diverse tasks',
        capabilities: [
          'Text generation',
          'Question answering',
          'Summarization',
          'Translation',
          'Creative content',
        ],
      ),
      AIService(
        name: 'Cursor AI',
        iconPath: 'assets/icons/cursor.png',
        url: 'https://cursor.sh',
        color: Colors.blue,
        description: 'AI-powered code editor and programming assistant',
        capabilities: [
          'Code completion',
          'Code explanation',
          'Bug fixing',
          'Refactoring suggestions',
          'Documentation generation',
        ],
      ),
    ];
  }

  void printCapabilities() {
    print('Capabilities of $name:');
    for (final capability in capabilities) {
      print('- $capability');
    }
  }
}