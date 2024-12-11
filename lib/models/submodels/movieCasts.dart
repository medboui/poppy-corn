class MovieCasts {
  final String? name;
  final String? image;

  MovieCasts({
    this.name,
    this.image,
  });

  MovieCasts.fromJson(Map<String, dynamic> json)
      : name = json['name'] == null ? null : json['name'].toString(),
        image = json['profile_path'] == null ? null : json['profile_path'].toString();

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
  };
}
