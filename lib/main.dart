import 'dart:io';

import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ichess/modules/game_viewer/games_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/config_manager.dart';
import 'game/theme_manager.dart';
import 'home_page.dart';
import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
import 'modules/board_setup/board_setup_page.dart';
import 'modules/clock/clock_page.dart';
import 'modules/opening_explorer/opening_explorer_page.dart';
import 'modules/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String languageCode = prefs.getString('language_code') ?? 'en';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager(), lazy: false),
        ChangeNotifierProvider(create: (_) => ConfigManager(), lazy: false),
      ],
      child: ChessApp(languageCode: languageCode),
    ),
  );
}

class ChessApp extends StatefulWidget {
  final String languageCode;
  const ChessApp({super.key, required this.languageCode});

  @override
  State<ChessApp> createState() => _ChessAppState();
}

class _ChessAppState extends State<ChessApp> with WidgetsBindingObserver {
  final _fluWakeLock = (Platform.isAndroid || Platform.isIOS) ? FluWakeLock() : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fluWakeLock?.enable();
  }

  @override
  Widget build(BuildContext context) {
    final configManager = Provider.of<ConfigManager>(context);

    return Consumer<ThemeManager>(
        builder: (context, themeManager, child) => MaterialApp(
              locale: Locale(configManager.language),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              title: AppLocalizations.of(context)?.appName ?? 'Chess Road',
              theme: themeManager.getTheme().copyWith(
                    textTheme: themeManager.getTheme().textTheme.apply(fontFamily: 'ZCOOLXiaoWei'),
                  ),
              home: const HomePage(),
              routes: {
                Routes.onlineBattle: (context) => const OnlineBattlePage(),
                Routes.viewer: (context) => const GamesPage(),
                Routes.openingExplorer: (context) => const OpeningExplorerPage(),
                Routes.setup: (context) => const BoardSetupPage(),
                Routes.chessClock: (context) => const ClockPage(),
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
            ));
  }

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
