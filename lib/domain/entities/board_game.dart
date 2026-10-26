enum BoardGameCategory {
  strategy,
  psychological,
  card,
  rolePlaying,
}

class BoardGame {
  const BoardGame({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.image,
    required this.genres,
    this.description = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final BoardGameCategory category;
  final String image;
  final List<String> genres;
  final String description;

  factory BoardGame.fromJson(Map<String, dynamic> json) {
    return BoardGame(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: BoardGameCategory.values.byName(json['category'] as String),
      image: json['image'] as String,
      genres: List<String>.from(json['genres'] as List),
      description: json['description'] as String? ?? '',
    );
  }

  // id не отправляем, его выдаёт сервер
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'image': image,
      'genres': genres,
      'description': description,
    };
  }
}