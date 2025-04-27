import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  static const String THEME_KEY = 'THEME_MODE';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider({required this.sharedPreferences}) {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() {
    _isDarkMode = sharedPreferences.getBool(THEME_KEY) ?? false;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    sharedPreferences.setBool(THEME_KEY, _isDarkMode);
    notifyListeners();
  }
}
