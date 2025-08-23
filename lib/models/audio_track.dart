class AudioTrack {
  final String id;
  final String title;
  final String category;
  final String url;
  String? localPath;

  AudioTrack({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    this.localPath,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) => AudioTrack(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    url: json['url'] as String,
    localPath: json['localPath'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'url': url,
    'localPath': localPath,
  };
}
