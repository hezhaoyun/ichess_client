import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'services/audios.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Route constants
class Routes {
  static const aiBattle = '/ai-battle';
  static const onlineBattle = '/online-battle';
  static const viewer = '/viewer';
  static const setup = '/setup';
  static const settings = '/settings';
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: const EdgeInsets.only(top: 40, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icons/icon-a.png', width: 32, height: 32),
              const SizedBox(width: 10),
              Text(
                'Chess Road',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Audios().playSound('sounds/button.mp3');
                  Navigator.pushNamed(context, Routes.settings);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Explore the infinite possibilities of chess',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    final grid = Expanded(
      child: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCard(
                  icon: Icons.computer,
                  label: 'Player vs AI',
                  onTap: () {
                    Audios().playSound('sounds/button.mp3');
                    Navigator.pushNamed(context, Routes.aiBattle);
                  },
                ),
                _buildCard(
                  icon: Icons.people,
                  label: 'Play Online',
                  onTap: () {
                    Audios().playSound('sounds/button.mp3');
                    Navigator.pushNamed(context, Routes.onlineBattle);
                  },
                ),
                _buildCard(
                  icon: Icons.menu_book,
                  label: 'View Games',
                  onTap: () {
                    Audios().playSound('sounds/button.mp3');
                    Navigator.pushNamed(context, Routes.viewer);
                  },
                ),
                _buildCard(
                  icon: Icons.swipe_right,
                  label: 'Setup Board',
                  onTap: () {
                    Audios().playSound('sounds/button.mp3');
                    Navigator.pushNamed(context, Routes.setup);
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: Lottie.asset('assets/animations/chess.json', repeat: true, animate: true),
          ),
        ],
      ),
    );

    final footer = Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Text(
          'ChessRoad v1.0.0 · ♟️',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              ),
        ),
      ),
    );

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [header, const SizedBox(height: 48), grid, footer],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String label, required VoidCallback onTap}) => Hero(
        tag: label,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withAlpha(0x1A),
              width: 1,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).cardColor.withAlpha(0xCC),
                ],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    builder: (context, double value, child) => Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(0x1A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
