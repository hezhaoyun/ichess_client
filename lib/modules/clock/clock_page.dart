import 'package:flutter/material.dart';

import '../../widgets/chess_clock.dart';
import '../battle/battle_mixin.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  var selectedTimeControl = TimeControl.rapid_5_2;
  int? customTimeInMinutes;
  int? incrementInSeconds;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ChessClock(
          timeControl: selectedTimeControl,
          onTimeOut: (whiteTimeout) {
            if (whiteTimeout) {
              // TODO: Time out by white
            } else {
              // TODO: Time out by black
            }
          },
        ),
      );
}
