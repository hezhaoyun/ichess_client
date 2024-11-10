class PgnGame {
  final String event;
  final String site;
  final String date;
  final String round;
  final String white;
  final String black;
  final String result;
  final List<String> moves;

  PgnGame({
    this.event = '',
    this.site = '',
    this.date = '',
    this.round = '',
    this.white = '',
    this.black = '',
    this.result = '',
    required this.moves,
  });

  factory PgnGame.fromPgn(String pgn) {
    final Map<String, String> tags = {};
    final List<String> moves = [];

    // 解析PGN标签
    final tagRegex = RegExp(r'\[(\w+)\s+"([^"]+)"\]');
    final moveRegex = RegExp(r'\b\d+\.\s+([^\s]+)\s+([^\s]+)?');

    for (var line in pgn.split('\n')) {
      final tagMatch = tagRegex.firstMatch(line);
      if (tagMatch != null) {
        tags[tagMatch.group(1)!] = tagMatch.group(2)!;
      }

      final moveMatches = moveRegex.allMatches(line);
      for (var match in moveMatches) {
        moves.add(match.group(1)!);
        if (match.group(2) != null) {
          moves.add(match.group(2)!);
        }
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
      moves: moves,
    );
  }
}
