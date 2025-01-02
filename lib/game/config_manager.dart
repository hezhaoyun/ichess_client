import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';
  static const String _engineLevelKey = 'engine_level';
  static const String _moveTimeKey = 'move_time';
  static const String _searchDepthKey = 'search_depth';
  static const String _useTimeControlKey = 'use_time_control';
  static const String _enginePathKey = 'engine_path';
  static const String _showArrowsKey = 'show_arrows';
  static const String _languageKey = 'language';

  String _serverUrl = 'http://42.193.22.115';
  int _engineLevel = 10;
  int _moveTime = 1000;
  int _searchDepth = 20;
  bool _useTimeControl = true;
  String _enginePath = '';
  bool _showArrows = false;
  String _language = 'zh';

  String get serverUrl => _serverUrl;
  int get engineLevel => _engineLevel;
  int get moveTime => _moveTime;
  int get searchDepth => _searchDepth;
  bool get useTimeControl => _useTimeControl;
  String get enginePath => _enginePath;
  bool get showArrows => _showArrows;
  String get language => _language;

  ConfigManager() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_serverUrlKey) ?? _serverUrl;
    _engineLevel = prefs.getInt(_engineLevelKey) ?? 10;
    _moveTime = prefs.getInt(_moveTimeKey) ?? 1000;
    _searchDepth = prefs.getInt(_searchDepthKey) ?? 20;
    _useTimeControl = prefs.getBool(_useTimeControlKey) ?? true;
    _enginePath = prefs.getString(_enginePathKey) ?? '';
    _showArrows = prefs.getBool(_showArrowsKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'zh';
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
    notifyListeners();
  }

  Future<void> setEngineLevel(int level) async {
    _engineLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_engineLevelKey, level);
    notifyListeners();
  }

  Future<void> setMoveTime(int time) async {
    _moveTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_moveTimeKey, time);
    notifyListeners();
  }

  Future<void> setSearchDepth(int depth) async {
    _searchDepth = depth;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_searchDepthKey, depth);
    notifyListeners();
  }

  Future<void> setUseTimeControl(bool useTime) async {
    _useTimeControl = useTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useTimeControlKey, useTime);
    notifyListeners();
  }

  Future<void> setEnginePath(String path) async {
    _enginePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_enginePathKey, path);
    notifyListeners();
  }

  Future<void> setShowArrows(bool show) async {
    _showArrows = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showArrowsKey, show);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    notifyListeners();
  }
}
