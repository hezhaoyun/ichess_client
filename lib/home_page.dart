import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    // h:120
    final header = SizedBox(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/icons/icon-a.png', width: 32, height: 32),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.appName,
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
              AppLocalizations.of(context)!.exploreTheInfinitePossibilitiesOfChess,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    // h:140
    final footer = SizedBox(
      height: 140,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100, child: Lottie.asset('assets/animations/chess.json')),
              Text(
                '${AppLocalizations.of(context)!.appName} v1.0.0 · ♟️',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                    ),
              ),
            ],
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
          child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth, h = constraints.maxHeight;
            return Column(children: [header, _buildGrid(w, h), footer]);
          }),
        ),
      ),
    );
  }

  Expanded _buildGrid(double w, double h) {
    final isLandscape = w > h;

    final availableHeight = h -
        // kToolbarHeight - // 顶部工具栏
        MediaQuery.of(context).padding.top - // 状态栏
        MediaQuery.of(context).padding.bottom - // 底部安全区域
        280; // 间距 120 + 140 + 20

    final height = isLandscape ? availableHeight : min(availableHeight, w);
    final size = isLandscape ? (w - 32 * 2 - 20 * 3) / 4 : (height - 32 * 2 - 20) / 2;

    return Expanded(
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: isLandscape ? size : size * 2 + 20,
            child: SizedBox(
              width: isLandscape ? size * 4 + 20 * 3 : size * 2 + 20,
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildAnimatedCard(
                    Icons.computer,
                    AppLocalizations.of(context)!.humanVsAi,
                    onTap: () => _animateAndNavigate(Routes.aiBattle),
                    size: size,
                  ),
                  _buildAnimatedCard(
                    Icons.people,
                    AppLocalizations.of(context)!.playOnline,
                    onTap: () => _animateAndNavigate(Routes.onlineBattle),
                    size: size,
                  ),
                  _buildAnimatedCard(
                    Icons.menu_book,
                    AppLocalizations.of(context)!.viewGames,
                    onTap: () => _animateAndNavigate(Routes.viewer),
                    size: size,
                  ),
                  _buildAnimatedCard(
                    Icons.swipe_right,
                    AppLocalizations.of(context)!.setupBoard,
                    onTap: () => _animateAndNavigate(Routes.setup),
                    size: size,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // 新增带动画效果的卡片构建方法
  Widget _buildAnimatedCard(IconData icon, String label, {required VoidCallback onTap, required double size}) =>
      AnimatedBuilder(
        animation: ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1),
        builder: (context, child) => Hero(
          tag: label,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withAlpha(0xCC)],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: _buildCardContent(icon, label, size),
            ),
          ),
        ),
      );

  // 新增卡片内容构建方法
  Widget _buildCardContent(IconData icon, String label, double size) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0.8, end: 1.0),
            builder: (context, double value, child) => Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.all(size * 0.15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(0x1A),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: size * 0.28, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          SizedBox(height: size * 0.06),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
          ),
        ],
      );

  // 新增页面跳转动画方法
  void _animateAndNavigate(String route) {
    Audios().playSound('sounds/button.mp3');
    Navigator.of(context).pushNamed(route, arguments: {'fromHome': true});
  }
}
