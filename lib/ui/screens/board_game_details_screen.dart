import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/board_games_bloc.dart';
import '../../bloc/board_games_event.dart';
import '../../bloc/board_games_state.dart';
import '../widgets/category_view.dart';

class BoardGameDetailsScreen extends StatelessWidget {
  const BoardGameDetailsScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardGamesBloc, BoardGamesState>(
      builder: (context, state) {
        if (state is! BoardGamesLoadSuccess) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final game = state.gameById(gameId);
        if (game == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Игра не найдена')),
          );
        }
        final isFavorite = state.favoriteIds.contains(game.id);

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 209, 166, 228),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                tooltip: isFavorite
                    ? 'Убрать из избранного'
                    : 'Добавить в избранное',
                onPressed: () => context
                    .read<BoardGamesBloc>()
                    .add(BoardGameFavoriteToggled(game.id)),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? const Color.fromARGB(255, 200, 0, 107)
                      : null,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Обложка
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          game.image,
                          height: 320,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 320,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.subtitle,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                categoryIcon(game.category),
                                size: 20,
                                color: const Color(0xFF7A4B94),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                categoryLabel(game.category),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF7A4B94),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (game.genres.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final genre in game.genres)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      genre,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Text(
                            'Описание',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.description.isEmpty
                                ? 'Описания пока нет'
                                : game.description,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}