class TrackModel {
  final String title;
  final List<dynamic> interprets;
  final String albumName;
  final String albumCoverUrl;

  TrackModel({
    required this.title,
    required this.interprets,
    required this.albumName,
    required this.albumCoverUrl,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: json["name"] as String,
      interprets:
          json["artists"].map((e) => e["name"]).toList() as List<dynamic>,
      albumName: json["album"]["name"] as String,
      albumCoverUrl: json["album"]["images"][0]["url"] as String,
    );
  }
}
