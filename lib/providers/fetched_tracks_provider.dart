import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotless/models/track_model.dart';
import 'package:http/http.dart' as http;
import 'package:spotless/providers/track_count_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final fetchedTracksProvider =
    StateNotifierProvider<FetchedTracksNotifier, List<TrackModel>?>(
        (ref) => FetchedTracksNotifier(ref));

class FetchedTracksNotifier extends StateNotifier<List<TrackModel>?>
    with UiLoggy {
  final Ref ref;

  FetchedTracksNotifier(this.ref) : super(null);

  List<TrackModel>? _tracks;

  int? trackCount;
  final int _limit = 50;

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
      if (trackCount == null) {
        trackCount = json.decode(response.body)["total"];
        ref.read(trackCountProvider.notifier).state = trackCount!;
      }

      List<dynamic> fetchedItems = json.decode(response.body)["items"];
      for (var item in fetchedItems) {
        _tracks ??= [];
        _tracks?.add(TrackModel.fromJson(item["track"]));
      }
      if (offset + _limit <= trackCount!) {
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

  void downloadTrack(int index) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory targetDirectory = Directory("/storage/emulated/0/Music/Spotless");
    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    String songName = generateSongFileName(index);

    var sourceFile = File("${targetDirectory.path}/$songName.mp4");
    var targetFile = File("${targetDirectory.path}/$songName.mp3");

    if (!targetFile.existsSync()) {
      loggy.info("Downloading track... ${targetFile.path}");

      final YoutubeExplode yt = YoutubeExplode();

      SearchList searchResults =
          await yt.search.searchContent("$songName (Official Audio)");

      var targetSongId = searchResults.first.id;

      StreamManifest videoManifest =
          await yt.videos.streamsClient.getManifest(targetSongId);
      var streamInfo = videoManifest.audioOnly.withHighestBitrate();

      // Get the actual stream
      var stream = yt.videos.streamsClient.get(streamInfo);

      // Open a file for writing.
      var fileStream = sourceFile.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();

      yt.close();

      FFmpegKit.execute(
              '-i "${sourceFile.path}" -id3v2_version 3 -metadata artist="${getInterpretsString(index)}" -metadata album="${_tracks![index].albumName}" -metadata title="${_tracks![index].title}" "${targetFile.path}"')
          .then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          loggy.info("success");
        } else if (ReturnCode.isCancel(returnCode)) {
          loggy.info("cancel");
        } else {
          loggy.error(returnCode?.getValue().toString());
          loggy.error(await session.getAllLogsAsString());
          loggy.error(await session.getFailStackTrace());
          loggy.error(await session.getOutput());
        }

        await sourceFile.delete();

        loggy.info("Track downloaded successfully! - ${targetFile.path}");
      });
    } else {
      loggy.info("Track already downloaded! - ${targetFile.path}");
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
    return "${getInterpretsString(trackIndex)} - ${_tracks![trackIndex].title}";
  }
}
