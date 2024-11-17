import 'package:flutter/material.dart';

class ViewerControlPanel extends StatelessWidget {
  final int currentGameIndex;
  final int gamesCount;
  final int currentMoveIndex;
  final int maxMoves;
  final VoidCallback onGameSelect;
  final VoidCallback onGoToStart;
  final VoidCallback onPreviousMove;
  final VoidCallback onNextMove;
  final VoidCallback onGoToEnd;

  const ViewerControlPanel({
    super.key,
    required this.currentGameIndex,
    required this.gamesCount,
    required this.currentMoveIndex,
    required this.maxMoves,
    required this.onGameSelect,
    required this.onGoToStart,
    required this.onPreviousMove,
    required this.onNextMove,
    required this.onGoToEnd,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: SizedBox()),
            TextButton(
              onPressed: onGameSelect,
              child: Row(
                children: [
                  Text(
                    '${currentGameIndex + 1} / $gamesCount',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: currentMoveIndex >= 0 ? onGoToStart : null,
              tooltip: '开始',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: currentMoveIndex >= 0 ? onPreviousMove : null,
              tooltip: '上一步',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              onPressed: currentMoveIndex < maxMoves - 1 ? onNextMove : null,
              tooltip: '下一步',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: currentMoveIndex < maxMoves - 1 ? onGoToEnd : null,
              tooltip: '结束',
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      );
}
