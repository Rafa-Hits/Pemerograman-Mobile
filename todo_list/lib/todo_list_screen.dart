import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'todo_service.dart';
import 'todo_dialog.dart';

enum TodoFilter { all, completed, pending }

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  TodoFilter _currentFilter = TodoFilter.all;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    final todos = await _todoService.getTodos();
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
    _applyFilter();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    List<Todo> filtered = _todos;

    // Apply status filter
    switch (_currentFilter) {
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.all:
        break;
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((todo) =>
              todo.title.toLowerCase().contains(query) ||
              todo.description.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _filteredTodos = filtered;
    });
  }

  Future<void> _addTodo() async {
    final result = await showDialog<Todo?>(
      context: context,
      builder: (context) => const TodoDialog(),
    );

    if (result != null) {
      final newTodo = result.copyWith(
        id: await _todoService.getNextId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _todos.insert(0, newTodo);
      });
      await _todoService.saveTodos(_todos);
      _applyFilter();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo berhasil ditambahkan')),
      );
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await showDialog<Todo?>(
      context: context,
      builder: (context) => TodoDialog(todo: todo),
    );

    if (result != null) {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        setState(() {
          _todos[index] = result.copyWith(updatedAt: DateTime.now());
        });
        await _todoService.saveTodos(_todos);
        _applyFilter();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo berhasil diupdate')),
        );
      }
    }
  }

  Future<void> _toggleTodoStatus(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      setState(() {
        _todos[index] = todo.copyWith(
          isCompleted: !todo.isCompleted,
          updatedAt: DateTime.now(),
        );
      });
      await _todoService.saveTodos(_todos);
      _applyFilter();
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Todo'),
        content: Text('Apakah Anda yakin ingin menghapus "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _todos.removeWhere((t) => t.id == todo.id);
      });
      await _todoService.saveTodos(_todos);
      _applyFilter();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo berhasil dihapus')),
      );
    }
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => _toggleTodoStatus(todo),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  todo.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Diperbarui: ${_formatDate(todo.updatedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editTodo(todo);
            } else if (value == 'delete') {
              _deleteTodo(todo);
            }
          },
        ),
        onTap: () => _toggleTodoStatus(todo),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List App'),
        actions: [
          PopupMenuButton<TodoFilter>(
            onSelected: (filter) {
              setState(() {
                _currentFilter = filter;
              });
              _applyFilter();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TodoFilter.all,
                child: Text('Semua'),
              ),
              const PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Selesai'),
              ),
              const PopupMenuItem(
                value: TodoFilter.pending,
                child: Text('Belum Selesai'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Cari todo...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Total: ${_todos.length}'),
                        backgroundColor: Colors.blue[100],
                      ),
                      Chip(
                        label: Text(
                            'Selesai: ${_todos.where((t) => t.isCompleted).length}'),
                        backgroundColor: Colors.green[100],
                      ),
                      Chip(
                        label: Text(
                            'Pending: ${_todos.where((t) => !t.isCompleted).length}'),
                        backgroundColor: Colors.orange[100],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filteredTodos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list_alt,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _todos.isEmpty
                                    ? 'Belum ada todo\nTap + untuk menambahkan'
                                    : 'Tidak ada todo yang sesuai',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = _filteredTodos[index];
                            return _buildTodoItem(todo);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
