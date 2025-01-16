import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'config_manager.g.dart';

const String kServerUrlKey = 'server_url';
const String kEngineLevelKey = 'engine_level';
const String kMoveTimeKey = 'move_time';
const String kSearchDepthKey = 'search_depth';
const String kUseTimeControlKey = 'use_time_control';
const String kEnginePathKey = 'engine_path';
const String kShowArrowsKey = 'show_arrows';
const String kLanguageKey = 'language';

@Riverpod(keepAlive: true)
class ConfigManager extends _$ConfigManager {
  @override
  ConfigState build() {
    _startAsyncRefresh();
    return ConfigState();
  }

  Future<void> _startAsyncRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final serverUrl = prefs.getString(kServerUrlKey);
    final engineLevel = prefs.getInt(kEngineLevelKey);
    final moveTime = prefs.getInt(kMoveTimeKey);
    final searchDepth = prefs.getInt(kSearchDepthKey);
    final useTimeControl = prefs.getBool(kUseTimeControlKey);
    final enginePath = prefs.getString(kEnginePathKey);
    final showArrows = prefs.getBool(kShowArrowsKey);
    final language = prefs.getString(kLanguageKey);

    state = state.copyWith(
      serverUrl: serverUrl,
      engineLevel: engineLevel,
      moveTime: moveTime,
      searchDepth: searchDepth,
      useTimeControl: useTimeControl,
      enginePath: enginePath,
      showArrows: showArrows,
      language: language,
    );
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kServerUrlKey, url);
    state = state.copyWith(serverUrl: url);
  }

  Future<void> setEngineLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kEngineLevelKey, level);
    state = state.copyWith(engineLevel: level);
  }

  Future<void> setMoveTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kMoveTimeKey, time);
    state = state.copyWith(moveTime: time);
  }

  Future<void> setSearchDepth(int depth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kSearchDepthKey, depth);
    state = state.copyWith(searchDepth: depth);
  }

  Future<void> setUseTimeControl(bool useTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kUseTimeControlKey, useTime);
    state = state.copyWith(useTimeControl: useTime);
  }

  Future<void> setEnginePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kEnginePathKey, path);
    state = state.copyWith(enginePath: path);
  }

  Future<void> setShowArrows(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kShowArrowsKey, show);
    state = state.copyWith(showArrows: show);
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLanguageKey, lang);
    state = state.copyWith(language: lang);
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
  }) =>
      ConfigState(
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
