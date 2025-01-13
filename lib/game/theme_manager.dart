import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _pieceThemeKey = 'selected_piece_theme';

  static const kColorThemes = {
    'Default Blue': Colors.blue,
    'Emerald Green': Colors.green,
    'Deep Purple': Colors.purple,
    'Passionate Red': Colors.red,
    'Steady Gray': Colors.blueGrey,
  };

  static const kPieceThemes = {
    'android': 'assets/pieces/android',
    'aquarium': 'assets/pieces/aquarium',
    'aquariumsteel': 'assets/pieces/aquariumsteel',
    'aquariumwood': 'assets/pieces/aquariumwood',
    'fragmented': 'assets/pieces/fragmented',
    'internet': 'assets/pieces/internet',
    'military': 'assets/pieces/military',
  };

  Color _primaryColor = Colors.blue;
  Color get primaryColor => _primaryColor;

  String _selectedPieceTheme = 'android';
  String get selectedPieceTheme => _selectedPieceTheme;

  String get currentThemeName => kColorThemes.entries.firstWhere((entry) => entry.value == primaryColor).key;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'Default Blue';
    _primaryColor = kColorThemes[themeName]!;
    final pieceThemeName = prefs.getString(_pieceThemeKey) ?? 'android';
    _selectedPieceTheme = pieceThemeName;
    notifyListeners();
  }

  Future<void> setTheme(String name) async {
    if (!kColorThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, name);
    _primaryColor = kColorThemes[name]!;
    notifyListeners();
  }

  Future<void> setPieceTheme(String name) async {
    if (!kPieceThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pieceThemeKey, name);
    _selectedPieceTheme = name;
    notifyListeners();
  }

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
      );
}
