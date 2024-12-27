import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../game/config_manager.dart';
import '../../game/theme_manager.dart';
import '../../widgets/sound_buttons.dart';

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
                    SoundButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      '设置',
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
                          '服务器设置',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: ListTile(
                            title: const Text('服务器地址'),
                            subtitle: Text(appConfigManager.serverUrl),
                            onTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController(text: appConfigManager.serverUrl);
                                  return AlertDialog(
                                    title: const Text('设置服务器地址'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(hintText: '请输入服务器地址'),
                                    ),
                                    actions: [
                                      SoundButton.text(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('取消'),
                                      ),
                                      SoundButton.text(
                                        onPressed: () => Navigator.pop(context, controller.text),
                                        child: const Text('确定'),
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
                          '主题颜色',
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
                          '棋子风格',
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
                          '引擎设置',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('引擎等级'),
                                subtitle: Text('当前：${appConfigManager.engineLevel}'),
                                onTap: () => _showEngineLevelDialog(context, appConfigManager),
                              ),
                              SwitchListTile(
                                title: const Text('时间控制模式'),
                                subtitle: Text(appConfigManager.useTimeControl ? '限制时间' : '限制深度'),
                                value: appConfigManager.useTimeControl,
                                onChanged: (value) => appConfigManager.setUseTimeControl(value),
                              ),
                              if (appConfigManager.useTimeControl)
                                ListTile(
                                  title: const Text('思考时间'),
                                  subtitle: Text('${appConfigManager.moveTime}毫秒'),
                                  onTap: () => _showMoveTimeDialog(context, appConfigManager),
                                )
                              else
                                ListTile(
                                  title: const Text('搜索深度'),
                                  subtitle: Text('${appConfigManager.searchDepth}层'),
                                  onTap: () => _showSearchDepthDialog(context, appConfigManager),
                                ),
                              if (!Platform.isAndroid && !Platform.isIOS)
                                ListTile(
                                  title: const Text('引擎路径'),
                                  subtitle: Text(appConfigManager.enginePath),
                                  onTap: () async {
                                    final result = await _showEnginePathDialog(context, appConfigManager);
                                    if (result != null) appConfigManager.setEnginePath(result);
                                  },
                                ),
                              SwitchListTile(
                                title: const Text('显示引擎分析箭头'),
                                subtitle: const Text('在引擎思考时显示预测着法'),
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
            title: const Text('设置引擎路径'),
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: '请输入引擎路径'),
                  ),
                ),
                SoundButton.text(
                  onPressed: () async {
                    final path = await FilePicker.platform.pickFiles();
                    if (path != null) {
                      controller.text = path.files.single.path ?? '';
                    }
                  },
                  child: const Text('浏览'),
                ),
              ],
            ),
            actions: [
              SoundButton.text(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              SoundButton.text(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('确定'),
              ),
            ],
          );
        },
      );

  void _showEngineLevelDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: '设置引擎等级',
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
        title: '设置思考时间',
        initialValue: configManager.moveTime.toDouble(),
        min: 1000,
        max: 15000,
        divisions: 14,
        labelFormat: (value) => '${value.round()}毫秒',
        onChanged: (value) => configManager.setMoveTime(value.round()),
      ),
    );
  }

  void _showSearchDepthDialog(BuildContext context, ConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => _EngineSliderDialog(
        title: '设置搜索深度',
        initialValue: configManager.searchDepth.toDouble(),
        min: 1,
        max: 30,
        divisions: 29,
        labelFormat: (value) => '${value.round()}层',
        onChanged: (value) => configManager.setSearchDepth(value.round()),
      ),
    );
  }

  void _showThemeColorDialog(BuildContext context, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题颜色'),
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
        title: const Text('选择棋子风格'),
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
  Widget build(BuildContext context) {
    return AlertDialog(
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
        SoundButton.text(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
