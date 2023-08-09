import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotless/models/track_model.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';

class TrackCardWidget extends ConsumerWidget {
  final AsyncSnapshot<List<TrackModel>?> snapshot;
  final int trackIndex;

  const TrackCardWidget({
    super.key,
    required this.snapshot,
    required this.trackIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  ref
                      .read(fetchedTracksProvider.notifier)
                      .getInterpretsString(trackIndex),
                ),
                Text(snapshot.data![trackIndex].title),
              ],
            ),
            IconButton(
              onPressed: () async {
                await ref
                    .read(fetchedTracksProvider.notifier)
                    .downloadTrack(trackIndex);
              },
              icon: const Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }
}
