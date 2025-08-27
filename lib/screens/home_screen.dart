import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';
import '../widgets/player_card.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/track_library_sheet.dart';
import '../services/catalog_service.dart';
import '../services/preferences_service.dart';
import '../models/audio_track.dart';
import '../services/audio_service.dart';
import '../services/download_service.dart';
import '../services/app_state.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AudioTrack> _tracks = const [];
  int _currentIndex = -1; // -1 = none
  bool _loading = true;
  late final AudioService _audio;
  StreamSubscription<dynamic>? _playingSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  bool _isPlaying = false;
  double _progress = 0.0; // 0..1
  // simple sleep timer
  Timer? _sleepTimer;
  DateTime? _sleepEnd;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _looping = false; // false=sequential, true=loop playlist
  StreamSubscription<ProcessingState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _audio = AudioService();
    _watchConnectivity();
    _bootstrap();
  }

  void _watchConnectivity() async {
    final initial = await Connectivity().checkConnectivity();
    final online = initial != ConnectivityResult.none;
    if (mounted) setState(() => _isOnline = online);
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final on = results.any((r) => r != ConnectivityResult.none);
      if (mounted && on != _isOnline) setState(() => _isOnline = on);
    });
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = PreferencesService();
      final savedId = await prefs.getSelectedTrackId();
      final downloaded = await PreferencesService().getDownloadedTracks();
      try {
        _tracks = await CatalogService().fetchTracks();
        // cache catalog for offline view
        await PreferencesService().setCachedCatalog(_tracks);
        // merge downloaded localPath into fetched tracks
        if (downloaded.isNotEmpty) {
          final map = {for (var d in downloaded) d.id: d};
          _tracks = _tracks
              .map(
                (t) => map.containsKey(t.id)
                    ? AudioTrack(
                        id: t.id,
                        title: t.title,
                        category: t.category,
                        url: t.url,
                        localPath: map[t.id]!.localPath,
                      )
                    : t,
              )
              .toList();
        }
      } catch (_) {
        // offline: try cached catalog; otherwise fallback to downloaded only
        final cached = await PreferencesService().getCachedCatalog();
        if (cached.isNotEmpty) {
          if (downloaded.isNotEmpty) {
            final map = {for (var d in downloaded) d.id: d};
            _tracks = cached
                .map(
                  (t) => map.containsKey(t.id)
                      ? AudioTrack(
                          id: t.id,
                          title: t.title,
                          category: t.category,
                          url: t.url,
                          localPath: map[t.id]!.localPath,
                        )
                      : t,
                )
                .toList();
          } else {
            _tracks = cached;
          }
        } else {
          _tracks = downloaded;
        }
      }

      if (_tracks.isNotEmpty) {
        if (savedId != null) {
          final idx = _tracks.indexWhere((t) => t.id == savedId);
          _currentIndex = idx >= 0 ? idx : 0;
        } else {
          _currentIndex = 0;
          await prefs.setSelectedTrackId(_tracks[_currentIndex].id);
        }

        await _setCurrentTrackUrl();
        _attachPlayerListeners();
      }
    } catch (_) {
      // keep _current null
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setCurrentTrackUrl() async {
    if (!(_currentIndex >= 0 && _currentIndex < _tracks.length)) return;
    final t = _tracks[_currentIndex];
    final source = (t.localPath != null && t.localPath!.isNotEmpty)
        ? t.localPath!
        : t.url;
    if (source.isEmpty) return;
    try {
      await _audio.setUrl(source);
    } catch (_) {
      // ignore for now; could show a snackbar
    }
  }

  void _attachPlayerListeners() {
    // playing state
    _playingSub?.cancel();
    _playingSub = _audio.player.playingStream.listen((playing) {
      if (!mounted) return;
      setState(() => _isPlaying = playing);
      // reflect global flag
      AppState.I.isAudioPlaying.value = playing;
    });
    // initialize once
    AppState.I.isAudioPlaying.value = _audio.player.playing;

    // position/duration to compute progress
    _posSub?.cancel();
    _durSub?.cancel();
    Duration? total;
    _durSub = _audio.player.durationStream.listen((d) {
      total = d;
    });
    _posSub = _audio.player.positionStream.listen((pos) {
      if (!mounted) return;
      final dur = total ?? _audio.player.duration;
      if (dur == null || dur.inMilliseconds == 0) {
        setState(() => _progress = 0.0);
      } else {
        final p = pos.inMilliseconds / dur.inMilliseconds;
        setState(() => _progress = p.clamp(0.0, 1.0));
      }
    });

    // processing state for auto-advance
    _stateSub?.cancel();
    _stateSub = _audio.player.processingStateStream.listen((state) async {
      if (!mounted) return;
      if (state == ProcessingState.completed) {
        if (_looping) {
          await _onNext();
        } else {
          try {
            await _audio.stop();
          } catch (_) {}
        }
      }
    });
  }

  Future<void> _onPlay() async {
    try {
      await _audio.play();
    } catch (_) {}
  }

  Future<void> _onPause() async {
    try {
      await _audio.pause();
    } catch (_) {}
  }

  bool get _canPrevious =>
      _tracks.isNotEmpty && (_looping || _currentIndex > 0);
  bool get _canNext =>
      _tracks.isNotEmpty && (_looping || _currentIndex < _tracks.length - 1);

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  Future<void> _onNext() async {
    if (_tracks.isEmpty) return;
    if (_currentIndex >= _tracks.length - 1) {
      if (_looping) {
        setState(() => _currentIndex = 0);
      } else {
        _toast('Already the last track');
        return;
      }
    } else {
      setState(() => _currentIndex += 1);
    }
    await PreferencesService().setSelectedTrackId(_tracks[_currentIndex].id);
    await _setCurrentTrackUrl();
    await _onPlay();
  }

  Future<void> _onPrevious() async {
    if (_tracks.isEmpty) return;
    if (_currentIndex <= 0) {
      if (_looping) {
        setState(() => _currentIndex = _tracks.length - 1);
      } else {
        _toast('Already the first track');
        return;
      }
    } else {
      setState(() => _currentIndex -= 1);
    }
    await PreferencesService().setSelectedTrackId(_tracks[_currentIndex].id);
    await _setCurrentTrackUrl();
    await _onPlay();
  }

  void _openLibrary() {
    _openLibrarySheet(initialTab: 0);
  }

  void _openLibrarySheet({int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => TrackLibrarySheet(
        initialTab: initialTab,
        onSelect: (track) async {
          final idx = _tracks.indexWhere((t) => t.id == track.id);
          setState(() {
            if (idx >= 0) {
              // replace to keep latest localPath info
              _tracks = List.of(_tracks);
              _tracks[idx] = track;
              _currentIndex = idx;
            } else {
              // if track not found in current cache, append it
              _tracks = List.of(_tracks)..add(track);
              _currentIndex = _tracks.length - 1;
            }
          });
          await PreferencesService().setSelectedTrackId(
            _tracks[_currentIndex].id,
          );
          await _setCurrentTrackUrl();
        },
      ),
    );
  }

  void _openTimer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        Widget item(String label, Duration? d) => ListTile(
          leading: const Icon(Icons.timer),
          title: Text(label),
          onTap: () {
            Navigator.of(ctx).maybePop();
            if (d == null) {
              _cancelSleepTimer();
            } else {
              _setSleepTimer(d);
            }
          },
        );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              if (_sleepEnd != null)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Timer set until ${_sleepEnd!.hour.toString().padLeft(2, '0')}:${_sleepEnd!.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              item('15 minutes', const Duration(minutes: 15)),
              item('30 minutes', const Duration(minutes: 30)),
              item('60 minutes', const Duration(minutes: 60)),
              const Divider(height: 1),
              item('Cancel timer', null),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _setSleepTimer(Duration d) {
    _sleepTimer?.cancel();
    _sleepEnd = DateTime.now().add(d);
    AppState.I.hasSleepTimer.value = true;
    _sleepTimer = Timer(d, () async {
      await _audio.pause();
      _sleepTimer = null;
      _sleepEnd = null;
      AppState.I.hasSleepTimer.value = false;
      if (mounted) {
        _toast('Timer ended');
        setState(() {});
      }
    });
    _toast('Timer set for ${d.inMinutes} minutes');
    setState(() {});
  }

  void _cancelSleepTimer() {
    if (_sleepTimer != null) {
      _sleepTimer!.cancel();
      _sleepTimer = null;
      _sleepEnd = null;
      AppState.I.hasSleepTimer.value = false;
      _toast('Timer canceled');
      setState(() {});
    }
  }

  Future<void> _downloadCurrent() async {
    if (!(_currentIndex >= 0 && _currentIndex < _tracks.length)) return;
    final t = _tracks[_currentIndex];
    if (t.localPath != null && t.localPath!.isNotEmpty) {
      _toast('Already downloaded');
      return;
    }
    if (!_isOnline) {
      _toast('No internet — connect to download');
      return;
    }
    try {
      final path = await DownloadService().downloadToLocal(
        t.url,
        '${t.id}.mp3',
      );
      final updated = AudioTrack(
        id: t.id,
        title: t.title,
        category: t.category,
        url: t.url,
        localPath: path,
      );
      _tracks = List.of(_tracks);
      _tracks[_currentIndex] = updated;
      await PreferencesService().addDownloadedTrack(updated);
      setState(() {});
      _toast('Downloaded');
    } catch (_) {
      _toast('Download failed');
    }
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _sleepTimer?.cancel();
    _connSub?.cancel();
    _stateSub?.cancel();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : (_tracks.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.wifi_off,
                                    size: 48,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isOnline
                                        ? 'No tracks available.'
                                        : 'You\'re offline. Download tracks when online to listen here.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              )
                            : PlayerCard(
                                title:
                                    (_currentIndex >= 0 &&
                                        _currentIndex < _tracks.length)
                                    ? _tracks[_currentIndex].title
                                    : 'No track',
                                subtitle:
                                    (_currentIndex >= 0 &&
                                        _currentIndex < _tracks.length)
                                    ? _tracks[_currentIndex].category
                                    : null,
                                isPlaying: _isPlaying,
                                onPlay: _onPlay,
                                onPause: _onPause,
                                onNext: _onNext,
                                onPrevious: _onPrevious,
                                canNext: _canNext,
                                canPrevious: _canPrevious,
                                progress: _progress,
                              )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: BottomMenu(
                  onLibrary: _openLibrary,
                  onTimer: _openTimer,
                  onDownload:
                      (_currentIndex >= 0 &&
                          _currentIndex < _tracks.length &&
                          _tracks[_currentIndex].localPath == null &&
                          _isOnline)
                      ? _downloadCurrent
                      : null,
                  isLooping: _looping,
                  onToggleLoop: () => setState(() => _looping = !_looping),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
