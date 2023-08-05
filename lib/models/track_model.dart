class TrackModel {
  final String title;
  final List<dynamic> authors;

  TrackModel({
    required this.title,
    required this.authors,
  });

  factory TrackModel.fromJson(Map<String, dynamic> jsonTrack) {
    return TrackModel(
      title: jsonTrack["name"] as String,
      authors:
          jsonTrack["artists"].map((e) => e["name"]).toList() as List<dynamic>,
    );
  }
}
