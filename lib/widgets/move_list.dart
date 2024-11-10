import 'package:flutter/material.dart';

class MoveList extends StatelessWidget {
  final List<String> moves;
  final int currentMoveIndex;
  final Function(int) onMoveSelected;

  const MoveList({
    super.key,
    required this.moves,
    required this.currentMoveIndex,
    required this.onMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(moves.length, (index) {
            final moveNumber = (index ~/ 2) + 1;
            final isWhiteMove = index % 2 == 0;
            return InkWell(
              onTap: () => onMoveSelected(index),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: index == currentMoveIndex
                      ? Colors.blue.withOpacity(0.2)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isWhiteMove ? '$moveNumber. ${moves[index]}' : moves[index],
                  style: TextStyle(
                    fontWeight: index == currentMoveIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color:
                        index <= currentMoveIndex ? Colors.black : Colors.grey,
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
