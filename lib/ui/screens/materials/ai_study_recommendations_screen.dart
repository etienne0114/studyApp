// lib/ui/screens/materials/ai_study_recommendations_screen.dart
// Screen to show AI-based study recommendations

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'package:study_scheduler/helpers/ai_helper.dart';
import 'package:study_scheduler/ui/screens/materials/material_detail_screen.dart';

class AIStudyRecommendationsScreen extends StatefulWidget {
  const AIStudyRecommendationsScreen({super.key});

  @override
  State<AIStudyRecommendationsScreen> createState() => _AIStudyRecommendationsScreenState();
}

class _AIStudyRecommendationsScreenState extends State<AIStudyRecommendationsScreen> {
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  
  bool _isLoading = true;
  List<StudyMaterial> _recommendedMaterials = [];
  List<StudyMaterial> _popularMaterials = [];
  List<Map<String, dynamic>> _popularAIServices = [];
  Map<String, List<String>> _categoryAIRecommendations = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load data in parallel for better performance
      final recommendedFuture = _repository.getRecommendedMaterials();
      final popularFuture = _repository.getMostAccessedMaterials();
      final servicesFuture = _repository.getMostUsedAIServices();
      
      // Wait for all futures to complete
      final results = await Future.wait([
        recommendedFuture,
        popularFuture,
        servicesFuture,
      ]);
      
      // Extract results
      final recommendedMaterials = results[0] as List<StudyMaterial>;
      final popularMaterials = results[1] as List<StudyMaterial>;
      final popularAIServices = results[2] as List<Map<String, dynamic>>;
      
      // Get recommended AI services by category
      final categoryAIRecommendations = <String, List<String>>{};
      for (final category in ['Document', 'Video', 'Article', 'Quiz', 'Practice']) {
        final recommendations = await _repository.getRecommendedAIServicesForCategory(category);
        if (recommendations.isNotEmpty) {
          categoryAIRecommendations[category] = recommendations;
        }
      }
      
      if (mounted) {
        setState(() {
          _recommendedMaterials = recommendedMaterials;
          _popularMaterials = popularMaterials;
          _popularAIServices = popularAIServices;
          _categoryAIRecommendations = categoryAIRecommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recommendations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildAskAnythingCard(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeading('Recommended Study Materials'),
                  _buildMaterialsList(_recommendedMaterials),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeading('Popular Materials with AI Assistance'),
                  _buildMaterialsList(_popularMaterials),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeading('Popular AI Services'),
                  _buildAIServicesList(),
                  const SizedBox(height: 24),
                  
                  if (_categoryAIRecommendations.isNotEmpty) ...[
                    _buildSectionHeading('Recommended AI by Category'),
                    _buildCategoryRecommendationsList(),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildAITipsSection(),
                ],
              ),
            ),
      floatingActionButton: AIHelper.createFloatingButton(context),
    );
  }
  
  Widget _buildAskAnythingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.shade700,
              Colors.blueAccent.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'AI Learning Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Get answers, explanations, and help with your study materials using advanced AI.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AIHelper.showAssistant(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ask Anything',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildMaterialsList(List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No materials available yet. Add some study materials and use the AI assistant with them to get personalized recommendations.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return _buildMaterialCard(material);
        },
      ),
    );
  }
  
  Widget _buildMaterialCard(StudyMaterial material) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialDetailScreen(material: material),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(material.category),
                      color: Theme.of(context).primaryColor,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.psychology_alt, size: 18, color: Colors.blueAccent),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => AIHelper.showExplanationAssistant(context, material),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  material.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (material.description != null) ...[
                  Text(
                    material.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    material.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAIServicesList() {
    if (_popularAIServices.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Start using AI services with your study materials to see which ones work best for you.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularAIServices.length,
        itemBuilder: (context, index) {
          final service = _popularAIServices[index];
          final aiServiceName = service['aiService'] as String;
          final serviceColor = _getAIServiceColor(aiServiceName);
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => AIHelper.showAssistant(
                  context,
                  initialQuestion: 'Tell me about what you can help with',
                ),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: serviceColor.withAlpha(50),
                        child: Text(
                          aiServiceName[0],
                          style: TextStyle(
                            color: serviceColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aiServiceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryRecommendationsList() {
    return Column(
      children: _categoryAIRecommendations.entries.map((entry) {
        final category = entry.key;
        final aiServices = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: Theme.of(context).primaryColor,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Best AI for this category:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: aiServices.map((serviceName) {
                          final serviceColor = _getAIServiceColor(serviceName);
                          return Chip(
                            backgroundColor: serviceColor.withAlpha(25),
                            label: Text(
                              serviceName,
                              style: TextStyle(
                                color: serviceColor,
                                fontSize: 12,
                              ),
                            ),
                            avatar: CircleAvatar(
                              backgroundColor: serviceColor.withAlpha(50),
                              child: Text(
                                serviceName[0],
                                style: TextStyle(
                                  color: serviceColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildAITipsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Tips for Using AI in Your Studies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTip(
              'Ask specific questions instead of broad ones for better answers',
              Icons.question_answer,
            ),
            _buildTip(
              'Use AI to explain concepts in different ways when you\'re stuck',
              Icons.psychology,
            ),
            _buildTip(
              'Request practice examples to reinforce your understanding',
              Icons.school,
            ),
            _buildTip(
              'Different AI services excel at different subjects - experiment!',
              Icons.compare_arrows,
            ),
            _buildTip(
              'Ask for step-by-step explanations for complex problems',
              Icons.format_list_numbered,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAIServiceColor(String serviceName) {
    // Map service names to colors
    switch (serviceName.toLowerCase()) {
      case 'claude':
        return Colors.purple;
      case 'chatgpt':
        return Colors.green;
      case 'github copilot':
      case 'copilot':
        return Colors.blue;
      case 'deepseek':
        return Colors.orange;
      case 'perplexity':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'practice':
        return Icons.school;
      case 'reference':
        return Icons.book;
      default:
        return Icons.folder;
    }
  }
}