class Reasons {
  static const kWinCheckmate = 'CHECKMATE';
  static const kWinOpponentOutOfTime = 'OPPONENT_OUT_OF_TIME';
  static const kWinOpponentResigned = 'OPPONENT_RESIGNED';
  static const kWinOpponentLeft = 'OPPONENT_LEFT';
  static const kLoseCheckmated = 'CHECKMATED';
  static const kLoseOutOfTime = 'OUT_OF_TIME';
  static const kLoseResigned = 'RESIGNED';
  static const kDrawStalemate = 'STALEMATE';
  static const kDrawInsufficientMaterial = 'INSUFFICIENT_MATERIAL';
  static const kDrawConsensus = 'CONSENSUS';

  // TODO: multiple language support
  static const win = {
    kWinCheckmate: 'Checkmated',
    kWinOpponentOutOfTime: 'Opponent Out of Time',
    kWinOpponentResigned: 'Opponent Resigned',
    kWinOpponentLeft: 'Opponent Left',
  };

  static const lose = {
    kLoseCheckmated: 'Checkmated',
    kLoseOutOfTime: 'Out of Time',
    kLoseResigned: 'Resigned',
  };

  static const draw = {
    kDrawStalemate: 'Stalemate',
    kDrawInsufficientMaterial: 'Insufficient Material',
    kDrawConsensus: 'Consensus',
  };

  static String winOf(String reason) => win[reason] ?? reason;
  static String loseOf(String reason) => lose[reason] ?? reason;
  static String drawOf(String reason) => draw[reason] ?? reason;
}
