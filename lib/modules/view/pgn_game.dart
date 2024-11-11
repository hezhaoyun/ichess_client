import 'package:chess/chess.dart' as chess_lib;

/// PGN棋局数据模型
class PgnGame {
  // 正则表达式常量
  static final _tagRegex = RegExp(r'\[(\w+)\s+"([^"]+)"\]');
  static final _moveRegex = RegExp(r'\b\d+\.\.?\.?\s+([^\s]+)(?:\s+([^\s]+))?');

  final String event;
  final String site;
  final String date;
  final String round;
  final String white;
  final String black;
  final String result;
  final List<String> moves;
  final String? _rawPgn;

  const PgnGame({
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

  /// 从PGN文本创建只包含头信息的棋局对象
  factory PgnGame.headerOnly(String pgn) {
    final Map<String, String> tags = _parseHeaders(pgn);

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

  /// 解析PGN头信息
  static Map<String, String> _parseHeaders(String pgn) {
    final Map<String, String> tags = {};

    for (var line in pgn.split('\n')) {
      line = line.trim();
      if (line.isEmpty || !line.startsWith('[')) continue;

      final tagMatch = _tagRegex.firstMatch(line);
      if (tagMatch != null) {
        tags[tagMatch.group(1)!] = tagMatch.group(2)!;
      }
    }

    return tags;
  }

  /// 解析棋局移动
  PgnGame parseMoves() {
    if (_rawPgn == null) return this;

    final moves = _parseMoveText(_rawPgn);

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

  /// 解析移动文本
  static List<String> _parseMoveText(String pgn) {
    final moves = <String>[];
    String movesText = '';

    // 提取移动文本
    for (var line in pgn.split('\n')) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('[')) continue;
      movesText += ' $line';
    }

    // 解析移动
    final moveMatches = _moveRegex.allMatches(movesText);
    for (var match in moveMatches) {
      if (match.group(1) != null) moves.add(match.group(1)!);
      if (match.group(2) != null) moves.add(match.group(2)!);
    }

    return moves;
  }

  /// 解析多个棋局
  static List<PgnGame> parseMultipleGames(String pgn) {
    final games = <PgnGame>[];
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

  /// 执行移动并返回新的FEN串
  static String moveToFen(String previousFen, String move) {
    final chess = chess_lib.Chess.fromFEN(previousFen);

    // 执行移动，如果不合法则返回原始位置
    return chess.move(move) ? chess.fen : previousFen;
  }
}
