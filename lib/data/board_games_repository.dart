import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/board_game.dart';

class BoardGamesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _games =>
      _db.collection('boardgames');

  CollectionReference<Map<String, dynamic>> get _favorites => _db
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('favorites');

  Future<void> checkConnection() async {
    await _games
        .limit(1)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
  }

  Stream<List<BoardGame>> watchGames() {
    return _games
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BoardGame.fromFirestore(doc))
            .toList());
  }

  Future<Set<String>> fetchFavoriteIds() async {
    final snapshot = await _favorites.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> setFavorite(String gameId, bool isFavorite) async {
    if (isFavorite) {
      await _favorites
          .doc(gameId)
          .set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await _favorites.doc(gameId).delete();
    }
  }

  Future<void> addGame(BoardGame game) {
    return _games.add({
      ...game.toJson(),
      'ownerId': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}