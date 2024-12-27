import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:ichess/modules/battle/reason_defines.dart';
import 'package:ichess/widgets/sound_buttons.dart';
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../widgets/chess_board_widget.dart';
import 'battle_mixin.dart';
import '../../widgets/game_result_dialog.dart';

class OnlineBattlePage extends StatefulWidget {
  const OnlineBattlePage({super.key});

  @override
  State<OnlineBattlePage> createState() => _HomePageState();
}

class _HomePageState extends State<OnlineBattlePage> with BattleMixin, OnlineBattleMixin {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SoundButton.icon(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              '在线对战',
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
          ],
        ),
      );

  Widget _buildMainContent() {
    if (gameState == OnlineState.offline) {
      return _buildIdleState();
    }

    if (gameState == OnlineState.joining || gameState == OnlineState.matching) {
      return _buildWaitingState();
    }

    return _buildGameState();
  }

  Widget _buildIdleState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports,
              size: 120,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '开始在线对战',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '连接服务器开始你的对战之旅',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            SoundButton.iconElevated(
              onPressed: connect,
              icon: const Icon(Icons.wifi),
              label: const Text('开始游戏'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
            Text('正在寻找对手...', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SoundButton.elevated(
              onPressed: disconnect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('退出连线'),
            ),
          ],
        ),
      );

  Widget _buildGameState() {
    final double size = MediaQuery.of(context).size.shortestSide - 36;
    final orientationColor = orientation == BoardOrientation.white ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;
    final interactiveEnable = gameState == OnlineState.waitingMove && chess.turn == orientationColor;

    return Column(
      children: [
        _buildPlayerInfo(
          name: opponent['name'],
          elo: opponent['elo'],
          time: opponentGameTime.toString(),
          isOpponent: true,
        ),
        const SizedBox(height: 10),
        ChessBoardWidget(
          size: size,
          orientation: orientation,
          controller: controller,
          getLastMove: () => lastMove,
          interactiveEnable: interactiveEnable,
          onPieceDrop: onPieceDrop,
          onPieceTap: onPieceTap,
          onPieceStartDrag: onPieceStartDrag,
          onEmptyFieldTap: onEmptyFieldTap,
        ),
        const SizedBox(height: 10),
        _buildPlayerInfo(
          name: player['name'],
          elo: player['elo'],
          time: gameTime.toString(),
          isOpponent: false,
        ),
        const SizedBox(height: 20),
        _buildGameControls(),
      ],
    );
  }

  Widget _buildPlayerInfo(
      {required String name, required dynamic elo, required String time, required bool isOpponent}) {
    // 获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;
    // 设置一个阈值，比如 700
    final bool isCompactMode = screenHeight < 700;

    if (isCompactMode) {
      // 紧凑模式 - 单行显示
      return Container(
        width: MediaQuery.of(context).size.shortestSide - 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // 头像
            CircleAvatar(
              radius: 16,
              backgroundColor: isOpponent ? Colors.red.shade100 : Colors.blue.shade100,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOpponent ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 名称
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // ELO信息
            _buildInfoChip(
              icon: Icons.emoji_events_outlined,
              label: 'ELO: $elo',
            ),
            const SizedBox(width: 8),
            // 时间信息
            _buildInfoChip(
              icon: Icons.timer_outlined,
              label: time,
            ),
          ],
        ),
      );
    }

    // 原有的卡片式布局代码
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
                      label: 'ELO: $elo',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.timer_outlined,
                      label: time,
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
        if (gameState == OnlineState.offline)
          SoundButton.elevated(
            style: buttonStyle,
            onPressed: connect,
            child: const Text('连接'),
          ),
        if (gameState == OnlineState.stayInLobby)
          SoundButton.elevated(
            style: buttonStyle,
            onPressed: match,
            child: const Text('匹配'),
          ),
        if (gameState == OnlineState.waitingMove)
          SoundButton.elevated(
            style: buttonStyle,
            onPressed: proposeDraw,
            child: const Text('求和'),
          ),
        if (gameState == OnlineState.waitingMove)
          SoundButton.elevated(
            style: buttonStyle,
            onPressed: chess.move_number >= 2 ? proposeTakeback : null,
            child: const Text('悔棋'),
          ),
        if (gameState == OnlineState.waitingMove)
          SoundButton.elevated(
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.orange),
            ),
            onPressed: resign,
            child: const Text('投降'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    disconnect();
  }

  @override
  onWin(data) {
    debugPrint('You won: ${data['reason']}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: '你赢了！',
        message: Reasons.winOf(data['reason']),
        result: GameResult.win,
      ),
    );
  }

  @override
  onLost(data) {
    debugPrint('You lost: ${data['reason']}');

    setState(() => gameState = OnlineState.stayInLobby);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: '你输了！',
        message: Reasons.loseOf(data['reason']),
        result: GameResult.lose,
      ),
    );
  }

  @override
  onDraw(data) {
    debugPrint('Draw: ${data['reason']}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        title: '和棋！',
        message: Reasons.drawOf(data['reason']),
        result: GameResult.draw,
      ),
    );
  }
}
