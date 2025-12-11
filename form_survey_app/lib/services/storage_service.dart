import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _key = 'survey_data';
  static const String _historyKey = 'survey_history';
  
  // Simpan data survey terakhir
  static Future<void> saveSurveyData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(data));
      
      // Tambahkan ke history
      await _addToHistory(data);
    } catch (e) {
      print('Error saving survey data: $e');
      rethrow;
    }
  }
  
  // Ambil data survey terakhir
  static Future<Map<String, dynamic>?> loadSurveyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_key);
      if (data != null) {
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      print('Error loading survey data: $e');
      return null;
    }
  }
  
  // Hapus data
  static Future<void> clearSurveyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing survey data: $e');
    }
  }
  
  // Tambahkan ke history
  static Future<void> _addToHistory(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      
      // Batasi history hingga 10 entri
      if (history.length >= 10) {
        history.removeAt(0);
      }
      
      history.add(jsonEncode(data));
      await prefs.setStringList(_historyKey, history);
    } catch (e) {
      print('Error adding to history: $e');
    }
  }
  
  // Ambil history
  static Future<List<Map<String, dynamic>>> getSurveyHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      
      return history.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }
  
  // Hapus history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}