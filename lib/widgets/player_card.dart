import 'package:flutter/material.dart';

import 'circular_player.dart';
import 'control_buttons.dart';

class PlayerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isPlaying;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final double progress; // 0..1
  // edge control flags
  final bool canNext;
  final bool canPrevious;

  const PlayerCard({
    super.key,
    this.title = 'No track',
    this.subtitle,
    this.isPlaying = false,
    this.onPlay,
    this.onPause,
    this.onNext,
    this.onPrevious,
    this.progress = 0.0,
    this.canNext = true,
    this.canPrevious = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(0.95);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player
            CircularPlayer(
              size: 320,
              progress: progress,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.album, size: 72, color: Colors.grey.shade700),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Controls
            ControlButtons(
              isPlaying: isPlaying,
              onPlay: onPlay,
              onPause: onPause,
              onNext: onNext,
              onPrevious: onPrevious,
              nextEnabled: canNext,
              previousEnabled: canPrevious,
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
