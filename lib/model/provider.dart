import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chess_opening.dart';

part 'provider.g.dart';

@riverpod
Future<ChessOpening> chessOpening(Ref ref) async {
  final response = await http.get(Uri.http('explorer.lichess.ovh', '/master'));
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return ChessOpening.fromJson(json);
}
