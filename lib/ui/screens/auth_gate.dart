import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/board_games_bloc.dart';
import '../../bloc/board_games_event.dart';
import '../../data/auth_repository.dart';
import '../../data/board_games_repository.dart';
import 'catalog_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: AuthRepository().userIdChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const LoginScreen();
        }
        return BlocProvider(
          create: (_) => BoardGamesBloc(BoardGamesRepository())
            ..add(BoardGamesLoadRequested()),
          child: const CatalogScreen(),
        );
      },
    );
  }
}