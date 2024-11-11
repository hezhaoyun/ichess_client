import 'package:flutter/material.dart';

import 'modules/battle/battle_page.dart';
import 'modules/view/view_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('棋路-国际象棋')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BattlePage()),
              ),
              child: const Text('在线对战'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewPage(),
                ),
              ),
              child: const Text('阅读棋谱'),
            ),
          ],
        ),
      ),
    );
  }
}
