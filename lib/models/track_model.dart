class TrackModel {
  final String title;
  final List<dynamic> author;

  TrackModel({
    required this.title,
    required this.author,
  });

  factory TrackModel.fromJson(Map<String, dynamic> jsonTrack) {
    return TrackModel(
      title: jsonTrack["name"] as String,
      author:
          jsonTrack["artists"].map((e) => e["name"]).toList() as List<dynamic>,
    );
  }
}
