import 'package:flutter/material.dart';

class WinPercentageChart extends StatelessWidget {
  Color _whiteBoxColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.8) : Colors.white;

  Color _blackBoxColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.black.withValues(alpha: 0.7) : Colors.black;

  const WinPercentageChart({super.key, required this.whiteWins, required this.draws, required this.blackWins});

  final int whiteWins;
  final int draws;
  final int blackWins;

  int percentGames(int games) => ((games / (whiteWins + draws + blackWins)) * 100).round();
  String label(int percent) => percent < 20 ? '' : '$percent%';

  @override
  Widget build(BuildContext context) {
    final percentWhite = percentGames(whiteWins);
    final percentDraws = percentGames(draws);
    final percentBlack = percentGames(blackWins);

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Row(
        children: [
          Expanded(
            flex: percentWhite,
            child: ColoredBox(
              color: _whiteBoxColor(context),
              child: Text(
                label(percentWhite),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: percentDraws,
            child: ColoredBox(
              color: Colors.grey,
              child: Text(
                label(percentDraws),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: percentBlack,
            child: ColoredBox(
              color: _blackBoxColor(context),
              child: Text(
                label(percentBlack),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
