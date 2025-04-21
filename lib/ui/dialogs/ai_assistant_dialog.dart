// lib/ui/dialogs/ai_assistant_dialog.dart
// This is the main AI assistant dialog

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_scheduler/data/models/study_material.dart';
import 'package:study_scheduler/managers/ai_assistant_manager.dart';

class AIAssistantDialog extends StatefulWidget {
  final StudyMaterial? material;
  final String? initialQuestion;
  
  const AIAssistantDialog({
    super.key,
    this.material,
    this.initialQuestion,
  });
  
  /// Show the AI assistant dialog
  static Future<void> show(BuildContext context, {
    StudyMaterial? material,
    String? initialQuestion,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AIAssistantDialog(
        material: material,
        initialQuestion: initialQuestion,
      ),
    );
  }

  @override
  State<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  late AIAssistantManager _manager;
  final TextEditingController _questionController = TextEditingController();
  bool _isProcessing = false;
  String _response = '';
  bool _showCodeHighlighting = true;
  
  @override
  void initState() {
    super.initState();
    _manager = Provider.of<AIAssistantManager>(context, listen: false);
    if (widget.initialQuestion != null) {
      _questionController.text = widget.initialQuestion!;
      _processQuestion();
    }
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
  
  Future<void> _processQuestion() async {
    if (_questionController.text.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
      _response = '';
    });
    
    try {
      final response = await _manager.getAIResponse(
        _questionController.text,
        _manager.preferredService,
        material: widget.material,
      );
      
      setState(() {
        _response = response;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Sorry, I encountered an error. Please try again.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Ask ${_manager.preferredService}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildResponseArea(),
            ),
            _buildInputSection(),
            _buildControlBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResponseArea() {
    if (_isProcessing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_response.isEmpty) {
      return Center(
        child: Text(
          'Ask a question about ${widget.material?.title ?? 'your studies'}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
    
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Text(
            _response,
            style: const TextStyle(fontSize: 16),
            softWrap: true,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: _getPlaceholderText(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _processQuestion(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _processQuestion,
            icon: const Icon(Icons.send),
            color: _manager.getServiceColor(_manager.preferredService),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _manager.preferredService,
            items: _manager.getAvailableServiceNames().map((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _manager.setPreferredService(value);
              }
            },
          ),
          Row(
            children: [
              const Text('Code Highlighting'),
              const SizedBox(width: 8),
              Switch(
                value: _showCodeHighlighting,
                onChanged: (value) {
                  setState(() {
                    _showCodeHighlighting = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getPlaceholderText() {
    if (widget.material != null) {
      return 'Ask about ${widget.material!.title}';
    }
    return 'Ask a question about your studies';
  }
  
}