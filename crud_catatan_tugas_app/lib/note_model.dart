import 'dart:convert';

class Note {
  String id;
  String title;
  String description;
  String category;
  DateTime createdAt;
  DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.create({
    required String title,
    required String description,
    required String category,
  }) {
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }
    return json.encode(data);
  }

  factory Note.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      return Note(
        id: data['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] as String? ?? 'Tanpa Judul',
        description: data['description'] as String? ?? '',
        category: data['category'] as String? ?? 'Lain-lain',
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      return Note.create(
        title: 'Error Loading',
        description: 'Data tidak dapat dimuat',
        category: 'Lain-lain',
      );
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Hari ini, ${_formatTime(createdAt)}';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${_formatTime(createdAt)}';
    } else {
      return '${_formatDate(createdAt)}, ${_formatTime(createdAt)}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Note{id: $id, title: $title, category: $category}';
  }
}
