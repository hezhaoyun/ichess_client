import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/audio_service.dart';
import '../../widgets/chess_board_widget.dart';

Future<void> showPromotionDialog(
    BuildContext context, BoardOrientation orientation, Function(String) onPromotionSelected) {
  //
  double calculatePieceSize() {
    final boardSize = MediaQuery.of(context).size.shortestSide - 48;
    return boardSize / 8;
  }

  Widget promotionOption(String type, VoidCallback onTap) {
    final isWhite = orientation == BoardOrientation.white;
    final size = calculatePieceSize();

    Widget piece;
    switch (type) {
      case 'q':
        piece = isWhite ? pieceMap(context).Q(size) : pieceMap(context).q(size);
        break;
      case 'r':
        piece = isWhite ? pieceMap(context).R(size) : pieceMap(context).r(size);
        break;
      case 'b':
        piece = isWhite ? pieceMap(context).B(size) : pieceMap(context).b(size);
        break;
      case 'n':
        piece = isWhite ? pieceMap(context).N(size) : pieceMap(context).n(size);
        break;
      default:
        throw ArgumentError('Invalid promotion type');
    }

    return InkWell(onTap: onTap, child: piece);
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Promotion'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['q', 'r', 'b', 'n']
            .map(
              (type) => promotionOption(type, () {
                Navigator.pop(context);
                onPromotionSelected(type);
                AudioService.playSound('sounds/promotion.mp3');
              }),
            )
            .toList(),
      ),
    ),
  );
}
