import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_track.dart';

class PreferencesService {
  static const _keySelectedTrackId = 'selected_track_id';
  static const _keyDownloadedTracks = 'downloaded_tracks';
  static const _keyCachedCatalog = 'cached_catalog';

  Future<String?> getSelectedTrackId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedTrackId);
  }

  Future<void> setSelectedTrackId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTrackId, id);
  }

  // Downloaded tracks persistence
  Future<List<AudioTrack>> getDownloadedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyDownloadedTracks);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = json.decode(jsonStr);
      if (list is! List) return [];
      return list
          .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDownloadedTracks(List<AudioTrack> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final list = tracks.map((t) => t.toJson()).toList();
    await prefs.setString(_keyDownloadedTracks, json.encode(list));
  }

  Future<void> addDownloadedTrack(AudioTrack track) async {
    final current = await getDownloadedTracks();
    final idx = current.indexWhere((t) => t.id == track.id);
    if (idx >= 0) {
      current[idx] = track;
    } else {
      current.add(track);
    }
    await saveDownloadedTracks(current);
  }

  Future<void> removeDownloadedTrack(String id) async {
    final current = await getDownloadedTracks();
    current.removeWhere((t) => t.id == id);
    await saveDownloadedTracks(current);
  }

  // Cache last catalog fetch (for offline display)
  Future<void> setCachedCatalog(List<AudioTrack> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final list = tracks.map((t) => t.toJson()).toList();
    await prefs.setString(_keyCachedCatalog, json.encode(list));
  }

  Future<List<AudioTrack>> getCachedCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyCachedCatalog);
    if (s == null || s.isEmpty) return [];
    try {
      final list = json.decode(s);
      if (list is! List) return [];
      return list
          .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
