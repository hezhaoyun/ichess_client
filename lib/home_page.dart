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
    // 获取屏幕方向
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final gridCrossAxisCount = isLandscape ? 4 : 2;

    final header = Padding(
      padding: EdgeInsets.only(
        top: isLandscape ? 20 : 40,
        left: 4,
      ),
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
              crossAxisCount: gridCrossAxisCount,
              mainAxisSpacing: isLandscape ? 24 : 16,
              crossAxisSpacing: isLandscape ? 24 : 16,
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 32 : 8,
                vertical: isLandscape ? 8 : 0,
              ),
              children: [
                _buildAnimatedCard(
                  icon: Icons.computer,
                  label: 'Player vs AI',
                  onTap: () => _animateAndNavigate(Routes.aiBattle),
                ),
                _buildAnimatedCard(
                  icon: Icons.people,
                  label: 'Play Online',
                  onTap: () => _animateAndNavigate(Routes.onlineBattle),
                ),
                _buildAnimatedCard(
                  icon: Icons.menu_book,
                  label: 'View Games',
                  onTap: () => _animateAndNavigate(Routes.viewer),
                ),
                _buildAnimatedCard(
                  icon: Icons.swipe_right,
                  label: 'Setup Board',
                  onTap: () => _animateAndNavigate(Routes.setup),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isLandscape ? 80 : 100,
            child: Lottie.asset('assets/animations/chess.json'),
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
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 24.0 : 24.0,
              vertical: isLandscape ? 8.0 : 0,
            ),
            child: Column(
              children: [
                header,
                SizedBox(height: isLandscape ? 24 : 48),
                grid,
                SizedBox(height: isLandscape ? 8 : 0),
                footer,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 新增带动画效果的卡片构建方法
  Widget _buildAnimatedCard({required IconData icon, required String label, required VoidCallback onTap}) =>
      AnimatedBuilder(
        animation: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1),
        builder: (context, child) => Hero(
          tag: label,
          child: Card(
            elevation: 4,
            shadowColor: Theme.of(context).colorScheme.primary.withAlpha(0x40),
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
                child: _buildCardContent(icon, label),
              ),
            ),
          ),
        ),
      );

  // 新增卡片内容构建方法
  Widget _buildCardContent(IconData icon, String label) {
    return Column(
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
    );
  }

  // 新增页面跳转动画方法
  void _animateAndNavigate(String route) {
    Audios().playSound('sounds/button.mp3');
    Navigator.of(context).pushNamed(route, arguments: {'fromHome': true});
  }
}
