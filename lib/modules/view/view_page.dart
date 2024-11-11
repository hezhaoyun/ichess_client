import 'dart:io';

import 'package:chess/chess.dart' as chess_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import 'move_list.dart';
import 'pgn_game.dart';
import 'chess_control_panel.dart';
import 'chess_board_view.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});
  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final controller = WPChessboardController();
  final _scrollController = ScrollController();
  final _selectedMoveKey = GlobalKey();

  bool isLoading = false;

  int currentGameIndex = 0;
  List<PgnGame> games = [];
  PgnGame? currentGame;
  int currentMoveIndex = -1;
  String currentFen = chess_lib.Chess.DEFAULT_POSITION;
  List<String> fenHistory = [chess_lib.Chess.DEFAULT_POSITION];

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
          final newFen = PgnGame.moveToFen(fenHistory.last, currentGame!.moves[i]);
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

  Widget _buildControlPanel() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ChessControlPanel(
          currentGameIndex: currentGameIndex,
          gamesCount: games.length,
          currentMoveIndex: currentMoveIndex,
          maxMoves: currentGame?.moves.length ?? 0,
          onGameSelect: _showGamesList,
          onGoToStart: () => _goToMove(-1),
          onPreviousMove: () => _goToMove(currentMoveIndex - 1),
          onNextMove: () => _goToMove(currentMoveIndex + 1),
          onGoToEnd: () => _goToMove(currentGame!.moves.length - 1),
        ),
      );

  // 添加新方法来显示对局列表对话框
  void _showGamesList() => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
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

  Widget _buildContent() {
    if (games.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
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
        ),
      );
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final isWideLayout = orientation == Orientation.landscape || MediaQuery.of(context).size.width > 900;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: isWideLayout
                    ? Row(
                        children: [
                          Expanded(flex: 3, child: _buildBoardSection()),
                          Expanded(flex: 2, child: _buildMoveListSection()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildBoardSection(),
                          Expanded(child: _buildMoveListSection()),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoardSection() => Column(
        children: [
          ChessboardView(
            controller: controller,
            whiteName: currentGame!.white,
            blackName: currentGame!.black,
            event: currentGame!.event,
            date: currentGame!.date,
          ),
          _buildControlPanel(),
        ],
      );

  Widget _buildMoveListSection() => Padding(
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
