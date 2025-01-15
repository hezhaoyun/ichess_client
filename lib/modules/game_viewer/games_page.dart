import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../services/favorites_service.dart';
import 'viewer_page.dart';

class GameInfo {
  final String file;
  final int count;
  final String event;

  GameInfo({required this.file, required this.count, required this.event});

  factory GameInfo.fromJson(Map<String, dynamic> json) => GameInfo(
        file: json['file'] as String,
        count: json['count'] as int,
        event: json['event'] as String,
      );
}

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GameInfo>? games;
  List<FavoriteGame>? favorites;
  String searchKeyword = '';
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    _tabController = TabController(length: 2, vsync: this);
    await _loadGamesList();
    await _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGamesList() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/games.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      setState(() {
        games = jsonList.map((json) => GameInfo.fromJson(json as Map<String, dynamic>)).toList();
        games!.sort((a, b) => a.event.compareTo(b.event));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadGamesList(e.toString()))),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    final favoritesService = FavoritesService();
    final favoritesList = await favoritesService.getFavorites();
    setState(() => favorites = favoritesList);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(0x1A),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.allGames),
                    Tab(text: AppLocalizations.of(context)!.favorites)
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildGameList(), _buildFavoritesList()],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              AppLocalizations.of(context)!.games,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(0x33),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _loadPgnFile,
            ),
          ],
        ),
      );

  Future<void> _loadPgnFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final file = result.files.first;
        String content;

        if (file.bytes != null) {
          content = String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        } else {
          throw Exception('Failed to read file content');
        }

        if (mounted) {
          await goToViewerPage(gameFile: file.name, pgnContent: content);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFile(e.toString()))),
        );
      }
    }
  }

  Widget _buildGameList() {
    if (games == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredGames =
        games!.where((game) => game.event.toLowerCase().contains(searchKeyword.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchGames,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchKeyword.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      iconSize: 12,
                      onPressed: () {
                        setState(() {
                          searchKeyword = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => setState(() => searchKeyword = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredGames.length,
            itemBuilder: (context, index) {
              final game = filteredGames[index];
              return Card(
                child: ListTile(
                  title: Text(
                    game.event,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${game.count} ${AppLocalizations.of(context)!.games}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async => await goToViewerPage(gameFile: game.file),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesList() {
    if (favorites == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favorites!.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noFavoriteGamesAvailable));
    }

    final filteredFavorites =
        favorites!.where((favorite) => favorite.event.toLowerCase().contains(searchKeyword.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFavorites.length,
      itemBuilder: (context, index) {
        final favorite = filteredFavorites[index];
        return Card(
          child: ListTile(
            title: Text(favorite.event),
            subtitle: Text('${favorite.white} vs ${favorite.black}\n${favorite.date}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async => await goToViewerPage(gameFile: 'favorite_${index + 1}.pgn', pgnContent: favorite.pgn),
          ),
        );
      },
    );
  }

  Future<void> goToViewerPage({required String gameFile, String? pgnContent}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ViewerPage(gameFile: gameFile, pgnContent: pgnContent),
      ),
    );
    await _loadFavorites();
  }
}
