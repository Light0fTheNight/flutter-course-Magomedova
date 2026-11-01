import '../domain/entities/board_game.dart';

sealed class BoardGamesState {}

class BoardGamesLoadInProgress extends BoardGamesState {}

class BoardGamesLoadSuccess extends BoardGamesState {
  BoardGamesLoadSuccess({
    required this.games,
    this.favoriteIds = const {},
    this.onlyFavorites = false,
    this.query = '',
  });

  final List<BoardGame> games;
  final Set<String> favoriteIds;
  final bool onlyFavorites;
  final String query;

  BoardGamesLoadSuccess copyWith({
    List<BoardGame>? games,
    Set<String>? favoriteIds,
    bool? onlyFavorites,
    String? query,
  }) {
    return BoardGamesLoadSuccess(
      games: games ?? this.games,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      query: query ?? this.query,
    );
  }

  List<BoardGame> get visibleGames {
    final search = query.trim().toLowerCase();
    return games.where((game) {
      if (onlyFavorites && !favoriteIds.contains(game.id)) return false;
      if (search.isNotEmpty && !game.title.toLowerCase().contains(search)) {
        return false;
      }
      return true;
    }).toList();
  }

  BoardGame? gameById(String id) {
    for (final game in games) {
      if (game.id == id) return game;
    }
    return null;
  }
}

class BoardGamesLoadFailure extends BoardGamesState {
  BoardGamesLoadFailure(this.message);

  final String message;
}