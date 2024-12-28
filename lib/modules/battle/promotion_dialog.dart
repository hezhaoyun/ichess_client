import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/audio_service.dart';

Future<void> showPromotionDialog(
    BuildContext context, BoardOrientation orientation, Function(String) onPromotionSelected) {
  //
  Widget promotionOption(String type, VoidCallback onTap) {
    final isWhite = orientation == BoardOrientation.white;
    Widget piece;
    switch (type) {
      case 'q':
        piece = isWhite ? WhiteQueen() : BlackQueen();
        break;
      case 'r':
        piece = isWhite ? WhiteRook() : BlackRook();
        break;
      case 'b':
        piece = isWhite ? WhiteBishop() : BlackBishop();
        break;
      case 'n':
        piece = isWhite ? WhiteKnight() : BlackKnight();
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
