import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<String?> userIdChanges() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  String get currentEmail => _auth.currentUser?.email ?? '';

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  // Код ошибки Firebase → текст для человека
  String _messageFor(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'weak-password':
        return 'Слишком короткий пароль: нужно не меньше 6 символов';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'operation-not-allowed':
        return 'Вход по email не включён в Firebase';
      default:
        return 'Ошибка входа ($code)';
    }
  }
}