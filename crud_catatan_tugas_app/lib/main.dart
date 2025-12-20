import 'package:flutter/material.dart';
import 'theme_manager.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _themeManager.setThemeChangedCallback((isDarkMode) {
      if (mounted) {
        setState(() {
          _isDarkMode = isDarkMode;
        });
      }
    });
    _themeManager.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Tugas Mahasiswa',
      theme: _themeManager.lightTheme,
      darkTheme: _themeManager.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: HomePage(themeManager: _themeManager),
    );
  }
}
