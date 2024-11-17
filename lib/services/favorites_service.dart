import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteGame {
  final String event;
  final String date;
  final String white;
  final String black;
  final String pgn;
  final DateTime addedAt;

  FavoriteGame({
    required this.event,
    required this.date,
    required this.white,
    required this.black,
    required this.pgn,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'event': event,
        'date': date,
        'white': white,
        'black': black,
        'pgn': pgn,
        'addedAt': addedAt.toIso8601String(),
      };

  factory FavoriteGame.fromJson(Map<String, dynamic> json) => FavoriteGame(
        event: json['event'],
        date: json['date'],
        white: json['white'],
        black: json['black'],
        pgn: json['pgn'],
        addedAt: DateTime.parse(json['addedAt']),
      );
}

class FavoritesService {
  static const String _key = 'favorite_games';

  Future<List<FavoriteGame>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => FavoriteGame.fromJson(json)).toList();
  }

  Future<void> addFavorite(FavoriteGame game) async {
    final favorites = await getFavorites();
    if (favorites.any((g) => g.pgn == game.pgn)) return;

    favorites.add(game);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(favorites.map((g) => g.toJson()).toList()));
  }

  Future<void> removeFavorite(String pgn) async {
    final favorites = await getFavorites();
    favorites.removeWhere((g) => g.pgn == pgn);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(favorites.map((g) => g.toJson()).toList()));
  }

  Future<bool> isFavorite(String pgn) async {
    final favorites = await getFavorites();
    return favorites.any((g) => g.pgn == pgn);
  }
}
