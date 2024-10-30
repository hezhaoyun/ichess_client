import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChessGame {
  final IO.Socket? socket;
  final Function(String message) xPrint;
  final Future<String?> Function(String message, {bool withInput}) xInput;

  ChessGame(this.socket, this.xPrint, this.xInput) {
    xPrint('You: Type FORFEIT to surrender');
    xPrint('You: Type moves in UCI, long algebraic notation, e.g e2e4');
  }

  Future<void> makeMove() async {
    xPrint("You: It's time for you to make a move or issue a command!");

    final command = await xInput('Your command: ', withInput: true);
    socket?.send([command]);

    xPrint('You: Sent[$command]!');
    if (command == 'FORFEIT') {
      xPrint('You: You have forfeited the game');
    }
  }
}
