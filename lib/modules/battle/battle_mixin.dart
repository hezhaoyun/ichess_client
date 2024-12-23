import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:ichess/widgets/sound_buttons.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:wp_chessboard/wp_chessboard.dart';

import '../../game/config_manager.dart';
import '../../services/audio_service.dart';
import 'promotion_dialog.dart';

enum OnlineState {
  offline,
  joining,
  matching,
  waitingMove,
  waitingOpponent,
  stayInLobby,
}

mixin BattleMixin<T extends StatefulWidget> on State<T> {
  late WPChessboardController controller;
  late chess_lib.Chess chess;
  List<List<int>>? lastMove;

  void setupChessBoard({String initialFen = chess_lib.Chess.DEFAULT_POSITION}) {
    chess = chess_lib.Chess();
    controller = WPChessboardController(
      initialFen: initialFen,
    );
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    showHintFields(square, piece);
  }

  void onPieceTap(SquareInfo square, String piece) {
    AudioService.playSound('sounds/click.mp3');

    if (controller.hints.key == square.index.toString()) {
      controller.setHints(HintMap());
      return;
    }
    showHintFields(square, piece);
  }

  void showHintFields(SquareInfo square, String piece) {
    final moves = chess.generate_moves({'square': square.toString()});
    final hintMap = HintMap(key: square.index.toString());

    for (var move in moves) {
      final position = calculateMovePosition(move.toAlgebraic);
      hintMap.set(
        position.$1,
        position.$2,
        (size) => MoveHint(size: size, onPressed: () => doMove(move)),
      );
    }

    controller.setHints(hintMap);
  }

  (int, int) calculateMovePosition(String algebraicMove) {
    final rank = algebraicMove.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
    final file = algebraicMove.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    return (rank, file);
  }

  void onEmptyFieldTap(SquareInfo square) {
    AudioService.playSound('sounds/fail.mp3');
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) => playerMoved({'from': event.from.toString(), 'to': event.to.toString()});

  void doMove(chess_lib.Move move) => playerMoved({'from': move.fromAlgebraic, 'to': move.toAlgebraic});

  void playerMoved(Map<String, String> move) {
    AudioService.playSound('sounds/move.mp3');

    bool isPromotion = chess.moves({'verbose': true}).any(
        (m) => m['from'] == move['from'] && m['to'] == move['to'] && m['flags'].contains('p'));

    if (!isPromotion) {
      onMove(move);
      return;
    }

    showPromotionDialog(
      context,
      BoardOrientation.white,
      (promotion) => onMove(
        {'from': move['from']!, 'to': move['to']!, 'promotion': promotion},
      ),
    );
  }

  void updateLastMove(String fromSquare, String toSquare) {
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

  // 这个方法需要在子类中实现
  void onMove(Map<String, String> move, {bool byPlayer = true});

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

mixin OnlineBattleMixin<T extends StatefulWidget> on BattleMixin<T> {
  socket_io.Socket? socket;
  OnlineState gameState = OnlineState.offline;
  BoardOrientation orientation = BoardOrientation.white;

  int gameTime = 0;
  int opponentGameTime = 0;

  Map<String, dynamic> player = {'name': '~', 'elo': 0};
  Map<String, dynamic> opponent = {'name': '~', 'elo': 0};

  late String pid, name;

  // 添加标志位
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    socket?.dispose();
    super.dispose();
  }

  // 修改 setState 调用
  void safeSetState(VoidCallback fn) {
    if (_mounted) setState(fn);
  }

  @override
  void setupChessBoard({String initialFen = chess_lib.Chess.DEFAULT_POSITION}) {
    super.setupChessBoard(initialFen: initialFen);

    pid = 'PID_${Random().nextInt(1000000)}';
    name = 'CLIENT_${Random().nextInt(1000000)}';
  }

  void setupSocketIO() {
    final appConfigManager = Provider.of<ConfigManager>(context, listen: false);

    socket = socket_io.io(appConfigManager.serverUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket?.onConnect(onConnect);
    socket?.onDisconnect(onDisconnect);

    socket?.on('waiting_match', onWaitingMatch);
    socket?.on('game_mode', onGameMode);
    socket?.on('move', onSocketMove);
    socket?.on('go', onGo);
    socket?.on('win', onWin);
    socket?.on('lost', onLost);
    socket?.on('draw', onDraw);
    socket?.on('takeback_request', onTakebackRequest);
    socket?.on('takeback_declined', onTakebackDeclined);
    socket?.on('takeback_success', onTakebackSuccess);
    socket?.on('draw_request', onDrawRequest);
    socket?.on('draw_declined', onDrawDeclined);
    socket?.on('game_over', onGameOver);
    socket?.on('timer', onTimer);

    socket?.on('message', (line) => debugPrint(line));
    socket?.onError((err) => debugPrint('Error: $err'));
  }

  onConnect(_) {
    debugPrint('Successful connection!');
    socket?.emit('join', {'pid': pid, 'name': name});
    safeSetState(() => gameState = OnlineState.joining);
  }

  onDisconnect(_) {
    debugPrint('Connection lost.');

    // 使用 safeSetState 替代 setState
    safeSetState(() {
      gameState = OnlineState.offline;
      lastMove = null;
    });

    controller.setFen('');
  }

  onWaitingMatch(data) async {
    debugPrint('Waiting for match...');
    safeSetState(() => gameState = OnlineState.stayInLobby);
  }

  onGameMode(data) {
    debugPrint('Game mode: $data');

    safeSetState(() {
      lastMove = null;
      orientation = data['side'] == 'white' ? BoardOrientation.white : BoardOrientation.black;
      player = data['side'] == 'white' ? data['white_player'] : data['black_player'];
      opponent = data['side'] == 'white' ? data['black_player'] : data['white_player'];
    });

    controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
  }

  onGo(data) {
    debugPrint('Your move');
    safeSetState(() => gameState = OnlineState.waitingMove);
  }

  onTakebackRequest(data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('悔棋'),
        content: Text(data['message']),
        actions: [
          SoundButton.text(
            child: const Text('接受'),
            onPressed: () {
              socket?.emit('takeback_response', {'accepted': true});
              Navigator.pop(context);
            },
          ),
          SoundButton.text(
            child: const Text('拒绝'),
            onPressed: () {
              socket?.emit('takeback_response', {'accepted': false});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  onTakebackDeclined(data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('悔棋被拒绝'),
        actions: [
          SoundButton.text(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  onTakebackSuccess(data) {
    // 撤销最近的两步棋
    chess.undo(); // 撤销 对手/自己 的最后一步
    chess.undo(); // 撤销 自己/对手 的最后一步

    // 清除最后移动的高亮显示
    safeSetState(() => lastMove = null);

    // 更新棋盘显示
    controller.setFen(chess.fen);
  }

  onDrawRequest(data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('求和'),
        content: Text(data['message']),
        actions: [
          SoundButton.text(
            child: const Text('接受'),
            onPressed: () {
              socket?.emit('draw_response', {'accepted': true});
              Navigator.pop(context);
            },
          ),
          SoundButton.text(
            child: const Text('拒绝'),
            onPressed: () {
              socket?.emit('draw_response', {'accepted': false});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  onDrawDeclined(data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('求和被拒绝'),
        actions: [
          SoundButton.text(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  onGameOver(data) {
    debugPrint('Game over: ${data['reason']}');
  }

  onTimer(data) {
    safeSetState(() {
      gameTime = data['mine'];
      opponentGameTime = data['opponent'];
    });
  }

  connect() {
    setupSocketIO();
  }

  disconnect() {
    socket?.dispose();
    safeSetState(() => gameState = OnlineState.offline);
  }

  proposeDraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认求和？'),
        content: const Text('你确定要请求和棋吗？'),
        actions: [
          SoundButton.text(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          SoundButton.text(
            onPressed: () {
              socket?.emit('propose_draw', {});
              Navigator.pop(context);
            },
            child: const Text('是'),
          ),
        ],
      ),
    );
  }

  proposeTakeback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认悔棋？'),
        content: const Text('你确定要请求悔棋吗？'),
        actions: [
          SoundButton.text(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          SoundButton.text(
            onPressed: () {
              socket?.emit('propose_takeback', {});
              Navigator.pop(context);
            },
            child: const Text('是'),
          ),
        ],
      ),
    );
  }

  resign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认投降？'),
        content: const Text('你确定要投降吗？'),
        actions: [
          SoundButton.text(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          SoundButton.text(
            onPressed: () {
              socket?.emit('resign', {});
              Navigator.pop(context);
            },
            child: const Text('是'),
          ),
        ],
      ),
    );
  }

  match() {
    safeSetState(() {
      gameState = OnlineState.matching;
      lastMove = null;
    });

    controller.setFen('');

    socket?.emit('match', {});
  }

  void onSocketMove(dynamic data) {
    if (data is! Map) return;

    final move = data['move'] as String;
    final from = move.substring(0, 2);
    final to = move.substring(2, 4);
    final promotion = move.length > 4 ? move.substring(4) : null;

    onMove({'from': from, 'to': to, if (promotion != null) 'promotion': promotion}, byPlayer: false);
  }

  @override
  void onMove(Map<String, String> move, {bool byPlayer = true}) {
    chess.move(move);
    updateLastMove(move['from']!, move['to']!);
    controller.setFen(chess.fen);

    if (byPlayer) {
      socket?.emit(
        'move',
        {'move': "${move['from']}${move['to']}${move['promotion'] ?? ''}"},
      );

      safeSetState(() => gameState = OnlineState.waitingOpponent);
    }
  }

  onWin(data);

  onLost(data);

  onDraw(data);
}
