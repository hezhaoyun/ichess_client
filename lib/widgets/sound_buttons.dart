import 'package:flutter/material.dart';

import '../services/audio_service.dart';

class SoundButton {
  static TextButton text({required Widget child, VoidCallback? onPressed, ButtonStyle? style}) =>
      TextButton(onPressed: () => wrapAction(onPressed), style: style, child: child);

  static IconButton icon({required Icon icon, VoidCallback? onPressed, String? tooltip, double? iconSize}) =>
      IconButton(icon: icon, onPressed: () => wrapAction(onPressed), tooltip: tooltip, iconSize: iconSize);

  static ElevatedButton elevated({required Widget child, VoidCallback? onPressed, ButtonStyle? style}) =>
      ElevatedButton(onPressed: () => wrapAction(onPressed), style: style, child: child);

  static ElevatedButton iconElevated(
          {required Widget label, required Widget icon, VoidCallback? onPressed, ButtonStyle? style}) =>
      ElevatedButton.icon(onPressed: () => wrapAction(onPressed), style: style, label: label, icon: icon);

  static wrapAction(VoidCallback? onPressed) {
    _playSound();
    if (onPressed != null) onPressed();
  }

  static void _playSound() => AudioService.playSound('sounds/button.mp3');
}
