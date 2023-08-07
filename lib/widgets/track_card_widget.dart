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

  String _getInterpretsString() {
    String authors = "";
    for (var item in snapshot.data![trackIndex].interprets) {
      if (authors != "") {
        authors += " & ";
      }
      authors += item;
    }
    return authors;
  }

  String _generateSongFileName() {
    return "${_getInterpretsString()} - ${snapshot.data![trackIndex].title}.mp3";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Column(
          children: [
            Text(_getInterpretsString()),
            Text(snapshot.data![trackIndex].title),
          ],
        ),
        IconButton(
          onPressed: () async {
            await ref
                .read(fetchedTracksProvider.notifier)
                .downloadTrack(trackIndex, _generateSongFileName());
          },
          icon: const Icon(Icons.download),
        ),
      ],
    );
  }
}
