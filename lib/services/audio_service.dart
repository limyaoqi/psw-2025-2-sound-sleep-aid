import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();

  void dispose() {
    _player.dispose();
  }
}
