class TrackModel {
  final String title;
  final List<dynamic> interprets;

  TrackModel({
    required this.title,
    required this.interprets,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: json["name"] as String,
      interprets:
          json["artists"].map((e) => e["name"]).toList() as List<dynamic>,
    );
  }
}
