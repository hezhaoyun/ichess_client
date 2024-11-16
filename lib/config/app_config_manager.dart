import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigManager extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';

  String _serverUrl = 'http://127.0.0.1:8888';
  String get serverUrl => _serverUrl;

  AppConfigManager() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_serverUrlKey) ?? 'http://127.0.0.1:8888';
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
    notifyListeners();
  }
}
