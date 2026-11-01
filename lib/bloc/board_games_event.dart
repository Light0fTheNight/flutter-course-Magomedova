import '../domain/entities/board_game.dart';

sealed class BoardGamesEvent {}

class BoardGamesLoadRequested extends BoardGamesEvent {}

class BoardGameFavoriteToggled extends BoardGamesEvent {
  BoardGameFavoriteToggled(this.gameId);

  final String gameId;
}

class BoardGamesFavoritesFilterToggled extends BoardGamesEvent {}

class BoardGamesSearchChanged extends BoardGamesEvent {
  BoardGamesSearchChanged(this.query);

  final String query;
}

class BoardGameAdded extends BoardGamesEvent {
  BoardGameAdded(this.game);

  final BoardGame game;
}