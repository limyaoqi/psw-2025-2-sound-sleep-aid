import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keySelectedTrackId = 'selected_track_id';

  Future<String?> getSelectedTrackId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedTrackId);
  }

  Future<void> setSelectedTrackId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTrackId, id);
  }
}
