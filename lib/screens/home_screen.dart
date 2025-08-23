import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';
import '../widgets/player_card.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/track_library_sheet.dart';
import '../services/catalog_service.dart';
import '../services/preferences_service.dart';
import '../models/audio_track.dart';
import '../services/audio_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AudioTrack? _current;
  bool _loading = true;
  late final AudioService _audio;
  StreamSubscription<dynamic>? _playingSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  bool _isPlaying = false;
  double _progress = 0.0; // 0..1

  @override
  void initState() {
    super.initState();
    _audio = AudioService();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = PreferencesService();
      final savedId = await prefs.getSelectedTrackId();
      final tracks = await CatalogService().fetchTracks();
      if (tracks.isNotEmpty) {
        if (savedId != null) {
          _current = tracks.firstWhere(
            (t) => t.id == savedId,
            orElse: () => tracks.first,
          );
        } else {
          // first-time user: pick first track
          _current = tracks.first;
          await prefs.setSelectedTrackId(_current!.id);
        }

        // prepare audio for the selected track
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
    final url = _current?.url;
    if (url == null || url.isEmpty) return;
    try {
      await _audio.setUrl(url);
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
    });

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

  void _openLibrary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => TrackLibrarySheet(
        onSelect: (track) async {
          setState(() => _current = track);
          await PreferencesService().setSelectedTrackId(track.id);
          await _setCurrentTrackUrl();
        },
      ),
    );
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
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
                      : PlayerCard(
                          title: _current?.title ?? 'No track',
                          subtitle: _current?.category,
                          isPlaying: _isPlaying,
                          onPlay: _onPlay,
                          onPause: _onPause,
                          progress: _progress,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: BottomMenu(onLibrary: _openLibrary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
