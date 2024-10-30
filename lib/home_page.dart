import 'package:chess_client/game.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IO.Socket? socket;
  ChessGame? game;
  final commands = <String>[];

  @override
  void initState() {
    super.initState();
    setupSocketIO();
  }

  void setupSocketIO() {
    socket = IO.io(
      'http://localhost:5000',
      <String, dynamic>{
        'transports': ['websocket']
      },
    );
    socket?.onConnect((_) => xPrint('Successful connection!'));
    socket?.onDisconnect((_) => xPrint('Connection lost.'));

    socket?.on('message', (line) async {
      switch (line) {
        case 'GAMEMODE':
          game = ChessGame(socket, xPrint, xInput);
          break;

        case 'YOUR MOVE':
        case 'TRYAGAIN':
          game?.makeMove();
          break;

        case 'GAMEOVER':
          game = null;
          break;

        case 'WAITINGMATCH':
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chess Client')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: commands.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(commands[index])),
              ),
            ),
          ],
        ),
      );

  xPrint(String message) => setState(() => commands.add(message));

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
