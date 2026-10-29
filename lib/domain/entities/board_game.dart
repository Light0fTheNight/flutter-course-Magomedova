import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory BoardGame.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BoardGame(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      category: BoardGameCategory.values.asNameMap()[data['category']] ??
          BoardGameCategory.strategy,
      image: data['image'] as String? ?? '',
      genres: List<String>.from(data['genres'] as List? ?? const []),
      description: data['description'] as String? ?? '',
    );
  }

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