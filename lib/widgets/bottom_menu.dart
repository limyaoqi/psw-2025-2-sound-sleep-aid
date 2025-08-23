import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  final VoidCallback? onLibrary;
  final VoidCallback? onFavorites;
  final VoidCallback? onSettings;

  const BottomMenu({
    super.key,
    this.onLibrary,
    this.onFavorites,
    this.onSettings,
  });

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).cardColor.withOpacity(0.9);
    final disabled = onTap == null;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
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
              child: Icon(
                icon,
                size: 22,
                color: disabled ? onSurface.withOpacity(0.38) : onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor.withOpacity(0.95);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: bg,
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
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildItem(context, icon: Icons.playlist_play, onTap: onLibrary),
            _buildItem(context, icon: Icons.timer, onTap: onFavorites),
            _buildItem(context, icon: Icons.download, onTap: onSettings),
          ],
        ),
      ),
    );
  }
}
