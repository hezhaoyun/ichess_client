import 'dart:io';

import 'package:flu_wake_lock/flu_wake_lock.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _fluWakeLock = (Platform.isAndroid || Platform.isIOS) ? FluWakeLock() : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fluWakeLock?.enable();
  }

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
              final args = settings.arguments as Map<String, dynamic>?;
              final fen = args?['fen'] as String?;
              return MaterialPageRoute(builder: (context) => AIBattlePage(initialFen: fen));
            }
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
            );
          },
          debugShowCheckedModeBanner: false,
        ),
      );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _fluWakeLock?.enable();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _fluWakeLock?.disable();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
