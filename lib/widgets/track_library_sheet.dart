import 'dart:async';
import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/download_service.dart';
import '../services/preferences_service.dart';
import '../models/audio_track.dart';

class TrackLibrarySheet extends StatefulWidget {
  final void Function(AudioTrack track)? onSelect;
  final int initialTab; // 0=All, 1=Downloaded
  const TrackLibrarySheet({super.key, this.onSelect, this.initialTab = 0});

  @override
  State<TrackLibrarySheet> createState() => _TrackLibrarySheetState();
}

class _TrackLibrarySheetState extends State<TrackLibrarySheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _online = true;
  bool _loadingAll = true;
  List<AudioTrack> _all = const [];
  List<AudioTrack> _downloaded = const [];
  bool _busy = false; // downloading/deleting flag to avoid double taps

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = widget.initialTab.clamp(0, 1);
    _init();
  }

  Future<void> _init() async {
    // load downloaded first
    _downloaded = await PreferencesService().getDownloadedTracks();
    setState(() {});

    // try load all from network
    try {
      _all = await CatalogService().fetchTracks();
      _online = true;
    } catch (_) {
      _online = false;
      // if offline, default to Downloaded tab
      _tabController.index = 1;
    } finally {
      _loadingAll = false;
      if (mounted) setState(() {});
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  Future<void> _download(AudioTrack t) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await DownloadService().downloadToLocal(
        t.url,
        '${t.id}.mp3',
      );
      final updated = AudioTrack(
        id: t.id,
        title: t.title,
        category: t.category,
        url: t.url,
        localPath: path,
      );
      // persist
      await PreferencesService().addDownloadedTrack(updated);
      // update local lists
      _downloaded = List.of(_downloaded);
      final di = _downloaded.indexWhere((e) => e.id == updated.id);
      if (di >= 0) {
        _downloaded[di] = updated;
      } else {
        _downloaded.add(updated);
      }
      final ai = _all.indexWhere((e) => e.id == updated.id);
      if (ai >= 0) {
        _all = List.of(_all);
        _all[ai] = updated;
      }
      if (mounted) setState(() {});
      _toast('Downloaded');
    } catch (e) {
      _toast('Download failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(AudioTrack t) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (t.localPath != null) {
        await DownloadService().deleteLocal(t.localPath!);
      }
      await PreferencesService().removeDownloadedTrack(t.id);
      // update lists
      _downloaded = List.of(_downloaded)..removeWhere((e) => e.id == t.id);
      final ai = _all.indexWhere((e) => e.id == t.id);
      if (ai >= 0) {
        final original = AudioTrack(
          id: _all[ai].id,
          title: _all[ai].title,
          category: _all[ai].category,
          url: _all[ai].url,
          localPath: null,
        );
        _all = List.of(_all);
        _all[ai] = original;
      }
      if (mounted) setState(() {});
      _toast('Removed download');
    } catch (_) {
      _toast('Delete failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildItem(AudioTrack t) {
    final isDownloaded = t.localPath != null && t.localPath!.isNotEmpty;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: const Icon(Icons.music_note_rounded),
      ),
      title: Text(t.title),
      subtitle: Text(t.category),
      onTap: widget.onSelect == null
          ? null
          : () {
              widget.onSelect?.call(t);
              Navigator.of(context).maybePop();
            },
      trailing: _busy
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : isDownloaded
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove download',
              onPressed: () => _delete(t),
            )
          : IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download',
              onPressed: () => _download(t),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: Theme.of(context).colorScheme.primary,
              onTap: (i) {
                if (i == 0 && !_online) {
                  // prevent switching to All when offline
                  _toast('Offline: only downloaded available');
                  // keep selection on Downloaded tab
                  _tabController.index = 1;
                }
              },
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.library_music,
                    color: _online ? null : Colors.grey,
                  ),
                  text: 'All',
                ),
                const Tab(icon: Icon(Icons.download_done), text: 'Downloaded'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // All
                  _online
                      ? (_loadingAll
                            ? const Center(child: CircularProgressIndicator())
                            : _all.isEmpty
                            ? const Center(child: Text('No tracks'))
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: _all.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                                ),
                                itemBuilder: (context, i) =>
                                    _buildItem(_all[i]),
                              ))
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Offline. Switch to Downloaded tab.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                  // Downloaded
                  _downloaded.isEmpty
                      ? const Center(child: Text('No downloads yet'))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _downloaded.length,
                          separatorBuilder: (_, __) => Divider(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.2),
                          ),
                          itemBuilder: (context, i) =>
                              _buildItem(_downloaded[i]),
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
