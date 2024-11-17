import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/ai_native.dart';
import '../../services/favorites_service.dart';
import '../../widgets/chess_board_widget.dart';
import 'analysis_chart.dart';
import 'move_list.dart';
import 'pgn_game.dart';
import 'viewer_control_panel.dart';
import 'viewer_mixin.dart';

class ViewerPage extends StatefulWidget {
  final String manualFile;
  final String? pgnContent;

  const ViewerPage({super.key, required this.manualFile, this.pgnContent});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> with ViewerMixin, ViewerAnalysisMixin, ViewerNavigationMixin {
  static const double kWideLayoutThreshold = 900;

  bool isLoading = false;
  final scrollController = ScrollController();
  bool isFavorite = false;
  final favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    initStockfish();
    analysisCardController = ExpansionTileController();
    _loadPgnAsset(widget.manualFile);
    _checkFavoriteStatus();
  }

  Future<void> initStockfish() async {
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
        content = await DefaultAssetBundle.of(context).loadString('assets/manuals/$filename');
      }

      setState(() {
        games = PgnGame.parseMultipleGames(content);
        if (games.isNotEmpty) {
          currentGameIndex = 0;
          currentGame = games[0].parseMoves();
          currentMoveIndex = -1;
          fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
          currentFen = chess_lib.Chess.DEFAULT_POSITION;
        }
      });

      chessboardController.setFen(currentFen);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载文件失败: $e')),
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

  Future<void> _toggleFavorite() async {
    if (currentGame == null) return;

    final pgnContent = widget.pgnContent ?? currentGame!.toPgn();

    if (isFavorite) {
      await favoritesService.removeFavorite(pgnContent);
    } else {
      final game = FavoriteGame(
        event: currentGame!.event,
        date: currentGame!.date,
        white: currentGame!.white,
        black: currentGame!.black,
        pgn: pgnContent,
        addedAt: DateTime.now(),
      );
      await favoritesService.addFavorite(game);
    }

    setState(() => isFavorite = !isFavorite);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isFavorite ? '已添加到收藏' : '已取消收藏')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Text(
          '棋谱阅读',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(0x33),
                offset: const Offset(1, 1),
                blurRadius: 2,
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
    );

    return Scaffold(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.all(16.0), child: header),
              Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final controlPanel = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ViewerControlPanel(
        currentGameIndex: currentGameIndex,
        gamesCount: games.length,
        currentMoveIndex: currentMoveIndex,
        maxMoves: currentGame?.moves.length ?? 0,
        onGameSelect: showGamesList,
        onGoToStart: () => goToMove(-1),
        onPreviousMove: () => goToMove(currentMoveIndex - 1),
        onNextMove: () => goToMove(currentMoveIndex + 1),
        onGoToEnd: () => goToMove(currentGame!.moves.length - 1),
      ),
    );

    final boardSection = Column(
      children: [
        ChessBoardWidget(
          size: MediaQuery.of(context).size.shortestSide - 52,
          orientation: BoardOrientation.white,
          controller: chessboardController,
          getLastMove: () => lastMove,
          interactiveEnable: false,
        ),
        controlPanel,
      ],
    );

    final moveListSection = Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MoveList(
              moves: currentGame!.moves,
              currentMoveIndex: currentMoveIndex,
              onMoveSelected: goToMove,
              scrollController: scrollController,
              key: selectedMoveKey,
            ),
          ),
        ],
      ),
    );

    final analysisCard = ExpansionTile(
      title: const Text('对局分析'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnalyzing) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          if (!isAnalyzing && evaluations.isEmpty) const Icon(Icons.analytics),
          if (evaluations.isNotEmpty && !isAnalyzing) const Icon(Icons.expand_more),
        ],
      ),
      controller: analysisCardController,
      initiallyExpanded: isAnalysisPanelExpanded,
      onExpansionChanged: (expanded) {
        if (!isAnalyzing && evaluations.isEmpty) analyzeGame();
        setState(() => isAnalysisPanelExpanded = expanded);
      },
      children: [
        SizedBox(
          height: 200,
          child: AnalysisChart(
            evaluations: evaluations,
            currentMoveIndex: currentMoveIndex + 1,
            onPositionChanged: goToMove,
          ),
        ),
      ],
    );

    return OrientationBuilder(
      builder: (context, orientation) {
        final isWideLayout =
            orientation == Orientation.landscape || MediaQuery.of(context).size.width > kWideLayoutThreshold;

        return Column(
          children: [
            Expanded(
              child: isWideLayout
                  ? Row(
                      children: [
                        Expanded(flex: 2, child: boardSection),
                        analysisCard,
                        if (!isAnalysisPanelExpanded) Expanded(flex: 3, child: moveListSection),
                      ],
                    )
                  : Column(
                      children: [
                        boardSection,
                        analysisCard,
                        if (!isAnalysisPanelExpanded) Expanded(child: moveListSection),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
