import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_manager.g.dart';

@riverpod
class ThemeManager extends _$ThemeManager {
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

  String _pieceTheme = 'android';

  @override
  Future<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final colorTheme = prefs.getString(_themeKey) ?? 'Default Blue';
    _pieceTheme = prefs.getString(_pieceThemeKey) ?? 'android';

    return ThemeState(
      primaryColor: kColorThemes[colorTheme]!,
      pieceTheme: _pieceTheme,
    );
  }

  Future<void> setPrimaryColor(String name) async {
    if (!kColorThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, name);

    state = AsyncData(state.value!.copyWith(primaryColor: kColorThemes[name]!));
  }

  Future<void> setPieceTheme(String name) async {
    if (!kPieceThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pieceThemeKey, name);

    state = AsyncData(state.value!.copyWith(pieceTheme: name));
  }
}

class ThemeState {
  final Color primaryColor;
  final String pieceTheme;

  const ThemeState({
    this.primaryColor = Colors.blue,
    this.pieceTheme = 'android',
  });

  ThemeState copyWith({Color? primaryColor, String? pieceTheme}) => ThemeState(
        primaryColor: primaryColor ?? this.primaryColor,
        pieceTheme: pieceTheme ?? this.pieceTheme,
      );

  String get currentThemeName =>
      ThemeManager.kColorThemes.keys.firstWhere((key) => ThemeManager.kColorThemes[key] == primaryColor);
}
