// lib/ui/screens/materials/materials_screen.dart
// Screen to display and manage study materials with AI integration

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/helpers/ai_helper.dart';
import 'package:study_scheduler/ui/screens/materials/material_detail_screen.dart';
import 'package:study_scheduler/ui/screens/materials/add_material_screen.dart';
import 'package:study_scheduler/data/helpers/logger.dart';
import 'package:study_scheduler/data/helpers/database_helper.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  static const List<String> _categories = [
    'All',
    'Document',
    'Video',
    'Article',
    'Quiz',
    'Practice',
    'Reference'
  ];

  bool _isLoading = true;
  List<StudyMaterial> _materials = [];
  List<StudyMaterial> _filteredMaterials = [];
  String _searchQuery = '';
  String? _selectedCategory;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _logger = Logger('MaterialsScreen');

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper.instance;
      _materials = await db.getStudyMaterials();
      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      _logger.error('Error loading materials: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading materials: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMaterials = _materials.where((material) {
        final matchesSearch = material.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (material.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        final matchesCategory = _selectedCategory == null || material.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          AIHelper.createAppBarAction(context),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaterials,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMaterials.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredMaterials.length,
                        itemBuilder: (context, index) {
                          final material = _filteredMaterials[index];
                          return _buildMaterialCard(material);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMaterialScreen(),
            ),
          ).then((_) => _loadMaterials());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              suffixIcon: IconButton(
                icon: const Icon(Icons.psychology_alt, color: Colors.blue),
                tooltip: 'Ask AI to find materials',
                onPressed: () {
                  AIHelper.showAssistant(
                    context,
                    initialQuestion: 'Help me find study materials about ${_searchQuery.isEmpty ? 'my subjects' : _searchQuery}',
                  );
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(StudyMaterial material) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ).then((_) => _loadMaterials());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(material.category),
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (material.description != null && material.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          material.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            material.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.psychology_alt, color: Colors.blueAccent),
                          tooltip: 'AI Assist',
                          onPressed: () => AIHelper.showExplanationAssistant(context, material),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          iconSize: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No study materials found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory != 'All' || _searchQuery.isNotEmpty
                ? 'Try adjusting your filters'
                : 'Add your first study material to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_selectedCategory != 'All' || _searchQuery.isNotEmpty) {
                setState(() {
                  _selectedCategory = 'All';
                  _searchQuery = '';
                  _applyFilters();
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMaterialScreen(),
                  ),
                ).then((_) => _loadMaterials());
              }
            },
            icon: Icon(
              _selectedCategory != 'All' || _searchQuery.isNotEmpty
                  ? Icons.clear_all
                  : Icons.add,
            ),
            label: Text(
              _selectedCategory != 'All' || _searchQuery.isNotEmpty
                  ? 'Clear Filters'
                  : 'Add Material',
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedCategory == 'All' && _searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => AIHelper.showStudyPlanningAssistant(context),
              icon: const Icon(Icons.psychology_alt),
              label: const Text('Ask AI Assistant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
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