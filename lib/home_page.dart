import 'package:flutter/material.dart';

import 'modules/battle/ai_battle_page.dart';
import 'modules/battle/online_battle_page.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                '棋路',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                '探索国际象棋的无限可能',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              _buildButton(
                icon: Icons.computer,
                label: '人机对战',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIBattlePage()),
                ),
              ),
              const SizedBox(height: 32),
              _buildButton(
                icon: Icons.people,
                label: '在线对战',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnlineBattlePage()),
                ),
              ),
              const SizedBox(height: 32),
              _buildButton(
                icon: Icons.menu_book,
                label: '阅读棋谱',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewPage()),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 280,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
