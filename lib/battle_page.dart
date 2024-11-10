import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import 'game_mixin.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _HomePageState();
}

class _HomePageState extends State<BattlePage> with GameMixin {
  static const kLightSquareColor = Color(0xFFDEC6A5);
  static const kDarkSquareColor = Color(0xFF98541A);
  static final kMoveHighlightColor = Colors.blueAccent.shade400;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  Widget squareBuilder(SquareInfo info) {
    final isLightSquare = (info.index + info.rank) % 2 == 0;
    final fieldColor = isLightSquare ? kLightSquareColor : kDarkSquareColor;
    final overlayColor = getOverlayColor(info);
    return buildSquare(info.size, fieldColor, overlayColor);
  }

  Color getOverlayColor(SquareInfo info) {
    if (lastMove == null) return Colors.transparent;

    if (lastMove!.first.first == info.rank &&
        lastMove!.first.last == info.file) {
      return kMoveHighlightColor.withOpacity(0.4);
    }

    if (lastMove!.last.first == info.rank && lastMove!.last.last == info.file) {
      return kMoveHighlightColor.withOpacity(0.87);
    }

    return Colors.transparent;
  }

  Widget buildSquare(double size, Color fieldColor, Color overlayColor) =>
      Container(
        color: fieldColor,
        width: size,
        height: size,
        child: AnimatedContainer(
          color: overlayColor,
          width: size,
          height: size,
          duration: const Duration(milliseconds: 200),
        ),
      );

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

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide;

    final orientationColor = orientation == BoardOrientation.white
        ? chess_lib.Color.WHITE
        : chess_lib.Color.BLACK;

    final interactiveEnable = (gameState == GameState.waitingMove ||
            gameState == GameState.waitingOpponent) &&
        chess.turn == orientationColor;

    PieceMap pieceMap() => PieceMap(
          K: (size) => WhiteKing(size: size),
          Q: (size) => WhiteQueen(size: size),
          B: (size) => WhiteBishop(size: size),
          N: (size) => WhiteKnight(size: size),
          R: (size) => WhiteRook(size: size),
          P: (size) => WhitePawn(size: size),
          k: (size) => BlackKing(size: size),
          q: (size) => BlackQueen(size: size),
          b: (size) => BlackBishop(size: size),
          n: (size) => BlackKnight(size: size),
          r: (size) => BlackRook(size: size),
          p: (size) => BlackPawn(size: size),
        );

    final chessboard = WPChessboard(
      size: size,
      orientation: orientation,
      squareBuilder: squareBuilder,
      controller: controller,
      // Don't pass any onPieceDrop handler to disable drag and drop
      onPieceDrop: interactiveEnable ? onPieceDrop : null,
      onPieceTap: interactiveEnable ? onPieceTap : null,
      onPieceStartDrag: onPieceStartDrag,
      onEmptyFieldTap: onEmptyFieldTap,
      turnTopPlayerPieces: false,
      ghostOnDrag: true,
      dropIndicator: DropIndicatorArgs(
        size: size / 2,
        color: Colors.lightBlue.withOpacity(0.24),
      ),
      pieceMap: pieceMap(),
    );

    Row buildButtons() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (gameState == GameState.idle)
              TextButton(onPressed: connect, child: const Text('连接')),
            if (gameState != GameState.idle)
              TextButton(onPressed: disconnect, child: const Text('断开')),
            if (gameState == GameState.waitingMatch)
              TextButton(onPressed: match, child: const Text('匹配')),
            if (gameState == GameState.waitingMove)
              TextButton(onPressed: proposeDraw, child: const Text('求和')),
            if (gameState == GameState.waitingMove)
              TextButton(
                onPressed: chess.move_number >= 2 ? proposeTakeback : null,
                child: const Text('悔棋'),
              ),
            if (gameState == GameState.waitingMove)
              TextButton(onPressed: resign, child: const Text('投降')),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('棋路-国际象棋')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${opponent['name']} (${opponent['elo']}): $opponentGameTime'),
          const SizedBox(height: 10),
          chessboard,
          const SizedBox(height: 10),
          Text('${player['name']} (${player['elo']}): $gameTime'),
          const SizedBox(height: 24),
          buildButtons(),
        ],
      ),
    );
  }
}
