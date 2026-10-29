import '../domain/entities/board_game.dart';

sealed class BoardGamesState {}

class BoardGamesLoadInProgress extends BoardGamesState {}

class BoardGamesLoadSuccess extends BoardGamesState {
  BoardGamesLoadSuccess(this.games);

  final List<BoardGame> games;
}

class BoardGamesLoadFailure extends BoardGamesState {
  BoardGamesLoadFailure(this.message);

  final String message;
}