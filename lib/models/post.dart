class Post {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final DateTime? createdAt;
  final String url;
  final List<String> tags; // ← MUST be List<String>

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.url,
    required this.tags,
    this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['short_id'] ?? 'unknown',
      title: json['title'] ?? 'Untitled',
      description: _buildDescription(json),
      authorName: json['submitter_user'] ?? 'Anonymous',
      url: json['url'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : <String>[],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'short_id': id,
      'title': title,
      'description': description,
      'submitter_user': authorName,
      'url': url,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static String _buildDescription(Map<String, dynamic> json) {
    final desc = json['description'];
    if (desc != null && desc.toString().isNotEmpty) {
      return desc;
    }
    final url = json['url'];
    if (url != null && url.toString().isNotEmpty) {
      try {
        final host = Uri.parse(url).host.replaceFirst('www.', '');
        return host;
      } catch (_) {
        return 'Tap to read on Lobste.rs';
      }
    }
    return 'Tap to read on Lobste.rs';
  }
}
