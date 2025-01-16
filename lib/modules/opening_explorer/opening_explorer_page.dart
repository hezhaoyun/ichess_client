import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ichess/model/chess_opening.dart';
import 'package:intl/intl.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../model/online_opening.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/bottom_bar_button.dart';
import '../../widgets/chess_board_widget.dart';
import '../../widgets/game_result_dialog.dart';
import '../battle/battle_mixin.dart';
import 'win_percentage_chart.dart';

const columnWidths = {
  0: FractionColumnWidth(0.16),
  1: FractionColumnWidth(0.34),
  2: FractionColumnWidth(0.50),
};

class OpeningExplorerPage extends ConsumerStatefulWidget {
  const OpeningExplorerPage({super.key});

  @override
  ConsumerState<OpeningExplorerPage> createState() => _OpeningExplorerPageState();
}

class _OpeningExplorerPageState extends ConsumerState<OpeningExplorerPage> with BattleMixin {
  BoardOrientation boardOrientation = BoardOrientation.white;
  List<String> moveHistory = [];
  int currentMoveIndex = -1;

  @override
  void initState() {
    super.initState();
    setupChessBoard();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
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
      children: [
        _buildHeader(),
        const Spacer(),
        Row(
          children: [
            const SizedBox(width: 10),
            _buildBoard(boardSize),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: boardSize - kToolbarHeight - 10,
                    child: _buildOpeningTable(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: kToolbarHeight, width: controlWidth, child: _buildBottomBar()),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPortraitLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight * 2 - 200;
    final boardSize = min(w, availableHeight) - 20;

    return Column(
      children: [
        _buildHeader(),
        _buildBoard(boardSize),
        const SizedBox(height: 10),
        Expanded(
          child: SizedBox(
            width: boardSize,
            child: _buildOpeningTable(),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() => SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'Opening Explorer',
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
              ),
            ],
          ),
        ),
      );

  Widget _buildBoard(double boardSize) => ChessBoardWidget(
        size: boardSize,
        controller: controller,
        orientation: boardOrientation,
        interactiveEnable: true,
        getLastMove: () => lastMove,
        onPieceDrop: onPieceDrop,
        onPieceTap: onPieceTap,
        onPieceStartDrag: onPieceStartDrag,
        onEmptyFieldTap: onEmptyFieldTap,
      );

  Widget _buildOpeningTable() {
    final provider = ref.watch(onlineOpeningProvider(fen: chess.fen));
    if (provider.isLoading) return _buildLoadingTable();

    final chessOpening = provider.value;

    final moves = chessOpening?.moves ?? [];

    final whiteWins = chessOpening?.white ?? 0;
    final draws = chessOpening?.draws ?? 0;
    final blackWins = chessOpening?.black ?? 0;

    final games = whiteWins + draws + blackWins;

    return SingleChildScrollView(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Table(
          columnWidths: columnWidths,
          children: [
            _buildTableHeader(),
            ...List.generate(moves.length, (int index) => _buildRow(moves, index, games)),
            if (moves.isNotEmpty) _buildSumRow(moves, games, whiteWins, draws, blackWins) else _buildEmptyRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingTable() => Table(
        columnWidths: columnWidths,
        children: [
          _buildTableHeader(),
          ...List.generate(9, (int index) => _buildLoadingRow(index)),
        ],
      );

  TableRow _buildTableHeader() => TableRow(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer),
        children: [
          Padding(padding: const EdgeInsets.all(10), child: Text('Move')),
          Padding(padding: const EdgeInsets.all(10), child: Text('Games')),
          Padding(padding: const EdgeInsets.all(10), child: Text('White / Draw / Black')),
        ],
      );

  TableRow _buildLoadingRow(int index) => TableRow(
        decoration: BoxDecoration(
          color: index.isEven
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(0x1A),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(0x1A),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(0x1A),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      );

  TableRow _buildRow(List<OpeningMove> moves, int index, int games) {
    final move = moves[index];
    final moveGames = move.white + move.draws + move.black;
    final percentGames = ((moveGames / games) * 100).round();
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      children: [
        TableRowInkWell(
          onTap: () => onMove(_parseMove(move.uci)),
          child: Padding(padding: const EdgeInsets.all(10), child: Text(move.san)),
        ),
        TableRowInkWell(
          onTap: () => onMove(_parseMove(move.uci)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('${_formatNum(moveGames)} ($percentGames%)'),
          ),
        ),
        TableRowInkWell(
          onTap: () => onMove(_parseMove(move.uci)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: WinPercentageChart(whiteWins: move.white, draws: move.draws, blackWins: move.black),
          ),
        ),
      ],
    );
  }

  TableRow _buildSumRow(List<OpeningMove> moves, int games, int whiteWins, int draws, int blackWins) => TableRow(
        decoration: BoxDecoration(
          color: moves.length.isEven
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.functions),
          ),
          Padding(padding: const EdgeInsets.all(10), child: Text('${_formatNum(games)} (100%)')),
          Padding(
            padding: const EdgeInsets.all(10),
            child: WinPercentageChart(whiteWins: whiteWins, draws: draws, blackWins: blackWins),
          ),
        ],
      );

  TableRow _buildEmptyRow() => TableRow(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow),
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              String.fromCharCode(Icons.not_interested_outlined.codePoint),
              style: TextStyle(fontFamily: Icons.not_interested_outlined.fontFamily),
            ),
          ),
          Padding(padding: const EdgeInsets.all(10), child: Text('No games found')),
          const Padding(padding: EdgeInsets.all(10), child: SizedBox.shrink()),
        ],
      );

  Widget _buildBottomBar() => BottomBar(
        children: [
          BottomBarButton(
            icon: Icons.flip,
            onTap: _flipBoard,
            label: AppLocalizations.of(context)!.flipBoard,
          ),
          BottomBarButton(
            icon: Icons.navigate_before,
            onTap: currentMoveIndex >= 0 ? goPrevious : null,
            label: AppLocalizations.of(context)!.previous,
          ),
          BottomBarButton(
            icon: Icons.navigate_next,
            onTap: currentMoveIndex < moveHistory.length - 1 ? goNext : null,
            label: AppLocalizations.of(context)!.next,
          ),
        ],
      );

  String _formatNum(int num) => NumberFormat.decimalPatternDigits().format(num);

  Map<String, String> _parseMove(String move) {
    final moveMap = {'from': move.substring(0, 2), 'to': move.substring(2, 4)};
    if (move.length > 4) moveMap['promotion'] = move[4];
    return moveMap;
  }

  @override
  void onMove(Map<String, String> move, {bool triggerOpponent = false, bool byDrag = false}) {
    updateLastMove(move['from']!, move['to']!);
    moveHistory.add('${move['from']}${move['to']}');
    currentMoveIndex = moveHistory.length - 1;

    chess.move(move);
    controller.setFen(chess.fen, animation: !byDrag);

    if (!chess.game_over) return;

    final myColor = boardOrientation == BoardOrientation.white ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;
    final result = (chess.in_checkmate && chess.turn != myColor)
        ? GameResult.win
        : (chess.in_stalemate || chess.insufficient_material || chess.in_threefold_repetition)
            ? GameResult.draw
            : GameResult.lose;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(title: _getResultTitle(), message: _getResultMessage(), result: result),
    );
  }

  void goPrevious() {
    if (currentMoveIndex < 0) return;

    setState(() {
      lastMove = null;
      chess.undo();
      currentMoveIndex--;
      controller.setFen(chess.fen);
    });
  }

  void goNext() {
    if (currentMoveIndex >= moveHistory.length - 1) return;

    final nextMove = moveHistory[currentMoveIndex + 1];
    final move = {
      'from': nextMove.substring(0, 2),
      'to': nextMove.substring(2, 4),
    };
    if (nextMove.length > 4) {
      move['promotion'] = nextMove[4];
    }

    setState(() {
      updateLastMove(move['from']!, move['to']!);
      chess.move(move);
      currentMoveIndex++;
      controller.setFen(chess.fen);
    });
  }

  String _getResultTitle() {
    if (chess.in_checkmate || chess.in_stalemate) {
      return chess.turn == chess_lib.Color.WHITE
          ? AppLocalizations.of(context)!.youLost
          : AppLocalizations.of(context)!.youWon;
    }
    return AppLocalizations.of(context)!.draw;
  }

  String _getResultMessage() {
    if (chess.in_checkmate) {
      return chess.turn == chess_lib.Color.WHITE
          ? AppLocalizations.of(context)!.youLost
          : AppLocalizations.of(context)!.youWon;
    }
    if (chess.in_stalemate) {
      return chess.turn == chess_lib.Color.WHITE
          ? AppLocalizations.of(context)!.dontBeDiscouraged
          : AppLocalizations.of(context)!.congratulations;
    }
    if (chess.insufficient_material) return AppLocalizations.of(context)!.insufficientMaterial;
    if (chess.in_threefold_repetition) return AppLocalizations.of(context)!.threefoldRepetition;
    return AppLocalizations.of(context)!.draw;
  }

  void _flipBoard() {
    setState(() {
      boardOrientation = boardOrientation == BoardOrientation.white ? BoardOrientation.black : BoardOrientation.white;
    });
  }
}
