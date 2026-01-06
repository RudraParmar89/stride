import 'package:flutter/material.dart';

class ThemeController with ChangeNotifier {
  // Default to system settings (or ThemeMode.light if you prefer)
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Toggles between light and dark mode
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets a specific mode (System, Light, or Dark)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}