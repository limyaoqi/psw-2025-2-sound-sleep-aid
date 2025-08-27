import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_state.dart';

/// Wraps the app's content and closes the app if there's no user interaction
/// for [timeout]. Resets on any pointer event.
class IdleShutdown extends StatefulWidget {
  final Duration timeout;
  final Widget child;
  final VoidCallback? onTimeout;
  final bool enabled;

  const IdleShutdown({
    super.key,
    required this.timeout,
    required this.child,
    this.onTimeout,
    this.enabled = true,
  });

  @override
  State<IdleShutdown> createState() => _IdleShutdownState();
}

class _IdleShutdownState extends State<IdleShutdown>
    with WidgetsBindingObserver {
  Timer? _timer;
  late final Listenable _flagsListener;
  DateTime _lastInteraction = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flagsListener = Listenable.merge([
      AppState.I.isAudioPlaying,
      AppState.I.hasSleepTimer,
    ]);
    _flagsListener.addListener(_onFlagsChanged);
    _scheduleNext();
  }

  @override
  void didUpdateWidget(covariant IdleShutdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeout != widget.timeout ||
        oldWidget.enabled != widget.enabled) {
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flagsListener.removeListener(_onFlagsChanged);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer in background; resume when active again.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    if (!widget.enabled) return;
    _timer?.cancel();
    final now = DateTime.now();
    final elapsed = now.difference(_lastInteraction);
    final remaining = widget.timeout - elapsed;
    if (_shouldBypassIdle()) {
      // While bypassing (audio playing or sleep timer active), check again soon.
      _timer = Timer(const Duration(seconds: 1), _onTimeout);
      return;
    }
    if (remaining <= Duration.zero) {
      // Already exceeded timeout; trigger immediately.
      unawaited(_onTimeout());
    } else {
      _timer = Timer(remaining, _onTimeout);
    }
  }

  void _onUserInteraction() {
    if (!widget.enabled) return;
    _lastInteraction = DateTime.now();
    _scheduleNext();
  }

  Future<void> _onTimeout() async {
    if (!mounted) return;
    if (_shouldBypassIdle()) {
      // State changed while waiting; don't exit. Reschedule.
      _scheduleNext();
      return;
    }
    try {
      if (widget.onTimeout != null) {
        widget.onTimeout!.call();
      } else {
        // Close the app gracefully (Android). On iOS this is discouraged; if
        // unsupported, this will no-op.
        await SystemNavigator.pop();
      }
    } catch (_) {
      // ignore
    }
  }

  bool _shouldBypassIdle() {
    // Skip idle shutdown if audio is playing or a sleep timer is set.
    return AppState.I.isAudioPlaying.value || AppState.I.hasSleepTimer.value;
  }

  void _onFlagsChanged() {
    // Reevaluate timer based on flags.
    _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerUp: (_) => _onUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
