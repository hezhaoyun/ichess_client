import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';

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

  final BuildContext context;
  Reasons(this.context);

  String winReason(String reason) {
    switch (reason) {
      case kWinCheckmate:
        return AppLocalizations.of(context)!.checkmated;
      case kWinOpponentOutOfTime:
        return AppLocalizations.of(context)!.opponentOutOfTime;
      case kWinOpponentResigned:
        return AppLocalizations.of(context)!.opponentResigned;
      case kWinOpponentLeft:
        return AppLocalizations.of(context)!.opponentLeft;
      default:
        return reason;
    }
  }

  String loseReason(String reason) {
    switch (reason) {
      case kLoseCheckmated:
        return AppLocalizations.of(context)!.checkmated;
      case kLoseOutOfTime:
        return AppLocalizations.of(context)!.outOfTime;
      case kLoseResigned:
        return AppLocalizations.of(context)!.resigned;
      default:
        return reason;
    }
  }

  String drawReason(String reason) {
    switch (reason) {
      case kDrawStalemate:
        return AppLocalizations.of(context)!.stalemate;
      case kDrawInsufficientMaterial:
        return AppLocalizations.of(context)!.insufficientMaterial;
      case kDrawConsensus:
        return AppLocalizations.of(context)!.consensus;
      default:
        return reason;
    }
  }
}
