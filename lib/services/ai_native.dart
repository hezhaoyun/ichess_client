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

  // 添加新的属性
  int _skillLevel = 10;
  int _moveTime = 1000; // 默认1秒
  int _searchDepth = 20; // 默认深度20层
  bool _useTime = true; // 默认使用时间限制而不是深度限制

  // 获取当前设置
  int get skillLevel => _skillLevel;
  int get moveTime => _moveTime;
  int get searchDepth => _searchDepth;
  bool get useTime => _useTime;

  // 私有构造函数
  AiNative._();

  // 获取单例实例
  static AiNative get instance {
    _instance ??= AiNative._();
    return _instance!;
  }

  // 初始化引擎
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
        final String execPath = await _getStockfishPath();
        _engine = await Process.start(execPath, []);

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
      debugPrint('引擎初始化失败: $e');
      rethrow;
    }
  }

  // 修改获取平台对应的 Stockfish 路径方法
  Future<String> _getStockfishPath() async {
    if (!Platform.isMacOS) {
      throw Exception('Platform is not support.');
    }

    return '/Users/zhaoyun/dev/ichess/chess_server/stockfish-17-m1';
  }

  // 修改 stdin 方法
  void sendCommand(String command) {
    if (!_isInitialized) return;

    if (isMobileDevice) {
      _engine.stdin = command;
    } else {
      _engine.stdin.writeln(command);
    }
  }

  // 设置引擎等级
  void setSkillLevel(int level) {
    if (!_isInitialized) return;
    _skillLevel = level.clamp(1, 20);
    sendCommand('setoption name Skill Level value $_skillLevel');
  }

  // 设置思考时间（毫秒）
  void setMoveTime(int milliseconds) {
    _moveTime = milliseconds.clamp(1000, 15000);
    _useTime = true;
  }

  // 设置搜索深度
  void setSearchDepth(int depth) {
    _searchDepth = depth.clamp(1, 30);
    _useTime = false;
  }

  // 修改获取引擎命令的方法
  String getGoCommand() {
    return _useTime ? 'go movetime $_moveTime' : 'go depth $_searchDepth';
  }

  // 修改释放资源方法
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

  // 添加重新初始化的方法
  Future<void> reinitialize() async {
    dispose();
    await Future.delayed(const Duration(milliseconds: 500));
    await initialize();
  }
}
