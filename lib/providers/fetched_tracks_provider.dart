import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';
import 'package:spotless/models/track_model.dart';
import 'package:http/http.dart' as http;

final fetchedTracksProvider =
    StateNotifierProvider<FetchedTracksNotifier, List<TrackModel>?>(
        (ref) => FetchedTracksNotifier());

class FetchedTracksNotifier extends StateNotifier<List<TrackModel>?>
    with UiLoggy {
  FetchedTracksNotifier() : super(null);

  List<TrackModel>? _tracks;

  Future<List<TrackModel>?> fetchFromPlaylistId(
      String playlistId, String accessToken) async {
    _tracks = null;
    http.Response response = await http.get(
        Uri.parse("https://api.spotify.com/v1/playlists/$playlistId/tracks"),
        headers: {"Authorization": "Bearer $accessToken"});
    if (response.statusCode == 200) {
      List<dynamic> fetchedItems = json.decode(response.body)["items"];
      for (var item in fetchedItems) {
        _tracks ??= [];
        _tracks?.add(TrackModel.fromJson(item["track"]));
      }
    } else {
      loggy.error("Failed to fetch the tracks!");
      loggy.error("Response code: ${response.statusCode}");
      loggy.error("Response body: ${response.body}");
    }
    return _tracks;
  }
}
