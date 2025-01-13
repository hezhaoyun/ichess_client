import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'config_manager.g.dart';

@riverpod
class ConfigManager extends _$ConfigManager {
  static const String _serverUrlKey = 'server_url';
  static const String _engineLevelKey = 'engine_level';
  static const String _moveTimeKey = 'move_time';
  static const String _searchDepthKey = 'search_depth';
  static const String _useTimeControlKey = 'use_time_control';
  static const String _enginePathKey = 'engine_path';
  static const String _showArrowsKey = 'show_arrows';
  static const String _languageKey = 'language';

  @override
  Future<ConfigState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return ConfigState(
      serverUrl: prefs.getString(_serverUrlKey) ?? 'http://42.193.22.115',
      engineLevel: prefs.getInt(_engineLevelKey) ?? 10,
      moveTime: prefs.getInt(_moveTimeKey) ?? 1000,
      searchDepth: prefs.getInt(_searchDepthKey) ?? 20,
      useTimeControl: prefs.getBool(_useTimeControlKey) ?? true,
      enginePath: prefs.getString(_enginePathKey) ?? '',
      showArrows: prefs.getBool(_showArrowsKey) ?? false,
      language: prefs.getString(_languageKey) ?? 'zh',
    );
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
    state = AsyncData(state.value!.copyWith(serverUrl: url));
  }

  Future<void> setEngineLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_engineLevelKey, level);
    state = AsyncData(state.value!.copyWith(engineLevel: level));
  }

  Future<void> setMoveTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_moveTimeKey, time);
    state = AsyncData(state.value!.copyWith(moveTime: time));
  }

  Future<void> setSearchDepth(int depth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_searchDepthKey, depth);
    state = AsyncData(state.value!.copyWith(searchDepth: depth));
  }

  Future<void> setUseTimeControl(bool useTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useTimeControlKey, useTime);
    state = AsyncData(state.value!.copyWith(useTimeControl: useTime));
  }

  Future<void> setEnginePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_enginePathKey, path);
    state = AsyncData(state.value!.copyWith(enginePath: path));
  }

  Future<void> setShowArrows(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showArrowsKey, show);
    state = AsyncData(state.value!.copyWith(showArrows: show));
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    state = AsyncData(state.value!.copyWith(language: lang));
  }
}

class ConfigState {
  final String serverUrl;
  final int engineLevel;
  final int moveTime;
  final int searchDepth;
  final bool useTimeControl;
  final String enginePath;
  final bool showArrows;
  final String language;

  const ConfigState({
    this.serverUrl = '',
    this.engineLevel = 10,
    this.moveTime = 1000,
    this.searchDepth = 20,
    this.useTimeControl = true,
    this.enginePath = '',
    this.showArrows = false,
    this.language = 'zh',
  });

  ConfigState copyWith({
    String? serverUrl,
    int? engineLevel,
    int? moveTime,
    int? searchDepth,
    bool? useTimeControl,
    String? enginePath,
    bool? showArrows,
    String? language,
  }) {
    return ConfigState(
      serverUrl: serverUrl ?? this.serverUrl,
      engineLevel: engineLevel ?? this.engineLevel,
      moveTime: moveTime ?? this.moveTime,
      searchDepth: searchDepth ?? this.searchDepth,
      useTimeControl: useTimeControl ?? this.useTimeControl,
      enginePath: enginePath ?? this.enginePath,
      showArrows: showArrows ?? this.showArrows,
      language: language ?? this.language,
    );
  }
}
