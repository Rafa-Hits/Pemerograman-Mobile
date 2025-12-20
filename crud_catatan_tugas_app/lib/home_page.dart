import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_manager.dart';
import 'note_model.dart';
import 'note_form_page.dart';

class HomePage extends StatefulWidget {
  final ThemeManager themeManager;

  const HomePage({Key? key, required this.themeManager}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String selectedCategory = 'Semua';
  bool isLoading = true;

  final List<String> categories = [
    'Semua',
    'Kuliah',
    'Organisasi',
    'Pribadi',
    'Lain-lain'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJsonList = prefs.getStringList('notes') ?? [];

      List<Note> loadedNotes = [];

      for (var jsonString in notesJsonList) {
        try {
          final note = Note.fromJson(jsonString);
          loadedNotes.add(note);
        } catch (e) {
          print('Error parsing note: $e');
        }
      }

      if (mounted) {
        setState(() {
          notes = loadedNotes;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notes: $e');
      if (mounted) {
        setState(() {
          notes = _getSampleNotes();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> notesJsonList =
          notes.map((note) => note.toJson()).toList();
      await prefs.setStringList('notes', notesJsonList);
    } catch (e) {
      print('Error saving notes: $e');
    }
  }

  List<Note> _getSampleNotes() {
    return [
      Note.create(
        title: 'Tugas Flutter',
        description: 'Buat aplikasi CRUD catatan tugas mahasiswa',
        category: 'Kuliah',
      ),
      Note.create(
        title: 'Rapat Organisasi',
        description: 'Persiapan acara tahunan UKM Programming',
        category: 'Organisasi',
      ),
      Note.create(
        title: 'Belanja Bulanan',
        description: 'Beli kebutuhan sehari-hari di supermarket',
        category: 'Pribadi',
      ),
      Note.create(
        title: 'Servis Laptop',
        description: 'Bawa laptop ke service center untuk tune-up',
        category: 'Lain-lain',
      ),
    ];
  }

  List<Note> get filteredNotes {
    if (selectedCategory == 'Semua') {
      return notes;
    }
    return notes.where((note) => note.category == selectedCategory).toList();
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
        return Icons.note;
    }
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

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormPage(
          isDarkMode: widget.themeManager.isDarkMode,
        ),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        notes.add(result);
      });
      await _saveNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan berhasil ditambahkan'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _editNote(int index) async {
    final noteToEdit = filteredNotes[index];
    final originalIndex = notes.indexOf(noteToEdit);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormPage(
          note: noteToEdit,
          isDarkMode: widget.themeManager.isDarkMode,
        ),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        notes[originalIndex] = result;
      });
      await _saveNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteNote(int index) {
    final noteToDelete = filteredNotes[index];
    final originalIndex = notes.indexOf(noteToDelete);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Catatan',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${noteToDelete.title}"?',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                notes.removeAt(originalIndex);
              });
              await _saveNotes();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Catatan berhasil dihapus'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllNotes() {
    if (notes.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Semua Catatan',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua catatan? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                notes.clear();
              });
              await _saveNotes();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Semua catatan telah dihapus'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan Tugas Mahasiswa'),
        actions: [
          if (notes.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _clearAllNotes,
              tooltip: 'Hapus Semua Catatan',
            ),
          IconButton(
            icon: Icon(widget.themeManager.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () async {
              await widget.themeManager.toggleTheme();
              setState(() {});
            },
            tooltip:
                widget.themeManager.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Filter Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        dropdownColor: theme.cardColor,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 16,
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  color: _getCategoryColor(category),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Info Statistik
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${notes.length} catatan',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                      if (selectedCategory != 'Semua')
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(selectedCategory)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(selectedCategory),
                                size: 14,
                                color: _getCategoryColor(selectedCategory),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Kategori: $selectedCategory',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getCategoryColor(selectedCategory),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // List Catatan
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note_add,
                                  size: 64, color: theme.disabledColor),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada catatan',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.disabledColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _addNote,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                                child: Text('Tambah Catatan Pertama'),
                              ),
                            ],
                          ),
                        )
                      : filteredNotes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.filter_alt_off,
                                      size: 64, color: theme.disabledColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada catatan untuk kategori "$selectedCategory"',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.disabledColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = 'Semua';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                    ),
                                    child: Text('Lihat Semua Catatan'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadNotes,
                              color: theme.colorScheme.primary,
                              child: ListView.builder(
                                itemCount: filteredNotes.length,
                                itemBuilder: (context, index) {
                                  final note = filteredNotes[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    color: theme.cardColor,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              _getCategoryColor(note.category)
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(note.category),
                                          color:
                                              _getCategoryColor(note.category),
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        note.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                            note.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: theme
                                                  .textTheme.bodyLarge?.color
                                                  ?.withOpacity(0.7),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: theme.hintColor,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                note.formattedDate,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: theme.hintColor,
                                                ),
                                              ),
                                              Spacer(),
                                              if (note.updatedAt != null) ...[
                                                Icon(
                                                  Icons.edit,
                                                  size: 12,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Diedit',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: theme
                                                        .colorScheme.primary,
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Ganti trailing dengan ini:
                                      trailing: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 70,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _editNote(index),
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _deleteNote(index),
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
        tooltip: 'Tambah Catatan Baru',
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
        foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
      ),
    );
  }
}
