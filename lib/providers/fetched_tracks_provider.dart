import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:loggy/loggy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotless/models/track_model.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final fetchedTracksProvider =
    StateNotifierProvider<FetchedTracksNotifier, List<TrackModel>?>(
        (ref) => FetchedTracksNotifier());

class FetchedTracksNotifier extends StateNotifier<List<TrackModel>?>
    with UiLoggy {
  FetchedTracksNotifier() : super(null);

  List<TrackModel>? _tracks;

  final int _limit = 50;

  int getTrackCount() {
    return _tracks?.length ?? 0;
  }

  Future<List<TrackModel>?> fetchFromPlaylistId(
      {required String playlistId,
      required String accessToken,
      int offset = 0}) async {
    if (offset == 0) {
      _tracks = null;
    }
    http.Response response = await http.get(
        Uri.parse(
            "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=$_limit&offset=$offset"),
        headers: {"Authorization": "Bearer $accessToken"});
    if (response.statusCode == 200) {
      int tracksTotal = json.decode(response.body)["total"];

      List<dynamic> fetchedItems = json.decode(response.body)["items"];
      for (var item in fetchedItems) {
        _tracks ??= [];
        _tracks?.add(TrackModel.fromJson(item["track"]));
      }
      if (offset + _limit <= tracksTotal) {
        await fetchFromPlaylistId(
          accessToken: accessToken,
          playlistId: playlistId,
          offset: offset + _limit,
        );
      }
    } else {
      loggy.error("Failed to fetch the tracks!");
      loggy.error("Response code: ${response.statusCode}");
      loggy.error("Response body: ${response.body}");
    }
    return _tracks;
  }

  Future<void> downloadTrack(int index) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String songName = generateSongFileName(index);

    String? downloadsDirectoryPath =
        (await DownloadsPath.downloadsDirectory())?.path;
    if (await File("${downloadsDirectoryPath!}/$songName").exists()) {
      loggy.info("Downloading track...");

      final YoutubeExplode yt = YoutubeExplode();

      SearchList searchResults = await yt.search.searchContent(songName);

      var targetSongId = searchResults.first.id;

      StreamManifest videoManifest =
          await yt.videos.streamsClient.getManifest(targetSongId);
      var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      // Get the actual stream
      var stream = yt.videos.streamsClient.get(streamInfo);

      // Open a file for writing.
      var file = File("$downloadsDirectoryPath/$songName");
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      yt.close();

      loggy.info("Track downloaded successfully! - $songName");
    } else {
      loggy.info("Track already downloaded! - $songName");
    }
  }

  String getInterpretsString(int trackIndex) {
    String authors = "";
    for (var item in _tracks![trackIndex].interprets) {
      if (authors != "") {
        authors += " & ";
      }
      authors += item;
    }
    return authors;
  }

  String generateSongFileName(int trackIndex) {
    return "${getInterpretsString(trackIndex)} - ${_tracks![trackIndex].title}.mp3";
  }
}
