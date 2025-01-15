import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'full_opening.dart';
import 'openings_database.dart';
part 'opening_service.g.dart';

/// Alternative castling uci notations.
const altCastles = {'e1a1': 'e1c1', 'e1h1': 'e1g1', 'e8a8': 'e8c8', 'e8h8': 'e8g8'};

@Riverpod(keepAlive: true)
OpeningService openingService(Ref ref) {
  return OpeningService(ref);
}

class OpeningService {
  OpeningService(this._ref);
  final Ref _ref;

  Future<Database> get _db => _ref.read(openingsDatabaseProvider.future);

  Future<FullOpening?> fetchFromMoves(Iterable<Move> moves) async {
    final db = await _db;

    final movesString =
        moves.map((move) => altCastles.containsKey(move.uci) ? altCastles[move.uci] : move.uci).join(' ');

    final list = await db.query('openings', where: 'uci = ?', whereArgs: [movesString]);
    final first = list.firstOrNull;

    if (first != null) {
      return FullOpening(
        eco: first['eco']! as String,
        name: first['name']! as String,
        fen: first['epd']! as String,
        pgnMoves: first['pgn']! as String,
        uciMoves: first['uci']! as String,
      );
    }

    return null;
  }
}
