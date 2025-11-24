import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'todo_model.dart';

class TodoService {
  static const String _todosKey = 'todos';

  Future<List<Todo>> getTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getStringList(_todosKey) ?? [];

      List<Todo> todos = [];
      for (String jsonStr in todosJson) {
        try {
          final todoMap = jsonDecode(jsonStr);
          todos.add(Todo.fromJson(todoMap));
        } catch (e) {
          print('Error parsing todo: $e');
        }
      }

      // Sort by updatedAt descending
      todos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return todos;
    } catch (e) {
      print('Error getting todos: $e');
      return [];
    }
  }

  Future<void> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = todos.map((todo) => jsonEncode(todo.toJson())).toList();
      await prefs.setStringList(_todosKey, todosJson);
    } catch (e) {
      print('Error saving todos: $e');
    }
  }

  Future<int> getNextId() async {
    final todos = await getTodos();
    if (todos.isEmpty) return 1;
    int maxId = todos.map((todo) => todo.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
