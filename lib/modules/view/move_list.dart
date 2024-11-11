import 'package:flutter/material.dart';

/// 显示棋局移动列表的组件
class MoveList extends StatelessWidget {
  static const double _horizontalSpacing = 8.0;
  static const double _verticalSpacing = 4.0;
  static const double _borderRadius = 8.0;
  static const double _moveItemBorderRadius = 4.0;

  final List<String> moves;
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
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(_horizontalSpacing),
        child: Wrap(
          spacing: _horizontalSpacing,
          runSpacing: _verticalSpacing,
          children: _buildMoveItems(),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  List<Widget> _buildMoveItems() {
    return List.generate(moves.length, (index) {
      return _MoveItem(
        move: moves[index],
        moveIndex: index,
        isSelected: index == currentMoveIndex,
        onTap: () => onMoveSelected(index),
      );
    });
  }
}

/// 单个移动项组件
class _MoveItem extends StatelessWidget {
  final String move;
  final int moveIndex;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoveItem({
    required this.move,
    required this.moveIndex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(MoveList._moveItemBorderRadius),
        ),
        child: Text(
          _formatMoveText(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatMoveText() {
    return moveIndex.isEven ? '${(moveIndex ~/ 2 + 1)}. $move' : move;
  }
}
