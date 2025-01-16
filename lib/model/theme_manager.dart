import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_manager.g.dart';

const kColorThemes = {
  'Default Blue': Colors.blue,
  'Emerald Green': Colors.green,
  'Deep Purple': Colors.purple,
  'Passionate Red': Colors.red,
  'Steady Gray': Colors.blueGrey,
};
const String kColorThemeKey = 'selected_theme';

const kPieceThemes = {
  'android': 'assets/pieces/android',
  'aquarium': 'assets/pieces/aquarium',
  'aquariumsteel': 'assets/pieces/aquariumsteel',
  'aquariumwood': 'assets/pieces/aquariumwood',
  'fragmented': 'assets/pieces/fragmented',
  'internet': 'assets/pieces/internet',
  'military': 'assets/pieces/military',
};
const String kPieceThemeKey = 'selected_piece_theme';

@Riverpod(keepAlive: true)
class ThemeManager extends _$ThemeManager {
  @override
  ThemeState build() {
    _startAsyncRefresh();
    return ThemeState();
  }

  Future<void> _startAsyncRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final colorTheme = prefs.getString(kColorThemeKey) ?? 'Default Blue';
    final pieceTheme = prefs.getString(kPieceThemeKey) ?? 'android';
    state = state.copyWith(primaryColor: kColorThemes[colorTheme]!, pieceTheme: pieceTheme);
  }

  Future<void> setPrimaryColor(String name) async {
    if (!kColorThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kColorThemeKey, name);

    state = state.copyWith(primaryColor: kColorThemes[name]!);
  }

  Future<void> setPieceTheme(String name) async {
    if (!kPieceThemes.containsKey(name)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPieceThemeKey, name);

    state = state.copyWith(pieceTheme: name);
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

  String get colorName => kColorThemes.keys.firstWhere((key) => kColorThemes[key] == primaryColor);
}
