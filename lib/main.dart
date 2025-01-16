import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ichess/modules/game_viewer/games_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../i18n/generated/app_localizations.dart';
import 'home_page.dart';
import 'model/config_manager.dart';
import 'model/theme_manager.dart';
import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
import 'modules/free_board/free_board_page.dart';
import 'modules/clock/clock_page.dart';
import 'modules/opening_explorer/opening_explorer_page.dart';
import 'modules/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String languageCode = prefs.getString('language_code') ?? 'en';

  runApp(ProviderScope(child: ChessApp(languageCode: languageCode)));
}

class ChessApp extends ConsumerWidget {
  final String languageCode;
  const ChessApp({super.key, required this.languageCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);
    final config = ref.watch(configManagerProvider);

    return MaterialApp(
      locale: Locale(config.language),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: AppLocalizations.of(context)?.appName ?? 'Chess Road',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: theme.primaryColor),
        fontFamily: 'ZCOOLXiaoWei',
      ),
      home: const HomePage(),
      routes: {
        Routes.onlineBattle: (context) => const OnlineBattlePage(),
        Routes.viewer: (context) => const GamesPage(),
        Routes.openingExplorer: (context) => const OpeningExplorerPage(),
        Routes.freeBoard: (context) => const FreeBoardPage(),
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
    );
  }
}
