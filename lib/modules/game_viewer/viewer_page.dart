import 'dart:io';
import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../game/config_manager.dart';
import '../../services/ai_native.dart';
import '../../services/favorites_service.dart';
import '../../widgets/chess_board_widget.dart';
import '../../widgets/sound_buttons.dart';
import 'analysis_chart.dart';
import 'move_list.dart';
import 'pgn_game_ex.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewerPage extends StatefulWidget {
  final String gameFile;
  final String? pgnContent;

  const ViewerPage({super.key, required this.gameFile, this.pgnContent});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  bool isLoading = false;

  // Game list
  int gameIndex = 0;
  List<PgnGame> games = [];
  PgnGame? get game => games.isNotEmpty ? games[gameIndex] : null;

  // Current game
  PgnGameEx? gameEx;
  String? get comment {
    if (gameEx?.tree?.atStartPoint == true) return gameEx?.comment();
    return gameEx?.tree?.moveComment;
  }

  List<String> fenHistory = [];
  bool showBranches = false;

  // Favorite
  bool isFavorite = false;
  final favoritesService = FavoritesService();

  // Analysis
  bool showAnalysisCard = false;
  bool isAnalyzing = false;
  List<double> evaluations = [];

  // Chessboard
  List<List<int>>? lastMove;
  final chessboardController = WPChessboardController();

  @override
  void initState() {
    super.initState();

    _initStockfish();

    _loadPgnAsset(widget.gameFile);
    _checkFavoriteStatus();
  }

  Future<void> _initStockfish() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      final configManager = Provider.of<ConfigManager>(context, listen: false);
      AiNative.instance.setEnginePath(configManager.enginePath);
    }

    await AiNative.instance.initialize();
    AiNative.instance.setSkillLevel(20);
  }

  Future<void> _loadPgnAsset(String filename) async {
    try {
      setState(() => isLoading = true);

      final String content;
      if (widget.pgnContent != null) {
        content = widget.pgnContent!;
      } else {
        content = await DefaultAssetBundle.of(context).loadString('assets/games/$filename');
      }

      games = PgnGame.parseMultiGamePgn(content);

      _gameSelected(0, resetAnalysis: false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFile(e.toString()))),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.pgnContent != null) {
      final status = await favoritesService.isFavorite(widget.pgnContent!);
      setState(() => isFavorite = status);
    }
  }

  void _gameSelected(int index, {bool resetAnalysis = true}) {
    if (resetAnalysis) {
      showAnalysisCard = false;
      isAnalyzing = false;
      evaluations = [];
    }

    gameIndex = index;
    gameEx = PgnGameEx(game!);
    fenHistory = [game!.headers['FEN'] ?? chess_lib.Chess.DEFAULT_POSITION];

    setState(() {
      evaluations = [];
      lastMove = null;
    });

    chessboardController.setFen(fenHistory.last);
  }

  void _showGamesList() => showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    games[gameIndex].headers['Event'] ?? '',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: games.length,
                    itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.all(2),
                      selected: index == gameIndex,
                      title: Text('${index + 1}. ${games[index].headers['Date']}'),
                      subtitle: Text(
                        '${games[index].headers['White']} vs ${games[index].headers['Black']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _gameSelected(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _toggleFavorite() async {
    if (game == null) return;

    final pgnContent = widget.pgnContent ?? game!.makePgn();

    if (isFavorite) {
      await favoritesService.removeFavorite(pgnContent);
    } else {
      final g = FavoriteGame(
        event: game!.headers['Event'] ?? '',
        date: game!.headers['Date'] ?? '',
        white: game!.headers['White'] ?? '',
        black: game!.headers['Black'] ?? '',
        pgn: pgnContent,
        addedAt: DateTime.now(),
      );
      await favoritesService.addFavorite(g);
    }

    setState(() => isFavorite = !isFavorite);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isFavorite
                ? AppLocalizations.of(context)!.addedToFavorites
                : AppLocalizations.of(context)!.removedFromFavorites)),
      );
    }
  }

  Future<void> _analyzeGame() async {
    if (isAnalyzing) return;

    setState(() {
      isAnalyzing = true;
      evaluations = [];
    });

    try {
      final chess = chess_lib.Chess();

      // Analyze initial position
      final (initialEval, isMate) = await _getEvaluation(chess.fen);
      evaluations.add(initialEval);

      double? mateScore;

      for (var move in game!.moves.mainline()) {
        chess.move(move.san);
        var (eval, isMate) = await _getEvaluation(chess.fen);

        if (isMate) {
          if (mateScore == null) {
            mateScore = eval.abs();
          } else {
            eval = eval > 0 ? mateScore : -mateScore;
          }
        }

        // If it's white's turn, the evaluation score needs to be negated
        if (chess.turn == chess_lib.Color.BLACK) eval = -eval;
        setState(() => evaluations.add(eval));
      }
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  Future<(double, bool)> _getEvaluation(String fen) async {
    final stockfish = AiNative.instance;
    stockfish.sendCommand('position fen $fen');
    stockfish.sendCommand('go depth 10');

    double evaluation = 0.0;
    bool isMate = false;

    await for (final output in stockfish.stdout) {
      // Split the output by lines and iterate through each line
      for (final line in output.split('\n')) {
        if (line.contains('score cp')) {
          final scoreMatch = RegExp(r'score cp (-?\d+)').firstMatch(line);
          if (scoreMatch != null) {
            evaluation = int.parse(scoreMatch.group(1)!) / 1.0;
          }
        } else if (line.contains('score mate')) {
          final mateMatch = RegExp(r'score mate (-?\d+)').firstMatch(line);
          if (mateMatch != null) {
            final moves = int.parse(mateMatch.group(1)!);
            double mateScore = _calcMateScore();
            evaluation = moves > 0 ? mateScore * 2 : mateScore * -2;
          }
          isMate = true;
        }

        if (line.startsWith('bestmove')) {
          return (evaluation, isMate);
        }
      }
    }

    return (evaluation, isMate);
  }

  double _calcMateScore() {
    final maxScore = evaluations.reduce(max);
    final minScore = evaluations.reduce(min);
    return max(maxScore.abs(), minScore.abs());
  }

  void _goToMove(int index) {
    var (moves, currentIndex) = gameEx?.tree?.moveList() ?? (<TreeNode>[], -1);
    if (index < -1 || index >= moves.length) return;

    chess_lib.Chess? chess;
    String? currentFen;

    if (index <= currentIndex) {
      // Backward
      while (currentIndex > index) {
        gameEx?.tree?.prevMove();
        currentIndex--;
      }

      fenHistory.removeRange(currentIndex + 2, fenHistory.length);
      currentFen = fenHistory[currentIndex + 1];
      lastMove = null;
    } else {
      // Forward
      chess = chess_lib.Chess.fromFEN(fenHistory.last);

      while (currentIndex < index) {
        currentIndex++;

        gameEx?.tree?.selectBranch(0);
        if (!chess.move(moves[currentIndex].pgnNode!.data.san)) break;

        currentFen = chess.fen;
        fenHistory.add(currentFen);
      }
    }

    if (chess != null && chess.history.isNotEmpty) {
      final last = chess.history.last.move;
      _updateLastMove(last.fromAlgebraic, last.toAlgebraic);
    }

    setState(() => showBranches = (gameEx?.tree?.siblingCount ?? 1) > 1);

    chessboardController.setFen(currentFen ?? fenHistory.last);
  }

  void _updateLastMove(String fromSquare, String toSquare) {
    int rankFrom = fromSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileFrom = fromSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    int rankTo = toSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileTo = toSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;

    setState(() {
      lastMove = [
        [rankFrom, fileFrom],
        [rankTo, fileTo]
      ];
    });
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
              Text(
                AppLocalizations.of(context)!.chessViewer,
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
              const Spacer(),
              IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
        ),
      );

  Widget _buildChessBoardSection(double boardSize) => ChessBoardWidget(
        size: boardSize,
        orientation: BoardOrientation.white,
        controller: chessboardController,
        getLastMove: () => lastMove,
        interactiveEnable: false,
      );

  Widget _buildControlPanel(double w) {
    final (moves, currentIndex) = gameEx?.tree?.moveList() ?? (<TreeNode>[], -1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0xCC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            SoundButton.text(
              style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8)),
              onPressed: () => _showGamesList(),
              child: Row(
                children: [
                  Text('${gameIndex + 1} / ${games.length}', style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            if (w > 320)
              SoundButton.icon(
                icon: const Icon(Icons.first_page),
                onPressed: currentIndex >= 0 ? () => _goToMove(-1) : null,
                tooltip: AppLocalizations.of(context)!.start,
              ),
            SoundButton.icon(
              icon: const Icon(Icons.navigate_before),
              onPressed: currentIndex >= 0 ? () => _goToMove(currentIndex - 1) : null,
              sound: 'sounds/move.mp3',
              tooltip: AppLocalizations.of(context)!.previous,
            ),
            SoundButton.icon(
              icon: const Icon(Icons.navigate_next),
              onPressed: currentIndex < moves.length - 1 ? () => _goToMove(currentIndex + 1) : null,
              sound: 'sounds/move.mp3',
              tooltip: AppLocalizations.of(context)!.next,
            ),
            if (w > 320)
              SoundButton.icon(
                icon: const Icon(Icons.last_page),
                onPressed: currentIndex < moves.length - 1 ? () => _goToMove(moves.length - 1) : null,
                tooltip: AppLocalizations.of(context)!.end,
              ),
            const Expanded(child: SizedBox()),
            SoundButton.icon(
              icon: Icon(showAnalysisCard ? Icons.analytics : Icons.analytics_outlined),
              onPressed: () {
                setState(() => showAnalysisCard = !showAnalysisCard);
                if (showAnalysisCard && evaluations.isEmpty) _analyzeGame();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualOrAnalysisSection() {
    final (moves, currentIndex) = gameEx?.tree?.moveList() ?? (<TreeNode>[], -1);

    if (showAnalysisCard) {
      return AnalysisChart(
        evaluations: evaluations,
        currentMoveIndex: currentIndex + 1,
        onPositionChanged: _goToMove,
      );
    }

    if (showBranches) {
      void selectBranch(int index) {
        setState(() => showBranches = false);

        final node = gameEx?.tree?.switchSibling(index);
        if (node == null) return;
        fenHistory.removeLast();
        final chess = chess_lib.Chess.fromFEN(fenHistory.last);

        // Update chessboard position
        if (!chess.move(node.pgnNode!.data.san)) return;

        final currentFen = chess.fen;
        fenHistory.add(currentFen);

        // Update last move display
        final last = chess.history.last.move;
        _updateLastMove(last.fromAlgebraic, last.toAlgebraic);

        chessboardController.setFen(currentFen);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.yellow.withAlpha(0xCC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.branchSelection, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: currentIndex > -1 ? gameEx?.tree?.siblingCount : 0,
                itemBuilder: (context, i) => ListTile(
                  title: Center(child: Text(gameEx?.tree?.getSibling(i)?.pgnNode!.data.san ?? '')),
                  onTap: () => selectBranch(i),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MoveList(
        moves: moves.map<TreeNode>((e) => e).toList(),
        currentMoveIndex: currentIndex,
        onMoveSelected: _goToMove,
      ),
    );
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
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildContent(w, h)),
                ],
              );
            }),
          ),
        ),
      );

  Widget _buildContent(double w, double h) {
    if (isLoading || games.isEmpty) return const Center(child: CircularProgressIndicator());
    return w > h ? _buildLandscapeLayout(w, h) : _buildPortraitLayout(w, h);
  }

  Widget _buildLandscapeLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight - 20;
    final boardSize = min(w - 350 - 10, availableHeight) - 20;
    final controlWidth = w - boardSize;

    final showComment = comment != null && comment!.isNotEmpty;
    return Row(
      children: [
        const SizedBox(width: 10),
        _buildChessBoardSection(boardSize),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: controlWidth,
                height: boardSize - 70 - (showComment ? 100 : 0),
                child: _buildManualOrAnalysisSection(),
              ),
              if (showComment)
                SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(AppLocalizations.of(context)!.comments(comment!), style: TextStyle(color: Colors.grey)),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(width: controlWidth, height: 60, child: _buildControlPanel(controlWidth)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight - 280;
    final boardSize = min(w, availableHeight) - 20;

    return Column(
      children: [
        _buildChessBoardSection(boardSize),
        const SizedBox(height: 10),
        SizedBox(width: boardSize + 20, height: 60, child: _buildControlPanel(boardSize)),
        const SizedBox(height: 10),
        Expanded(child: SizedBox(width: boardSize + 20, child: _buildManualOrAnalysisSection())),
        if (comment != null && comment!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context)!.comments(comment!), style: TextStyle(color: Colors.grey)),
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
