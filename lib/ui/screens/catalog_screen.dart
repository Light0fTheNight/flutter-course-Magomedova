import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/board_games_bloc.dart';
import '../../bloc/board_games_event.dart';
import '../../bloc/board_games_state.dart';
import '../../domain/entities/board_game.dart';
import '../widgets/board_game_card.dart';
const placeholderImage = 'https://placehold.co/300x360.png';

String _categoryLabel(BoardGameCategory category) {
  switch (category) {
    case BoardGameCategory.strategy:
      return 'Стратегия';
    case BoardGameCategory.psychological:
      return 'Психологическая';
    case BoardGameCategory.card:
      return 'Карточная';
    case BoardGameCategory.rolePlaying:
      return 'Ролевая';
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _favoriteIds = {};
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imageController = TextEditingController();
  final _genresController = TextEditingController();

  BoardGameCategory _category = BoardGameCategory.strategy;
  bool _onlyFavorites = false;
  bool _isSending = false;
  bool _showForm = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  Future<void> _addGame() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final image = _imageController.text.trim();
    final genres = _genresController.text
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();

    setState(() => _isSending = true);
    try {
      final newGame = BoardGame(
        id: '',
        title: title,
        subtitle: _subtitleController.text.trim(),
        category: _category,
        image: image.isEmpty ? placeholderImage : image,
        genres: genres,
      );
      await FirebaseFirestore.instance.collection(collectionName).add({
        ...newGame.toJson(),
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _titleController.clear();
      _subtitleController.clear();
      _imageController.clear();
      _genresController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _toggleFavorite(String gameId) {
    setState(() {
      if (_favoriteIds.contains(gameId)) {
        _favoriteIds.remove(gameId);
      } else {
        _favoriteIds.add(gameId);
      }
    });
  }

  void _toggleFavoritesFilter(bool value) {
    setState(() {
      _onlyFavorites = value;
    });
  }

  Widget _buildHeader(int total) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Настольные игры',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_showForm ? Icons.close : Icons.add),
                tooltip: _showForm ? 'Скрыть форму' : 'Добавить игру',
                onPressed: () => setState(() => _showForm = !_showForm),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  'В каталоге: $total · '
                  'В избранном: ${_favoriteIds.length}\n'
                  '$email',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF858585),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Выйти'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Кнопка фильтра
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                _toggleFavoritesFilter(!_onlyFavorites);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      _onlyFavorites ? const Color(0xFFE3F0EF) : Colors.white,
                  border: Border.all(
                    color: _onlyFavorites
                        ? const Color(0xFFE3F0EF)
                        : const Color(0xFFEAEAEA),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _onlyFavorites ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: _onlyFavorites
                          ? const Color.fromARGB(255, 200, 0, 107)
                          : const Color(0xFF858585),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Только избранные',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _onlyFavorites
                            ? const Color(0xFF376F70)
                            : const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          _buildField(_titleController, 'Название *'),
          _buildField(_subtitleController, 'Автор · год'),
          _buildField(_imageController, 'Ссылка на картинку'),
          _buildField(_genresController, 'Жанры через запятую'),
          Row(
            children: [
              Expanded(
                child: DropdownButton<BoardGameCategory>(
                  value: _category,
                  isExpanded: true,
                  items: [
                    for (final category in BoardGameCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(_categoryLabel(category)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSending ? null : _addGame,
                child: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Отправить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildContent(BoardGamesState state, List<BoardGame> visibleGames) {
    if (state is BoardGamesLoadInProgress) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is BoardGamesLoadFailure) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Нажмите «Обновить», чтобы попробовать ещё раз',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<BoardGamesBloc>()
                  .add(BoardGamesLoadRequested()),
              child: const Text('Обновить'),
            ),
          ],
        ),
      );
    }
    if (visibleGames.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('Ничего не нашлось', style: TextStyle(fontSize: 16)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final game in visibleGames)
            BoardGameCard(
              game: game,
              isFavorite: _favoriteIds.contains(game.id),
              onFavoritePressed: () {
                _toggleFavorite(game.id);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 166, 228),
      body: SafeArea(
        child: BlocBuilder<BoardGamesBloc, BoardGamesState>(
          builder: (context, state) {
            final games = state is BoardGamesLoadSuccess
                ? state.games
                : <BoardGame>[];
            final visibleGames = _onlyFavorites
                ? games
                    .where((game) => _favoriteIds.contains(game.id))
                    .toList()
                : games;

            return Column(
              children: [
                _buildHeader(games.length),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (_showForm) _buildForm(),
                      _buildContent(state, visibleGames),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}