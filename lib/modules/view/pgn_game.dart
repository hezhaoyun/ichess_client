import 'package:chess/chess.dart' as chess_lib;

class PgnGame {
  final String event;
  final String site;
  final String date;
  final String round;
  final String white;
  final String black;
  final String result;
  final List<String> moves;
  final String? _rawPgn;

  PgnGame({
    this.event = '',
    this.site = '',
    this.date = '',
    this.round = '',
    this.white = '',
    this.black = '',
    this.result = '',
    required this.moves,
    String? rawPgn,
  }) : _rawPgn = rawPgn;

  factory PgnGame.headerOnly(String pgn) {
    final Map<String, String> tags = {};
    final tagRegex = RegExp(r'\[(\w+)\s+"([^"]+)"\]');

    for (var line in pgn.split('\n')) {
      line = line.trim();
      if (line.isEmpty || !line.startsWith('[')) continue;

      final tagMatch = tagRegex.firstMatch(line);
      if (tagMatch != null) {
        tags[tagMatch.group(1)!] = tagMatch.group(2)!;
      }
    }

    return PgnGame(
      event: tags['Event'] ?? '',
      site: tags['Site'] ?? '',
      date: tags['Date'] ?? '',
      round: tags['Round'] ?? '',
      white: tags['White'] ?? '',
      black: tags['Black'] ?? '',
      result: tags['Result'] ?? '',
      moves: const [],
      rawPgn: pgn,
    );
  }

  PgnGame parseMoves() {
    if (_rawPgn == null) return this;

    final moveRegex = RegExp(r'\b\d+\.\.?\.?\s+([^\s]+)(?:\s+([^\s]+))?');
    String movesText = '';
    List<String> moves = [];

    for (var line in _rawPgn.split('\n')) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('[')) continue;
      movesText += ' $line';
    }

    final moveMatches = moveRegex.allMatches(movesText);
    for (var match in moveMatches) {
      if (match.group(1) != null) moves.add(match.group(1)!);
      if (match.group(2) != null) moves.add(match.group(2)!);
    }

    return PgnGame(
      event: event,
      site: site,
      date: date,
      round: round,
      white: white,
      black: black,
      result: result,
      moves: moves,
    );
  }

  static List<PgnGame> parseMultipleGames(String pgn) {
    List<PgnGame> games = [];
    String currentGame = '';
    bool inGame = false;

    for (var line in pgn.split('\n')) {
      line = line.trim();

      if (line.startsWith('[Event "')) {
        if (currentGame.isNotEmpty) {
          games.add(PgnGame.headerOnly(currentGame));
          currentGame = '';
        }
        inGame = true;
      }

      if (line.isNotEmpty || inGame) {
        currentGame += '$line\n';
      }
    }

    if (currentGame.isNotEmpty) {
      games.add(PgnGame.headerOnly(currentGame));
    }

    return games;
  }

  static String moveToFen(String previousFen, String move) {
    // 使用 chess 包创建棋局实例
    final chess = chess_lib.Chess.fromFEN(previousFen);

    // 尝试执行移动
    final success = chess.move(move);
    if (!success) {
      // 如果移动不合法，返回原始 FEN
      return previousFen;
    }

    // 返回新的 FEN
    return chess.fen;
  }
}
