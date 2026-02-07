import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeManager extends ChangeNotifier {
  // Access the box
  final Box _box = Hive.box('settingsBox');

  late bool _isDark;
  late Color _accentColor;

  ThemeManager() {
    _loadSettings();
  }

  void _loadSettings() {
    // 🛡️ CRASH FIX: use 'as bool?' and '?? true' to handle possible nulls
    final dynamic savedDarkMode = _box.get('isDarkMode', defaultValue: true);
    _isDark = (savedDarkMode as bool?) ?? true;

    // 🛡️ CRASH FIX: Handle color safely
    final dynamic savedColor = _box.get('accentColor', defaultValue: const Color(0xFF2ECC71).value);
    final int colorInt = (savedColor as int?) ?? const Color(0xFF2ECC71).value;
    _accentColor = Color(colorInt);
  }

  // --- GETTERS ---
  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
  Color get accentColor => _accentColor;

  // --- DYNAMIC COLORS ---
  Color get bgColor => isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black;
  Color get subText => isDark ? Colors.grey.shade600 : Colors.grey.shade700;

  // --- METHODS ---

  // ✅ Renamed to 'toggleTheme' to match your ProfileScreen
  void toggleTheme(bool isDark) {
    _isDark = isDark;
    _box.put('isDarkMode', _isDark);
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _box.put('accentColor', color.value);
    notifyListeners();
  }
}