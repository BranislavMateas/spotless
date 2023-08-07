import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:spotless/models/track_model.dart';
import 'package:spotless/providers/access_token_provider.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';
import 'package:spotless/providers/playlist_id_provider.dart';
import 'package:spotless/widgets/track_card_widget.dart';

class TrackListPage extends ConsumerStatefulWidget {
  const TrackListPage({super.key});

  static String pageRoute = "/track-list";

  @override
  ConsumerState<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends ConsumerState<TrackListPage> {
  int trackCount = 0;

  @override
  Widget build(BuildContext context) {
    var accessToken = ref.watch(accessTokenProvider);
    var playlistId = ref.watch(playlistIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("$trackCount tracks found"),
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
            tooltip: "Download all",
          ),
          IconButton(
            onPressed: () {
              openFileManager();
            },
            icon: const Icon(Icons.folder),
            tooltip: "Show in folder",
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<TrackModel>?>(
          future: ref
              .read(fetchedTracksProvider.notifier)
              .fetchFromPlaylistId(playlistId, accessToken),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasError) {
                if (snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.data == []) {
                  return Center(child: Text("No tracks found!"));
                } else {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return TrackCardWidget(
                        snapshot: snapshot,
                        trackIndex: index,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 5);
                    },
                  );
                }
              } else {
                return Center(
                  child: Text(
                    "There was a failure while fetching the tracks!",
                  ),
                );
              }
            }

            return Container();
          },
        ),
      ),
    );
  }
}
