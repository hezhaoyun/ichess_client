import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

/// 显示棋局移动列表的组件
class MoveList extends StatefulWidget {
  static const double _horizontalSpacing = 8.0;
  static const double _verticalSpacing = 4.0;
  static const double _moveItemBorderRadius = 4.0;

  final List<PgnChildNode> moves;
  final int currentMoveIndex;
  final Function(int) onMoveSelected;
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

class MoveListState extends State<MoveList> {
  @override
  Widget build(BuildContext context) => Card(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: MoveList._horizontalSpacing,
            runSpacing: MoveList._verticalSpacing,
            children: _buildMoveItems(),
          ),
        ),
      );

  List<Widget> _buildMoveItems() => List.generate(
        widget.moves.length,
        (index) => _MoveItem(
          move: widget.moves[index],
          moveIndex: index,
          isSelected: index == widget.currentMoveIndex,
          isBranch: widget.moves[index].children.length > 1,
          onTap: () => widget.onMoveSelected(index),
        ),
      );

  void scrollToSelectedMove() {
    if (widget.currentMoveIndex < 0 || widget.currentMoveIndex >= widget.moves.length) return;

    const itemHeight = 32.0;
    final rowsBeforeSelected = (widget.currentMoveIndex * (40.0 + MoveList._horizontalSpacing)) / 300.0;
    final approximateOffset = rowsBeforeSelected * (itemHeight + MoveList._verticalSpacing);

    widget.scrollController.animateTo(
      approximateOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

/// 单个移动项组件
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
