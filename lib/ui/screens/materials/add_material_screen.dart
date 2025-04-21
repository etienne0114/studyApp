// lib/ui/screens/materials/add_material_screen.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/data/repositories/study_materials_repository.dart';
// We'll implement a simpler version without third-party dependencies
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  
  final StudyMaterialsRepository _repository = StudyMaterialsRepository();
  
  String _selectedCategory = 'Document';
  File? _selectedFile;
  String? _filePath;
  String? _fileType;
  bool _isOnline = false;
  bool _isLoading = false;
  
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
      }
      
      _filePath = widget.material!.filePath;
      _fileType = widget.material!.fileType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  // Simplified file picking for demo purposes
  Future<void> _pickFile() async {
    try {
      // Instead of using actual file picker, we'll simulate it
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        // Simulate a selected PDF file
        _selectedFile = null; // We won't have an actual File object
        _filePath = '/simulated/path/document.pdf';
        _fileType = 'pdf';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File selected: document.pdf')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      // Instead of using actual camera, we'll simulate it
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        // Simulate a captured image
        _selectedFile = null; // We won't have an actual File object
        _filePath = '/simulated/path/captured_image.jpg';
        _fileType = 'jpg';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image captured successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
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
                    const SizedBox(height: 8),
                    if (_isOnline) ...[
                      TextFormField(
                        controller: _fileUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Resource URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          hintText: 'https://example.com/resource',
                        ),
                        validator: (value) {
                          if (_isOnline) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a URL';
                            }
                            if (!Uri.parse(value).isAbsolute) {
                              return 'Please enter a valid URL';
                            }
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedFile != null || _filePath != null
                                ? Colors.green
                                : Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedFile != null || _filePath != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      _getFileIcon(_fileType ?? ''),
                                      size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getFileName() ?? 'Selected File',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_fileType != null)
                                            Text(
                                              'File type: ${_fileType!.toUpperCase()}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _selectedFile = null;
                                          _filePath = null;
                                          _fileType = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const Text(
                                  'Select a file or capture an image',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickFile,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Pick File'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _captureImage,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Capture Image'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
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

  String? _getFileName() {
    if (_selectedFile != null) {
      return _selectedFile!.path.split('/').last;
    } else if (_filePath != null) {
      return _filePath!.split('/').last;
    }
    return null;
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