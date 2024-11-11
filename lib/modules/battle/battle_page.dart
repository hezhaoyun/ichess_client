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
  static const kLightSquareColor = Color(0xFFEED7BE);
  static const kDarkSquareColor = Color(0xFFB58863);
  static final kMoveHighlightColor = Colors.blue.shade300;

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

    if (lastMove!.first.first == info.rank && lastMove!.first.last == info.file) {
      return kMoveHighlightColor.withAlpha(0x66);
    }

    if (lastMove!.last.first == info.rank && lastMove!.last.last == info.file) {
      return kMoveHighlightColor.withAlpha(0xDD);
    }

    return Colors.transparent;
  }

  Widget buildSquare(double size, Color fieldColor, Color overlayColor) => Container(
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

  void onPieceDrop(PieceDropEvent event) => playerMoved({'from': event.from.toString(), 'to': event.to.toString()});

  void doMove(chess_lib.Move move) => playerMoved({'from': move.fromAlgebraic, 'to': move.toAlgebraic});

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 24;

    final orientationColor = orientation == BoardOrientation.white ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;

    final interactiveEnable = (gameState == GameState.waitingMove || gameState == GameState.waitingOpponent) &&
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
      onPieceDrop: interactiveEnable ? onPieceDrop : null,
      onPieceTap: interactiveEnable ? onPieceTap : null,
      onPieceStartDrag: onPieceStartDrag,
      onEmptyFieldTap: onEmptyFieldTap,
      turnTopPlayerPieces: false,
      ghostOnDrag: true,
      dropIndicator: DropIndicatorArgs(
        size: size / 2,
        color: Colors.lightBlue.withAlpha(0x3D),
      ),
      pieceMap: pieceMap(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('棋路-国际象棋'),
        elevation: 0,
        centerTitle: true,
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
            _buildPlayerInfo(
              name: opponent['name'],
              elo: opponent['elo'],
              time: opponentGameTime.toString(),
              isOpponent: true,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: chessboard,
              ),
            ),
            const SizedBox(height: 20),
            _buildPlayerInfo(
              name: player['name'],
              elo: player['elo'],
              time: gameTime.toString(),
              isOpponent: false,
            ),
            const SizedBox(height: 32),
            _buildGameControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo({
    required String name,
    required dynamic elo,
    required String time,
    required bool isOpponent,
  }) {
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
            child: Text(name[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ELO: $elo | 时间: $time',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
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
        if (gameState == GameState.idle)
          ElevatedButton(
            style: buttonStyle,
            onPressed: connect,
            child: const Text('连接'),
          ),
        if (gameState != GameState.idle)
          ElevatedButton(
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.red.shade400),
            ),
            onPressed: disconnect,
            child: const Text('断开'),
          ),
        if (gameState == GameState.waitingMatch)
          ElevatedButton(
            style: buttonStyle,
            onPressed: match,
            child: const Text('匹配'),
          ),
        if (gameState == GameState.waitingMove)
          ElevatedButton(
            style: buttonStyle,
            onPressed: proposeDraw,
            child: const Text('求和'),
          ),
        if (gameState == GameState.waitingMove)
          ElevatedButton(
            style: buttonStyle,
            onPressed: chess.move_number >= 2 ? proposeTakeback : null,
            child: const Text('悔棋'),
          ),
        if (gameState == GameState.waitingMove)
          ElevatedButton(
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.orange),
            ),
            onPressed: resign,
            child: const Text('投降'),
          ),
      ],
    );
  }
}
