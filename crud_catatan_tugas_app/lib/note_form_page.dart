import 'package:flutter/material.dart';
import 'note_model.dart';

class NoteFormPage extends StatefulWidget {
  final Note? note;
  final bool isDarkMode;

  const NoteFormPage({
    Key? key,
    this.note,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _NoteFormPageState createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Kuliah';

  final List<String> categories = [
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _selectedCategory = widget.note!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Judul tidak boleh kosong';
    }
    if (value.length > 100) {
      return 'Judul terlalu panjang (maks. 100 karakter)';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    if (value.length > 500) {
      return 'Deskripsi terlalu panjang (maks. 500 karakter)';
    }
    return null;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Kuliah':
        return Colors.blue;
      case 'Organisasi':
        return Colors.green;
      case 'Pribadi':
        return Colors.orange;
      case 'Lain-lain':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Kuliah':
        return Icons.school;
      case 'Organisasi':
        return Icons.group;
      case 'Pribadi':
        return Icons.person;
      case 'Lain-lain':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      Note note;

      if (widget.note == null) {
        note = Note.create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
        );
      } else {
        note = Note(
          id: widget.note!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          createdAt: widget.note!.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Tambah Catatan' : 'Edit Catatan',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        iconTheme: IconThemeData(color: theme.appBarTheme.foregroundColor),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Tugas',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan judul tugas',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: _validateTitle,
                maxLength: 100,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan deskripsi tugas',
                  alignLabelWithHint: true,
                ),
                validator: _validateDescription,
                maxLines: 5,
                maxLength: 500,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 16),
              Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : _getCategoryColor(category),
                        ),
                        SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: _getCategoryColor(category),
                    backgroundColor: theme.cardColor,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              if (widget.note != null) ...[
                Divider(color: theme.dividerColor),
                ListTile(
                  leading: Icon(Icons.calendar_today,
                      size: 20, color: theme.iconTheme.color),
                  title: Text(
                    'Dibuat pada',
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  subtitle: Text(
                    widget.note!.formattedDate,
                    style: TextStyle(color: theme.hintColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
