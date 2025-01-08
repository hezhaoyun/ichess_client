import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../game/config_manager.dart';
import '../../game/theme_manager.dart';
import 'languages_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final configManager = Provider.of<ConfigManager>(context);
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppLocalizations.of(context)!.settings,
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
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.language,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(configManager.language, style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(getLanguageName(configManager.language)),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LanguagesPage()),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.colorTheme,
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
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onTap: () => _showThemeColorDialog(context, themeManager),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.pieceTheme,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            leading: SvgPicture.asset('$pieceThemePath/wk.svg', width: 32, height: 32),
                            title: Text(themeManager.selectedPieceTheme),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onTap: () => _showPieceThemeDialog(context, themeManager),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.serverSettings,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            title: Text(AppLocalizations.of(context)!.serverAddress),
                            subtitle: Text(configManager.serverUrl),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(text: configManager.serverUrl);
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.setServerAddress),
                                    content: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)!.pleaseEnterTheServerAddress),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)!.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, controller.text),
                                        child: Text(AppLocalizations.of(context)!.confirm),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (result != null) {
                                configManager.setServerUrl(result);
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.engineSettings,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(AppLocalizations.of(context)!.engineLevel),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${AppLocalizations.of(context)!.current}: ${configManager.engineLevel}',
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ],
                                ),
                                onTap: () => _showEngineLevelDialog(context, configManager),
                              ),
                              ListTile(
                                title: Text(AppLocalizations.of(context)!.timeControlMode),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      configManager.useTimeControl
                                          ? AppLocalizations.of(context)!.limitTime
                                          : AppLocalizations.of(context)!.limitDepth,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ],
                                ),
                                onTap: () => configManager.setUseTimeControl(!configManager.useTimeControl),
                              ),
                              if (configManager.useTimeControl)
                                ListTile(
                                  title: Text(AppLocalizations.of(context)!.thinkingTime),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${configManager.moveTime}ms'),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showMoveTimeDialog(context, configManager),
                                )
                              else
                                ListTile(
                                  title: Text(AppLocalizations.of(context)!.searchDepth),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${configManager.searchDepth} ${AppLocalizations.of(context)!.layers}'),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showSearchDepthDialog(context, configManager),
                                ),
                              if (!Platform.isAndroid && !Platform.isIOS)
                                ListTile(
                                  title: Text(AppLocalizations.of(context)!.enginePath),
                                  subtitle: Text(
                                    configManager.enginePath,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  onTap: () async {
                                    final result = await _showEnginePathDialog(context, configManager);
                                    if (result != null) configManager.setEnginePath(result);
                                  },
                                ),
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.showAnalysisArrows),
                                subtitle: Text(AppLocalizations.of(context)!.showPredictedMovesWhenTheEngineIsThinking),
                                value: configManager.showArrows,
                                onChanged: (value) => configManager.setShowArrows(value),
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

  Future<String?> _showEnginePathDialog(BuildContext context, ConfigManager configManager) => showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: configManager.enginePath);
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.setEnginePath),
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: AppLocalizations.of(context)!.pleaseEnterTheEnginePath),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final path = await FilePicker.platform.pickFiles();
                    if (path != null) {
                      controller.text = path.files.single.path ?? '';
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.browse),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          );
        },
      );

  void _showEngineLevelDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: AppLocalizations.of(context)!.setEngineLevel,
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
        title: AppLocalizations.of(context)!.setThinkingTime,
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
        title: AppLocalizations.of(context)!.setSearchDepth,
        initialValue: configManager.searchDepth.toDouble(),
        min: 1,
        max: 30,
        divisions: 29,
        labelFormat: (value) => '${value.round()} ${AppLocalizations.of(context)!.layers}',
        onChanged: (value) => configManager.setSearchDepth(value.round()),
      ),
    );
  }

  void _showThemeColorDialog(BuildContext context, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectThemeColor),
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
        title: Text(AppLocalizations.of(context)!.selectPieceTheme),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
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
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      );
}
