import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'game.dart';

mixin SocketIoMixin<T extends StatefulWidget> on State<T> {
  io.Socket? socket;
  ChessGame? game;

  void setupSocketIO() {
    socket = io.io('http://localhost:5000', {
      'transports': ['websocket']
    });

    socket?.onConnect((_) => debugPrint('Successful connection!'));

    socket?.onDisconnect((_) => debugPrint('Connection lost.'));

    socket?.on('message', (line) async {
      switch (line) {
        case 'GAME_MODE':
          game = ChessGame(socket, xPrint, xInput);
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

  xPrint(String message) => setState(() => debugPrint(message));

  Future<String?> xInput(String message, {withInput = false}) {
    final controller = withInput ? TextEditingController() : null;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (withInput)
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop('Cancel'),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () =>
                Navigator.of(context).pop(withInput ? controller?.text : 'OK'),
          ),
        ],
      ),
    );
  }
}
