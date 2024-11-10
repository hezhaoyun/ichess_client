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

    // 修改移动正则表达式以匹配跨行的情况
    // 匹配格式：数字. 移动1 移动2 或 数字... 移动
    final moveRegex = RegExp(r'\b\d+\.\.?\.?\s+([^\s]+)(?:\s+([^\s]+))?');

    // 将所有移动文本合并到一起处理
    String movesText = '';

    for (var line in pgn.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;

      // 检查是否是标签部分
      if (line.startsWith('[')) {
        final tagMatch = tagRegex.firstMatch(line);
        if (tagMatch != null) {
          tags[tagMatch.group(1)!] = tagMatch.group(2)!;
        }
      } else {
        // 非标签部分认为是走法部分
        movesText += ' $line';
      }
    }

    // 处理合并后的走法文本
    final moveMatches = moveRegex.allMatches(movesText);
    for (var match in moveMatches) {
      if (match.group(1) != null) {
        moves.add(match.group(1)!);
      }
      if (match.group(2) != null) {
        moves.add(match.group(2)!);
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
