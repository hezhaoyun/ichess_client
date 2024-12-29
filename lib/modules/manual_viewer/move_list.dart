import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'pgn_manual.dart';

/// Component to display the list of moves in a chess game
class MoveList extends StatefulWidget {
  static const double _horizontalSpacing = 8.0;
  static const double _verticalSpacing = 4.0;
  static const double _moveItemBorderRadius = 4.0;

  final List<TreeNode> moves;
  final int currentMoveIndex;
  final Function(int, {bool scrollToSelectedMove}) onMoveSelected;
  final ScrollController scrollController;

  const MoveList({
    super.key,
    required this.moves,
    required this.currentMoveIndex,
    required this.onMoveSelected,
    required this.scrollController,
  });

  @override
  State<MoveList> createState() => MoveListState();
}

/// State class for the MoveList component
class MoveListState extends State<MoveList> {
  @override
  Widget build(BuildContext context) => Card(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            controller: widget.scrollController,
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
          onTap: () => widget.onMoveSelected(index, scrollToSelectedMove: false),
        ),
      );

  void scrollToSelectedMove(int index) {
    const itemHeight = 32.0;
    final rowsBeforeSelected = (index * (40.0 + MoveList._horizontalSpacing)) / 300.0;
    final approximateOffset = rowsBeforeSelected * (itemHeight + MoveList._verticalSpacing);
    widget.scrollController.jumpTo(approximateOffset);
  }
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
