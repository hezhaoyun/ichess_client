import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config_manager.dart';
import 'theme/theme_manager.dart';
import 'home_page.dart';
import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
import 'modules/board_setup/board_setup_page.dart';
import 'modules/manual_viewer/viewer_page.dart';
import 'modules/settings/settings_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => AppConfigManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) => MaterialApp(
        title: '棋路',
        theme: themeManager.getTheme(),
        home: const HomePage(),
        routes: {
          Routes.onlineBattle: (context) => const OnlineBattlePage(),
          Routes.viewer: (context) => const ViewerPage(),
          Routes.setup: (context) => const BoardSetupPage(),
          Routes.settings: (context) => const SettingsPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == Routes.aiBattle) {
            final fen = settings.arguments as String?;
            return MaterialPageRoute(builder: (context) => AIBattlePage(initialFen: fen));
          }
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
