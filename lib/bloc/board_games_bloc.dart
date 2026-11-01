import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/board_game.dart';
import 'board_games_event.dart';
import 'board_games_state.dart';

const collectionName = 'boardgames';

class BoardGamesBloc extends Bloc<BoardGamesEvent, BoardGamesState> {
  BoardGamesBloc() : super(BoardGamesLoadInProgress()) {
    on<BoardGamesLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    BoardGamesLoadRequested event,
    Emitter<BoardGamesState> emit,
  ) async {
    emit(BoardGamesLoadInProgress());
    await emit.forEach(
      FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      onData: (snapshot) => BoardGamesLoadSuccess(
        snapshot.docs.map((doc) => BoardGame.fromFirestore(doc)).toList(),
      ),
      onError: (error, stackTrace) => BoardGamesLoadFailure(
        'Не удалось загрузить каталог',
      ),
    );
  }
}