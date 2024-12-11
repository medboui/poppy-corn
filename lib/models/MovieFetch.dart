// ignore_for_file: file_names

class MovieInfo {
  final String? kinopoiskUrl;
  final String? tmdbId;
  final String? name;
  final String? originalName;
  final String? coverImage;
  final String? movieImage;
  final String? releaseDate;
  final String? episodeRunTime;
  final dynamic youtubeTrailer;
  final String? director;
  final String? actors;
  final String? cast;
  final String? description;
  final String? plot;
  final String? age;
  final String? mpaaRating;
  final String? ratingCountKinopoisk;
  final String? country;
  final String? genre;
  final List<String>? backdropPath;
  final String? durationSecs;
  final String? duration;
  final String? bitrate;
  final String? rating;

  MovieInfo({
    this.kinopoiskUrl,
    this.tmdbId,
    this.name,
    this.originalName,
    this.coverImage,
    this.movieImage,
    this.releaseDate,
    this.episodeRunTime,
    this.youtubeTrailer,
    this.director,
    this.actors,
    this.cast,
    this.description,
    this.plot,
    this.age,
    this.mpaaRating,
    this.ratingCountKinopoisk,
    this.country,
    this.genre,
    this.backdropPath,
    this.durationSecs,
    this.duration,
    this.bitrate,
    this.rating,
  });

  factory MovieInfo.fromJson(Map<String, dynamic> json) {
    return MovieInfo(
      kinopoiskUrl: json['kinopoisk_url'].toString() ?? '',
      tmdbId: json['tmdb_id'].toString() ?? '',
      name: json['name'].toString() ?? '',
      originalName: json['o_name'].toString() ?? '',
      coverImage: json['cover_big'].toString() ?? '',
      movieImage: json['movie_image'].toString() ?? '',
      releaseDate: json['releasedate'].toString() ?? '',
      episodeRunTime: json['episode_run_time'].toString() ?? '',
      youtubeTrailer: json['youtube_trailer'].toString() ?? '',
      director: json['director'].toString() ?? '',
      actors: json['actors'].toString() ?? '',
      cast: json['cast'].toString() ?? '',
      description: json['description'].toString() ?? '',
      plot: json['plot'].toString() ?? '',
      age: json['age'].toString() ?? '',
      mpaaRating: json['mpaa_rating'].toString() ?? '',
      ratingCountKinopoisk: json['rating_count_kinopoisk'].toString() ?? '',
      country: json['country'].toString() ?? '',
      genre: json['genre'].toString() ?? '',
      backdropPath: json['backdrop_path'] == null ||
          json['backdrop_path'].runtimeType == String
          ? []
          : (json['backdrop_path'] as List)
          .map((dynamic e) => e.toString())
          .toList(),
      durationSecs: json['duration_secs'].toString() ?? '',
      duration: json['duration'].toString() ?? '',
      bitrate: json['bitrate'].toString() ?? '',
      rating: json['rating'].toString() ?? '',
    );
  }
}

class MovieData {
  final String? streamId;
  final String? name;
  final String? added;
  final String? categoryId;
  final String? containerExtension;
  final String? customSid;
  final String? directSource;

  MovieData({
    this.streamId,
    this.name,
    this.added,
    this.categoryId,
    this.containerExtension,
    this.customSid,
    this.directSource,
  });

  factory MovieData.fromJson(Map<String, dynamic> json) {
    return MovieData(
      streamId: json['stream_id'].toString(),
      name: json['name'],
      added: json['added'],
      categoryId: json['category_id'],
      containerExtension: json['container_extension'],
      customSid: json['custom_sid'],
      directSource: json['direct_source'],
    );
  }
}
