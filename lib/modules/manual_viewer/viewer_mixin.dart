import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/ai_native.dart';
import 'move_list.dart';
import 'pgn_game.dart';
import 'viewer_page.dart';

mixin ViewerMixin on State<ViewerPage> {
  PgnGame? currentGame;
  List<double> evaluations = [];
}

// 1. 首先创建一个 mixin 来处理棋局分析相关的逻辑
mixin ViewerAnalysisMixin on ViewerMixin {
  bool isAnalyzing = false;

  Future<void> analyzeGame() async {
    if (isAnalyzing) return;

    setState(() {
      isAnalyzing = true;
      evaluations = [];
    });

    try {
      final chess = chess_lib.Chess();

      // 分析初始局面（白方视角）
      double initialEval = await getPositionEvaluation(chess.fen);
      evaluations.add(initialEval);

      // 分析每一步棋后的局面
      for (var move in currentGame!.moves) {
        chess.move(move);
        double eval = await getPositionEvaluation(chess.fen);
        // 如果是黑方走完棋，评估分数需要取反
        if (chess.turn == chess_lib.Color.WHITE) {
          eval = -eval;
        }
        setState(() => evaluations.add(eval));
      }
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  Future<double> getPositionEvaluation(String fen) async {
    final stockfish = AiNative.instance;
    stockfish.sendCommand('position fen $fen');
    stockfish.sendCommand('go depth 8');

    double evaluation = 0.0;
    await for (final output in stockfish.stdout) {
      // 将输出按行分割并遍历每一行
      for (final line in output.split('\n')) {
        if (line.contains('score cp')) {
          final scoreMatch = RegExp(r'score cp (-?\d+)').firstMatch(line);
          if (scoreMatch != null) {
            evaluation = int.parse(scoreMatch.group(1)!) / 1.0;
          }
        } else if (line.contains('score mate')) {
          final mateMatch = RegExp(r'score mate (-?\d+)').firstMatch(line);
          if (mateMatch != null) {
            final moves = int.parse(mateMatch.group(1)!);
            evaluation = moves > 0 ? 10000.0 : -10000.0;
          }
        }

        if (line.startsWith('bestmove')) {
          return evaluation;
        }
      }
    }

    return evaluation;
  }
}

// 2. 创建一个 mixin 处理棋局导航
mixin ViewerNavigationMixin on ViewerMixin {
  List<PgnGame> games = [];
  int currentGameIndex = 0;

  int currentMoveIndex = -1;
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;
  List<String> fenHistory = [chess_lib.Chess.DEFAULT_POSITION];

  final chessboardController = WPChessboardController();
  final selectedMoveKey = GlobalKey<MoveListState>();

  ExpansionTileController? analysisCardController;
  bool isAnalysisPanelExpanded = false;

  List<List<int>>? lastMove;

  void goToMove(int index) {
    if (index < -1 || index >= currentGame!.moves.length) return;

    chess_lib.Chess? chess;

    if (index < currentMoveIndex) {
      // 后退时，删除当前位置之后的所有历史记录
      fenHistory.removeRange(index + 2, fenHistory.length);
      currentMoveIndex = index;
      currentFen = fenHistory[index + 1];
      lastMove = null;
    } else if (index > currentMoveIndex) {
      // 前进
      chess = chess_lib.Chess.fromFEN(fenHistory.last);

      for (var i = currentMoveIndex + 1; i <= index; i++) {
        if (!chess.move(currentGame!.moves[i])) break;
        currentFen = chess.fen;
        fenHistory.add(currentFen);
      }

      currentMoveIndex = index;
    }

    if (chess != null && chess.history.isNotEmpty) {
      final last = chess.history.last.move;
      updateLastMove(last.fromAlgebraic, last.toAlgebraic);
    } else {
      setState(() {});
    }

    chessboardController.setFen(currentFen);
    selectedMoveKey.currentState?.scrollToSelectedMove();
  }

  void gameSelected(int index) {
    analysisCardController?.collapse();

    setState(() {
      currentGameIndex = index;
      currentGame = games[index].parseMoves();
      currentMoveIndex = -1;
      fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
      currentFen = chess_lib.Chess.DEFAULT_POSITION;
      evaluations = [];
      isAnalysisPanelExpanded = false;
      lastMove = null;
    });

    chessboardController.setFen(currentFen);
  }

  void showGamesList() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('选择对局'),
          content: SizedBox(
            width: double.maxFinite, // 使对话框更宽
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (context, index) => ListTile(
                selected: index == currentGameIndex,
                title: Text('${index + 1}. ${games[index].white} vs ${games[index].black}'),
                subtitle: Text('${games[index].event} (${games[index].date})'),
                onTap: () {
                  Navigator.of(context).pop();
                  gameSelected(index);
                },
              ),
            ),
          ),
        ),
      );

  void updateLastMove(String fromSquare, String toSquare) {
    int rankFrom = fromSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileFrom = fromSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    int rankTo = toSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileTo = toSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;

    setState(() {
      lastMove = [
        [rankFrom, fileFrom],
        [rankTo, fileTo]
      ];
    });
  }
}
