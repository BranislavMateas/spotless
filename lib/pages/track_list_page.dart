import 'package:android_intent_plus/android_intent.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotless/models/track_model.dart';
import 'package:spotless/providers/access_token_provider.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';
import 'package:spotless/providers/playlist_id_provider.dart';
import 'package:spotless/providers/track_count_provider.dart';
import 'package:spotless/widgets/track_card_widget.dart';

class TrackListPage extends ConsumerStatefulWidget {
  const TrackListPage({super.key});

  static String pageRoute = "/track-list";

  @override
  ConsumerState<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends ConsumerState<TrackListPage> {
  final String musicAppPackageName = "in.krosbits.musicolet";

  @override
  Widget build(BuildContext context) {
    var accessToken = ref.watch(accessTokenProvider);
    var playlistId = ref.watch(playlistIdProvider);
    var trackCount = ref.watch(trackCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$trackCount tracks found",
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: "Back",
        ),
        actions: [
          IconButton(
            onPressed: () async {
              for (int i = 0; i < trackCount; i++) {
                ref.read(fetchedTracksProvider.notifier).downloadTrack(i);
              }
            },
            icon: const Icon(Icons.download),
            tooltip: "Download all",
          ),
          IconButton(
            onPressed: () async {
              bool isAppInstalled = await LaunchApp.isAppInstalled(
                androidPackageName: musicAppPackageName,
              );
              if (isAppInstalled) {
                LaunchApp.openApp(
                  androidPackageName: musicAppPackageName,
                );
              } else {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  AndroidIntent intent = const AndroidIntent(
                    action: "android.intent.action.MAIN",
                    category: "android.intent.category.APP_MUSIC",
                  );
                  await intent.launch();
                }
              }
            },
            icon: const Icon(Icons.library_music),
            tooltip: "Open music app",
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<TrackModel>?>(
          future: ref.read(fetchedTracksProvider.notifier).fetchFromPlaylistId(
                playlistId: playlistId,
                accessToken: accessToken,
              ),
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
