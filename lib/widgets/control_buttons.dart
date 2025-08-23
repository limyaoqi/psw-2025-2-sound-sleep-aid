import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isPlaying;

  const ControlButtons({
    super.key,
    this.onPlay,
    this.onPause,
    this.onNext,
    this.onPrevious,
    this.isPlaying = false,
  });

  Widget _smallButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).cardColor.withOpacity(0.9);
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 22,
          color: disabled ? onSurface.withOpacity(0.38) : onSurface,
        ),
      ),
    );
  }

  Widget _playPauseButton(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: isPlaying ? onPause : onPlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // gradient ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  primary.withOpacity(0.18),
                  primary.withOpacity(0.06),
                  primary.withOpacity(0.18),
                ],
              ),
            ),
          ),
          // inner button
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: isPlaying ? primary : surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: primary.withOpacity(0.18), width: 1.2),
            ),
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 34,
                color: isPlaying ? onPrimary : primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _smallButton(context, icon: Icons.skip_previous, onTap: onPrevious),
          const SizedBox(width: 12),
          _playPauseButton(context),
          const SizedBox(width: 12),
          _smallButton(context, icon: Icons.skip_next, onTap: onNext),
        ],
      ),
    );
  }
}
