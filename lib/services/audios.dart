import 'package:audioplayers/audioplayers.dart';

class Audios {
  Audios._internal();
  static final Audios _instance = Audios._internal();
  factory Audios() => _instance;

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _tonePlayer;

  init() async {}

  loopBgm() async {
    try {
      _bgmPlayer ??= AudioPlayer();
      await _bgmPlayer?.setPlayerMode(PlayerMode.mediaPlayer);
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer?.play(AssetSource('audios/bg_music.mp3'));
    } catch (_) {}
  }

  playSound(String soundFile) async {
    try {
      _tonePlayer ??= AudioPlayer();

      if (_tonePlayer?.state == PlayerState.playing) {
        await _tonePlayer?.stop();
      }

      await _tonePlayer?.play(
        AssetSource(soundFile),
        ctx: AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {}
  }

  stopBgm() {
    try {
      _bgmPlayer?.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      _bgmPlayer?.dispose();
      _tonePlayer?.dispose();
    } catch (_) {}
  }
}
