import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../modules/widgets/chess_board_widget.dart';

class ChessSetupPage extends StatefulWidget {
  const ChessSetupPage({super.key});

  @override
  State<ChessSetupPage> createState() => _ChessSetupPageState();
}

class _ChessSetupPageState extends State<ChessSetupPage> {
  final controller = WPChessboardController(initialFen: '8/8/8/8/8/8/8/8 w - - 0 1');
  final chess = chess_lib.Chess.fromFEN('8/8/8/8/8/8/8/8 w - - 0 1');

  // 定义可用棋子
  final List<MapEntry<String, Widget>> whitePieces = [
    MapEntry('K', WhiteKing(size: 32)),
    MapEntry('Q', WhiteQueen(size: 32)),
    MapEntry('R', WhiteRook(size: 32)),
    MapEntry('B', WhiteBishop(size: 32)),
    MapEntry('N', WhiteKnight(size: 32)),
    MapEntry('P', WhitePawn(size: 32)),
  ];

  final List<MapEntry<String, Widget>> blackPieces = [
    MapEntry('k', BlackKing(size: 32)),
    MapEntry('q', BlackQueen(size: 32)),
    MapEntry('r', BlackRook(size: 32)),
    MapEntry('b', BlackBishop(size: 32)),
    MapEntry('n', BlackKnight(size: 32)),
    MapEntry('p', BlackPawn(size: 32)),
  ];

  // 在类的顶部定义一个静态变量
  static chess_lib.Piece? _draggingPiece; // 保存当前正在拖拽的棋子类型

  @override
  Widget build(BuildContext context) {
    final double boardSize = MediaQuery.of(context).size.shortestSide - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置局面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _startGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildPiecesPanel(isWhite: false), // 黑方棋子

            const SizedBox(height: 20),

            ChessBoardWidget(
              size: boardSize,
              controller: controller,
              orientation: BoardOrientation.white,
              interactiveEnable: true,
              onPieceStartDrag: (square, piece) {},
              onPieceDrop: _handlePieceDrop,
              onEmptyFieldTap: _handleEmptyFieldTap,
            ),

            const SizedBox(height: 20),

            _buildPiecesPanel(isWhite: true), // 白方棋子
          ],
        ),
      ),
    );
  }

  Widget _buildPiecesPanel({required bool isWhite}) {
    final pieces = isWhite ? whitePieces : blackPieces;

    return Container(
      height: 52,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pieces
            .map((piece) => Draggable<MapEntry<String, chess_lib.Piece>>(
                  data: MapEntry(
                    piece.key,
                    chess_lib.Piece(
                      _getPieceType(piece.key),
                      isWhite ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
                    ),
                  ),
                  feedback: piece.value,
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: piece.value,
                  ),
                  child: piece.value,
                  onDragStarted: () {
                    _draggingPiece = chess_lib.Piece(
                      _getPieceType(piece.key),
                      isWhite ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
                    );
                  },
                ))
            .toList(),
      ),
    );
  }

  void _handlePieceDrop(PieceDropEvent event) {
    if (event.from.index == -1) {
      // 从棋盘外拖入时，直接在目标位置放置棋子
      final squareName = _getSquareFromIndex(event.to.index);
      chess.put(_draggingPiece!, squareName);
    } else {
      // 棋盘内移动棋子
      chess.move({
        'from': _getSquareFromIndex(event.from.index),
        'to': _getSquareFromIndex(event.to.index),
      });
    }

    controller.setFen(chess.fen);
  }

  void _handleEmptyFieldTap(SquareInfo square) {
    // 点击空格时移除该位置的棋子
    final squareName = _getSquareFromIndex(square.index);
    if (chess.get(squareName) != null) {
      chess.remove(squareName);
      controller.setFen(chess.fen);
    }
  }

  String _getSquareFromIndex(int index) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + (index % 8));
    final rank = 8 - (index ~/ 8);
    return '$file$rank';
  }

  void _startGame() {
    if (!_isValidPosition()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('局面无效，请检查：\n1. 双方各有一个王\n2. 兵不能在第一行或第八行')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/battle',
      arguments: chess.fen,
    );
  }

  bool _isValidPosition() {
    // 检查是否有王
    bool hasWhiteKing = false;
    bool hasBlackKing = false;

    // 检查兵的位置
    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final square = _getSquareFromIndex(rank * 8 + file);
        final piece = chess.get(square);

        if (piece != null) {
          if (piece.type == chess_lib.PieceType.KING) {
            if (piece.color == chess_lib.Color.WHITE) hasWhiteKing = true;
            if (piece.color == chess_lib.Color.BLACK) hasBlackKing = true;
          }

          // 检查兵是否在第一行或第八行
          if (piece.type == chess_lib.PieceType.PAWN && (rank == 0 || rank == 7)) {
            return false;
          }
        }
      }
    }

    return hasWhiteKing && hasBlackKing;
  }

  chess_lib.PieceType _getPieceType(String piece) {
    switch (piece.toLowerCase()) {
      case 'k':
        return chess_lib.PieceType.KING;
      case 'q':
        return chess_lib.PieceType.QUEEN;
      case 'r':
        return chess_lib.PieceType.ROOK;
      case 'b':
        return chess_lib.PieceType.BISHOP;
      case 'n':
        return chess_lib.PieceType.KNIGHT;
      case 'p':
        return chess_lib.PieceType.PAWN;
      default:
        throw ArgumentError('Invalid piece type: $piece');
    }
  }
}