import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../widgets/chess_board_widget.dart';
import 'online_battle_mixin.dart';

class OnlineBattlePage extends StatefulWidget {
  const OnlineBattlePage({super.key});

  @override
  State<OnlineBattlePage> createState() => _HomePageState();
}

class _HomePageState extends State<OnlineBattlePage> with OnlineBattleMixin {
  @override
  void initState() {
    super.initState();
    initGame();
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

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 24;

    final orientationColor = orientation == BoardOrientation.white
        ? chess_lib.Color.WHITE
        : chess_lib.Color.BLACK;

    final interactiveEnable = (gameState == GameState.waitingMove ||
            gameState == GameState.waitingOpponent) &&
        chess.turn == orientationColor;

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
            ChessBoardWidget(
              size: size,
              orientation: orientation,
              controller: controller,
              lastMove: lastMove,
              interactiveEnable: interactiveEnable,
              onPieceDrop: onPieceDrop,
              onPieceTap: onPieceTap,
              onPieceStartDrag: onPieceStartDrag,
              onEmptyFieldTap: onEmptyFieldTap,
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
            backgroundColor:
                isOpponent ? Colors.red.shade100 : Colors.blue.shade100,
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
