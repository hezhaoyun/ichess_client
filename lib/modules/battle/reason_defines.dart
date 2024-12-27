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

  static const win = {
    kWinCheckmate: '绝杀',
    kWinOpponentOutOfTime: '对手超时',
    kWinOpponentResigned: '对手认输',
    kWinOpponentLeft: '对手离开',
  };

  static const lose = {
    kLoseCheckmated: '被绝杀',
    kLoseOutOfTime: '超时',
    kLoseResigned: '认输',
  };

  static const draw = {
    kDrawStalemate: '僵局',
    kDrawInsufficientMaterial: '子力不足',
    kDrawConsensus: '议和',
  };

  static String winOf(String reason) => win[reason] ?? reason;
  static String loseOf(String reason) => lose[reason] ?? reason;
  static String drawOf(String reason) => draw[reason] ?? reason;
}
