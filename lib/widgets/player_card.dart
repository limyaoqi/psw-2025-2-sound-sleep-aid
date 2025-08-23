import 'package:flutter/material.dart';

import 'circular_player.dart';
import 'control_buttons.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({super.key});

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.album, size: 72, color: Colors.grey.shade700),
                  const SizedBox(height: 8),
                  Text('No track', style: theme.textTheme.titleMedium),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Controls (UI only)
            const ControlButtons(isPlaying: false),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
