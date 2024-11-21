import 'dart:io';
import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../config/app_config_manager.dart';
import '../../services/ai_native.dart';
import '../../services/favorites_service.dart';
import '../../widgets/chess_board_widget.dart';
import 'analysis_chart.dart';
import 'move_list.dart';
import 'pgn_manual.dart';

class ViewerPage extends StatefulWidget {
  final String manualFile;
  final String? pgnContent;

  const ViewerPage({super.key, required this.manualFile, this.pgnContent});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  bool isLoading = false;

  // Game list
  int gameIndex = 0;
  List<PgnGame> games = [];
  PgnGame? get game => games.isNotEmpty ? games[gameIndex] : null;

  // Current manual
  PgnManual? manual;
  String? get comment {
    if (manual?.tree?.atStartPoint == true) return manual?.comment();
    return manual?.tree?.moveComment;
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

  // Move list
  final selectedMoveKey = GlobalKey<MoveListState>();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _initStockfish();

    _loadPgnAsset(widget.manualFile);
    _checkFavoriteStatus();
  }

  Future<void> _initStockfish() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      final configManager = Provider.of<AppConfigManager>(context, listen: false);
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
        content = await DefaultAssetBundle.of(context).loadString('assets/manuals/$filename');
      }

      games = PgnGame.parseMultiGamePgn(content);

      _gameSelected(0, resetAnalysis: false);
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

  void _gameSelected(int index, {bool resetAnalysis = true}) {
    if (resetAnalysis) {
      showAnalysisCard = false;
      isAnalyzing = false;
      evaluations = [];
    }

    gameIndex = index;
    manual = PgnManual(game!);
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
        SnackBar(content: Text(isFavorite ? '已添加到收藏' : '已取消收藏')),
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

      // 分析初始局面
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

        // 如果是白方走完棋，评估分数需要取反
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
      // 将输出按行分割并遍历每一行
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

  void _goToMove(int index, {bool scrollToSelectedMove = true}) {
    var (moves, currentIndex) = manual?.tree?.moveList() ?? (<TreeNode>[], -1);
    if (index < -1 || index >= moves.length) return;

    chess_lib.Chess? chess;
    String? currentFen;

    if (index <= currentIndex) {
      // 后退
      while (currentIndex > index) {
        manual?.tree?.prevMove();
        currentIndex--;
      }

      if (moves[currentIndex].hasSibling) {
        manual?.tree?.prevMove();
        currentIndex--;
      }

      fenHistory.removeRange(currentIndex + 2, fenHistory.length);
      currentFen = fenHistory[currentIndex + 1];
      lastMove = null;
    } else if (index > currentIndex) {
      // 前进
      chess = chess_lib.Chess.fromFEN(fenHistory.last);

      while (currentIndex < index) {
        // 如果点击的是一个有『分枝』的节点，会触发变着显示
        if (currentIndex + 1 == index && moves[currentIndex + 1].hasSibling) {
          break;
        }

        currentIndex++;

        manual?.tree?.selectBranch(0);
        if (!chess.move(moves[currentIndex].pgnNode!.data.san)) break;

        currentFen = chess.fen;
        fenHistory.add(currentFen);
      }
    }

    if (chess != null && chess.history.isNotEmpty) {
      final last = chess.history.last.move;
      _updateLastMove(last.fromAlgebraic, last.toAlgebraic); // with setState(...)
    }

    // 只有点击了有『分枝』的节点，才会提前 break;
    setState(() => showBranches = currentIndex != index);

    chessboardController.setFen(currentFen ?? fenHistory.last);
    if (scrollToSelectedMove) selectedMoveKey.currentState?.scrollToSelectedMove(index);
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

  Widget _buildHeader() => Row(
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

  Widget _buildControlPanel() {
    final (moves, currentIndex) = manual?.tree?.moveList() ?? (<TreeNode>[], -1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 8),
              ),
              onPressed: () => _showGamesList(),
              child: Row(
                children: [
                  Text('${gameIndex + 1} / ${games.length}', style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: currentIndex >= 0 ? () => _goToMove(-1) : null,
              tooltip: '开始',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: currentIndex >= 0 ? () => _goToMove(currentIndex - 1) : null,
              tooltip: '上一步',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              onPressed: currentIndex < moves.length - 1 ? () => _goToMove(currentIndex + 1) : null,
              tooltip: '下一步',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: currentIndex < moves.length - 1 ? () => _goToMove(moves.length - 1) : null,
              tooltip: '结束',
            ),
            const Expanded(child: SizedBox()),
            IconButton(
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

  Widget _buildChessBoardSection() => Column(
        children: [
          ChessBoardWidget(
            size: MediaQuery.of(context).size.shortestSide - 52,
            orientation: BoardOrientation.white,
            controller: chessboardController,
            getLastMove: () => lastMove,
            interactiveEnable: false,
          ),
          _buildControlPanel(),
        ],
      );

  Widget _buildBottomSection() {
    final (moves, currentIndex) = manual?.tree?.moveList() ?? (<TreeNode>[], -1);

    if (showAnalysisCard) {
      return SizedBox(
        height: 200,
        child: AnalysisChart(
          evaluations: evaluations,
          currentMoveIndex: currentIndex + 1,
          onPositionChanged: _goToMove,
        ),
      );
    }

    if (showBranches) {
      void selectBranch(int index) {
        showBranches = false;

        final chess = chess_lib.Chess.fromFEN(fenHistory.last);
        manual?.tree?.selectBranch(index);

        // 更新棋盘位置
        if (!chess.move(moves[currentIndex].children[index].pgnNode!.data.san)) return;
        final currentFen = chess.fen;
        fenHistory.add(currentFen);

        // 更新最后一步移动的显示
        final last = chess.history.last.move;
        _updateLastMove(last.fromAlgebraic, last.toAlgebraic);

        chessboardController.setFen(currentFen);
      }

      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('分支选择', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: currentIndex > -1 ? moves[currentIndex].branchCount : 0,
                itemBuilder: (context, i) => ListTile(
                  title: Center(child: Text(moves[currentIndex].children[i].pgnNode!.data.san)),
                  onTap: () => selectBranch(i),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: MoveList(
        moves: moves.map<TreeNode>((e) => e).toList(),
        currentMoveIndex: currentIndex,
        onMoveSelected: _goToMove,
        scrollController: scrollController,
        key: selectedMoveKey,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.all(16.0), child: _buildHeader()),
                Expanded(child: isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent()),
              ],
            ),
          ),
        ),
      );

  Widget _buildContent() {
    if (games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return OrientationBuilder(
      builder: (context, orientation) => Column(
        children: [
          _buildChessBoardSection(),
          Expanded(child: _buildBottomSection()),
          if (comment != null && comment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('注释: $comment', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
