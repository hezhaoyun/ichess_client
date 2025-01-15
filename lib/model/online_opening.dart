import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chess_opening.dart';

part 'online_opening.g.dart';

@riverpod
Future<ChessOpening> onlineOpening(Ref ref, {String fen = ''}) async {
  final response = await http.get(
    Uri.http('explorer.lichess.ovh', '/master', {
      if (fen.isNotEmpty) 'fen': fen,
    }),
  );
  return ChessOpening.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}
