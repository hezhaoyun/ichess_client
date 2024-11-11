import 'dart:io';

import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import 'move_list.dart';
import 'pgn_game.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  static const kLightSquareColor = Color(0xFFDEC6A5);
  static const kDarkSquareColor = Color(0xFF98541A);

  final controller = WPChessboardController();

  PgnGame? currentGame;
  int currentMoveIndex = -1;
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;
  List<String> fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
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
      body: isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
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

    return OrientationBuilder(
      builder: (context, orientation) {
        final isWideLayout = orientation == Orientation.landscape || MediaQuery.of(context).size.width > 900;

        return Column(
          children: [
            Expanded(
              child: isWideLayout
                  ? Row(
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
                    )
                  : Column(
                      children: [
                        _buildBoardSection(),
                        Expanded(
                          child: _buildMoveListSection(),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget squareBuilder(SquareInfo info) {
    final isLightSquare = (info.index + info.rank) % 2 == 0;
    final fieldColor = isLightSquare ? kLightSquareColor : kDarkSquareColor;
    return buildSquare(info.size, fieldColor, Colors.transparent);
  }

  Widget buildSquare(double size, Color fieldColor, Color overlayColor) => Container(
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
    // 根据屏幕方向计算棋盘大小
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    double size;
    if (orientation == Orientation.landscape) {
      // 横屏时，棋盘高度为屏幕高度的80%
      size = screenSize.height * 0.6;
      // 确保棋盘不会太宽
      size = size.clamp(0.0, screenSize.width * 0.4);
    } else {
      // 竖屏时，棋盘宽度为屏幕宽度的90%
      size = screenSize.width * 0.8;
      // 确保棋盘不会太大
      size = size.clamp(0.0, screenSize.height * 0.5);
    }

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

    // 创建坐标标签
    Widget buildCoordinates() {
      const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      const ranks = ['8', '7', '6', '5', '4', '3', '2', '1'];
      final squareSize = size / 8;
      const labelStyle = TextStyle(fontSize: 12);

      return Stack(
        children: [
          // 棋盘本体
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: chessboard,
          ),
          // 列标签 (a-h)
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
          // 行标签 (1-8)
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(
            '${currentGame!.white} vs ${currentGame!.black}\n'
            '${currentGame!.event} (${currentGame!.date})',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildCoordinates(), // 使用新的包含坐标的组件
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 对局切换
          TextButton(
            onPressed: () => _showGamesList(),
            child: Row(
              children: [
                Text(
                  '${currentGameIndex + 1} / ${games.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.grey[400],
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          // 走法控制按钮
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
            onPressed: currentMoveIndex < (currentGame?.moves.length ?? 0) - 1 ? _nextMove : null,
            tooltip: '下一步',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentGame != null && currentMoveIndex < currentGame!.moves.length - 1 ? _goToEnd : null,
            tooltip: '结束',
          ),
        ],
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
            currentGame = games[0].parseMoves();
            currentMoveIndex = -1;
            fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
            currentFen = chess_lib.Chess.DEFAULT_POSITION;
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
          final newFen = PgnGame.moveToFen(
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
        final RenderObject? renderObject = _selectedMoveKey.currentContext?.findRenderObject();
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

  // 添加新方法来显示对局列表对话框
  void _showGamesList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择对局'),
          content: SizedBox(
            width: double.maxFinite, // 使对话框更宽
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return ListTile(
                  selected: index == currentGameIndex,
                  title: Text('${index + 1}. ${game.white} vs ${game.black}'),
                  subtitle: Text('${game.event} (${game.date})'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      currentGameIndex = index;
                      currentGame = games[index].parseMoves();
                      currentMoveIndex = -1;
                      fenHistory = [chess_lib.Chess.DEFAULT_POSITION];
                      currentFen = chess_lib.Chess.DEFAULT_POSITION;
                      controller.setFen(currentFen);
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
