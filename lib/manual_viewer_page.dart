import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wp_chessboard/wp_chessboard.dart';
import 'dart:io';
import 'models/pgn_game.dart';
import 'widgets/move_list.dart';
import 'utils/chess_utils.dart';

class ManualViewerPage extends StatefulWidget {
  const ManualViewerPage({super.key});

  @override
  State<ManualViewerPage> createState() => _ManualViewerPageState();
}

class _ManualViewerPageState extends State<ManualViewerPage> {
  static const kLightSquareColor = Color(0xFFDEC6A5);
  static const kDarkSquareColor = Color(0xFF98541A);

  final controller = WPChessboardController();

  PgnGame? currentGame;
  int currentMoveIndex = -1;
  String currentFen = ChessUtils.initialFen;
  List<String> fenHistory = [ChessUtils.initialFen];
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  // 添加一个 GlobalKey
  final _selectedMoveKey = GlobalKey();

  // 添加新属性
  List<PgnGame> games = [];
  int currentGameIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('棋谱阅读'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: isLoading ? null : _loadPgnFile,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '请点击右上角按钮加载PGN文件',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (games.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: currentGameIndex,
              items: List.generate(
                games.length,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text(
                      '对局 ${index + 1}: ${games[index].white} vs ${games[index].black}'),
                ),
              ),
              onChanged: (index) {
                if (index != null) {
                  setState(() {
                    currentGameIndex = index;
                    currentGame = games[index];
                    currentMoveIndex = -1;
                    fenHistory = [ChessUtils.initialFen];
                    currentFen = ChessUtils.initialFen;
                    controller.setFen(currentFen);
                  });
                }
              },
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 900;

              if (isWideScreen) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildBoardSection(),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildMoveListSection(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildBoardSection(),
                    Expanded(
                      child: _buildMoveListSection(),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget squareBuilder(SquareInfo info) {
    final isLightSquare = (info.index + info.rank) % 2 == 0;
    final fieldColor = isLightSquare ? kLightSquareColor : kDarkSquareColor;
    return buildSquare(info.size, fieldColor, Colors.transparent);
  }

  Widget buildSquare(double size, Color fieldColor, Color overlayColor) =>
      Container(
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

  Widget _buildBoardSection() {
    final double size = MediaQuery.of(context).size.width *
        (MediaQuery.of(context).size.width > 900 ? 0.4 : 0.8);

    PieceMap pieceMap() => PieceMap(
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

    final chessboard = WPChessboard(
      size: size,
      squareBuilder: squareBuilder,
      controller: controller,
      pieceMap: pieceMap(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${currentGame!.white} vs ${currentGame!.black}\n'
            '${currentGame!.event} (${currentGame!.date})',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: chessboard,
          ),
        ),
        _buildControlPanel(),
      ],
    );
  }

  Widget _buildMoveListSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: MoveList(
              moves: currentGame!.moves,
              currentMoveIndex: currentMoveIndex,
              onMoveSelected: _goToMove,
              scrollController: _scrollController,
              key: _selectedMoveKey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: currentMoveIndex >= 0 ? _goToStart : null,
              tooltip: '开始',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_before),
              onPressed: currentMoveIndex >= 0 ? _previousMove : null,
              tooltip: '上一步',
            ),
            IconButton(
              icon: const Icon(Icons.navigate_next),
              onPressed: currentMoveIndex < (currentGame?.moves.length ?? 0) - 1
                  ? _nextMove
                  : null,
              tooltip: '下一步',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: currentGame != null &&
                      currentMoveIndex < currentGame!.moves.length - 1
                  ? _goToEnd
                  : null,
              tooltip: '结束',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadPgnFile() async {
    try {
      setState(() => isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pgn'],
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
            currentGame = games[0];
            currentMoveIndex = -1;
            fenHistory = [ChessUtils.initialFen];
            currentFen = ChessUtils.initialFen;
          }
        });

        controller.setFen(currentFen);
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

  void _goToMove(int index) {
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
          final newFen = ChessUtils.moveToFen(
            fenHistory.last,
            currentGame!.moves[i],
          );
          fenHistory.add(newFen);
          currentFen = newFen;
        }
        currentMoveIndex = index;
      }
    });

    controller.setFen(currentFen);

    if (index >= 0) {
      // 使用 Future.delayed 等待状态更新完成
      Future.delayed(const Duration(milliseconds: 100), () {
        final RenderObject? renderObject =
            _selectedMoveKey.currentContext?.findRenderObject();
        if (renderObject == null) return;

        _scrollController.position.ensureVisible(
          renderObject,
          alignment: 0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _goToStart() => _goToMove(-1);
  void _previousMove() => _goToMove(currentMoveIndex - 1);
  void _nextMove() => _goToMove(currentMoveIndex + 1);
  void _goToEnd() => _goToMove(currentGame!.moves.length - 1);
}
