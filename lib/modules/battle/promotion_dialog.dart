import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/audios.dart';
import '../../widgets/chess_board_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showPromotionDialog(
    BuildContext context, WidgetRef ref, BoardOrientation orientation, Function(String) onPromotionSelected) {
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
        piece = isWhite ? pieceMap(ref).Q(size) : pieceMap(ref).q(size);
        break;
      case 'r':
        piece = isWhite ? pieceMap(ref).R(size) : pieceMap(ref).r(size);
        break;
      case 'b':
        piece = isWhite ? pieceMap(ref).B(size) : pieceMap(ref).b(size);
        break;
      case 'n':
        piece = isWhite ? pieceMap(ref).N(size) : pieceMap(ref).n(size);
        break;
      default:
        throw ArgumentError('Invalid promotion type');
    }

    return InkWell(onTap: onTap, child: piece);
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.promotion),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['q', 'r', 'b', 'n']
            .map(
              (type) => promotionOption(type, () {
                Navigator.pop(context);
                onPromotionSelected(type);
                Audios().playSound('sounds/promotion.mp3');
              }),
            )
            .toList(),
      ),
    ),
  );
}
