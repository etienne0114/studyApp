// lib/data/models/study_material.dart

class StudyMaterial {
  final int id;
  String title;
  String? description;
  String category;
  String? filePath;
  String? fileType;
  String? fileUrl;
  bool isOnline;
  final String createdAt;
  String updatedAt;

  StudyMaterial({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.filePath,
    this.fileType,
    this.fileUrl,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map) {
    return StudyMaterial(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      filePath: map['filePath'] as String?,
      fileType: map['fileType'] as String?,
      fileUrl: map['fileUrl'] as String?,
      isOnline: (map['isOnline'] as int) == 1,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'filePath': filePath,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'isOnline': isOnline ? 1 : 0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'StudyMaterial(id: $id, title: $title, category: $category)';
  }
}