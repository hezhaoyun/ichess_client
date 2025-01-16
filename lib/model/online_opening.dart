import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chess_opening.dart';

part 'online_opening.g.dart';

class OnlineOpeningCache {
  static final OnlineOpeningCache _instance = OnlineOpeningCache._();
  factory OnlineOpeningCache() => _instance;
  OnlineOpeningCache._();

  final Map<String, ChessOpening> cache = {};

  ChessOpening? get(String fen) => cache[fen];
  void set(String fen, ChessOpening opening) => cache[fen] = opening;
}

@riverpod
Future<ChessOpening> onlineOpening(Ref ref, {String fen = ''}) async {
  // check cache
  final cachedOpening = OnlineOpeningCache().get(fen);
  if (cachedOpening != null) return cachedOpening;

  final response = await http.get(
    Uri.http('explorer.lichess.ovh', '/master', {if (fen.isNotEmpty) 'fen': fen}),
  );

  final chessOpening = ChessOpening.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  // cache result
  OnlineOpeningCache().set(fen, chessOpening);

  return chessOpening;
}
