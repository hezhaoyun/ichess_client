import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigManager extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';
  static const String _engineLevelKey = 'engine_level';
  static const String _moveTimeKey = 'move_time';
  static const String _searchDepthKey = 'search_depth';
  static const String _useTimeControlKey = 'use_time_control';
  static const String _enginePathKey = 'engine_path';

  String _serverUrl = 'http://127.0.0.1:8888';
  int _engineLevel = 10;
  int _moveTime = 1000;
  int _searchDepth = 20;
  bool _useTimeControl = true;
  String _enginePath = '';

  String get serverUrl => _serverUrl;
  int get engineLevel => _engineLevel;
  int get moveTime => _moveTime;
  int get searchDepth => _searchDepth;
  bool get useTimeControl => _useTimeControl;
  String get enginePath => _enginePath;

  AppConfigManager() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_serverUrlKey) ?? 'http://127.0.0.1:8888';
    _engineLevel = prefs.getInt(_engineLevelKey) ?? 10;
    _moveTime = prefs.getInt(_moveTimeKey) ?? 3;
    _searchDepth = prefs.getInt(_searchDepthKey) ?? 20;
    _useTimeControl = prefs.getBool(_useTimeControlKey) ?? true;
    _enginePath = prefs.getString(_enginePathKey) ?? '';
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
}
