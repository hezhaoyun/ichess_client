import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess_lib;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ichess/widgets/sound_buttons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../game/config_manager.dart';
import '../../services/ai_native.dart';
import '../../services/audio_service.dart';
import '../../widgets/chess_board_widget.dart';
import '../../widgets/game_result_dialog.dart';
import 'battle_mixin.dart';

class AIBattlePage extends StatefulWidget {
  final String? initialFen;
  const AIBattlePage({super.key, this.initialFen});

  @override
  State<AIBattlePage> createState() => _AIBattlePageState();
}

class _AIBattlePageState extends State<AIBattlePage> with BattleMixin {
  static const String _gameStateKey = 'ai_battle_game_state';

  String? initialFen;
  bool isThinking = false;
  bool _isEngineReady = false;
  List<String> moves = [];
  int? evaluation;
  BoardOrientation boardOrientation = BoardOrientation.white;
  bool isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    initialFen = widget.initialFen;

    setupChessBoard();

    if (initialFen != null) {
      chess.load(initialFen!);
      controller.setFen(initialFen!);
    } else {
      _restoreGameState();
    }

    setupStockfishEngine();
  }

  Future<void> setupStockfishEngine() async {
    final configManager = Provider.of<ConfigManager>(context, listen: false);

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        AiNative.instance.setEnginePath(configManager.enginePath);
      }

      await AiNative.instance.initialize();

      AiNative.instance.setSkillLevel(configManager.engineLevel);
      if (configManager.useTimeControl) {
        AiNative.instance.setMoveTime(configManager.moveTime);
      } else {
        AiNative.instance.setSearchDepth(configManager.searchDepth);
      }

      setState(() => _isEngineReady = true);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Engine initialization failed!')),
          );
        }
        debugPrint('Engine initialization failed: ${e.toString()}');
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

        controller.setFen(chess.fen);
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
  void dispose() {
    _saveGameState();
    super.dispose();
  }

  @override
  void onMove(Map<String, String> move, {bool byPlayer = true}) {
    if (!_isEngineReady) return;

    updateLastMove(move['from']!, move['to']!);
    moves.add('${move['from']}${move['to']}');

    chess.move(move);
    controller.setFen(chess.fen);

    if (!chess.game_over) {
      if (byPlayer) makeComputerMove();
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
      return chess.turn == chess_lib.Color.WHITE ? 'You lost!' : 'You won!';
    }
    return 'Draw!';
  }

  String _getResultMessage() {
    if (chess.in_checkmate) {
      return chess.turn == chess_lib.Color.WHITE
          ? 'Don’t be discouraged, keep trying!'
          : 'Congratulations on defeating your opponent!';
    }
    if (chess.in_stalemate) {
      return chess.turn == chess_lib.Color.WHITE
          ? 'Don’t be discouraged, keep trying!'
          : 'Congratulations on defeating your opponent!';
    }
    if (chess.insufficient_material) return 'Insufficient material, draw';
    if (chess.in_threefold_repetition) return 'Threefold repetition, draw';
    return 'Draw';
  }

  Future<void> makeComputerMove() async {
    setState(() => isThinking = true);
    controller.setArrows([]);

    try {
      final stockfish = AiNative.instance;
      final configManager = Provider.of<ConfigManager>(context, listen: false);
      final showArrows = configManager.showArrows;

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
                    const SnackBar(content: Text('Engine cannot find a valid move')),
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
          AudioService.playSound('sounds/promotion.mp3');
        } else {
          AudioService.playSound('sounds/move.mp3');
        }

        onMove(moveMap, byPlayer: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Engine move error, please try again')),
        );
        debugPrint('Engine move error: ${e.toString()}');
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
    final depthMatch = RegExp(r'depth (\d+)').firstMatch(line);
    if (depthMatch != null && int.parse(depthMatch.group(1)!) < 8) return;

    final scoreMatch = RegExp(r'score cp (-?\d+)').firstMatch(line);
    if (scoreMatch != null) {
      setState(() => evaluation = -1 * int.parse(scoreMatch.group(1)!));
    }

    final pvMatch = RegExp(r'\spv (.+)$').firstMatch(line);
    if (pvMatch != null) {
      final pvs = pvMatch.group(1)!.split(' ');
      final configManager = Provider.of<ConfigManager>(context, listen: false);

      if (pvs.isNotEmpty && configManager.showArrows) {
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
        title: const Text('Choose your color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.circle, color: Colors.white, size: 24, shadows: [
                Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 4),
              ]),
              title: const Text('White'),
              onTap: () {
                Navigator.pop(context);
                _startNewGame(BoardOrientation.white);
              },
            ),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.black, size: 24, shadows: [
                Shadow(color: Theme.of(context).colorScheme.primary, blurRadius: 4),
              ]),
              title: const Text('Black'),
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
    if (moves.length >= 2) {
      setState(() {
        lastMove = null;
        controller.setArrows([]);
        chess.undo();
        chess.undo();
        moves.removeLast();
        moves.removeLast();
        controller.setFen(chess.fen);
      });
    }
  }

  Future<void> saveGame() async {
    try {
      // Choose save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Choose save location',
        fileName: 'chess_game_${DateTime.now().millisecondsSinceEpoch}.pgn',
        type: FileType.custom,
        allowedExtensions: ['pgn'],
      );

      if (outputFile == null) {
        // User canceled saving
        return;
      }

      final now = DateTime.now();
      final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

      // Create PGN content
      final pgn = [
        '[Event "AI Chess Game"]',
        '[Site "Your App"]',
        '[Date "$dateStr"]',
        '[Round "1"]',
        '[White "Player"]',
        '[Black "Computer"]',
        '[Result "${_getPgnResult()}"]',
        '',
        _generateMovesText(),
      ].join('\n');

      final file = File(outputFile);
      await file.writeAsString(pgn);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed, please try again')),
        );
      }
      debugPrint('Save failed: $e');
    }
  }

  // Get game result
  String _getPgnResult() {
    if (!chess.game_over) return "*";

    if (chess.in_checkmate) {
      return chess.turn == chess_lib.Color.WHITE ? "0-1" : "1-0";
    }

    if (chess.in_draw || chess.in_stalemate) return "1/2-1/2";

    return "*";
  }

  // Generate standard move record
  String _generateMovesText() => chess.san_moves().join(' ');

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
          const SnackBar(content: Text('Analysis failed, please try again')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide - 48;

    return Scaffold(
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SoundButton.icon(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'AI Battle',
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
                    SoundButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      onPressed: saveGame,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayerInfo(isOpponent: true),
                    const SizedBox(height: 10),
                    ChessBoardWidget(
                      size: size,
                      controller: controller,
                      orientation: boardOrientation,
                      interactiveEnable: !isThinking,
                      getLastMove: () => lastMove,
                      onPieceDrop: onPieceDrop,
                      onPieceTap: onPieceTap,
                      onPieceStartDrag: onPieceStartDrag,
                      onEmptyFieldTap: onEmptyFieldTap,
                    ),
                    const SizedBox(height: 10),
                    _buildPlayerInfo(isOpponent: false),
                    const SizedBox(height: 20),
                    _buildGameControls(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo({required bool isOpponent}) {
    // Get screen height
    final screenHeight = MediaQuery.of(context).size.height;
    // Set a threshold, e.g. 700
    final bool isCompactMode = screenHeight < 700;

    if (isCompactMode) {
      // Compact mode - single line display
      return Container(
        width: MediaQuery.of(context).size.shortestSide - 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Avatar part
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isOpponent && isThinking)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red.shade300,
                      ),
                    ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isOpponent ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Text(
                      isOpponent ? 'AI' : 'You',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Text(
              isOpponent ? 'Computer' : 'Player',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // ELO information
            _buildInfoChip(
              icon: Icons.emoji_events_outlined,
              label: 'ELO: ${isOpponent ? '2000' : '1500'}',
            ),
            if (isOpponent && evaluation != null) ...[
              const SizedBox(width: 8),
              Text(
                'Evaluation: ${evaluation!}',
                style: TextStyle(
                  color: evaluation! > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Original card layout code
    return Container(
      width: MediaQuery.of(context).size.shortestSide - 36,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpponent ? [Colors.red.shade50, Colors.red.shade100] : [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0x1A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red.shade300,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOpponent ? Colors.red.shade300 : Colors.blue.shade300,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      isOpponent ? 'AI' : 'You',
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
                  isOpponent ? 'Computer' : 'Player',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.emoji_events_outlined,
                      label: 'ELO: ${isOpponent ? '2000' : '1500'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(0xCC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGameControls() {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        SoundButton.elevated(style: buttonStyle, onPressed: newGame, child: const Text('New Game')),
        SoundButton.elevated(style: buttonStyle, onPressed: undoMove, child: const Text('Undo')),
        if (!isThinking && chess.turn == chess_lib.Color.WHITE && !chess.game_over)
          SoundButton.iconElevated(
            style: buttonStyle,
            onPressed: isAnalyzing ? null : analyzePosition,
            icon: isAnalyzing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.lightbulb_outline),
            label: Text(isAnalyzing ? 'Analyzing...' : 'Hint'),
          ),
      ],
    );
  }
}
