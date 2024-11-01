import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wp_chessboard/wp_chessboard.dart';

import 'game.dart';
import 'socket_io_mixin.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SocketIoMixin {
  static const defaultFen =
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

  io.Socket? socket;
  bool isConnected = false, inLobby = false;

  final controller = WPChessboardController();
  chess_lib.Chess chess = chess_lib.Chess();
  List<List<int>>? lastMove;

  void setupSocketIO() {
    socket = io.io('http://localhost:5000', {
      'transports': ['websocket']
    });

    socket?.onConnect((_) {
      isConnected = true;
      debugPrint('Successful connection!');
    });

    socket?.onDisconnect((_) {
      isConnected = false;
      debugPrint('Connection lost.');
    });

    socket?.on('message', (line) async {
      switch (line) {
        case 'GAME_MODE':
          controller
              .setFen("3bK3/4B1P1/3p2N1/1rp3P1/2p2p2/p3n3/P5k1/6q1 w - - 0 1");
          break;

        case 'YOUR_MOVE':
        case 'TRY_AGAIN':
          game?.makeMove();
          break;

        case 'GAME_OVER':
          game = null;
          break;

        case 'WAITING_MATCH':
          final response =
              await xInput('Do you want join the waiting queue (y/n)? \n');
          if (response == 'OK') {
            socket?.send(['MATCH']);
            xPrint('You: Sent[MATCH]!');
          }
          break;

        default:
          xPrint(line);
      }
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
      int rank = to.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

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

  void onPieceDrop(PieceDropEvent event) {
    chess.move({"from": event.from.toString(), "to": event.to.toString()});

    lastMove = [
      [event.from.rank, event.from.file],
      [event.to.rank, event.to.file]
    ];

    controller.setFen(chess.fen, animation: false);
  }

  void doMove(chess_lib.Move move) {
    chess.move(move);

    int rankFrom = move.fromAlgebraic.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
    int fileFrom = move.fromAlgebraic.codeUnitAt(0) - "a".codeUnitAt(0) + 1;
    int rankTo = move.toAlgebraic.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
    int fileTo = move.toAlgebraic.codeUnitAt(0) - "a".codeUnitAt(0) + 1;

    lastMove = [
      [rankFrom, fileFrom],
      [rankTo, fileTo]
    ];

    controller.setFen(chess.fen);
  }

  void connect() {}

  void disconnect() {
    controller.setArrows([
      Arrow(
        from: SquareLocation.fromString("b1"),
        to: SquareLocation.fromString("c3"),
      ),
      Arrow(
        from: SquareLocation.fromString("g1"),
        to: SquareLocation.fromString("f3"),
        color: Colors.red,
      )
    ]);
  }

  void forfeit() {
    controller.setArrows([]);
  }

  BoardOrientation orientation = BoardOrientation.white;

  void match() {
    setState(() {
      if (orientation == BoardOrientation.white) {
        orientation = BoardOrientation.black;
      } else {
        orientation = BoardOrientation.white;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      appBar: AppBar(title: const Text('Chess Client')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WPChessboard(
            size: size,
            orientation: orientation,
            squareBuilder: squareBuilder,
            controller: controller,
            // Don't pass any onPieceDrop handler to disable drag and drop
            onPieceDrop: onPieceDrop,
            onPieceTap: onPieceTap,
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: connect,
                child: const Text("Connect"),
              ),
              TextButton(
                onPressed: disconnect,
                child: const Text("Disconnect"),
              ),
              TextButton(
                onPressed: forfeit,
                child: const Text("Forfeit"),
              ),
              TextButton(
                onPressed: match,
                child: const Text("Match"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
