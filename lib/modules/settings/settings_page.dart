import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config_manager.dart';
import '../../theme/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final appConfigManager = Provider.of<AppConfigManager>(context);

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
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              TextButton(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: themeManager.themes.length,
                  itemBuilder: (context, index) {
                    final themeName = themeManager.themes.keys.elementAt(index);
                    final themeColor = themeManager.themes[themeName]!;
                    final isSelected = themeColor == themeManager.primaryColor;

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                        ),
                        title: Text(themeName),
                        trailing: isSelected ? Icon(Icons.check_circle, color: themeColor) : null,
                        onTap: () => themeManager.setTheme(themeName),
                      ),
                    );
                  },
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

  void _showEngineLevelDialog(BuildContext context, AppConfigManager configManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置引擎等级'),
        content: Slider(
          value: configManager.engineLevel.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: configManager.engineLevel.toString(),
          onChanged: (value) => configManager.setEngineLevel(value.round()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMoveTimeDialog(BuildContext context, AppConfigManager configManager) {
    // 实现移动时间对话框的逻辑
  }

  void _showSearchDepthDialog(BuildContext context, AppConfigManager configManager) {
    // 实现搜索深度对话框的逻辑
  }
}
