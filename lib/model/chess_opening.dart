import 'package:freezed_annotation/freezed_annotation.dart';

part 'chess_opening.freezed.dart';
part 'chess_opening.g.dart';

@freezed
class ChessOpening with _$ChessOpening {
  const factory ChessOpening({
    required int white,
    required int draws,
    required int black,
    required List<OpeningMove> moves,
    required List<TopGame> topGames,
    OpeningInfo? opening,
  }) = _ChessOpening;

  factory ChessOpening.fromJson(Map<String, dynamic> json) => _$ChessOpeningFromJson(json);
}

@freezed
class OpeningMove with _$OpeningMove {
  const factory OpeningMove({
    required String uci,
    required String san,
    required int averageRating,
    required int white,
    required int draws,
    required int black,
    dynamic game,
    required OpeningInfo opening,
  }) = _OpeningMove;

  factory OpeningMove.fromJson(Map<String, dynamic> json) => _$OpeningMoveFromJson(json);
}

@freezed
class OpeningInfo with _$OpeningInfo {
  const factory OpeningInfo({required String eco, required String name}) = _OpeningInfo;

  factory OpeningInfo.fromJson(Map<String, dynamic> json) => _$OpeningInfoFromJson(json);
}

@freezed
class TopGame with _$TopGame {
  const factory TopGame({
    required String uci,
    required String id,
    String? winner,
    required Player black,
    required Player white,
    required int year,
    required String month,
  }) = _TopGame;

  factory TopGame.fromJson(Map<String, dynamic> json) => _$TopGameFromJson(json);
}

@freezed
class Player with _$Player {
  const factory Player({required String name, required int rating}) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}
