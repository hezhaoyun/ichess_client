import 'package:flutter/material.dart';

import 'home_page.dart';
import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
import 'modules/board_setup/chess_setup_page.dart';
import 'modules/manual_viewer/viewer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '棋路',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          Routes.aiBattle: (context) => const AIBattlePage(),
          Routes.onlineBattle: (context) => const OnlineBattlePage(),
          Routes.viewer: (context) => const ViewerPage(),
          Routes.setup: (context) => const ChessSetupPage(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
}
