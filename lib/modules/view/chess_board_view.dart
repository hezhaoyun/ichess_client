import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

class ChessboardView extends StatelessWidget {
  static const kLightSquareColor = Color(0xFFDEC6A5);
  static const kDarkSquareColor = Color(0xFF98541A);

  final WPChessboardController controller;
  final String whiteName;
  final String blackName;
  final String event;
  final String date;

  const ChessboardView({
    super.key,
    required this.controller,
    required this.whiteName,
    required this.blackName,
    required this.event,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    double size;
    if (orientation == Orientation.landscape) {
      size = screenSize.height * 0.6;
      size = size.clamp(0.0, screenSize.width * 0.4);
    } else {
      size = screenSize.width * 0.8;
      size = size.clamp(0.0, screenSize.height * 0.5);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(
            '$whiteName vs $blackName\n$event ($date)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCoordinates(size),
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinates(double size) {
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
    final squareSize = size / 8;
    const labelStyle = TextStyle(fontSize: 12);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          child: _buildChessboard(size),
        ),
        Positioned(
          bottom: 0,
          left: 20,
          right: 0,
          height: 20,
          child: Row(
            children: [
              ...files.map((file) => SizedBox(
                    width: squareSize,
                    child: Center(child: Text(file, style: labelStyle)),
                  )),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 20,
          width: 20,
          child: Column(
            children: [
              ...ranks.map((rank) => SizedBox(
                    height: squareSize,
                    child: Center(child: Text(rank, style: labelStyle)),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChessboard(double size) => WPChessboard(
        size: size,
        squareBuilder: _squareBuilder,
        controller: controller,
        pieceMap: _pieceMap(size),
      );

  Widget _squareBuilder(SquareInfo info) {
    final isLightSquare = (info.index + info.rank) % 2 == 0;
    final fieldColor = isLightSquare ? kLightSquareColor : kDarkSquareColor;
    return _buildSquare(info.size, fieldColor, Colors.transparent);
  }

  Widget _buildSquare(double size, Color fieldColor, Color overlayColor) => Container(
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

  PieceMap _pieceMap(double size) => PieceMap(
        K: (size) => WhiteKing(size: size),
        Q: (size) => WhiteQueen(size: size),
        B: (size) => WhiteBishop(size: size),
        N: (size) => WhiteKnight(size: size),
        R: (size) => WhiteRook(size: size),
        P: (size) => WhitePawn(size: size),
        k: (size) => BlackKing(size: size),
        q: (size) => BlackQueen(size: size),
        b: (size) => BlackBishop(size: size),
        n: (size) => BlackKnight(size: size),
        r: (size) => BlackRook(size: size),
        p: (size) => BlackPawn(size: size),
      );
}
