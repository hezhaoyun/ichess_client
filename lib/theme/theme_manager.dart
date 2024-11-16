import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';

  final themes = {
    '默认蓝': Colors.blue,
    '翡翠绿': Colors.green,
    '深邃紫': Colors.purple,
    '热情红': Colors.red,
    '沉稳灰': Colors.blueGrey,
  };

  Color _primaryColor = Colors.blue;

  ThemeManager() {
    _loadTheme();
  }

  Color get primaryColor => _primaryColor;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? '默认蓝';
    _primaryColor = themes[themeName]!;
    notifyListeners();
  }

  Future<void> setTheme(String name) async {
    if (!themes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, name);
    _primaryColor = themes[name]!;
    notifyListeners();
  }

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
        ),
      );
}
