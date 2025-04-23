// lib/ui/screens/materials/add_material_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
import 'package:study_scheduler/data/helpers/file_picker_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class AddMaterialScreen extends StatefulWidget {
  final StudyMaterial? material;

  const AddMaterialScreen({
    super.key,
    this.material,
  });

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  final _filePathController = TextEditingController();
  
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  
  String _selectedCategory = 'Document';
  String? _filePath;
  String? _fileType;
  bool _isOnline = false;
  bool _isLoading = false;
  bool _isUrlValid = true;
  
  final List<String> _categories = [
    'Document',
    'Video',
    'Article',
    'Quiz',
    'Practice',
    'Reference',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.material != null) {
      // Populate form with existing data
      _titleController.text = widget.material!.title;
      if (widget.material!.description != null) {
        _descriptionController.text = widget.material!.description!;
      }
      _selectedCategory = widget.material!.category;
      _isOnline = widget.material!.isOnline;
      
      if (widget.material!.fileUrl != null) {
        _fileUrlController.text = widget.material!.fileUrl!;
        _validateUrl(_fileUrlController.text);
      }
      
      _filePath = widget.material!.filePath;
      if (_filePath != null) {
        _filePathController.text = _filePath!;
      }
      _fileType = widget.material!.fileType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    _filePathController.dispose();
    super.dispose();
  }


  void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    setState(() {
      _isUrlValid = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    });
  }

  Future<void> _testUrl() async {
    final url = _fileUrlController.text;
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL is valid and accessible')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL is not accessible')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error testing URL: $e')),
      );
    }
  }

  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });
    
    try {
      final now = DateTime.now().toIso8601String();
      
      StudyMaterial material;
      
      if (widget.material == null) {
        // Create new material
        material = StudyMaterial(
          id: 0, // Will be set by the database
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _selectedCategory,
          filePath: _isOnline ? null : _filePath,
          fileType: _fileType,
          fileUrl: _isOnline ? _fileUrlController.text : null,
          isOnline: _isOnline,
          createdAt: now,
          updatedAt: now,
        );
        
        await _repository.addMaterial(material);
      } else {
        // Update existing material
        material = StudyMaterial(
          id: widget.material!.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          category: _selectedCategory,
          filePath: _isOnline ? null : _filePath,
          fileType: _fileType,
          fileUrl: _isOnline ? _fileUrlController.text : null,
          isOnline: _isOnline,
          createdAt: widget.material!.createdAt,
          updatedAt: now,
        );
        
        await _repository.updateMaterial(material);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving material: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material == null ? 'Add Study Material' : 'Edit Study Material'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Material Source',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildFileSection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMaterial,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.material == null ? 'Add Material' : 'Update Material',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFileSection() {
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
              'File or URL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Local File'),
                    value: false,
                    groupValue: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Online URL'),
                    value: true,
                    groupValue: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isOnline) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _filePathController,
                      decoration: const InputDecoration(
                        labelText: 'File Path',
                        border: OutlineInputBorder(),
                        hintText: 'Select a file...',
                        prefixIcon: Icon(Icons.attach_file),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final allowedExtensions = FilePickerHelper.getAllowedExtensions(_selectedCategory);
                        final filePath = await FilePickerHelper.pickFile(
                          allowedExtensions: allowedExtensions,
                          dialogTitle: 'Select ${_selectedCategory.toLowerCase()} file',
                        );
                        
                        if (filePath != null) {
                          setState(() {
                            _filePath = filePath;
                            _filePathController.text = filePath;
                            _fileType = FilePickerHelper.getFileType(filePath);
                          });
                        }
                      },
                      validator: (value) {
                        if (!_isOnline && (value == null || value.isEmpty)) {
                          return 'Please select a file';
                        }
                        if (!_isOnline && value != null && value.isNotEmpty) {
                          final allowedTypes = FilePickerHelper.getAllowedExtensions(_selectedCategory);
                          if (!FilePickerHelper.isValidFileType(value, allowedTypes)) {
                            return 'Invalid file type for ${_selectedCategory.toLowerCase()}';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      final allowedExtensions = FilePickerHelper.getAllowedExtensions(_selectedCategory);
                      final filePath = await FilePickerHelper.pickFile(
                        allowedExtensions: allowedExtensions,
                        dialogTitle: 'Select ${_selectedCategory.toLowerCase()} file',
                      );
                      
                      if (filePath != null) {
                        setState(() {
                          _filePath = filePath;
                          _filePathController.text = filePath;
                          _fileType = FilePickerHelper.getFileType(filePath);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_filePath != null) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    _getFileIcon(_fileType ?? ''),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    path.basename(_filePath!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Type: ${_fileType?.toUpperCase() ?? 'Unknown'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _filePath = null;
                        _filePathController.clear();
                        _fileType = null;
                      });
                    },
                  ),
                ),
              ],
            ] else ...[
              TextFormField(
                controller: _fileUrlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: _testUrl,
                  ),
                ),
                onChanged: _validateUrl,
                validator: (value) {
                  if (_isOnline && (value == null || value.isEmpty)) {
                    return 'Please enter a URL';
                  }
                  if (_isOnline && !_isUrlValid) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    final type = fileType.toLowerCase();
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
}