import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/board_games_repository.dart';
import 'board_games_event.dart';
import 'board_games_state.dart';

class BoardGamesBloc extends Bloc<BoardGamesEvent, BoardGamesState> {
  BoardGamesBloc(this._repository) : super(BoardGamesLoadInProgress()) {
    on<BoardGamesLoadRequested>(_onLoadRequested);
    on<BoardGameFavoriteToggled>(_onFavoriteToggled);
    on<BoardGamesFavoritesFilterToggled>(_onFavoritesFilterToggled);
    on<BoardGamesSearchChanged>(_onSearchChanged);
    on<BoardGameAdded>(_onGameAdded);
  }

  final BoardGamesRepository _repository;

  Future<void> _onLoadRequested(
    BoardGamesLoadRequested event,
    Emitter<BoardGamesState> emit,
  ) async {
    emit(BoardGamesLoadInProgress());

    var favoriteIds = <String>{};
    try {
      await _repository.checkConnection();
      favoriteIds = await _repository.fetchFavoriteIds();
    } catch (_) {
      emit(BoardGamesLoadFailure(
        'Не удалось загрузить каталог.\n'
        'Проверьте интернет и нажмите «Обновить».',
      ));
      return;
    }

    await emit.forEach(
      _repository.watchGames(),
      onData: (games) {
        final s = state;
        return s is BoardGamesLoadSuccess
            ? s.copyWith(games: games)
            : BoardGamesLoadSuccess(games: games, favoriteIds: favoriteIds);
      },
      onError: (error, stackTrace) => BoardGamesLoadFailure(
        'Не удалось загрузить каталог.\n'
        'Проверьте интернет и нажмите «Обновить».',
      ),
    );
  }

  Future<void> _onFavoriteToggled(
    BoardGameFavoriteToggled event,
    Emitter<BoardGamesState> emit,
  ) async {
    final s = state;
    if (s is! BoardGamesLoadSuccess) return;

    final wasFavorite = s.favoriteIds.contains(event.gameId);
    final ids = {...s.favoriteIds}; // новый набор, старый не трогаем
    if (wasFavorite) {
      ids.remove(event.gameId);
    } else {
      ids.add(event.gameId);
    }
    emit(s.copyWith(favoriteIds: ids));
    await _repository.setFavorite(event.gameId, !wasFavorite);
  }

  void _onFavoritesFilterToggled(
    BoardGamesFavoritesFilterToggled event,
    Emitter<BoardGamesState> emit,
  ) {
    final s = state;
    if (s is BoardGamesLoadSuccess) {
      emit(s.copyWith(onlyFavorites: !s.onlyFavorites));
    }
  }

  void _onSearchChanged(
    BoardGamesSearchChanged event,
    Emitter<BoardGamesState> emit,
  ) {
    final s = state;
    if (s is BoardGamesLoadSuccess) {
      emit(s.copyWith(query: event.query));
    }
  }

  Future<void> _onGameAdded(
    BoardGameAdded event,
    Emitter<BoardGamesState> emit,
  ) async {
    await _repository.addGame(event.game);
  }
}