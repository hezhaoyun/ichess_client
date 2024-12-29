import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/favorites_service.dart';
import '../../widgets/sound_buttons.dart';
import 'viewer_page.dart';

class ManualInfo {
  final String file;
  final int count;
  final String event;

  ManualInfo({required this.file, required this.count, required this.event});

  factory ManualInfo.fromJson(Map<String, dynamic> json) => ManualInfo(
        file: json['file'] as String,
        count: json['count'] as int,
        event: json['event'] as String,
      );
}

class ManualsPage extends StatefulWidget {
  const ManualsPage({super.key});

  @override
  State<ManualsPage> createState() => _ManualsPageState();
}

class _ManualsPageState extends State<ManualsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ManualInfo>? manuals;
  List<FavoriteGame>? favorites;
  String searchKeyword = '';
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadManualsList();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadManualsList() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/manuals.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      setState(() {
        manuals = jsonList.map((json) => ManualInfo.fromJson(json as Map<String, dynamic>)).toList();
        manuals!.sort((a, b) => a.event.compareTo(b.event));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load games list: $e')),
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
                  tabs: const [Tab(text: 'All Games'), Tab(text: 'My Favorites')],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildManualList(), _buildFavoritesList()],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SoundButton.icon(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Text(
              'Games',
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
            SoundButton.icon(
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ViewerPage(manualFile: file.name, pgnContent: content),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load file: $e')),
        );
      }
    }
  }

  Widget _buildManualList() {
    if (manuals == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredManuals =
        manuals!.where((manual) => manual.event.toLowerCase().contains(searchKeyword.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search games...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchKeyword.isNotEmpty
                  ? SoundButton.icon(
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => setState(() => searchKeyword = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredManuals.length,
            itemBuilder: (context, index) {
              final manual = filteredManuals[index];
              return Card(
                child: ListTile(
                  title: Text(
                    manual.event,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${manual.count} games',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewerPage(manualFile: manual.file),
                    ),
                  ),
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
      return const Center(child: Text('No favorite manuals available'));
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
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ViewerPage(manualFile: 'favorite_${index + 1}.pgn', pgnContent: favorite.pgn),
              ),
            ),
          ),
        );
      },
    );
  }
}
