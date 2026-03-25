// post.dart
class Post {
  int? id;
  String title;
  String content;
  String createdAt;
  int isFavorite;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'isFavorite': isFavorite,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
      isFavorite: map['isFavorite'],
    );
  }
}