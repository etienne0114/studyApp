import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:study_scheduler/data/helpers/logger.dart';
import 'dart:io' show File;

class FilePickerHelper {
  static final _logger = Logger('FilePickerHelper');
  static final _picker = ImagePicker();

  static Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickMedia(
        imageQuality: 100,
        requestFullMetadata: true,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileType = path.extension(file.path).toLowerCase().replaceAll('.', '');
        
        if (allowedExtensions != null && !allowedExtensions.contains(fileType)) {
          _logger.warning('File type $fileType is not allowed');
          return null;
        }

        _logger.info('File picked: ${pickedFile.name}');
        return pickedFile.path;
      }
      
      _logger.info('No file selected');
      return null;
    } catch (e) {
      _logger.error('Error picking file: $e');
      return null;
    }
  }

  static String? getFileType(String? filePath) {
    if (filePath == null || filePath.isEmpty) return null;
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  static bool isValidFileType(String filePath, List<String> allowedTypes) {
    final fileType = getFileType(filePath);
    return fileType != null && allowedTypes.contains(fileType.toLowerCase());
  }

  static List<String> getAllowedExtensions(String category) {
    switch (category.toLowerCase()) {
      case 'document':
        return ['pdf', 'doc', 'docx', 'txt', 'rtf'];
      case 'video':
        return ['mp4', 'avi', 'mov', 'wmv', 'mkv'];
      case 'article':
        return ['pdf', 'epub', 'mobi'];
      case 'quiz':
        return ['pdf', 'doc', 'docx', 'txt'];
      case 'practice':
        return ['pdf', 'doc', 'docx', 'txt', 'zip'];
      case 'reference':
        return ['pdf', 'epub', 'mobi', 'doc', 'docx'];
      default:
        return [];
    }
  }
} 