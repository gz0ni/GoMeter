class ReleaseAsset {
  final String name;
  final String url;
  final int size;

  const ReleaseAsset({
    required this.name,
    required this.url,
    required this.size,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] as String,
      url: json['browser_download_url'] as String,
      size: json['size'] as int? ?? 0,
    );
  }
}

class ReleaseInfo {
  final String tagName;
  final String body;
  final List<ReleaseAsset> assets;

  const ReleaseInfo({
    required this.tagName,
    required this.body,
    required this.assets,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) {
    final assetsList = (json['assets'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(ReleaseAsset.fromJson)
        .toList();
    return ReleaseInfo(
      tagName: json['tag_name'] as String,
      body: json['body'] as String? ?? '',
      assets: assetsList,
    );
  }
}
