import 'dart:async';

import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
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

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setupSocketIO() {
    socket = socket_io.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket']
    });

    socket?.onConnect((_) {
      debugPrint('Successful connection!');
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
      debugPrint('Game mode: $side');

      chess = chess_lib.Chess();

      setState(() {
        gameState = GameState.waitingOpponent;
        lastMove = null;

        orientation =
            side == 'white' ? BoardOrientation.white : BoardOrientation.black;
      });

      controller.setFen(chess_lib.Chess.DEFAULT_POSITION);

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        socket?.emit('timer_check', {});
      });
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
      _timer?.cancel();
      debugPrint('Game over: ${data['reason']}');
    });

    socket?.on('win', (data) {
      debugPrint('You won: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('You won!'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('lost', (data) {
      debugPrint('You lost: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('You lost!'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('draw', (data) {
      debugPrint('Draw: ${data['reason']}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Draw!'),
          content: Text(data['reason']),
        ),
      );
    });

    socket?.on('waiting_match', (data) async {
      debugPrint('Waiting for match...');
      setState(() => gameState = GameState.waitingMatch);
    });

    socket?.on('timer', (data) {
      // debugPrint('Timer: $data');

      setState(() {
        gameTime = data['mine'];
        opponentGameTime = data['opponent'];
      });
    });

    socket?.on('message', (line) => debugPrint(line));

    socket?.onError((err) {
      debugPrint('Error: $err');
    });
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
        title: const Text('Promotion'),
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
    _timer?.cancel();
    gameState = GameState.idle;
  }

  void forfeit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm surrender?'),
        content: const Text('Are you sure you want to surrender?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              socket?.emit('forfeit', {});
              Navigator.pop(context);
            },
            child: const Text('Yes'),
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
      appBar: AppBar(title: const Text('Chess Client')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Opponent time: $opponentGameTime'),
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
          Text('My time: $gameTime'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (gameState == GameState.idle)
                TextButton(
                  onPressed: connect,
                  child: const Text('Connect'),
                ),
              if (gameState != GameState.idle)
                TextButton(
                  onPressed: disconnect,
                  child: const Text('Disconnect'),
                ),
              TextButton(
                onPressed: gameState == GameState.waitingMove ? forfeit : null,
                child: const Text('Forfeit'),
              ),
              TextButton(
                onPressed: gameState == GameState.waitingMatch ? match : null,
                child: const Text('Match'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
