import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotless/models/track_model.dart';
import 'package:spotless/providers/access_token_provider.dart';
import 'package:spotless/providers/fetched_tracks_provider.dart';
import 'package:spotless/providers/playlist_url_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TrackListPage extends ConsumerStatefulWidget {
  const TrackListPage({super.key});

  static String pageRoute = "/track-list";

  @override
  ConsumerState<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends ConsumerState<TrackListPage> {
  @override
  Widget build(BuildContext context) {
    var accessToken = ref.watch(accessTokenProvider);
    var url = ref.watch(playlistUrlProvider);

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<TrackModel>?>(
        future: ref
            .read(fetchedTracksProvider.notifier)
            .fetchFromUrl(url!, accessToken),
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
                return ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String authors = "";
                      for (var item in snapshot.data![index].authors) {
                        if (authors != "") {
                          authors += " & ";
                        }

                        authors += item;
                      }

                      String songName =
                          "$authors - ${snapshot.data![index].title}";

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(authors),
                                Text(snapshot.data![index].title),
                              ],
                            ),
                            IconButton(
                                onPressed: () async {
                                  final YoutubeExplode yt = YoutubeExplode();

                                  var status = await Permission.storage.status;
                                  if (!status.isGranted) {
                                    await Permission.storage.request();
                                  }

                                  SearchList searchResults =
                                      await yt.search.searchContent(songName);

                                  var targetSongId = searchResults.first.id;

                                  StreamManifest videoManifest = await yt
                                      .videos.streamsClient
                                      .getManifest(targetSongId);
                                  var streamInfo = videoManifest.audioOnly
                                      .withHighestBitrate();

                                  // Get the actual stream
                                  var stream =
                                      yt.videos.streamsClient.get(streamInfo);

                                  // Open a file for writing.
                                  String? downloadsDirectoryPath =
                                      (await DownloadsPath.downloadsDirectory())
                                          ?.path;

                                  var file = File(
                                      "${downloadsDirectoryPath!}/$songName.mp3");
                                  var fileStream = file.openWrite();

                                  // Pipe all the content of the stream into the file.
                                  await stream.pipe(fileStream);

                                  // Close the file.
                                  await fileStream.flush();
                                  await fileStream.close();

                                  yt.close();
                                },
                                icon: Icon(Icons.download))
                          ],
                        ),
                      );
                    });
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
    );
  }
}
