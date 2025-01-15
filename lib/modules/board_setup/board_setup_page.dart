import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../home_page.dart';
import '../../i18n/generated/app_localizations.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/bottom_bar_button.dart';
import '../../widgets/chess_board_widget.dart';

class BoardSetupPage extends ConsumerStatefulWidget {
  const BoardSetupPage({super.key});

  @override
  ConsumerState<BoardSetupPage> createState() => _BoardSetupPageState();
}

class _BoardSetupPageState extends ConsumerState<BoardSetupPage> {
  // Board state constants
  static const String _emptyBoardFen = '8/8/8/8/8/8/8/8 w - - 0 1';
  static const String _initialBoardFen = chess_lib.Chess.DEFAULT_POSITION;

  // Piece configuration
  static const _pieceConfigs = {
    'white': {
      'K': {'num': 1},
      'Q': {'num': 1},
      'R': {'num': 2},
      'B': {'num': 2},
      'N': {'num': 2},
      'P': {'num': 8},
    },
    'black': {
      'k': {'num': 1},
      'q': {'num': 1},
      'r': {'num': 2},
      'b': {'num': 2},
      'n': {'num': 2},
      'p': {'num': 8},
    },
  };

  final _controller = WPChessboardController(initialFen: _initialBoardFen);
  final _chess = chess_lib.Chess.fromFEN(_initialBoardFen);
  static chess_lib.Piece? _draggingPiece;

  // Piece counter
  final Map<String, int> _currentPieceCounts = Map.fromIterables(
    [..._pieceConfigs['white']!.keys, ..._pieceConfigs['black']!.keys],
    List.filled(12, 0),
  );

  @override
  void initState() {
    super.initState();
    _updatePieceCounts();
  }

  void _updatePieceCounts() {
    _currentPieceCounts.updateAll((key, value) => 0);

    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final piece = _chess.get(_getSquareFromIndex(rank * 8 + file));
        if (piece != null) {
          final key = piece.color == chess_lib.Color.WHITE
              ? _getPieceChar(piece.type).toUpperCase()
              : _getPieceChar(piece.type).toLowerCase();
          _currentPieceCounts[key] = (_currentPieceCounts[key] ?? 0) + 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(0x1A),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final w = constraints.maxWidth, h = constraints.maxHeight;
              final isLandscape = w > h;
              return isLandscape ? _buildLandscapeLayout(w, h) : _buildPortraitLayout(w, h);
            }),
          ),
        ),
      );

  Widget _buildLandscapeLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight - 20;
    final boardSize = min(w - 350 - 10, availableHeight) - 20;
    final controlWidth = w - boardSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const Spacer(),
        SizedBox(
          height: boardSize,
          child: Row(
            children: [
              const SizedBox(width: 10),
              _buildChessBoard(boardSize),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: controlWidth > 450 ? 100 : 60,
                      width: controlWidth,
                      child: _buildPiecesPanel(width: controlWidth, isWhite: false),
                    ),
                    SizedBox(
                      height: controlWidth > 450 ? 100 : 60,
                      width: controlWidth,
                      child: _buildPiecesPanel(width: controlWidth, isWhite: true),
                    ),
                    SizedBox(
                      height: controlWidth > 450 ? 90 : 60,
                      width: controlWidth,
                      child: _buildTrashBin(boardSize),
                    ),
                    SizedBox(
                      height: boardSize - (controlWidth > 450 ? 300 : 190),
                      width: controlWidth,
                      child: Column(
                        children: [
                          const Spacer(),
                          _buildButtonControlls(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPortraitLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight * 2 - 170; // 60 + 60 + 50
    final boardSize = min(w, availableHeight) - 20;

    return Column(
      children: [
        _buildHeader(context),
        SizedBox(width: boardSize, height: 60, child: _buildPiecesPanel(width: boardSize, isWhite: false)),
        _buildChessBoard(boardSize),
        SizedBox(width: boardSize, height: 60, child: _buildPiecesPanel(width: boardSize, isWhite: true)),
        SizedBox(width: boardSize, height: 50, child: _buildTrashBin(boardSize)),
        const Spacer(),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildButtonControlls() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: _toggleBoardState, child: Text(AppLocalizations.of(context)!.fullEmpty)),
          ElevatedButton(onPressed: _startGame, child: Text(AppLocalizations.of(context)!.playWithAI)),
        ],
      );

  Widget _buildBottomBar() => BottomBar(
        children: [
          BottomBarButton(
            icon: Icons.flip,
            onTap: _toggleBoardState,
            label: AppLocalizations.of(context)!.fullEmpty,
          ),
          BottomBarButton(
            icon: Icons.play_arrow,
            onTap: _startGame,
            label: AppLocalizations.of(context)!.playWithAI,
          ),
        ],
      );

  Widget _buildHeader(BuildContext context) => SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                AppLocalizations.of(context)!.setupBoard,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.primary.withAlpha(0x33),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildChessBoard(double boardSize) => ChessBoardWidget(
        size: boardSize,
        controller: _controller,
        orientation: BoardOrientation.white,
        interactiveEnable: true,
        onPieceStartDrag: (square, piece) {},
        onPieceDrop: onPieceDrop,
        onEmptyFieldTap: onEmptyFieldTap,
      );

  Widget _buildPiecesPanel({required bool isWhite, required double width}) {
    final pieceSize = _calculatePieceSize(width);
    final pieces = _buildPiecesList(isWhite, pieceSize);

    return Container(
      height: pieceSize + 20,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pieces,
      ),
    );
  }

  double _calculatePieceSize(double width) => width / 8;

  List<Widget> _buildPiecesList(bool isWhite, double pieceSize) {
    final config = _pieceConfigs[isWhite ? 'white' : 'black']!;

    return config.entries.map((entry) {
      final canDrag = _canDragPiece(entry.key);
      return _buildDraggablePiece(
        pieceKey: entry.key,
        pieceSize: pieceSize,
        canDrag: canDrag,
        isWhite: isWhite,
      );
    }).toList();
  }

  bool _canDragPiece(String pieceKey) {
    final maxCount = _pieceConfigs[pieceKey.toUpperCase() == pieceKey ? 'white' : 'black']![pieceKey]!['num'] as int;
    return (_currentPieceCounts[pieceKey] ?? 0) < maxCount;
  }

  Widget _buildDraggablePiece({
    required String pieceKey,
    required double pieceSize,
    required bool canDrag,
    required bool isWhite,
  }) {
    final pieceWidget = _createPieceWidget(pieceKey, pieceSize, ref);

    return Opacity(
      opacity: canDrag ? 1.0 : 0.3,
      child: canDrag
          ? Draggable<SquareInfo>(
              data: SquareInfo(-1, pieceSize),
              feedback: pieceWidget,
              childWhenDragging: Opacity(opacity: 0.3, child: pieceWidget),
              child: pieceWidget,
              onDragStarted: () {
                _draggingPiece = chess_lib.Piece(
                  _getPieceType(pieceKey),
                  isWhite ? chess_lib.Color.WHITE : chess_lib.Color.BLACK,
                );
              },
            )
          : pieceWidget,
    );
  }

  Widget _createPieceWidget(String pieceKey, double size, WidgetRef ref) {
    return pieceMap(ref).get(pieceKey)(size);
  }

  Widget _buildTrashBin(double boardSize) => DragTarget<SquareInfo>(
        builder: (context, candidateData, rejectedData) => Container(
          width: boardSize,
          height: 40,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.red.shade300 : Colors.transparent,
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.transparent : Colors.red.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: candidateData.isNotEmpty ? Colors.white : Colors.red.shade300,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.dragAndDropToRemove,
                style: TextStyle(
                  color: candidateData.isNotEmpty ? Colors.white : Colors.red.shade300,
                ),
              ),
            ],
          ),
        ),
        onWillAcceptWithDetails: (details) => details.data.index != -1,
        onAcceptWithDetails: (details) {
          _chess.remove(details.data.toString());
          _controller.setFen(_chess.fen);
          _updatePieceCounts();
          setState(() {});
        },
      );

  void onPieceDrop(PieceDropEvent event) {
    if (event.from.index == -1) {
      if (_draggingPiece == null) return;

      final pieceKey = _draggingPiece!.color == chess_lib.Color.WHITE
          ? _getPieceChar(_draggingPiece!.type).toUpperCase()
          : _getPieceChar(_draggingPiece!.type).toLowerCase();

      if (!_canDragPiece(pieceKey)) return;

      _chess.put(_draggingPiece!, event.to.toString());
    } else {
      final piece = _chess.get(event.from.toString());
      if (piece != null) {
        _chess.remove(event.from.toString());
        _chess.put(piece, event.to.toString());
      }
    }

    _controller.setFen(_chess.fen);
    _updatePieceCounts();
    setState(() {});
  }

  void onEmptyFieldTap(SquareInfo square) {
    final squareName = _getSquareFromIndex(square.index);

    if (_chess.get(squareName) != null) {
      _chess.remove(squareName);
      _controller.setFen(_chess.fen);
      _updatePieceCounts();
      setState(() {});
    }
  }

  void _startGame() {
    if (!_isValidPosition()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidPosition)),
      );
      return;
    }

    Navigator.pushNamed(context, Routes.aiBattle, arguments: {'fen': _chess.fen});
  }

  bool _isValidPosition() {
    var kingCount = {'white': 0, 'black': 0};
    var hasPawnOnInvalidRank = false;

    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        final piece = _chess.get(_getSquareFromIndex(rank * 8 + file));
        if (piece == null) continue;

        if (piece.type == chess_lib.PieceType.KING) {
          kingCount[piece.color == chess_lib.Color.WHITE ? 'white' : 'black'] = 1;
        }

        if (piece.type == chess_lib.PieceType.PAWN && (rank == 0 || rank == 7)) {
          hasPawnOnInvalidRank = true;
          break;
        }
      }
    }

    return kingCount['white'] == 1 && kingCount['black'] == 1 && !hasPawnOnInvalidRank;
  }

  void _toggleBoardState() {
    final newFen = _chess.fen == _initialBoardFen ? _emptyBoardFen : _initialBoardFen;

    setState(() {
      _chess.load(newFen);
      _controller.setFen(newFen);
      _updatePieceCounts();
    });
  }

  String _getSquareFromIndex(int index) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + (index % 8));
    final rank = 8 - (index ~/ 8);
    return '$file$rank';
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

  String _getPieceChar(chess_lib.PieceType type) {
    switch (type) {
      case chess_lib.PieceType.KING:
        return 'k';
      case chess_lib.PieceType.QUEEN:
        return 'q';
      case chess_lib.PieceType.ROOK:
        return 'r';
      case chess_lib.PieceType.BISHOP:
        return 'b';
      case chess_lib.PieceType.KNIGHT:
        return 'n';
      case chess_lib.PieceType.PAWN:
        return 'p';
      default:
        throw ArgumentError('Invalid piece type');
    }
  }
}
