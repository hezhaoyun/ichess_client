import 'package:freezed_annotation/freezed_annotation.dart';

part 'full_opening.freezed.dart';

@freezed
class FullOpening with _$FullOpening {
  const FullOpening._();
  const factory FullOpening({
    required String eco,
    required String name,
    required String fen,
    required String pgnMoves,
    required String uciMoves,
  }) = _FullOpening;
}
