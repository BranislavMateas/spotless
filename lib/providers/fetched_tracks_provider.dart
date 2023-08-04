import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotless/models/track_model.dart';
import 'package:http/http.dart' as http;

final fetchedTracksProvider =
    StateNotifierProvider<FetchedTracksNotifier, List<TrackModel>?>(
        (ref) => FetchedTracksNotifier());

class FetchedTracksNotifier extends StateNotifier<List<TrackModel>?> {
  FetchedTracksNotifier() : super(null);

  List<TrackModel>? _tracks;

  List<TrackModel>? getFetchedTracks() {
    return _tracks;
  }

  Future<void> fetchFromUrl(Uri url, String accessToken) async {
    http.Response response =
        await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if (response.statusCode == 200) {
      List<dynamic> fetchedItems = json.decode(response.body)["items"];
      for (var item in fetchedItems) {
        _tracks ??= [];
        _tracks?.add(TrackModel.fromJson(item["track"]));
      }
    } else {}
  }
}
