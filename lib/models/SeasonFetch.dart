// ignore_for_file: file_names

class Season {
  final String airDate;
  final String episodeCount;
  final String id;
  final String name;
  final String overview;
  final String seasonNumber;
  final String cover;
  final String coverBig;

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    required this.seasonNumber,
    required this.cover,
    required this.coverBig,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      airDate: json['air_date'],
      episodeCount: json['episode_count'].toString(),
      id: json['id'].toString(),
      name: json['name'],
      overview: json['overview'],
      seasonNumber: json['season_number'].toString(),
      cover: json['cover'],
      coverBig: json['cover_big'],
    );
  }
}
