import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:wp_chessboard/wp_chessboard.dart';

import 'chess_battle_mixin.dart';

mixin OnlineBattleMixin<T extends StatefulWidget> on ChessBattleMixin<T> {
  socket_io.Socket? socket;
  GameState gameState = GameState.idle;
  BoardOrientation orientation = BoardOrientation.white;

  int gameTime = 0;
  int opponentGameTime = 0;

  Map<String, dynamic> player = {'name': '~', 'elo': 0};
  Map<String, dynamic> opponent = {'name': '~', 'elo': 0};

  late String pid, name;

  @override
  void initChessGame({String initialFen = chess_lib.Chess.DEFAULT_POSITION}) {
    super.initChessGame(initialFen: initialFen);

    pid = 'PID_${Random().nextInt(1000000)}';
    name = 'CLIENT_${Random().nextInt(1000000)}';
  }

  void setupSocketIO() {
    socket = socket_io.io('http://192.168.50.118:8888', <String, dynamic>{
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
    setState(() => gameState = GameState.connected);
  }

  onDisconnect(_) {
    debugPrint('Connection lost.');

    setState(() {
      gameState = GameState.idle;
      lastMove = null;
    });

    controller.setFen('');
  }

  onWaitingMatch(data) async {
    debugPrint('Waiting for match...');
    setState(() => gameState = GameState.waitingMatch);
  }

  onGameMode(data) {
    debugPrint('Game mode: $data');

    setState(() {
      gameState = GameState.waitingOpponent;
      lastMove = null;

      orientation = data['side'] == 'white'
          ? BoardOrientation.white
          : BoardOrientation.black;

      player =
          data['side'] == 'white' ? data['white_player'] : data['black_player'];
      opponent =
          data['side'] == 'white' ? data['black_player'] : data['white_player'];
    });

    controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
  }

  onGo(data) {
    debugPrint('Your move');
    setState(() => gameState = GameState.waitingMove);
  }

  onWin(data) {
    debugPrint('You won: ${data['reason']}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('你赢了！'),
        content: Text(data['reason']),
      ),
    );
  }

  onLost(data) {
    debugPrint('You lost: ${data['reason']}');

    setState(() => gameState = GameState.waitingMatch);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('你输了！'),
        content: Text(data['reason']),
      ),
    );
  }

  onDraw(data) {
    debugPrint('Draw: ${data['reason']}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('和棋！'),
        content: Text(data['reason']),
      ),
    );
  }

  onTakebackRequest(data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('悔棋'),
        content: Text(data['message']),
        actions: [
          TextButton(
            child: const Text('接受'),
            onPressed: () {
              socket?.emit('takeback_response', {'accepted': true});
              Navigator.pop(context);
            },
          ),
          TextButton(
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
          TextButton(
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
    setState(() => lastMove = null);

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
          TextButton(
            child: const Text('接受'),
            onPressed: () {
              socket?.emit('draw_response', {'accepted': true});
              Navigator.pop(context);
            },
          ),
          TextButton(
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
          TextButton(
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
    setState(() {
      gameTime = data['mine'];
      opponentGameTime = data['opponent'];
    });
  }

  connect() {
    setupSocketIO();
  }

  disconnect() {
    socket?.dispose();
    gameState = GameState.idle;
  }

  proposeDraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认求和？'),
        content: const Text('你确定要请求和棋吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          TextButton(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          TextButton(
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('否'),
          ),
          TextButton(
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
    setState(() {
      gameState = GameState.waitingOpponent;
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

    onMove({
      'from': from,
      'to': to,
      if (promotion != null) 'promotion': promotion
    });
  }

  @override
  void onMove(Map<String, String> move) {
    chess.move(move);
    updateLastMove(move['from']!, move['to']!);
    controller.setFen(chess.fen);

    socket?.emit(
      'move',
      {'move': "${move['from']}${move['to']}${move['promotion'] ?? ''}"},
    );

    setState(() => gameState = GameState.waitingOpponent);
  }
}
