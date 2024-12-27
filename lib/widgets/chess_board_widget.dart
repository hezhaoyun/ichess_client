import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../game/theme_manager.dart';

class ChessBoardWidget extends StatelessWidget {
  static const kLightSquareColor = Color(0xFFEED7BE);
  static const kDarkSquareColor = Color(0xFFB58863);
  static final kMoveHighlightColor = Colors.blue.shade300;

  final double size;
  final BoardOrientation orientation;
  final WPChessboardController controller;
  final List<List<int>>? Function()? getLastMove;
  final bool interactiveEnable;
  final Function(SquareInfo, String)? onPieceStartDrag;
  final Function(PieceDropEvent)? onPieceDrop;
  final Function(SquareInfo, String)? onPieceTap;
  final Function(SquareInfo)? onEmptyFieldTap;

  const ChessBoardWidget({
    super.key,
    required this.size,
    required this.orientation,
    required this.controller,
    this.getLastMove,
    this.interactiveEnable = false,
    this.onPieceStartDrag,
    this.onPieceDrop,
    this.onPieceTap,
    this.onEmptyFieldTap,
  });

  Widget squareBuilder(SquareInfo info) {
    final isLightSquare = (info.index + info.rank) % 2 == 0;
    final fieldColor = isLightSquare ? kLightSquareColor : kDarkSquareColor;
    final overlayColor = getOverlayColor(info);
    return buildSquare(info.size, fieldColor, overlayColor);
  }

  Color getOverlayColor(SquareInfo info) {
    final lastMove = getLastMove?.call();
    if (lastMove == null) return Colors.transparent;

    if (lastMove.first.first == info.rank && lastMove.first.last == info.file) {
      return kMoveHighlightColor.withAlpha(0x66);
    }

    if (lastMove.last.first == info.rank && lastMove.last.last == info.file) {
      return kMoveHighlightColor.withAlpha(0xDD);
    }

    return Colors.transparent;
  }

  Widget buildSquare(double size, Color fieldColor, Color overlayColor) => Container(
        color: fieldColor,
        width: size,
        height: size,
        child: AnimatedContainer(
          color: overlayColor,
          width: size,
          height: size,
          duration: const Duration(milliseconds: 200),
        ),
      );

  PieceMap pieceMap(BuildContext context) {
    // return PieceMap(
    //   K: (size) => WhiteKing(size: size),
    //   Q: (size) => WhiteQueen(size: size),
    //   B: (size) => WhiteBishop(size: size),
    //   N: (size) => WhiteKnight(size: size),
    //   R: (size) => WhiteRook(size: size),
    //   P: (size) => WhitePawn(size: size),
    //   k: (size) => BlackKing(size: size),
    //   q: (size) => BlackQueen(size: size),
    //   b: (size) => BlackBishop(size: size),
    //   n: (size) => BlackKnight(size: size),
    //   r: (size) => BlackRook(size: size),
    //   p: (size) => BlackPawn(size: size),
    // );

    final pieceTheme = Provider.of<ThemeManager>(context).selectedPieceTheme;
    final pieceThemePath = ThemeManager.kPieceThemes[pieceTheme]!;

    return PieceMap(
      K: (size) => SvgPicture.asset('$pieceThemePath/wk.svg', width: size, height: size),
      Q: (size) => SvgPicture.asset('$pieceThemePath/wq.svg', width: size, height: size),
      B: (size) => SvgPicture.asset('$pieceThemePath/wb.svg', width: size, height: size),
      N: (size) => SvgPicture.asset('$pieceThemePath/wn.svg', width: size, height: size),
      R: (size) => SvgPicture.asset('$pieceThemePath/wr.svg', width: size, height: size),
      P: (size) => SvgPicture.asset('$pieceThemePath/wp.svg', width: size, height: size),
      k: (size) => SvgPicture.asset('$pieceThemePath/bk.svg', width: size, height: size),
      q: (size) => SvgPicture.asset('$pieceThemePath/bq.svg', width: size, height: size),
      b: (size) => SvgPicture.asset('$pieceThemePath/bb.svg', width: size, height: size),
      n: (size) => SvgPicture.asset('$pieceThemePath/bn.svg', width: size, height: size),
      r: (size) => SvgPicture.asset('$pieceThemePath/br.svg', width: size, height: size),
      p: (size) => SvgPicture.asset('$pieceThemePath/bp.svg', width: size, height: size),
    );
  }

  @override
  Widget build(BuildContext context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WPChessboard(
            size: size,
            orientation: orientation,
            squareBuilder: squareBuilder,
            controller: controller,
            onPieceDrop: interactiveEnable ? onPieceDrop : null,
            onPieceTap: interactiveEnable ? onPieceTap : null,
            onPieceStartDrag: onPieceStartDrag,
            onEmptyFieldTap: interactiveEnable ? onEmptyFieldTap : null,
            turnTopPlayerPieces: false,
            ghostOnDrag: true,
            dropIndicator: DropIndicatorArgs(
              size: size / 2,
              color: Colors.lightBlue.withAlpha(0x3D),
            ),
            pieceMap: pieceMap(context),
          ),
        ),
      );
}
