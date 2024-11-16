import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

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
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(themeName),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: themeColor,
                              )
                            : null,
                        onTap: () => themeManager.setTheme(themeName),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
