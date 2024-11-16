import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../widgets/chess_board_widget.dart';
import 'battle_mixin.dart';

class OnlineBattlePage extends StatefulWidget {
  const OnlineBattlePage({super.key});

  @override
  State<OnlineBattlePage> createState() => _HomePageState();
}

class _HomePageState extends State<OnlineBattlePage> with BattleMixin, OnlineBattleMixin {
  @override
  void initState() {
    super.initState();
    initChessGame(initialFen: '');
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 36;

    final orientationColor = orientation == BoardOrientation.white ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;

    final interactiveEnable = (gameState == GameState.waitingMove || gameState == GameState.waitingOpponent) &&
        chess.turn == orientationColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(0x1A),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      '在线对战',
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
                  ],
                ),
              ),
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
                getLastMove: () => lastMove,
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
      ),
    );
  }

  Widget _buildPlayerInfo(
      {required String name, required dynamic elo, required String time, required bool isOpponent}) {
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
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                      label: 'ELO: $elo',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.timer_outlined,
                      label: time,
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

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
