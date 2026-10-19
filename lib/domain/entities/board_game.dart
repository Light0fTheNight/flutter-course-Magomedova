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
    this.description,
  });

  final int id;
  final String title;
  final String subtitle;
  final BoardGameCategory category;
  final String image;
  final List<String> genres;
  final String? description;
}