import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ichess/modules/battle/reason_defines.dart';
import 'package:ichess/widgets/sound_buttons.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/bottom_bar_button.dart';
import '../../widgets/chess_board_widget.dart';
import '../../widgets/game_result_dialog.dart';
import 'battle_mixin.dart';

class OnlineBattlePage extends ConsumerStatefulWidget {
  const OnlineBattlePage({super.key});

  @override
  ConsumerState<OnlineBattlePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<OnlineBattlePage> with BattleMixin, OnlineBattleMixin {
  @override
  void initState() {
    super.initState();
    setupChessBoard(initialFen: '');
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(
                    buttons: w > h
                        ? [
                            if (gameState == OnlineState.offline)
                              IconButton(
                                onPressed: connect,
                                icon: const Icon(Icons.wifi),
                                tooltip: AppLocalizations.of(context)!.connect,
                              ),
                            if (gameState == OnlineState.stayInLobby)
                              IconButton(
                                onPressed: match,
                                icon: const Icon(Icons.join_inner),
                                tooltip: AppLocalizations.of(context)!.match,
                              ),
                            if (gameState == OnlineState.waitingMove)
                              IconButton(
                                onPressed: proposeDraw,
                                icon: const Icon(Icons.handshake),
                                tooltip: AppLocalizations.of(context)!.proposeDraw,
                              ),
                            if (gameState == OnlineState.waitingMove)
                              IconButton(
                                onPressed: chess.move_number >= 2 ? proposeTakeback : null,
                                icon: const Icon(Icons.undo),
                                tooltip: AppLocalizations.of(context)!.takeBack,
                              ),
                            if (gameState == OnlineState.waitingMove)
                              IconButton(
                                onPressed: resign,
                                icon: const Icon(Icons.pan_tool),
                                tooltip: AppLocalizations.of(context)!.resign,
                              ),
                          ]
                        : null,
                  ),
                  Expanded(child: _buildMainContent(w, h)),
                ],
              );
            }),
          ),
        ),
      );

  Widget _buildHeader({List<Widget>? buttons}) => SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.playOnline,
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
            ],
          ),
        ),
      );

  Widget _buildMainContent(double w, double h) {
    if (gameState == OnlineState.offline) return _buildIdleState();
    if (gameState == OnlineState.joining || gameState == OnlineState.matching) return _buildWaitingState();
    return w > h ? _buildLandscapeLayout(w, h) : _buildPortraitLayout(w, h);
  }

  Widget _buildIdleState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withAlpha(0x88),
            ),
            Text(
              AppLocalizations.of(context)!.timeControl,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 10),
            _buildTimeControlSelector(),
            const SizedBox(height: 20),
            SoundButton.iconElevated(
              onPressed: connect,
              icon: const Icon(Icons.wifi, size: 12),
              label: Text(AppLocalizations.of(context)!.connect),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      );

  Widget _buildWaitingState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.searchingForAnOpponent, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SoundButton.elevated(
              onPressed: disconnect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      );

  Widget _buildPlayerInfo(
          {required String name, required dynamic elo, required String time, required bool isOpponent}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
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
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(icon: Icons.emoji_events_outlined, label: 'ELO: $elo'),
                      const SizedBox(width: 8),
                      _buildInfoChip(icon: Icons.timer_outlined, label: time),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildInfoChip({required IconData icon, required String label}) => Container(
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

  Widget _buildBottomBar() => BottomBar(children: [
        if (gameState == OnlineState.offline)
          BottomBarButton(
            icon: Icons.wifi,
            onTap: connect,
            label: AppLocalizations.of(context)!.connect,
          ),
        if (gameState == OnlineState.stayInLobby)
          BottomBarButton(
            icon: Icons.join_inner,
            onTap: match,
            label: AppLocalizations.of(context)!.match,
          ),
        if (gameState == OnlineState.waitingMove)
          BottomBarButton(
            icon: Icons.handshake,
            onTap: proposeDraw,
            label: AppLocalizations.of(context)!.proposeDraw,
          ),
        if (gameState == OnlineState.waitingMove)
          BottomBarButton(
            icon: Icons.undo,
            onTap: proposeTakeback,
            label: AppLocalizations.of(context)!.takeBack,
          ),
        if (gameState == OnlineState.waitingMove)
          BottomBarButton(
            icon: Icons.pan_tool,
            onTap: resign,
            label: AppLocalizations.of(context)!.resign,
          ),
      ]);

  @override
  void dispose() {
    super.dispose();
    disconnect();
  }

  @override
  onWin(data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: AppLocalizations.of(context)!.youWon,
        message: Reasons(context).winReason(data['reason']),
        result: GameResult.win,
      ),
    );
  }

  @override
  onLost(data) {
    setState(() => gameState = OnlineState.stayInLobby);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: AppLocalizations.of(context)!.youLost,
        message: Reasons(context).loseReason(data['reason']),
        result: GameResult.lose,
      ),
    );
  }

  @override
  onDraw(data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: AppLocalizations.of(context)!.draw,
        message: Reasons(context).drawReason(data['reason']),
        result: GameResult.draw,
      ),
    );
  }

  Widget _buildLandscapeLayout(double w, double h) {
    final availableHeight = h - kToolbarHeight - 20;
    final boardSize = min(w - 350 - 10, availableHeight) - 20;
    final controlWidth = w - boardSize;

    return Column(
      children: [
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
                    SizedBox(
                      height: 90,
                      width: controlWidth,
                      child: _buildPlayerInfo(
                        name: opponent['name'],
                        elo: opponent['elo'],
                        time: opponentGameTime.toString(),
                        isOpponent: true,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 90,
                      width: controlWidth,
                      child: _buildPlayerInfo(
                        name: player['name'],
                        elo: player['elo'],
                        time: gameTime.toString(),
                        isOpponent: false,
                      ),
                    ),
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
    final availableHeight = h - kToolbarHeight * 2 - 210;
    final boardSize = min(w, availableHeight) - 20;

    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          width: boardSize,
          child: _buildPlayerInfo(
            name: opponent['name'],
            elo: opponent['elo'],
            time: opponentGameTime.toString(),
            isOpponent: true,
          ),
        ),
        const SizedBox(height: 10),
        _buildBoard(boardSize),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          width: boardSize,
          child: _buildPlayerInfo(
            name: player['name'],
            elo: player['elo'],
            time: gameTime.toString(),
            isOpponent: false,
          ),
        ),
        const Spacer(),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildBoard(double boardSize) => ChessBoardWidget(
        size: boardSize,
        controller: controller,
        orientation: orientation,
        interactiveEnable: interactiveEnable,
        getLastMove: () => lastMove,
        onPieceDrop: onPieceDrop,
        onPieceTap: onPieceTap,
        onPieceStartDrag: onPieceStartDrag,
        onEmptyFieldTap: onEmptyFieldTap,
      );

  bool get interactiveEnable {
    final orientationColor = orientation == BoardOrientation.white ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;
    return gameState == OnlineState.waitingMove && chess.turn == orientationColor;
  }

  Widget _buildTimeControlSelector() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoSegmentedControl<TimeControl>(
          children: {
            for (var control in TimeControl.values)
              control: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  control.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedTimeControl == control
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          },
          groupValue: selectedTimeControl,
          onValueChanged: (TimeControl value) {
            setState(() => selectedTimeControl = value);
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          unselectedColor: Theme.of(context).colorScheme.surface,
          borderColor: Theme.of(context).colorScheme.primary,
        ),
      );
}
