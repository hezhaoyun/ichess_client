import 'dart:io';

import 'package:chess/chess.dart' as chess_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../services/ai_native.dart';
import '../../widgets/chess_board_widget.dart';
import 'analysis_chart.dart';
import 'move_list.dart';
import 'pgn_game.dart';
import 'viewer_control_panel.dart';

class ViewerPage extends StatefulWidget {
  const ViewerPage({super.key});

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

mixin ViewerMixin on State<ViewerPage> {
  PgnGame? currentGame;
  List<double> evaluations = [];
}

// 1. 首先创建一个 mixin 来处理棋局分析相关的逻辑
mixin ViewerAnalysisMixin on ViewerMixin {
  bool isAnalyzing = false;

  Future<void> analyzeGame() async {
    if (isAnalyzing) return;

    setState(() {
      isAnalyzing = true;
      evaluations = [];
    });

    try {
      final chess = chess_lib.Chess();

      // 分析初始局面（白方视角）
      double initialEval = await getPositionEvaluation(chess.fen);
      evaluations.add(initialEval);

      // 分析每一步棋后的局面
      for (var move in currentGame!.moves) {
        chess.move(move);
        double eval = await getPositionEvaluation(chess.fen);
        // 如果是黑方走完棋，评估分数需要取反
        if (chess.turn == chess_lib.Color.WHITE) {
          eval = -eval;
        }
        setState(() => evaluations.add(eval));
      }
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  Future<double> getPositionEvaluation(String fen) async {
    final stockfish = AiNative.instance;
    stockfish.sendCommand('position fen $fen');
    stockfish.sendCommand('go depth 8');

    double evaluation = 0.0;
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
            evaluation = moves > 0 ? 10000.0 : -10000.0;
          }
        }

        if (line.startsWith('bestmove')) {
          return evaluation;
        }
      }
    }

    return evaluation;
  }
}

// 2. 创建一个 mixin 处理棋局导航
mixin ViewerNavigationMixin on ViewerMixin {
  List<PgnGame> games = [];
  int currentGameIndex = 0;

  int currentMoveIndex = -1;
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;
  List<String> fenHistory = [chess_lib.Chess.DEFAULT_POSITION];

  final chessboardController = WPChessboardController();
  final selectedMoveKey = GlobalKey<MoveListState>();

  ExpansionTileController? analysisCardController;
  bool isAnalysisPanelExpanded = false;

  void goToMove(int index) {
    if (index < -1 || index >= currentGame!.moves.length) return;

    setState(() {
      if (index < currentMoveIndex) {
        // 后退时，删除当前位置之后的所有历史记录
        fenHistory.removeRange(index + 2, fenHistory.length);
        currentMoveIndex = index;
        currentFen = fenHistory[index + 1];
      } else if (index > currentMoveIndex) {
        // 前进
        for (var i = currentMoveIndex + 1; i <= index; i++) {
          final newFen = PgnGame.moveToFen(fenHistory.last, currentGame!.moves[i]);
          fenHistory.add(newFen);
          currentFen = newFen;
        }

        currentMoveIndex = index;
      }
    });

    chessboardController.setFen(currentFen);
    selectedMoveKey.currentState?.scrollToSelectedMove();
  }

  void gameSelected(int index) {
    analysisCardController?.collapse();

    setState(() {
      currentGameIndex = index;
      currentGame = games[index].parseMoves();
      currentMoveIndex = -1;
      fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
      currentFen = chess_lib.Chess.DEFAULT_POSITION;
      chessboardController.setFen(currentFen);
      evaluations = [];
      isAnalysisPanelExpanded = false;
    });
  }

  void showGamesList() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('选择对局'),
          content: SizedBox(
            width: double.maxFinite, // 使对话框更宽
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (context, index) => ListTile(
                selected: index == currentGameIndex,
                title: Text('${index + 1}. ${games[index].white} vs ${games[index].black}'),
                subtitle: Text('${games[index].event} (${games[index].date})'),
                onTap: () {
                  Navigator.of(context).pop();
                  gameSelected(index);
                },
              ),
            ),
          ),
        ),
      );
}

// 3. 主类实现
class _ViewerPageState extends State<ViewerPage> with ViewerMixin, ViewerAnalysisMixin, ViewerNavigationMixin {
  static const double kWideLayoutThreshold = 900;

  bool isLoading = false;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initStockfish();
    analysisCardController = ExpansionTileController();
  }

  Future<void> initStockfish() async {
    await AiNative.instance.initialize();
    AiNative.instance.setSkillLevel(20);
  }

  Future<void> _loadPgnFile() async {
    try {
      setState(() => isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final file = result.files.first;
        String content;

        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        } else {
          throw Exception('无法读取文件内容');
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
      }
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
          icon: const Icon(Icons.folder_open),
          onPressed: isLoading ? null : _loadPgnFile,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.primary.withAlpha(0x33)),
            const SizedBox(height: 16),
            Text('请点击右上角按钮加载PGN文件', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
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
          interactiveEnable: false,
        ),
        controlPanel,
      ],
    );

    final moveListSection = Padding(
      padding: const EdgeInsets.all(16.0),
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
