import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioPlayer? audioPlayer;
  static void playSound(String soundFile) {
    audioPlayer ??= AudioPlayer();
    audioPlayer?.play(AssetSource(soundFile));
  }
}
