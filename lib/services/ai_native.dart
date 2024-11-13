import 'package:stockfish/stockfish.dart';
import 'package:flutter/foundation.dart';

class AiNative {
  static AiNative? _instance;

  late Stockfish _stockfish;
  bool _isInitialized = false;

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

    _stockfish = Stockfish();
    await Future.delayed(const Duration(milliseconds: 500));

    _stockfish.stdin = 'uci';
    _stockfish.stdin = 'isready';
    _stockfish.stdin = 'ucinewgame';

    _isInitialized = true;
  }

  // 获取 Stockfish 实例
  Stockfish get stockfish {
    if (!_isInitialized) {
      throw StateError('Stockfish 引擎尚未初始化');
    }
    return _stockfish;
  }

  // 设置技能等级
  void setSkillLevel(int level) {
    if (!_isInitialized) return;
    _stockfish.stdin = 'setoption name Skill Level value $level';
  }

  // 释放资源
  void dispose() {
    if (_isInitialized) {
      debugPrint('Disposing StockfishManager...');
      _stockfish.dispose();
      _isInitialized = false;
      _instance = null; // 重置单例实例
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
