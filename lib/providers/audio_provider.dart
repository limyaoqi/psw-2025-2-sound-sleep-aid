import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/audio_track.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _service;
  final DownloadService _downloadService;
  List<AudioTrack> _playlist = [];
  int _currentIndex = 0;
  final Map<String, bool> _downloading = {};
  Timer? _timer;
  DateTime? _timerEnd;

  AudioProvider(this._service, [DownloadService? downloadService])
    : _downloadService = downloadService ?? DownloadService();

  List<AudioTrack> get playlist => _playlist;
  AudioTrack? get current =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];

  bool isDownloading(String id) => _downloading[id] == true;

  Duration? get timerRemaining {
    if (_timer == null || _timerEnd == null) return null;
    final rem = _timerEnd!.difference(DateTime.now());
    if (rem.isNegative) return Duration.zero;
    return rem;
  }

  bool get timerActive => _timer != null;

  Future<void> setPlaylist(List<AudioTrack> tracks) async {
    _playlist = tracks;
    _currentIndex = 0;
    if (current != null)
      await _service.setUrl(current!.localPath ?? current!.url);
    notifyListeners();
  }

  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _service.setUrl(current!.localPath ?? current!.url);
    await _service.play();
    notifyListeners();
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1) % _playlist.length;
    if (_currentIndex < 0) _currentIndex += _playlist.length;
    await _service.setUrl(current!.localPath ?? current!.url);
    await _service.play();
    notifyListeners();
  }

  void disposeService() {
    _service.dispose();
    super.dispose();
  }

  Future<void> downloadTrack(AudioTrack track) async {
    _downloading[track.id] = true;
    notifyListeners();
    try {
      final filename = '${track.id}.mp3';
      final path = await _downloadService.downloadToLocal(track.url, filename);
      track.localPath = path;
      notifyListeners();
    } finally {
      _downloading.remove(track.id);
      notifyListeners();
    }
  }

  Future<void> deleteDownloaded(AudioTrack track) async {
    if (track.localPath == null) return;
    try {
      await _downloadService.deleteLocal(track.localPath!);
    } catch (_) {}
    track.localPath = null;
    notifyListeners();
  }

  void setTimer(Duration d) {
    cancelTimer();
    _timerEnd = DateTime.now().add(d);
    _timer = Timer(d, () async {
      await _service.pause();
      cancelTimer();
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _timerEnd = null;
    notifyListeners();
  }
}
