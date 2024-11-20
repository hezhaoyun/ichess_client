import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/ai_native.dart';
import 'move_list.dart';
import 'pgn_manual.dart';
import 'viewer_page.dart';

mixin ViewerMixin on State<ViewerPage> {
  PgnGame? currentGame;
  List<PgnGame> games = [];
  int currentGameIndex = 0;

  late PgnManual manual;
  late ManualTree moveTree;
  String? currentComment;

  List<double> evaluations = [];

  void parseManual() {
    manual = PgnManual(currentGame!);
    moveTree = manual.createTree();
    currentComment = manual.comment();
  }
}

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

      // 分析初始局面
      final (initialEval, isMate) = await getPositionEvaluation(chess.fen);
      evaluations.add(initialEval);

      double? mateScore;

      for (var move in currentGame!.moves.mainline()) {
        chess.move(move.san);
        var (eval, isMate) = await getPositionEvaluation(chess.fen);

        if (isMate) {
          if (mateScore == null) {
            mateScore = eval.abs();
          } else {
            eval = eval > 0 ? mateScore : -mateScore;
          }
        }

        // 如果是白方走完棋，评估分数需要取反
        if (chess.turn == chess_lib.Color.BLACK) eval = -eval;
        setState(() => evaluations.add(eval));
      }
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  Future<(double, bool)> getPositionEvaluation(String fen) async {
    final stockfish = AiNative.instance;
    stockfish.sendCommand('position fen $fen');
    stockfish.sendCommand('go depth 10');

    double evaluation = 0.0;
    bool isMate = false;

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
            double mateScore = calcMateScore();
            evaluation = moves > 0 ? mateScore * 2 : mateScore * -2;
          }
          isMate = true;
        }

        if (line.startsWith('bestmove')) {
          return (evaluation, isMate);
        }
      }
    }

    return (evaluation, isMate);
  }

  double calcMateScore() {
    final maxScore = evaluations.reduce(max);
    final minScore = evaluations.reduce(min);
    return max(maxScore.abs(), minScore.abs());
  }
}

mixin ViewerNavigationMixin on ViewerMixin {
  int currentMoveIndex = -1;
  List<String> fenHistory = [chess_lib.Chess.DEFAULT_POSITION];

  final chessboardController = WPChessboardController();
  final selectedMoveKey = GlobalKey<MoveListState>();

  ExpansionTileController? analysisCardController;
  bool isAnalysisPanelExpanded = false;

  List<List<int>>? lastMove;

  void goToMove(int index) {
    final (moves, currentIndex) = moveTree.moveList();
    if (index < -1 || index >= moves.length) return;

    chess_lib.Chess? chess;
    String? currentFen;

    if (index < currentMoveIndex) {
      // 后退
      while (currentMoveIndex > index) {
        moveTree.prevMove();
        currentMoveIndex--;
      }
      fenHistory.removeRange(index + 2, fenHistory.length);
      currentFen = fenHistory[index + 1];
      currentComment = moveTree.moveComment;
      lastMove = null;
    } else if (index > currentMoveIndex) {
      // 前进
      chess = chess_lib.Chess.fromFEN(fenHistory.last);

      while (currentMoveIndex < index) {
        currentMoveIndex++;
        moveTree.selectBranch(0); // 默认选择主线
        if (!chess.move(moves[currentMoveIndex].data.san)) break;
        currentFen = chess.fen;
        fenHistory.add(currentFen);
      }
      currentComment = moveTree.moveComment;
    }

    if (chess != null && chess.history.isNotEmpty) {
      final last = chess.history.last.move;
      updateLastMove(last.fromAlgebraic, last.toAlgebraic);
    } else {
      setState(() {});
    }

    chessboardController.setFen(currentFen!);
    selectedMoveKey.currentState?.scrollToSelectedMove();
  }

  void gameSelected(int index) {
    analysisCardController?.collapse();

    String? currentFen;
    setState(() {
      currentGameIndex = index;
      currentGame = games[index];
      parseManual();
      currentMoveIndex = -1;
      currentFen = currentGame!.headers['FEN'] ?? chess_lib.Chess.DEFAULT_POSITION;
      fenHistory = [currentFen!];
      currentComment = currentGame!.comments.join('\n');
      evaluations = [];
      isAnalysisPanelExpanded = false;
      lastMove = null;
    });

    chessboardController.setFen(currentFen!);
  }

  void showGamesList() => showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    games[currentGameIndex].headers['Event'] ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: games.length,
                    itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.all(2),
                      selected: index == currentGameIndex,
                      title: Text('${index + 1}. ${games[index].headers['Date']}'),
                      subtitle: Text(
                        '${games[index].headers['White']} vs ${games[index].headers['Black']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        gameSelected(index);
                      },
                    ),
                  ),
                ),
              ],
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
