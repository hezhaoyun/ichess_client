import 'dart:async';
import 'dart:math';

import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:wp_chessboard/wp_chessboard.dart';

enum GameState { idle, connected, waitingMatch, waitingMove, waitingOpponent }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  socket_io.Socket? socket;
  GameState gameState = GameState.idle;

  final controller = WPChessboardController();
  BoardOrientation orientation = BoardOrientation.white;

  late chess_lib.Chess chess;
  List<List<int>>? lastMove;

  int gameTime = 0;
  int opponentGameTime = 0;

  String opponentName = '~';
  late String pid, name;

  @override
  void initState() {
    super.initState();
    pid = 'PID_${Random().nextInt(1000000)}';
    name = 'CLIENT_${Random().nextInt(1000000)}';
  }

  void setupSocketIO() {
    socket = socket_io.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket?.onConnect((_) {
      debugPrint('Successful connection!');
      socket?.emit('join', {'pid': pid, 'name': name});
      setState(() => gameState = GameState.connected);
    });

    socket?.onDisconnect((_) {
      debugPrint('Connection lost.');

      setState(() {
        gameState = GameState.idle;
        lastMove = null;
      });

      controller.setFen('');
    });

    socket?.on('game_mode', (data) {
      final side = data['side'];
      final opponent = data['opponent'];

      debugPrint('Game mode: $side, opponent: $opponent');

      chess = chess_lib.Chess();

      setState(() {
        gameState = GameState.waitingOpponent;
        lastMove = null;

        opponentName = opponent;
        orientation =
            side == 'white' ? BoardOrientation.white : BoardOrientation.black;
      });

      controller.setFen(chess_lib.Chess.DEFAULT_POSITION);
    });

    socket?.on('go', (data) {
      final lastMove = data['last_move'];
      debugPrint('Your move, last move: $lastMove');

      if (lastMove != null) {
        chess.move(
          {
            'from': lastMove.substring(0, 2),
            'to': lastMove.substring(2, 4),
            'promotion': lastMove.length > 4 ? lastMove.substring(4, 5) : null,
          },
        );

        controller.setFen(chess.fen);
      }

      setState(() => gameState = GameState.waitingMove);
    });

    socket?.on('game_over', (data) {
      debugPrint('Game over: ${data['reason']}');
    });

    socket?.on('win', (data) {
      debugPrint('You won: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('你赢了！'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('lost', (data) {
      debugPrint('You lost: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('你输了！'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('draw', (data) {
      debugPrint('Draw: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('和棋！'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('waiting_match', (data) async {
      debugPrint('Waiting for match...');
      setState(() => gameState = GameState.waitingMatch);
    });

    socket?.on('draw_request', (data) {
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
    });

    socket?.on('draw_declined', (data) {
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
    });

    socket?.on('takeback_request', (data) {
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
    });

    socket?.on('takeback_success', (data) {
      // 撤销最近的两步棋
      chess.undo(); // 撤销 对手/自己 的最后一步
      chess.undo(); // 撤销 自己/对手 的最后一步

      // 清除最后移动的高亮显示
      setState(() => lastMove = null);

      // 更新棋盘显示
      controller.setFen(chess.fen);
    });

    socket?.on('takeback_declined', (data) {
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
    });

    socket?.on('timer', (data) {
      // debugPrint('Timer: $data');
      setState(() {
        gameTime = data['mine'];
        opponentGameTime = data['opponent'];
      });
    });

    socket?.on('message', (line) => debugPrint(line));

    socket?.onError((err) => debugPrint('Error: $err'));
  }

  // not working on drop
  Widget squareBuilder(SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0
        ? Colors.grey.shade200
        : Colors.grey.shade600;
    Color overlayColor = Colors.transparent;

    if (lastMove != null) {
      if (lastMove!.first.first == info.rank &&
          lastMove!.first.last == info.file) {
        overlayColor = Colors.blueAccent.shade400.withOpacity(0.4);
      } else if (lastMove!.last.first == info.rank &&
          lastMove!.last.last == info.file) {
        overlayColor = Colors.blueAccent.shade400.withOpacity(0.87);
      }
    }

    return Container(
      color: fieldColor,
      width: info.size,
      height: info.size,
      child: AnimatedContainer(
        color: overlayColor,
        width: info.size,
        height: info.size,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }

  void onPieceStartDrag(SquareInfo square, String piece) {
    showHintFields(square, piece);
  }

  void onPieceTap(SquareInfo square, String piece) {
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
      String to = move.toAlgebraic;
      int rank = to.codeUnitAt(1) - '1'.codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;

      hintMap.set(
        rank,
        file,
        (size) => MoveHint(size: size, onPressed: () => doMove(move)),
      );
    }

    controller.setHints(hintMap);
  }

  void onEmptyFieldTap(SquareInfo square) {
    controller.setHints(HintMap());
  }

  void onPieceDrop(PieceDropEvent event) =>
      doMoveAction({'from': event.from.toString(), 'to': event.to.toString()});

  void doMove(chess_lib.Move move) =>
      doMoveAction({'from': move.fromAlgebraic, 'to': move.toAlgebraic});

  void doMoveAction(Map<String, String> move) {
    bool isPromotion = chess.moves({'verbose': true}).any((m) =>
        m['from'] == move['from'] &&
        m['to'] == move['to'] &&
        m['flags'].contains('p'));

    if (isPromotion) {
      showPromotionDialog(
        (promotion) => makeMove(
          {'from': move['from']!, 'to': move['to']!, 'promotion': promotion},
        ),
      );
    } else {
      makeMove(move);
    }
  }

  Future<void> showPromotionDialog(Function(String) onPromotionSelected) {
    Widget promotionOption(String type, VoidCallback onTap) {
      final isWhite = orientation == BoardOrientation.white;
      Widget piece;
      switch (type) {
        case 'q':
          piece = isWhite ? WhiteQueen() : BlackQueen();
          break;
        case 'r':
          piece = isWhite ? WhiteRook() : BlackRook();
          break;
        case 'b':
          piece = isWhite ? WhiteBishop() : BlackBishop();
          break;
        case 'n':
          piece = isWhite ? WhiteKnight() : BlackKnight();
          break;
        default:
          throw ArgumentError('Invalid promotion type');
      }

      return InkWell(onTap: onTap, child: piece);
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('升变'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['q', 'r', 'b', 'n']
              .map(
                (type) => promotionOption(type, () {
                  Navigator.pop(context);
                  onPromotionSelected(type);
                }),
              )
              .toList(),
        ),
      ),
    );
  }

  void makeMove(Map<String, String> move) {
    chess.move(move);

    final fromSquare = move['from']!;
    final toSquare = move['to']!;

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

    controller.setFen(chess.fen);

    socket?.emit(
      'move',
      {'move': "${move['from']}${move['to']}${move['promotion'] ?? ''}"},
    );

    setState(() => gameState = GameState.waitingOpponent);
  }

  void connect() {
    setupSocketIO();
  }

  void disconnect() {
    socket?.dispose();
    gameState = GameState.idle;
  }

  void proposeDraw() {
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

  void proposeTakeback() {
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

  void forfeit() {
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
              socket?.emit('forfeit', {});
              Navigator.pop(context);
            },
            child: const Text('是'),
          ),
        ],
      ),
    );
  }

  void match() {
    chess = chess_lib.Chess();

    setState(() {
      gameState = GameState.waitingOpponent;
      lastMove = null;
    });

    controller.setFen('');

    socket?.emit('match', {});
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide;
    final orientationColor = orientation == BoardOrientation.white
        ? chess_lib.Color.WHITE
        : chess_lib.Color.BLACK;
    final interactiveEnable = (gameState == GameState.waitingMove ||
            gameState == GameState.waitingOpponent) &&
        chess.turn == orientationColor;

    return Scaffold(
      appBar: AppBar(title: const Text('棋路-国际象棋')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$opponentName：$opponentGameTime'),
          const SizedBox(height: 10),
          WPChessboard(
            size: size,
            orientation: orientation,
            squareBuilder: squareBuilder,
            controller: controller,
            // Don't pass any onPieceDrop handler to disable drag and drop
            onPieceDrop: interactiveEnable ? onPieceDrop : null,
            onPieceTap: interactiveEnable ? onPieceTap : null,
            onPieceStartDrag: onPieceStartDrag,
            onEmptyFieldTap: onEmptyFieldTap,
            turnTopPlayerPieces: false,
            ghostOnDrag: true,
            dropIndicator: DropIndicatorArgs(
              size: size / 2,
              color: Colors.lightBlue.withOpacity(0.24),
            ),
            pieceMap: PieceMap(
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
            ),
          ),
          const SizedBox(height: 10),
          Text('我的时间：$gameTime'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (gameState == GameState.idle)
                TextButton(onPressed: connect, child: const Text('连接')),
              if (gameState != GameState.idle)
                TextButton(onPressed: disconnect, child: const Text('断开')),
              if (gameState == GameState.waitingMatch)
                TextButton(onPressed: match, child: const Text('匹配')),
              if (gameState == GameState.waitingMove)
                TextButton(onPressed: proposeDraw, child: const Text('求和')),
              if (gameState == GameState.waitingMove)
                TextButton(
                  onPressed: chess.move_number >= 2 ? proposeTakeback : null,
                  child: const Text('悔棋'),
                ),
              if (gameState == GameState.waitingMove)
                TextButton(onPressed: forfeit, child: const Text('投降')),
            ],
          ),
        ],
      ),
    );
  }
}
