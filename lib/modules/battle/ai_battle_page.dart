import 'package:flutter/material.dart';
import 'package:stockfish/stockfish.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:chess/chess.dart' as chess_lib;
import 'package:wp_chessboard/wp_chessboard.dart';

import '../widgets/chess_board_widget.dart';

class AIBattlePage extends StatefulWidget {
  const AIBattlePage({super.key});

  @override
  State<AIBattlePage> createState() => _AIBattlePageState();
}

class _AIBattlePageState extends State<AIBattlePage> {
  late WPChessboardController controller;
  late Stockfish stockfish;
  late chess_lib.Chess chess;
  List<String> moves = [];
  bool isThinking = false;
  bool _isEngineReady = false;

  @override
  void initState() {
    super.initState();
    controller = WPChessboardController();
    chess = chess_lib.Chess();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await initStockfish();
      setState(() => _isEngineReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('引擎初始化失败，请重启应')),
        );
      }
    }
  }

  initStockfish() {
    stockfish = Stockfish();

    stockfish.stdin = 'uci';
    stockfish.stdin = 'setoption name Skill Level value 10';
    stockfish.stdin = 'isready';
    stockfish.stdin = 'ucinewgame';
  }

  void onMove(String move) {
    if (!_isEngineReady) return;

    setState(() {
      moves.add(move);
      chess.move({
        'from': move.substring(0, 2),
        'to': move.substring(2, 4),
        'promotion': move.length > 4 ? move[4] : null,
      });
    });

    if (!chess.game_over) {
      makeComputerMove();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            chess.in_checkmate
                ? '将死！游戏结束'
                : chess.in_stalemate
                    ? '逼和！游戏结束'
                    : chess.in_draw
                        ? '和棋！游戏结束'
                        : '游戏结束',
          ),
        ),
      );
    }
  }

  Future<void> makeComputerMove() async {
    setState(() => isThinking = true);

    try {
      stockfish.stdin = 'position fen ${chess.fen} moves ${moves.join(' ')}';
      stockfish.stdin = 'go movetime 1000';

      String? bestMove;
      await for (final output in stockfish.stdout) {
        if (output.startsWith('info')) {
          continue;
        }

        if (output.startsWith('bestmove')) {
          final move = output.split(' ')[1];
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

      if (bestMove != null && bestMove.isNotEmpty) {
        chess.move({
          'from': bestMove.substring(0, 2),
          'to': bestMove.substring(2, 4),
          'promotion': bestMove.length > 4 ? bestMove[4] : null,
        });
        controller.setFen(chess.fen);
        moves.add(bestMove);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('引擎走子出错，请重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isThinking = false);
      }
    }
  }

  Future<void> saveGame() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/chess_game_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(moves.join(' '));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('棋局已保存')),
      );
    }
  }

  void newGame() {
    setState(() {
      controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
      chess.reset();
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

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('国际象棋对战'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlayerInfo(isOpponent: true),
            const SizedBox(height: 20),
            ChessBoardWidget(
              controller: controller,
              size: size,
              orientation: BoardOrientation.white,
              interactiveEnable: !isThinking,
              onPieceDrop: (event) {
                final move = '${event.from}${event.to}';
                onMove(move);
              },
            ),
            const SizedBox(height: 20),
            _buildPlayerInfo(isOpponent: false),
            const SizedBox(height: 32),
            _buildGameControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo({required bool isOpponent}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: isOpponent ? Colors.red.shade100 : Colors.blue.shade100,
            child: Text(isOpponent ? 'AI' : '你'),
          ),
          const SizedBox(width: 12),
          Text(
            isOpponent ? '电脑' : '玩家',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
        if (isThinking) const CircularProgressIndicator()
      ],
    );
  }

  @override
  void dispose() {
    stockfish.dispose();
    controller.dispose();
    super.dispose();
  }
}
