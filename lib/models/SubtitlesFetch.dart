// ignore_for_file: file_names

class SubtitlesFetch {
  final int key;
  final String name;

  SubtitlesFetch({required this.key, required this.name});

  factory SubtitlesFetch.fromMapEntry(MapEntry<int, String> entry) {
    return SubtitlesFetch(
      key: entry.key,
      name: entry.value,
    );
  }
}