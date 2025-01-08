import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'pgn_game_ex.dart';

/// Component to display the list of moves in a chess game
class MoveList extends StatefulWidget {
  static const double _horizontalSpacing = 8.0;
  static const double _verticalSpacing = 4.0;
  static const double _moveItemBorderRadius = 4.0;

  final List<TreeNode> moves;
  final int currentMoveIndex;
  final Function(int) onMoveSelected;

  const MoveList({
    super.key,
    required this.moves,
    required this.currentMoveIndex,
    required this.onMoveSelected,
  });

  @override
  State<MoveList> createState() => MoveListState();
}

/// State class for the MoveList component
class MoveListState extends State<MoveList> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0xCC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: MoveList._horizontalSpacing,
              runSpacing: MoveList._verticalSpacing,
              children: _buildMoveItems(),
            ),
          ),
        ),
      );

  List<Widget> _buildMoveItems() => List.generate(
        widget.moves.length,
        (index) => _MoveItem(
          move: widget.moves[index].pgnNode!,
          moveIndex: index,
          isSelected: index == widget.currentMoveIndex,
          isBranch: widget.moves[index].parent!.branchCount > 1,
          onTap: () => widget.onMoveSelected(index),
        ),
      );
}

/// Component for a single move item
class _MoveItem extends StatelessWidget {
  final PgnChildNode move;
  final int moveIndex;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isBranch;

  const _MoveItem({
    required this.move,
    required this.moveIndex,
    required this.isSelected,
    required this.onTap,
    this.isBranch = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade300 : Colors.transparent,
            borderRadius: BorderRadius.circular(MoveList._moveItemBorderRadius),
            border: isBranch ? Border.all(color: Colors.grey.shade400) : null,
          ),
          child: Text(
            _formatMoveText(),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: isBranch ? Colors.grey.shade700 : null,
            ),
          ),
        ),
      );

  String _formatMoveText() {
    final moveText = move.data.san;
    return moveIndex.isEven ? '${(moveIndex ~/ 2 + 1)}. $moveText' : moveText;
  }
}
