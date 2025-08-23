import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/audio_track.dart';

class CatalogService {
  static const String defaultUrl =
      'https://limyaoqi.github.io/sound-sleep/audio/sounds.json';

  Future<List<AudioTrack>> fetchTracks({String? url}) async {
    final uri = Uri.parse(url ?? defaultUrl);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Fetch failed: ${res.statusCode}');
    }
    final body = utf8.decode(res.bodyBytes);
    final data = json.decode(body);
    if (data is! List) throw Exception('Unexpected JSON format');
    return data
        .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
        .toList()
        .cast<AudioTrack>();
  }
}
