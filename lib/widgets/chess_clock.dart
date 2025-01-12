import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../modules/battle/battle_mixin.dart';
import '../services/audios.dart';

typedef TimeOutCallback = void Function(bool whiteTimeout);

class ChessClock extends StatefulWidget {
  final TimeControl timeControl;
  final TimeOutCallback onTimeOut;
  const ChessClock({super.key, required this.timeControl, required this.onTimeOut});

  @override
  State<ChessClock> createState() => _ChessClockState();
}

class _ChessClockState extends State<ChessClock> {
  late int whiteTimeLeft, blackTimeLeft;
  TimeControl? timeControl;

  Timer? timer;
  bool isRunning = false;
  bool isWhiteTurn = true;

  @override
  void initState() {
    super.initState();
    timeControl = widget.timeControl;
    _resetTime();
  }

  void _resetTime() {
    whiteTimeLeft = timeControl!.totalTimeInSeconds;
    blackTimeLeft = timeControl!.totalTimeInSeconds;
  }

  void _startTimer() {
    if (timer?.isActive ?? false) return;

    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (isWhiteTurn) {
          whiteTimeLeft--;
          if (whiteTimeLeft < 10) Audios().playSound('sounds/low_time.mp3');
          if (whiteTimeLeft <= 0) _handleTimeout();
        } else {
          blackTimeLeft--;
          if (blackTimeLeft < 10) Audios().playSound('sounds/low_time.mp3');
          if (blackTimeLeft <= 0) _handleTimeout();
        }
      });
    });
  }

  void _pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void _handleTimeout() {
    timer?.cancel();
    widget.onTimeOut(isWhiteTurn);
  }

  void _switchTurn() {
    if (!isRunning) return;

    Audios().playSound('sounds/clock.mp3');

    setState(() {
      isWhiteTurn = !isWhiteTurn;

      if (isWhiteTurn) {
        blackTimeLeft += timeControl!.incrementInSeconds;
      } else {
        whiteTimeLeft += timeControl!.incrementInSeconds;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final whiteCardColor = isWhiteTurn && isRunning ? Theme.of(context).primaryColor : null;
    final blackCardColor = !isWhiteTurn && isRunning ? Theme.of(context).primaryColor : null;

    final whiteTextColor = whiteTimeLeft <= 10
        ? Colors.red
        : isWhiteTurn && isRunning
            ? Colors.white
            : Colors.black45;
    final blackTextColor = blackTimeLeft <= 10
        ? Colors.red
        : !isWhiteTurn && isRunning
            ? Colors.white
            : Colors.black45;

    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 2,
            child: GestureDetector(
              onTap: () => _switchTurn(),
              child: Container(
                color: blackCardColor,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: blackTimeLeft <= 10 ? 80 : 60,
                      color: blackTextColor,
                    ),
                    child: Text(
                      '${blackTimeLeft ~/ 60}:${(blackTimeLeft % 60).toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 50,
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  _pauseTimer();
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
              IconButton(
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                onPressed: isRunning ? _pauseTimer : _startTimer,
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  timer?.cancel();
                  setState(() {
                    isRunning = false;
                    _resetTime();
                  });
                },
                color: Colors.white,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _switchTurn(),
            child: Container(
              color: whiteCardColor,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: whiteTimeLeft <= 10 ? 80 : 60,
                    color: whiteTextColor,
                  ),
                  child: Text(
                    '${whiteTimeLeft ~/ 60}:${(whiteTimeLeft % 60).toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    _pauseTimer();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.timeControl),
            const SizedBox(height: 10),
            CupertinoSegmentedControl<TimeControl>(
              children: {
                for (var control in TimeControl.values)
                  control: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      control.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: timeControl == control
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              },
              groupValue: timeControl,
              onValueChanged: (TimeControl value) {
                Navigator.pop(context);
                setState(() {
                  timeControl = value;
                  _resetTime();
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              unselectedColor: Theme.of(context).colorScheme.surface,
              borderColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
