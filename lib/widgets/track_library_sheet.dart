import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../models/audio_track.dart';

class TrackLibrarySheet extends StatelessWidget {
  final void Function(AudioTrack track)? onSelect;
  const TrackLibrarySheet({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return FutureBuilder<List<AudioTrack>>(
          future: CatalogService().fetchTracks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Load failed'));
            }
            final tracks = snapshot.data ?? const <AudioTrack>[];
            return ListView.separated(
              controller: scrollController,
              itemCount: tracks.length,
              separatorBuilder: (_, __) => Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              itemBuilder: (context, i) {
                final t = tracks[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    child: const Icon(Icons.music_note_rounded),
                  ),
                  title: Text(t.title),
                  subtitle: Text(t.category),
                  onTap: onSelect == null
                      ? null
                      : () {
                          onSelect?.call(t);
                          Navigator.of(context).maybePop();
                        },
                  trailing: IconButton(
                    icon: const Icon(Icons.link_rounded),
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(t.url)));
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
