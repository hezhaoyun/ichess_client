import 'package:flutter/material.dart';
import 'package:stockfish/stockfish.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:chess/chess.dart' as chess_lib;
import 'package:wp_chessboard/wp_chessboard.dart';

import '../widgets/chess_board_widget.dart';
import 'promotion_dialog.dart';

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
  List<List<int>>? lastMove;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    chess = chess_lib.Chess();

    controller = WPChessboardController(
      initialFen: chess_lib.Chess.DEFAULT_POSITION,
    );

    try {
      await initStockfish();
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

  initStockfish() async {
    stockfish = Stockfish();
    await Future.delayed(const Duration(milliseconds: 500));

    stockfish.stdin = 'uci';
    stockfish.stdin = 'setoption name Skill Level value 10';
    stockfish.stdin = 'isready';
    stockfish.stdin = 'ucinewgame';
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    showHintFields(square, piece);
  }

  void onPieceTap(SquareInfo square, String piece) {
    if (controller.hints.key == square.index.toString()) {
      controller.setHints(HintMap());
      return;
    }

    showHintFields(square, piece);
  }

  void showHintFields(SquareInfo square, String piece) {
    final moves = chess.generate_moves({'square': square.toString()});
    final hintMap = HintMap(key: square.index.toString());

    for (var move in moves) {
      final position = calculateMovePosition(move.toAlgebraic);
      hintMap.set(
        position.$1, // rank
        position.$2, // file
        (size) => MoveHint(size: size, onPressed: () => doMove(move)),
      );
    }

    controller.setHints(hintMap);
  }

  (int, int) calculateMovePosition(String algebraicMove) {
    final rank = algebraicMove.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    final file = algebraicMove.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    return (rank, file);
  }

  void onEmptyFieldTap(SquareInfo square) {
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) =>
      playerMoved({'from': event.from.toString(), 'to': event.to.toString()});

  void doMove(chess_lib.Move move) =>
      playerMoved({'from': move.fromAlgebraic, 'to': move.toAlgebraic});

  playerMoved(Map<String, String> move) {
    bool isPromotion = chess.moves({'verbose': true}).any((m) =>
        m['from'] == move['from'] &&
        m['to'] == move['to'] &&
        m['flags'].contains('p'));

    if (!isPromotion) {
      onMove(move);
      return;
    }

    showPromotionDialog(
      context,
      BoardOrientation.white,
      (promotion) => onMove(
        {'from': move['from']!, 'to': move['to']!, 'promotion': promotion},
      ),
    );
  }

  void onMove(Map<String, String> move) {
    if (!_isEngineReady) return;

    final fromSquare = move['from']!;
    final toSquare = move['to']!;

    int rankFrom = fromSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileFrom = fromSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    int rankTo = toSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileTo = toSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;

    setState(() {
      lastMove = [
        [rankFrom, fileFrom],
        [rankTo, fileTo]
      ];
      moves.add('$fromSquare$toSquare}');
    });

    chess.move(move);
    controller.setFen(chess.fen);

    if (!chess.game_over) {
      makeComputerMove();
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
      stockfish.stdin = 'position fen ${chess.fen} moves ${moves.join(' ')}';
      stockfish.stdin = 'go movetime 1000';

      String? bestMove;
      await for (final output in stockfish.stdout) {
        debugPrint('引擎输出：$output');

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
      chess.reset();
      moves.clear();
    });

    controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
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
    final dateStr =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

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
    final double size = MediaQuery.of(context).size.shortestSide - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('国际象棋对战'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: saveGame),
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
              size: size,
              controller: controller,
              orientation: BoardOrientation.white,
              interactiveEnable: !isThinking,
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
            backgroundColor:
                isOpponent ? Colors.red.shade100 : Colors.blue.shade100,
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
