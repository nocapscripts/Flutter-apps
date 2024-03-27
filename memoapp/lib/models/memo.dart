class Memo {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  Memo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }
}
