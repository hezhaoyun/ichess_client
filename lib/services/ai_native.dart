import 'dart:async';

import 'package:stockfish/stockfish.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class AiNative {
  static AiNative? _instance;

  late dynamic _engine;
  bool _isInitialized = false;
  bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;

  Stream<String> get stdout => _outputController.stream;
  final _outputController = StreamController<String>.broadcast();

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

  // 添加获取平台对应的 Stockfish 路径方法
  Future<String> _getStockfishPath() async {
    final Directory docDir = await getApplicationDocumentsDirectory();
    final String docPath = docDir.path;

    String engineFileName;
    if (Platform.isMacOS) {
      engineFileName = 'stockfish17-apple-silicon';
    } else if (Platform.isWindows) {
      engineFileName = 'stockfish17-win.exe';
    } else if (Platform.isLinux) {
      engineFileName = 'stockfish17-linux';
    } else {
      throw UnsupportedError('不支持的平台');
    }

    final String enginePath = '$docPath/$engineFileName';
    final File engineFile = File(enginePath);

    if (!engineFile.existsSync()) {
      final ByteData data = await rootBundle.load('assets/engine/$engineFileName');
      final List<int> bytes = data.buffer.asUint8List();
      await engineFile.writeAsBytes(bytes);
    }

    // 确保在 macOS 上正确设置权限
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', enginePath]);
    }

    if (Platform.isMacOS) {
      try {
        // 使用完整路径运行 xattr
        final result = await Process.run(
          '/usr/bin/xattr',
          ['-d', 'com.apple.quarantine', enginePath],
          runInShell: true,
        );
        if (result.exitCode != 0) {
          debugPrint('xattr 命令执行失败: ${result.stderr}');
        }
      } catch (e) {
        debugPrint('设置 quarantine 属性失败: $e');
      }
    }

    return enginePath;
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

  void setSkillLevel(int level) {
    if (!_isInitialized) return;
    sendCommand('setoption name Skill Level value $level');
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
