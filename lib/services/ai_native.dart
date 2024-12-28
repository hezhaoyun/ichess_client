import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

class AiNative {
  static AiNative? _instance;

  late dynamic _engine;
  bool _isInitialized = false;
  bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;

  final _outputController = StreamController<String>.broadcast();
  Stream<String> get stdout => _outputController.stream;

  // Add new properties
  int _skillLevel = 10;
  int _moveTime = 1000; // Default 1 second
  int _searchDepth = 20; // Default depth 20 layers
  bool _useTime = true; // Default use time limit instead of depth limit
  String _enginePath = '';

  // Get current settings
  int get skillLevel => _skillLevel;
  int get moveTime => _moveTime;
  int get searchDepth => _searchDepth;
  bool get useTime => _useTime;
  String get enginePath => _enginePath;

  // Private constructor
  AiNative._();

  // Get singleton instance
  static AiNative get instance {
    _instance ??= AiNative._();
    return _instance!;
  }

  // Initialize engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (isMobileDevice) {
        _engine = Stockfish();
        await Future.delayed(const Duration(milliseconds: 500));

        _engine.stdin = 'uci';
        _engine.stdin = 'isready';
        _engine.stdin = 'ucinewgame';

        _engine.stdout.listen((output) {
          debugPrint('Stockfish output: $output');
          _outputController.add(output);
        });
      } else {
        _engine = await Process.start(enginePath, []);

        _engine.stdin.writeln('uci');
        _engine.stdin.writeln('isready');
        _engine.stdin.writeln('ucinewgame');

        _engine.stdout.transform(utf8.decoder).listen((output) {
          debugPrint('Stockfish output: $output');
          _outputController.add(output);
        });
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Engine initialization failed: $e');
    }
  }

  // Modify stdin method
  void sendCommand(String command) {
    if (!_isInitialized) return;

    if (isMobileDevice) {
      _engine.stdin = command;
    } else {
      _engine.stdin.writeln(command);
    }
  }

  // Set engine level
  void setSkillLevel(int level) {
    if (!_isInitialized) return;
    _skillLevel = level.clamp(1, 20);
    sendCommand('setoption name Skill Level value $_skillLevel');
  }

  // Set thinking time (milliseconds)
  void setMoveTime(int milliseconds) {
    _moveTime = milliseconds.clamp(1000, 15000);
    _useTime = true;
  }

  // Set search depth
  void setSearchDepth(int depth) {
    _searchDepth = depth.clamp(1, 30);
    _useTime = false;
  }

  void setEnginePath(String path) {
    _enginePath = path;
  }

  // Modify the method to get the engine command
  String getGoCommand() {
    return _useTime ? 'go movetime $_moveTime' : 'go depth $_searchDepth';
  }

  // Modify the method to release resources
  void dispose() {
    if (_isInitialized) {
      debugPrint('Disposing StockfishManager...');

      if (isMobileDevice) {
        (_engine as Stockfish).dispose();
      } else {
        (_engine as Process).kill();
      }

      _isInitialized = false;
      _instance = null;
      debugPrint('StockfishManager disposed successfully');
    }
  }

  // Add a method to reinitialize
  Future<void> reinitialize() async {
    dispose();
    await Future.delayed(const Duration(milliseconds: 500));
    await initialize();
  }
}
