import 'package:flutter/material.dart';

class MoveList extends StatelessWidget {
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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0, // 水平间距
          runSpacing: 4.0, // 垂直间距
          children: List.generate(moves.length, (index) {
            return InkWell(
              onTap: () => onMoveSelected(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: index == currentMoveIndex
                      ? Colors.grey.shade200
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  index.isEven
                      ? '${(index ~/ 2 + 1)}. ${moves[index]}'
                      : moves[index],
                  style: TextStyle(
                    fontWeight: index == currentMoveIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
