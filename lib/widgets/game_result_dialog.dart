import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GameResultDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isVictory;
  const GameResultDialog({super.key, required this.title, required this.message, this.isVictory = false});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isVictory ? Colors.yellow : Colors.blue).withAlpha(0x33),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 这里使用 Lottie 动画，你需要准备对应的动画文件
              SizedBox(
                height: 120,
                child: Lottie.asset(
                  isVictory ? 'assets/animations/victory.json' : 'assets/animations/game_over.json',
                  repeat: isVictory,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isVictory ? Colors.orange : Colors.blue,
                  shadows: [
                    Shadow(
                      color: (isVictory ? Colors.orange : Colors.blue).withAlpha(0x33),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVictory ? Colors.orange : Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '确定',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
}
