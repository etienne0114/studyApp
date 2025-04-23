// lib/ui/screens/materials/material_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/helpers/ai_helper.dart';
import 'package:study_scheduler/ui/screens/materials/add_material_screen.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'package:study_scheduler/utils/logger.dart';

class MaterialDetailScreen extends StatefulWidget {
  final StudyMaterial material;

  const MaterialDetailScreen({
    super.key,
    required this.material,
  });

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  late StudyMaterial _material;
  bool _isLoading = true;
  final _logger = Logger();
  
  @override
  void initState() {
    super.initState();
    _material = widget.material;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Details'),
        actions: [
          AIHelper.createAppBarAction(context, material: _material),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMaterialScreen(material: _material),
                ),
              ).then((_) {
                // Refresh material data
                _loadMaterial();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(context),
            const SizedBox(height: 24),
            _buildDescriptionSection(context),
            const SizedBox(height: 24),
            _buildFileSection(context),
            const SizedBox(height: 24),
            _buildMetadataSection(context),
            const SizedBox(height: 24),
            _buildAIActionsSection(context),
          ],
        ),
      ),
    );
  }
  
  Future<void> _loadMaterial() async {
    if (_material.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final updatedMaterial = await _repository.getMaterialById(_material.id!);
      if (updatedMaterial != null && mounted) {
        setState(() {
          _material = updatedMaterial;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading material: $e')),
        );
      }
    }
  }

  Widget _buildHeaderSection(BuildContext context) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _material.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _material.category,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    if (_material.description == null || _material.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _material.description!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection(BuildContext context) {
    if ((_material.filePath == null || _material.filePath!.isEmpty) &&
        (_material.fileUrl == null || _material.fileUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }
    
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
            const Text(
              'Attached File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                _getFileTypeIcon(),
                color: Theme.of(context).primaryColor,
                size: 36,
              ),
              title: Text(
                _getFileName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _material.isOnline ? 'Online Resource' : 'Local File',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  _material.isOnline ? Icons.open_in_new : Icons.download,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // Open or download file
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _material.isOnline
                            ? 'Opening ${_getFileName()}'
                            : 'Downloading ${_getFileName()}'
                      ),
                    ),
                  );
                },
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
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
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataItem(
              context,
              'Created',
              _formatDate(_material.createdAt),
              Icons.calendar_today,
            ),
            const Divider(),
            _buildMetadataItem(
              context,
              'Last Updated',
              _formatDate(_material.updatedAt),
              Icons.update,
            ),
            if (_material.fileType != null) ...[
              const Divider(),
              _buildMetadataItem(
                context,
                'File Type',
                _material.fileType!.toUpperCase(),
                Icons.description,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAIActionsSection(BuildContext context) {
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
            const Text(
              'AI Assistant Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.psychology_alt, size: 16),
                  label: const Text('Explain'),
                  onPressed: () {
                    AIHelper.showAssistant(
                      context,
                      material: _material,
                      initialQuestion: 'Explain the concepts in ${_material.title}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.question_answer, size: 16),
                  label: const Text('Practice Questions'),
                  onPressed: () {
                    AIHelper.showAssistant(
                      context,
                      material: _material,
                      initialQuestion: 'Create practice questions about ${_material.title}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.summarize, size: 16),
                  label: const Text('Summarize'),
                  onPressed: () {
                    AIHelper.showAssistant(
                      context,
                      material: _material,
                      initialQuestion: 'Summarize the key points of ${_material.title}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.emoji_objects, size: 16),
                  label: const Text('Study Plan'),
                  onPressed: () {
                    AIHelper.showAssistant(
                      context,
                      material: _material,
                      initialQuestion: 'Create a study plan for learning ${_material.title}',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (_material.category.toLowerCase()) {
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

  IconData _getFileTypeIcon() {
    if (_material.fileType == null) return Icons.insert_drive_file;
    
    final type = _material.fileType!.toLowerCase();
    if (type.contains('pdf')) return Icons.picture_as_pdf;
    if (type.contains('doc')) return Icons.description;
    if (type.contains('xls')) return Icons.table_chart;
    if (type.contains('ppt')) return Icons.slideshow;
    if (type.contains('jpg') || type.contains('png') || type.contains('image')) {
      return Icons.image;
    }
    if (type.contains('mp4') || type.contains('avi') || type.contains('video')) {
      return Icons.video_file;
    }
    
    return Icons.insert_drive_file;
  }

  String _getFileName() {
    if (_material.filePath != null && _material.filePath!.isNotEmpty) {
      return _material.filePath!.split('/').last;
    }
    if (_material.fileUrl != null && _material.fileUrl!.isNotEmpty) {
      return _material.fileUrl!.split('/').last;
    }
    return 'File';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${_padZero(date.hour)}:${_padZero(date.minute)}';
    } catch (e) {
      return dateString;
    }
  }
  
  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${_material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete material and return to previous screen
              await _deleteMaterial();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMaterial() async {
    if (_material.id == null) {
      Navigator.pop(context);
      return;
    }

    try {
      final success = await _repository.deleteMaterial(_material.id!);
      if (mounted) {
        Navigator.pop(context);
        if (success > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting material: $e')),
        );
      }
    }
  }
}