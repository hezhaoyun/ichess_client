import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'pgn_manual.dart';

/// 显示棋局移动列表的组件
class MoveList extends StatefulWidget {
  static const double _horizontalSpacing = 8.0;
  static const double _verticalSpacing = 4.0;
  static const double _moveItemBorderRadius = 4.0;

  final List<PgnChildNode> moves;
  final int currentMoveIndex;
  final Function(int) onMoveSelected;
  final ScrollController scrollController;
  final List<TreeNode> branches;
  final Function(int) onBranchSelected;

  const MoveList({
    super.key,
    required this.moves,
    required this.currentMoveIndex,
    required this.onMoveSelected,
    required this.scrollController,
    this.branches = const [],
    required this.onBranchSelected,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: MoveList._horizontalSpacing,
                runSpacing: MoveList._verticalSpacing,
                children: _buildMoveItems(),
              ),
              if (widget.branches.isNotEmpty) ...[
                const Divider(),
                Text('变着:', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: MoveList._horizontalSpacing,
                  runSpacing: MoveList._verticalSpacing,
                  children: _buildBranchItems(),
                ),
              ],
            ],
          ),
        ),
      );

  List<Widget> _buildMoveItems() => List.generate(
        widget.moves.length,
        (index) => _MoveItem(
          move: widget.moves[index].data.san,
          moveIndex: index,
          isSelected: index == widget.currentMoveIndex,
          onTap: () => widget.onMoveSelected(index),
        ),
      );

  List<Widget> _buildBranchItems() => List.generate(
        widget.branches.length,
        (index) => _MoveItem(
          move: widget.branches[index].toString(),
          moveIndex: index,
          isSelected: false,
          onTap: () => widget.onBranchSelected(index),
          isBranch: true,
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
  final String move;
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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

  String _formatMoveText() => moveIndex.isEven ? '${(moveIndex ~/ 2 + 1)}. $move' : move;
}
