import 'package:flutter/material.dart';

import '../services/audios.dart';

class SoundButton {
  static TextButton text({
    required Widget child,
    VoidCallback? onPressed,
    String? sound,
    ButtonStyle? style,
  }) =>
      TextButton(
        onPressed: () => wrapAction(onPressed, sound: sound),
        style: style,
        child: child,
      );

  static IconButton icon({
    required Icon icon,
    VoidCallback? onPressed,
    String? sound,
    String? tooltip,
    double? iconSize,
  }) =>
      IconButton(
        icon: icon,
        onPressed: () => wrapAction(onPressed, sound: sound),
        tooltip: tooltip,
        iconSize: iconSize,
      );

  static ElevatedButton elevated({
    required Widget child,
    VoidCallback? onPressed,
    String? sound,
    ButtonStyle? style,
  }) =>
      ElevatedButton(
        onPressed: () => wrapAction(onPressed, sound: sound),
        style: style,
        child: child,
      );

  static ElevatedButton iconElevated({
    required Widget label,
    required Widget icon,
    VoidCallback? onPressed,
    String? sound,
    ButtonStyle? style,
  }) =>
      ElevatedButton.icon(
        onPressed: () => wrapAction(onPressed, sound: sound),
        style: style,
        label: label,
        icon: icon,
      );

  static wrapAction(VoidCallback? onPressed, {String? sound}) {
    _playSound(sound ?? 'sounds/button.mp3');
    if (onPressed != null) onPressed();
  }

  static void _playSound(String sound) => Audios().playSound(sound);
}
