import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/board_games_bloc.dart';
import '../../bloc/board_games_event.dart';
import '../../bloc/board_games_state.dart';
import '../../data/auth_repository.dart';
import '../../domain/entities/board_game.dart';
import '../widgets/board_game_card.dart';
import 'add_game_screen.dart';
import 'board_game_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  final _auth = AuthRepository();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddScreen() async {
    final game = await Navigator.push<BoardGame>(
      context,
      MaterialPageRoute(builder: (_) => const AddGameScreen()),
    );
    if (game == null || !mounted) return;
    context.read<BoardGamesBloc>().add(BoardGameAdded(game));
  }

  void _openDetails(BoardGame game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BoardGamesBloc>(),
          child: BoardGameDetailsScreen(gameId: game.id),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<BoardGamesBloc>().add(BoardGamesSearchChanged(''));
  }

  Widget _buildHeader(BoardGamesState state) {
    final s = state is BoardGamesLoadSuccess ? state : null;
    final total = s?.games.length ?? 0;
    final favorites = s?.favoriteIds.length ?? 0;
    final onlyFavorites = s?.onlyFavorites ?? false;
    final hasQuery = (s?.query ?? '').isNotEmpty;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настольные игры',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'В каталоге: $total · В избранном: $favorites\n'
                  '${_auth.currentEmail}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF858585),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _auth.signOut(),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Выйти'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _searchController,
            onChanged: (value) => context
                .read<BoardGamesBloc>()
                .add(BoardGamesSearchChanged(value)),
            decoration: InputDecoration(
              hintText: 'Поиск по названию',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: hasQuery
                  ? IconButton(
                      tooltip: 'Очистить',
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: () => context
                .read<BoardGamesBloc>()
                .add(BoardGamesFavoritesFilterToggled()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: onlyFavorites ? const Color(0xFFE3F0EF) : Colors.white,
                border: Border.all(
                  color: onlyFavorites
                      ? const Color(0xFFE3F0EF)
                      : const Color(0xFFEAEAEA),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    onlyFavorites ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: onlyFavorites
                        ? const Color.fromARGB(255, 200, 0, 107)
                        : const Color(0xFF858585),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Только избранные',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onlyFavorites
                          ? const Color(0xFF376F70)
                          : const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF7A4B94)),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BoardGamesState state) {
    if (state is BoardGamesLoadInProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BoardGamesLoadFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Color(0xFF7A4B94)),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
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
        ),
      );
    }

    final s = state as BoardGamesLoadSuccess;
    final games = s.visibleGames;

    if (games.isEmpty) {
      if (s.query.trim().isNotEmpty) {
        return _message(
          Icons.search_off,
          'По запросу «${s.query.trim()}» ничего не нашлось',
        );
      }
      if (s.onlyFavorites) {
        return _message(Icons.favorite_border, 'В избранном пока пусто');
      }
      return _message(Icons.inbox, 'В каталоге пока нет игр');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return BoardGameCard(
          game: game,
          isFavorite: s.favoriteIds.contains(game.id),
          onFavoritePressed: () => context
              .read<BoardGamesBloc>()
              .add(BoardGameFavoriteToggled(game.id)),
          onTap: () => _openDetails(game),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 166, 228),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: SafeArea(
        child: BlocBuilder<BoardGamesBloc, BoardGamesState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(state),
                Expanded(child: _buildContent(state)),
              ],
            );
          },
        ),
      ),
    );
  }
}