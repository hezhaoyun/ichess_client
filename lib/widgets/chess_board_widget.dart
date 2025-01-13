import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../game/theme_manager.dart';

PieceMap pieceMap(WidgetRef ref) {
  final themeState = ref.watch(themeManagerProvider).when(
        data: (theme) => theme,
        error: (_, __) => ThemeState(),
        loading: () => ThemeState(),
      );
  final pieceTheme = themeState.pieceTheme;
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

class ChessBoardWidget extends ConsumerWidget {
  static const kLightSquareColor = Color(0xFFEED7BE);
  static const kDarkSquareColor = Color(0xFFB58863);
  static final kMoveHighlightColor = Colors.blue.shade300;

  final double _size;
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
    required double size,
    required this.orientation,
    required this.controller,
    this.getLastMove,
    this.interactiveEnable = false,
    this.onPieceStartDrag,
    this.onPieceDrop,
    this.onPieceTap,
    this.onEmptyFieldTap,
  }) : _size = size - 20;

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

  Widget _buildRankNumber(int index) => Positioned(
        left: 2, // 左边距
        top: 10 + (_size / 8) * index + (_size / 16) - 6, // 垂直居中
        child: Text(
          '${8 - index}',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      );

  Widget _buildFileLabel(int index) => Positioned(
        left: 10 + (_size / 8) * index + (_size / 16) - 4, // 水平居中
        bottom: -2, // 底部边距
        child: Text(
          String.fromCharCode('a'.codeUnitAt(0) + index),
          style: const TextStyle(fontSize: 10, color: Colors.black54),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0xCC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: WPChessboard(
                size: _size,
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
                  size: _size / 2,
                  color: Colors.lightBlue.withAlpha(0x3D),
                ),
                pieceMap: pieceMap(ref),
              ),
            ),
            // 添加标记
            ...List.generate(8, (i) => _buildRankNumber(i)),
            ...List.generate(8, (i) => _buildFileLabel(i)),
          ],
        ),
      );
}
