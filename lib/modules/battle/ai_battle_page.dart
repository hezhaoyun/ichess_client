import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../model/config_manager.dart';
import '../../services/ai_native.dart';
import '../../services/audios.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/bottom_bar_button.dart';
import '../../widgets/chess_board_widget.dart';
import '../../widgets/game_result_dialog.dart';
import 'battle_mixin.dart';

class AIBattlePage extends ConsumerStatefulWidget {
  final String? initialFen;
  const AIBattlePage({super.key, this.initialFen});

  @override
  ConsumerState<AIBattlePage> createState() => _AIBattlePageState();
}

class _AIBattlePageState extends ConsumerState<AIBattlePage> with BattleMixin {
  static const String _gameStateKey = 'ai_battle_game_state';

  String? initialFen;
  bool isThinking = false;
  bool _isEngineReady = false;
  List<String> moves = [];
  int? evaluation;
  BoardOrientation boardOrientation = BoardOrientation.white;
  bool isAnalyzing = false;
  int currentMoveIndex = -1;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    initialFen = widget.initialFen;

    setupChessBoard();

    if (initialFen != null) {
      chess.load(initialFen!);
      controller.setFen(initialFen!);

      // before call ref.watch, we need to wait for mounted of current context
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      await _restoreGameState();
    }

    await setupStockfishEngine();
  }

  Future<void> setupStockfishEngine() async {
    final config = ref.watch(configManagerProvider);

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        AiNative.instance.setEnginePath(config.enginePath);
      }

      await AiNative.instance.initialize();

      AiNative.instance.setSkillLevel(config.engineLevel);
      if (config.useTimeControl) {
        AiNative.instance.setMoveTime(config.moveTime);
      } else {
        AiNative.instance.setSearchDepth(config.searchDepth);
      }

      setState(() => _isEngineReady = true);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.engineInitializationFailed)),
          );
        }
      });
    }
  }

  Future<void> _restoreGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStateJson = prefs.getString(_gameStateKey);

    if (savedStateJson != null) {
      final savedState = json.decode(savedStateJson);

      setState(() {
        // Load saved initial state
        initialFen = savedState['initialFen'];
        if (initialFen != null) {
          chess.load(initialFen!);
        } else {
          chess.reset();
        }

        // Replay all historical moves
        final List<String> historicalMoves = List<String>.from(savedState['moves']);
        for (String move in historicalMoves) {
          final moveMap = {
            'from': move.substring(0, 2),
            'to': move.substring(2, 4),
            if (move.length > 4) 'promotion': move[4],
          };
          chess.move(moveMap);
        }

        controller.setFen(chess.fen, animation: false);
        moves = historicalMoves;

        if (savedState['lastMove'] != null) {
          lastMove = List<List<int>>.from(savedState['lastMove'].map((move) => List<int>.from(move)));
        }
      });
    }
  }

  Future<void> _saveGameState() async {
    if (chess.game_over) {
      await _clearGameState();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedState = {
      'initialFen': initialFen ?? chess_lib.Chess.DEFAULT_POSITION,
      'moves': moves,
      'lastMove': lastMove,
    };

    await prefs.setString(_gameStateKey, json.encode(savedState));
  }

  Future<void> _clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }

  @override
  String genManual(String dateStr) => [
        '[Event "AI Chess Game"]',
        '[Site "Your App"]',
        '[Date "$dateStr"]',
        '[Round "1"]',
        '[White "Player"]',
        '[Black "Computer"]',
        '[Result "${getPgnResult()}"]',
        '',
        generateMovesText(),
      ].join('\n');

  @override
  void onMove(Map<String, String> move, {bool triggerOpponent = false, bool byDrag = false}) {
    if (!_isEngineReady) return;

    updateLastMove(move['from']!, move['to']!);

    if (currentMoveIndex < moves.length - 1) {
      moves.removeRange(currentMoveIndex + 1, moves.length);
    }

    moves.add('${move['from']}${move['to']}${move['promotion'] ?? ''}');
    currentMoveIndex++;

    chess.move(move);
    controller.setFen(chess.fen, animation: !byDrag);

    if (!chess.game_over) {
      if (triggerOpponent) makeComputerMove();
      return;
    }

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

  Future<void> makeComputerMove() async {
    setState(() => isThinking = true);
    controller.setArrows([]);

    try {
      final stockfish = AiNative.instance;
      final config = ref.watch(configManagerProvider);
      final showArrows = config.showArrows;

      stockfish.sendCommand(
        'position fen ${chess.fen} moves ${moves.join(' ')}',
      );
      stockfish.sendCommand(stockfish.getGoCommand());

      String? bestMove;
      String? ponderMove;
      await for (final output in stockfish.stdout) {
        for (final line in output.split('\n')) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) continue;

          if (trimmedLine.startsWith('info')) {
            _parseInfoLine(trimmedLine);
            continue;
          }

          if (trimmedLine.startsWith('bestmove')) {
            final parts = trimmedLine.split(' ');
            if (parts.length >= 2) {
              final move = parts[1];
              if (move == '(none)' || move == 'NULL') {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.engineCannotFindValidMove)),
                  );
                }
                break;
              }
              bestMove = move;

              if (parts.length >= 4 && parts[2] == 'ponder') {
                ponderMove = parts[3];
              }
            }
            break;
          }
        }

        if (bestMove != null) break;
      }

      if (bestMove != null && bestMove.isNotEmpty) {
        if (mounted) {
          setState(() {
            List<Arrow> arrows = [];
            if (showArrows) {
              arrows.add(_createArrow(bestMove!, Colors.blue.withAlpha(0x7F)));

              if (ponderMove != null) {
                arrows.add(_createArrow(ponderMove, Colors.red.withAlpha(0x7F)));
              }
            }

            controller.setArrows(arrows);
          });
        }

        final moveMap = {'from': bestMove.substring(0, 2), 'to': bestMove.substring(2, 4)};

        if (bestMove.length > 4) {
          moveMap['promotion'] = bestMove[4];
          Audios().playSound('sounds/promotion.mp3');
        } else {
          Audios().playSound('sounds/move.mp3');
        }

        onMove(moveMap);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.engineMoveError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isThinking = false;
          // controller.setArrows([]);
          // evaluation = null;
        });
      }
    }
  }

  void _parseInfoLine(String line) {
    final config = ref.watch(configManagerProvider);

    final depthMatch = RegExp(r'depth (\d+)').firstMatch(line);
    if (depthMatch != null && int.parse(depthMatch.group(1)!) < 8) return;

    final scoreMatch = RegExp(r'score cp (-?\d+)').firstMatch(line);
    if (scoreMatch != null) {
      setState(() => evaluation = -1 * int.parse(scoreMatch.group(1)!));
    }

    final pvMatch = RegExp(r'\spv (.+)$').firstMatch(line);
    if (pvMatch != null) {
      final pvs = pvMatch.group(1)!.split(' ');

      if (pvs.isNotEmpty && config.showArrows) {
        setState(() {
          List<Arrow> arrows = [];
          final engineMove = pvs[0];
          arrows.add(_createArrow(engineMove, Colors.blue.withAlpha(0x7F)));

          if (pvs.length >= 2) {
            final opponentMove = pvs[1];
            arrows.add(_createArrow(opponentMove, Colors.red.withAlpha(0x7F)));
          }

          controller.setArrows(arrows);
        });
      }
    }
  }

  Arrow _createArrow(String move, Color color) {
    final fromSquare = move.substring(0, 2);
    final toSquare = move.substring(2, 4);

    int rankFrom = fromSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileFrom = fromSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    int rankTo = toSquare.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    int fileTo = toSquare.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;

    return Arrow(
      from: SquareLocation(rankFrom, fileFrom),
      to: SquareLocation(rankTo, fileTo),
      color: color,
    );
  }

  void newGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseYourColor),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.circle, color: Colors.white, size: 24, shadows: [
                Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 4),
              ]),
              title: Text(AppLocalizations.of(context)!.white),
              onTap: () {
                Navigator.pop(context);
                _startNewGame(BoardOrientation.white);
              },
            ),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.black, size: 24, shadows: [
                Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 4),
              ]),
              title: Text(AppLocalizations.of(context)!.black),
              onTap: () {
                Navigator.pop(context);
                _startNewGame(BoardOrientation.black);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startNewGame(BoardOrientation orientation) {
    _clearGameState();

    setState(() {
      boardOrientation = orientation;
      chess.reset();
      controller.setFen(chess_lib.Chess.DEFAULT_POSITION);

      moves.clear();
      currentMoveIndex = -1;
      initialFen = null;
      evaluation = null;
      controller.setArrows([]);
      lastMove = null;

      // If selected black, let the computer go first
      if (orientation == BoardOrientation.black) {
        makeComputerMove();
      }
    });
  }

  void undoMove() {
    if (moves.length >= 2 && currentMoveIndex >= 1) {
      setState(() {
        lastMove = null;
        controller.setArrows([]);
        chess.undo();
        chess.undo();
        currentMoveIndex -= 2;
        controller.setFen(chess.fen);
      });
    }
  }

  void redoMove() {
    if (currentMoveIndex < moves.length - 2) {
      setState(() {
        for (int i = 0; i < 2; i++) {
          final moveStr = moves[currentMoveIndex + 1 + i];

          final move = {
            'from': moveStr.substring(0, 2),
            'to': moveStr.substring(2, 4),
            if (moveStr.length > 4) 'promotion': moveStr[4],
          };
          chess.move(move);

          if (i == 1) updateLastMove(move['from']!, move['to']!);
        }
        currentMoveIndex += 2;
        controller.setFen(chess.fen);
      });
    }
  }

  Future<void> analyzePosition() async {
    if (!_isEngineReady || isThinking || isAnalyzing) return;

    setState(() => isAnalyzing = true);
    controller.setArrows([]);

    try {
      final stockfish = AiNative.instance;
      stockfish.sendCommand(
        'position fen ${chess.fen} moves ${moves.join(' ')}',
      );
      stockfish.sendCommand(stockfish.getGoCommand());

      String? bestMove;
      String? ponderMove;
      await for (final output in stockfish.stdout) {
        for (final line in output.split('\n')) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) continue;

          if (trimmedLine.startsWith('info')) {
            _parseInfoLine(trimmedLine);
            continue;
          }

          if (trimmedLine.startsWith('bestmove')) {
            final parts = trimmedLine.split(' ');
            if (parts.length >= 2) {
              bestMove = parts[1];
              if (parts.length >= 4 && parts[2] == 'ponder') {
                ponderMove = parts[3];
              }
            }
            break;
          }
        }

        if (bestMove != null) break;
      }

      if (bestMove != null && mounted) {
        setState(() {
          List<Arrow> arrows = [];
          arrows.add(_createArrow(bestMove!, Colors.green.withAlpha(0x7F)));

          if (ponderMove != null) {
            arrows.add(_createArrow(ponderMove, Colors.red.withAlpha(0x7F)));
          }

          controller.setArrows(arrows);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.analysisFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isAnalyzing = false);
      }
    }
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
        _buildHeader(
          buttons: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: newGame,
              tooltip: AppLocalizations.of(context)!.newGame,
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: moves.length >= 2 && currentMoveIndex >= 1 ? undoMove : null,
              tooltip: AppLocalizations.of(context)!.undo,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: currentMoveIndex < moves.length - 2 ? redoMove : null,
              tooltip: AppLocalizations.of(context)!.redo,
            ),
            if (!isThinking && chess.turn == chess_lib.Color.WHITE && !chess.game_over)
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: isAnalyzing ? null : analyzePosition,
                tooltip: AppLocalizations.of(context)!.hint,
              ),
          ],
        ),
        const Spacer(),
        SizedBox(
          height: boardSize,
          child: Row(
            children: [
              const SizedBox(width: 10),
              _buildBoard(boardSize),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 90, width: controlWidth, child: _buildPlayerInfo(isOpponent: true)),
                    const Spacer(),
                    SizedBox(height: 90, width: controlWidth, child: _buildPlayerInfo(isOpponent: false)),
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
    final availableHeight = h - kToolbarHeight * 2 - 210; // 10 + 90 + 10 + 10 + 90
    final boardSize = min(w, availableHeight) - 20;

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 10),
        SizedBox(height: 90, width: boardSize, child: _buildPlayerInfo(isOpponent: true)),
        const SizedBox(height: 10),
        _buildBoard(boardSize),
        const SizedBox(height: 10),
        SizedBox(height: 90, width: boardSize, child: _buildPlayerInfo(isOpponent: false)),
        const Spacer(),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBoard(double boardSize) => ChessBoardWidget(
        size: boardSize,
        controller: controller,
        orientation: boardOrientation,
        interactiveEnable: !isThinking,
        getLastMove: () => lastMove,
        onPieceDrop: onPieceDrop,
        onPieceTap: onPieceTap,
        onPieceStartDrag: onPieceStartDrag,
        onEmptyFieldTap: onEmptyFieldTap,
      );

  Widget _buildHeader({List<Widget>? buttons}) => SizedBox(
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
                  AppLocalizations.of(context)!.humanVsAi,
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
              ...?buttons,
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: saveGame,
                tooltip: AppLocalizations.of(context)!.save,
              ),
            ],
          ),
        ),
      );

  Widget _buildPlayerInfo({required bool isOpponent}) {
    final score = evaluation != null ? evaluation! * (isOpponent ? -1 : 1) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isOpponent && isThinking)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red.shade300),
                  ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isOpponent ? Colors.red.shade300 : Colors.blue.shade300, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      isOpponent ? AppLocalizations.of(context)!.ai : AppLocalizations.of(context)!.you,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpponent ? AppLocalizations.of(context)!.computer : AppLocalizations.of(context)!.player,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildLevelChip(label: isOpponent ? '2000' : '1500'),
                    if (score != null) ...[
                      const SizedBox(width: 8),
                      _buildScoreChip(score),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelChip({required String label}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0xCC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );

  Widget _buildScoreChip(int score) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(0xCC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.scoreboard_outlined, size: 14),
            const SizedBox(width: 4),
            Text(
              '$score',
              style: TextStyle(
                color: score > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  Widget _buildBottomBar() => BottomBar(
        children: [
          BottomBarButton(
            icon: Icons.restart_alt,
            onTap: newGame,
            label: AppLocalizations.of(context)!.newGame,
          ),
          BottomBarButton(
            icon: Icons.undo,
            onTap: moves.length >= 2 && currentMoveIndex >= 1 ? undoMove : null,
            label: AppLocalizations.of(context)!.undo,
          ),
          BottomBarButton(
            icon: Icons.redo,
            onTap: currentMoveIndex < moves.length - 2 ? redoMove : null,
            label: AppLocalizations.of(context)!.redo,
          ),
          if (!isThinking && chess.turn == chess_lib.Color.WHITE && !chess.game_over)
            BottomBarButton(
              icon: Icons.lightbulb_outline,
              onTap: isAnalyzing ? null : analyzePosition,
              label: isAnalyzing ? AppLocalizations.of(context)!.analyzing : AppLocalizations.of(context)!.hint,
            ),
        ],
      );

  @override
  void dispose() {
    _saveGameState();
    super.dispose();
  }
}
