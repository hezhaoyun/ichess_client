import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../game/config_manager.dart';
import '../../game/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final appConfigManager = Provider.of<ConfigManager>(context);
    final pieceThemePath = ThemeManager.kPieceThemes[themeManager.selectedPieceTheme]!;

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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Settings',
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
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Color Theme',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: themeManager.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(themeManager.currentThemeName),
                            onTap: () => _showThemeColorDialog(context, themeManager),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Piece Theme',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            leading: SvgPicture.asset('$pieceThemePath/wk.svg', width: 32, height: 32),
                            title: Text(themeManager.selectedPieceTheme),
                            onTap: () => _showPieceThemeDialog(context, themeManager),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Server Settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            title: const Text('Server Address'),
                            subtitle: Text(appConfigManager.serverUrl),
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(text: appConfigManager.serverUrl);
                                  return AlertDialog(
                                    title: const Text('Set Server Address'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(hintText: 'Please enter the server address'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, controller.text),
                                        child: const Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (result != null) {
                                appConfigManager.setServerUrl(result);
                              }
                            },
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Engine Settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Engine Level'),
                                subtitle: Text('Current: ${appConfigManager.engineLevel}'),
                                onTap: () => _showEngineLevelDialog(context, appConfigManager),
                              ),
                              SwitchListTile(
                                title: const Text('Time Control Mode'),
                                subtitle: Text(appConfigManager.useTimeControl ? 'Limit Time' : 'Limit Depth'),
                                value: appConfigManager.useTimeControl,
                                onChanged: (value) => appConfigManager.setUseTimeControl(value),
                              ),
                              if (appConfigManager.useTimeControl)
                                ListTile(
                                  title: const Text('Thinking Time'),
                                  subtitle: Text('${appConfigManager.moveTime}ms'),
                                  onTap: () => _showMoveTimeDialog(context, appConfigManager),
                                )
                              else
                                ListTile(
                                  title: const Text('Search Depth'),
                                  subtitle: Text('${appConfigManager.searchDepth} layers'),
                                  onTap: () => _showSearchDepthDialog(context, appConfigManager),
                                ),
                              if (!Platform.isAndroid && !Platform.isIOS)
                                ListTile(
                                  title: const Text('Engine Path'),
                                  subtitle: Text(appConfigManager.enginePath),
                                  onTap: () async {
                                    final result = await _showEnginePathDialog(context, appConfigManager);
                                    if (result != null) appConfigManager.setEnginePath(result);
                                  },
                                ),
                              SwitchListTile(
                                title: const Text('Show Engine Analysis Arrows'),
                                subtitle: const Text('Show predicted moves when the engine is thinking'),
                                value: appConfigManager.showArrows,
                                onChanged: (value) => appConfigManager.setShowArrows(value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showEnginePathDialog(BuildContext context, ConfigManager appConfigManager) => showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: appConfigManager.enginePath);
          return AlertDialog(
            title: const Text('Set Engine Path'),
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Please enter the engine path'),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final path = await FilePicker.platform.pickFiles();
                    if (path != null) {
                      controller.text = path.files.single.path ?? '';
                    }
                  },
                  child: const Text('Browse'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

  void _showEngineLevelDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: 'Set Engine Level',
        initialValue: configManager.engineLevel.toDouble(),
        min: 1,
        max: 20,
        divisions: 19,
        labelFormat: (value) => value.round().toString(),
        onChanged: (value) => configManager.setEngineLevel(value.round()),
      ),
    );
  }

  void _showMoveTimeDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: 'Set Thinking Time',
        initialValue: configManager.moveTime.toDouble(),
        min: 1000,
        max: 15000,
        divisions: 14,
        labelFormat: (value) => '${value.round()}ms',
        onChanged: (value) => configManager.setMoveTime(value.round()),
      ),
    );
  }

  void _showSearchDepthDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: 'Set Search Depth',
        initialValue: configManager.searchDepth.toDouble(),
        min: 1,
        max: 30,
        divisions: 29,
        labelFormat: (value) => '${value.round()} layers',
        onChanged: (value) => configManager.setSearchDepth(value.round()),
      ),
    );
  }

  void _showThemeColorDialog(BuildContext context, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: themeManager.themes.length,
            itemBuilder: (context, index) {
              final themeName = themeManager.themes.keys.elementAt(index);
              final themeColor = themeManager.themes[themeName]!;
              final isSelected = themeColor == themeManager.primaryColor;

              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                ),
                title: Text(themeName),
                trailing: isSelected ? Icon(Icons.check_circle, color: themeColor) : null,
                onTap: () {
                  themeManager.setTheme(themeName);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPieceThemeDialog(BuildContext context, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Piece Theme'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: ThemeManager.kPieceThemes.length,
            itemBuilder: (context, index) {
              final themeName = ThemeManager.kPieceThemes.keys.elementAt(index);
              final pieceThemePath = ThemeManager.kPieceThemes[themeName]!;
              final isSelected = themeName == themeManager.selectedPieceTheme;

              return ListTile(
                leading: SvgPicture.asset('$pieceThemePath/wk.svg', width: 32, height: 32),
                title: Text(themeName),
                trailing: isSelected ? Icon(Icons.check_circle) : null,
                onTap: () {
                  themeManager.setPieceTheme(themeName);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EngineSliderDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelFormat;
  final void Function(double) onChanged;

  const _EngineSliderDialog({
    required this.title,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelFormat,
    required this.onChanged,
  });

  @override
  State<_EngineSliderDialog> createState() => _EngineSliderDialogState();
}

class _EngineSliderDialogState extends State<_EngineSliderDialog> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        content: SizedBox(
          height: 48,
          child: Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.labelFormat(_value),
            onChanged: (value) {
              setState(() => _value = value);
              widget.onChanged(value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
}
