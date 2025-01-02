import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/audios.dart';
import 'sound_buttons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum GameResult { win, draw, lose }

class GameResultDialog extends StatelessWidget {
  final String title, message;
  final GameResult result;
  const GameResultDialog({super.key, required this.title, required this.message, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == GameResult.win) {
      Audios().playSound('sounds/win.mp3');
    } else if (result == GameResult.draw) {
      Audios().playSound('sounds/draw.mp3');
    } else {
      Audios().playSound('sounds/lose.mp3');
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (result == GameResult.win ? Colors.yellow : Colors.blue).withAlpha(0x33),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Lottie.asset(
                result == GameResult.win ? 'assets/animations/victory.json' : 'assets/animations/game_over.json',
                repeat: result == GameResult.win,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: result == GameResult.win ? Colors.orange : Colors.blue,
                shadows: [
                  Shadow(
                    color: (result == GameResult.win ? Colors.orange : Colors.blue).withAlpha(0x33),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            SoundButton.elevated(
              style: ElevatedButton.styleFrom(
                backgroundColor: result == GameResult.win ? Colors.orange : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
