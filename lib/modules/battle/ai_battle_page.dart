import 'dart:io';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/ai_native.dart';
import '../../widgets/chess_board_widget.dart';
import 'chess_battle_mixin.dart';

class AIBattlePage extends StatefulWidget {
  final String? initialFen;
  const AIBattlePage({super.key, this.initialFen});

  @override
  State<AIBattlePage> createState() => _AIBattlePageState();
}

class _AIBattlePageState extends State<AIBattlePage> with ChessBattleMixin {
  bool isThinking = false;
  bool _isEngineReady = false;
  List<String> moves = [];

  @override
  void initState() {
    super.initState();
    initChessGame();

    if (widget.initialFen != null) {
      chess.load(widget.initialFen!);
      controller.setFen(widget.initialFen!);
    }

    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await AiNative.instance.initialize();
      AiNative.instance.setSkillLevel(10);
      setState(() => _isEngineReady = true);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('引擎初始化失败!')),
          );
        }
        debugPrint('引擎初始化失败：${e.toString()}');
      });
    }
  }

  @override
  void onMove(Map<String, String> move, {bool byPlayer = true}) {
    if (!_isEngineReady) return;

    updateLastMove(move['from']!, move['to']!);
    moves.add('${move['from']}${move['to']}');

    chess.move(move);
    controller.setFen(chess.fen);

    if (!chess.game_over) {
      if (byPlayer) makeComputerMove();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(gameResult)),
    );
  }

  String get gameResult {
    if (chess.in_checkmate) return '将死！游戏结束';
    if (chess.in_stalemate) return '逼和！游戏结束';
    if (chess.in_draw) return '和棋！游戏结束';
    return '游戏结束';
  }

  Future<void> makeComputerMove() async {
    setState(() => isThinking = true);

    try {
      final stockfish = AiNative.instance;
      stockfish.sendCommand(
        'position fen ${chess.fen} moves ${moves.join(' ')}',
      );
      stockfish.sendCommand('go movetime 1000');

      String? bestMove;
      await for (final output in stockfish.stdout) {
        debugPrint('引擎输出：$output');

        // 按行分割输出并逐行处理
        for (final line in output.split('\n')) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) continue;

          if (trimmedLine.startsWith('info')) {
            continue;
          }

          if (trimmedLine.startsWith('bestmove')) {
            final move = trimmedLine.split(' ')[1];

            if (move == '(none)' || move == 'NULL') {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('引擎无法找到有效着法')),
                );
              }
              break;
            }

            bestMove = move;
            break;
          }
        }

        if (bestMove != null) break; // 如果已找到最佳着法，退出外层循环
      }

      if (bestMove != null && bestMove.isNotEmpty) {
        final moveMap = {'from': bestMove.substring(0, 2), 'to': bestMove.substring(2, 4)};
        if (bestMove.length > 4) moveMap['promotion'] = bestMove[4];
        onMove(moveMap, byPlayer: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('引擎走子出错，请重试')),
        );
        debugPrint('引擎走子出错：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => isThinking = false);
      }
    }
  }

  void newGame() {
    setState(() {
      if (widget.initialFen != null) {
        chess.load(widget.initialFen!);
        controller.setFen(widget.initialFen!);
      } else {
        chess.reset();
        controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
      }
      moves.clear();
    });
  }

  void undoMove() {
    if (moves.length >= 2) {
      setState(() {
        chess.undo();
        chess.undo();
        moves.removeLast();
        moves.removeLast();
        controller.setFen(chess.fen);
      });
    }
  }

  Future<void> saveGame() async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    // 创建PGN格式的内容
    final pgn = [
      '[Event "AI Chess Game"]',
      '[Site "Your App"]',
      '[Date "$dateStr"]',
      '[Round "1"]',
      '[White "Player"]',
      '[Black "Computer"]',
      '[Result "${_getPgnResult()}"]',
      '',
      _generateMovesText(),
    ].join('\n');

    debugPrint(pgn);

    final file = File(
      '${directory.path}/chess_game_${now.millisecondsSinceEpoch}.pgn',
    );

    await file.writeAsString(pgn);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('棋局已保存为PGN格式')),
      );
    }
  }

  // 获取对局结果
  String _getPgnResult() {
    if (!chess.game_over) return "*";

    if (chess.in_checkmate) {
      return chess.turn == chess_lib.Color.WHITE ? "0-1" : "1-0";
    }

    if (chess.in_draw || chess.in_stalemate) return "1/2-1/2";

    return "*";
  }

  // 生成标准的移动记录
  String _generateMovesText() => chess.san_moves().join(' ');

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 36;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(0x1A),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        '人机对战',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Theme.of(context).colorScheme.primary.withAlpha(0x33),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_outlined),
                      onPressed: saveGame,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayerInfo(isOpponent: true),
                    const SizedBox(height: 20),
                    ChessBoardWidget(
                      size: size,
                      controller: controller,
                      orientation: BoardOrientation.white,
                      interactiveEnable: !isThinking,
                      getLastMove: () => lastMove,
                      onPieceDrop: onPieceDrop,
                      onPieceTap: onPieceTap,
                      onPieceStartDrag: onPieceStartDrag,
                      onEmptyFieldTap: onEmptyFieldTap,
                    ),
                    const SizedBox(height: 20),
                    _buildPlayerInfo(isOpponent: false),
                    const SizedBox(height: 32),
                    _buildGameControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo({required bool isOpponent}) {
    return Container(
      width: MediaQuery.of(context).size.shortestSide - 36,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpponent ? [Colors.red.shade50, Colors.red.shade100] : [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0x1A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isOpponent && isThinking)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red.shade300,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOpponent ? Colors.red.shade300 : Colors.blue.shade300,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      isOpponent ? 'AI' : '你',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpponent ? '电脑' : '玩家',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.emoji_events_outlined,
                      label: 'ELO: ${isOpponent ? '2000' : '1500'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(0xCC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls() {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          style: buttonStyle,
          onPressed: newGame,
          child: const Text('新局'),
        ),
        ElevatedButton(
          style: buttonStyle,
          onPressed: undoMove,
          child: const Text('悔棋'),
        ),
      ],
    );
  }
}
