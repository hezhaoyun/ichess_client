class ChessUtils {
  static const initialFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  static final Map<String, int> _fileToIndex = {
    'a': 0,
    'b': 1,
    'c': 2,
    'd': 3,
    'e': 4,
    'f': 5,
    'g': 6,
    'h': 7,
  };

  static String moveToFen(String previousFen, String move) {
    var board = _fenToBoard(previousFen);
    var parts = previousFen.split(' ');
    var isWhiteMove = parts[1] == 'w';

    // 处理王车易位
    if (move == 'O-O') {
      var rank = isWhiteMove ? 7 : 0;
      board[rank][4] = ''; // 王的原位置
      board[rank][7] = ''; // 车的原位置
      board[rank][6] = isWhiteMove ? 'K' : 'k'; // 王的新位置
      board[rank][5] = isWhiteMove ? 'R' : 'r'; // 车的新位置
    } else if (move == 'O-O-O') {
      var rank = isWhiteMove ? 7 : 0;
      board[rank][4] = ''; // 王的原位置
      board[rank][0] = ''; // 车的原位置
      board[rank][2] = isWhiteMove ? 'K' : 'k'; // 王的新位置
      board[rank][3] = isWhiteMove ? 'R' : 'r'; // 车的新位置
    } else {
      // 处理普通走法
      var movePattern = RegExp(
          r'([KQRBN])?([a-h])?([1-8])?x?([a-h][1-8])(?:=([QRBN]))?[\+#]?');
      var match = movePattern.firstMatch(move);

      if (match != null) {
        var piece = match.group(1) ?? 'P';
        var targetSquare = match.group(4)!;
        var promotion = match.group(5);

        var targetFile = _fileToIndex[targetSquare[0]]!;
        var targetRank = 8 - int.parse(targetSquare[1]);

        // 找到起始位置
        var sourceSquare = _findSourceSquare(
          board,
          piece,
          targetFile,
          targetRank,
          isWhiteMove,
          match.group(2),
          match.group(3),
        );

        if (sourceSquare != null) {
          // 移动棋子
          var movingPiece = board[sourceSquare.rank][sourceSquare.file];
          board[sourceSquare.rank][sourceSquare.file] = '';
          board[targetRank][targetFile] = promotion != null
              ? (isWhiteMove ? promotion : promotion.toLowerCase())
              : movingPiece;
        }
      }
    }

    // 更新FEN字符串
    parts[0] = _boardToFen(board);
    parts[1] = isWhiteMove ? 'b' : 'w'; // 交换走子方
    return parts.join(' ');
  }

  static List<List<String>> _fenToBoard(String fen) {
    var board = List.generate(8, (_) => List.filled(8, ''));
    var rows = fen.split(' ')[0].split('/');

    for (var i = 0; i < 8; i++) {
      var col = 0;
      for (var char in rows[i].split('')) {
        if (int.tryParse(char) != null) {
          col += int.parse(char);
        } else {
          board[i][col] = char;
          col++;
        }
      }
    }
    return board;
  }

  static String _boardToFen(List<List<String>> board) {
    var fen = '';
    for (var rank = 0; rank < 8; rank++) {
      var emptyCount = 0;
      for (var file = 0; file < 8; file++) {
        var piece = board[rank][file];
        if (piece.isEmpty) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }
          fen += piece;
        }
      }
      if (emptyCount > 0) {
        fen += emptyCount.toString();
      }
      if (rank < 7) fen += '/';
    }
    return fen;
  }

  static Square? _findSourceSquare(
    List<List<String>> board,
    String piece,
    int targetFile,
    int targetRank,
    bool isWhite,
    String? sourceFile,
    String? sourceRank,
  ) {
    var candidateSquares = <Square>[];

    for (var rank = 0; rank < 8; rank++) {
      for (var file = 0; file < 8; file++) {
        var currentPiece = board[rank][file];
        if (currentPiece.toUpperCase() == piece &&
            isWhite == (currentPiece.toUpperCase() == currentPiece)) {
          if (_isLegalMove(board, file, rank, targetFile, targetRank, piece)) {
            candidateSquares.add(Square(file, rank));
          }
        }
      }
    }

    // 根据提供的起始位置信息筛选
    if (sourceFile != null) {
      candidateSquares.removeWhere(
        (s) => s.file != _fileToIndex[sourceFile]!,
      );
    }
    if (sourceRank != null) {
      candidateSquares.removeWhere(
        (s) => s.rank != 8 - int.parse(sourceRank),
      );
    }

    return candidateSquares.isNotEmpty ? candidateSquares.first : null;
  }

  static bool _isLegalMove(
    List<List<String>> board,
    int sourceFile,
    int sourceRank,
    int targetFile,
    int targetRank,
    String piece,
  ) {
    // 简化版的走法验证
    switch (piece) {
      case 'P':
        return _isPawnMove(
            board, sourceFile, sourceRank, targetFile, targetRank);
      case 'N':
        return _isKnightMove(sourceFile, sourceRank, targetFile, targetRank);
      case 'B':
        return _isBishopMove(sourceFile, sourceRank, targetFile, targetRank);
      case 'R':
        return _isRookMove(sourceFile, sourceRank, targetFile, targetRank);
      case 'Q':
        return _isQueenMove(sourceFile, sourceRank, targetFile, targetRank);
      case 'K':
        return _isKingMove(sourceFile, sourceRank, targetFile, targetRank);
      default:
        return false;
    }
  }

  static bool _isPawnMove(
      List<List<String>> board, int sf, int sr, int tf, int tr) {
    var fileDiff = (tf - sf).abs();
    var rankDiff = tr - sr;

    // 白方兵
    if (board[sr][sf].toUpperCase() == board[sr][sf]) {
      // 普通前进一步
      if (fileDiff == 0 && rankDiff == -1) return true;
      // 第一次可以走两步
      if (fileDiff == 0 && rankDiff == -2 && sr == 6) return true;
    }
    // 黑方兵
    else {
      // 普通前进一步
      if (fileDiff == 0 && rankDiff == 1) return true;
      // 第一次可以走两步
      if (fileDiff == 0 && rankDiff == 2 && sr == 1) return true;
    }

    return false;
  }

  static bool _isKnightMove(int sf, int sr, int tf, int tr) {
    var fileDiff = (tf - sf).abs();
    var rankDiff = (tr - sr).abs();
    return (fileDiff == 2 && rankDiff == 1) || (fileDiff == 1 && rankDiff == 2);
  }

  static bool _isBishopMove(int sf, int sr, int tf, int tr) {
    return (tf - sf).abs() == (tr - sr).abs();
  }

  static bool _isRookMove(int sf, int sr, int tf, int tr) {
    return sf == tf || sr == tr;
  }

  static bool _isQueenMove(int sf, int sr, int tf, int tr) {
    return _isBishopMove(sf, sr, tf, tr) || _isRookMove(sf, sr, tf, tr);
  }

  static bool _isKingMove(int sf, int sr, int tf, int tr) {
    return (tf - sf).abs() <= 1 && (tr - sr).abs() <= 1;
  }
}

class Square {
  final int file;
  final int rank;

  Square(this.file, this.rank);
}
