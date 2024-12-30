import 'package:flutter/material.dart';
import 'package:ichess/modules/game_viewer/games_page.dart';
import 'package:provider/provider.dart';

import 'game/config_manager.dart';
import 'home_page.dart';
import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
import 'modules/board_setup/board_setup_page.dart';
import 'modules/settings/settings_page.dart';
import 'game/theme_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => ConfigManager(), lazy: false),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ThemeManager>(
        builder: (context, themeManager, child) => MaterialApp(
          title: 'Chess Road',
          theme: themeManager.getTheme().copyWith(
                textTheme: themeManager.getTheme().textTheme.apply(
                      fontFamily: 'Komigo3D-Regular',
                    ),
              ),
          home: const HomePage(),
          routes: {
            Routes.onlineBattle: (context) => const OnlineBattlePage(),
            Routes.viewer: (context) => const GamesPage(),
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
