import 'dart:convert';

import 'package:flutter/material.dart';

import 'viewer_page.dart';

class ManualInfo {
  final String file;
  final int count;
  final String event;

  ManualInfo({
    required this.file,
    required this.count,
    required this.event,
  });

  factory ManualInfo.fromJson(Map<String, dynamic> json) {
    return ManualInfo(
      file: json['file'] as String,
      count: json['count'] as int,
      event: json['event'] as String,
    );
  }
}

class ManualListPage extends StatefulWidget {
  const ManualListPage({super.key});

  @override
  State<ManualListPage> createState() => _ManualListPageState();
}

class _ManualListPageState extends State<ManualListPage> {
  List<ManualInfo>? manuals;
  String searchKeyword = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadManualsList();
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
          SnackBar(content: Text('加载棋谱列表失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Expanded(
                child: _buildManualList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            '棋谱列表',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(0x33),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            decoration: InputDecoration(
              hintText: '搜索棋谱...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                    '${manual.count} 局棋谱',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManualViewerPage(manualFile: manual.file),
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
}
