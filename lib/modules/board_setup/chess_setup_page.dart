import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../widgets/chess_board_widget.dart';

class ChessSetupPage extends StatefulWidget {
  const ChessSetupPage({super.key});

  @override
  State<ChessSetupPage> createState() => _ChessSetupPageState();
}

class _ChessSetupPageState extends State<ChessSetupPage> {
  // 添加初始FEN常量
  static const String emptyBoardFen = '8/8/8/8/8/8/8/8 w - - 0 1';
  static const String initialBoardFen = chess_lib.Chess.DEFAULT_POSITION;

  final controller = WPChessboardController(initialFen: emptyBoardFen);
  final chess = chess_lib.Chess.fromFEN(emptyBoardFen);

  // 在类的顶部定义一个静态变量
  static chess_lib.Piece? _draggingPiece; // 保存当前正在拖拽的棋子类型

  @override
  Widget build(BuildContext context) {
    final double boardSize = MediaQuery.of(context).size.shortestSide - 24;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置局面'),
        actions: [
          // 添加切换按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _toggleBoardState,
          ),
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
    final boardSize = MediaQuery.of(context).size.shortestSide - 24;
    final pieceSize = boardSize / 8;

    // 定义可用棋子
    final whitePieces = [
      MapEntry('K', WhiteKing(size: pieceSize)),
      MapEntry('Q', WhiteQueen(size: pieceSize)),
      MapEntry('R', WhiteRook(size: pieceSize)),
      MapEntry('B', WhiteBishop(size: pieceSize)),
      MapEntry('N', WhiteKnight(size: pieceSize)),
      MapEntry('P', WhitePawn(size: pieceSize)),
    ];

    final blackPieces = [
      MapEntry('k', BlackKing(size: pieceSize)),
      MapEntry('q', BlackQueen(size: pieceSize)),
      MapEntry('r', BlackRook(size: pieceSize)),
      MapEntry('b', BlackBishop(size: pieceSize)),
      MapEntry('n', BlackKnight(size: pieceSize)),
      MapEntry('p', BlackPawn(size: pieceSize)),
    ];

    final pieces = isWhite ? whitePieces : blackPieces;

    return Container(
      height: boardSize / 8 + 20,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pieces
            .map((piece) => Draggable<SquareInfo>(
                  data: SquareInfo(-1, boardSize / 8),
                  feedback: piece.value,
                  childWhenDragging: Opacity(opacity: 0.3, child: piece.value),
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
      chess.put(_draggingPiece!, event.to.toString());
    } else {
      // 棋盘内移动棋子：先获取原位置的棋子，然后移除原位置，最后放置到新位置
      final piece = chess.get(event.from.toString());
      if (piece != null) {
        chess.remove(event.from.toString());
        chess.put(piece, event.to.toString());
      }
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
          if (piece.type == chess_lib.PieceType.PAWN &&
              (rank == 0 || rank == 7)) {
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

  // 添加切换功能
  void _toggleBoardState() {
    final currentFen = chess.fen;
    final newFen =
        currentFen == emptyBoardFen ? initialBoardFen : emptyBoardFen;

    setState(() {
      chess.load(newFen);
      controller.setFen(newFen);
    });
  }
}
