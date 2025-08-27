import 'package:flutter/foundation.dart';

/// Global app state flags used for cross-cutting features like idle shutdown.
class AppState {
  AppState._();
  static final AppState I = AppState._();

  /// True while audio is playing.
  final ValueNotifier<bool> isAudioPlaying = ValueNotifier<bool>(false);

  /// True while a sleep timer is active.
  final ValueNotifier<bool> hasSleepTimer = ValueNotifier<bool>(false);
}
