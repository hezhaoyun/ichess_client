import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import 'promotion_dialog.dart';

enum GameState { idle, connected, waitingMatch, waitingMove, waitingOpponent }

mixin ChessBattleMixin<T extends StatefulWidget> on State<T> {
  late WPChessboardController controller;
  late chess_lib.Chess chess;
  List<List<int>>? lastMove;

  void initChessGame({String initialFen = chess_lib.Chess.DEFAULT_POSITION}) {
    chess = chess_lib.Chess();
    controller = WPChessboardController(
      initialFen: initialFen,
    );
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
        position.$1,
        position.$2,
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

  void playerMoved(Map<String, String> move) {
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

  // 这个方法需要在子类中实现
  void onMove(Map<String, String> move);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
