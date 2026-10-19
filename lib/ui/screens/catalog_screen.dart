import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/board_game.dart';
import '../widgets/board_game_card.dart';

const baseUrl = 'https://6ad66dfbf71f154ac486d69e.mockapi.io';
const placeholderImage = 'https://placehold.co/300x360.png';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _favoriteIds = {};
  final TextEditingController _titleController = TextEditingController();

  List<BoardGame> _games = [];
  bool _onlyFavorites = false;
  bool _isLoading = true;
  bool _isSending = false;
  bool _showForm = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/boardgames'));
      if (response.statusCode != 200) {
        throw Exception('Статус ${response.statusCode}');
      }
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final games = list.map((e) => BoardGame.fromJson(e)).toList();
      if (!mounted) return;
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addGame() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final newGame = BoardGame(
        id: '',
        title: title,
        subtitle: 'Добавлено из приложения',
        category: BoardGameCategory.strategy,
        image: placeholderImage,
        genres: [],
        description: '',
      );
      final response = await http.post(
        Uri.parse('$baseUrl/boardgames'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newGame.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Статус ${response.statusCode}');
      }
      final created =
          BoardGame.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      if (!mounted) return;
      setState(() {
        _games.insert(0, created);
        _isSending = false;
      });
      _titleController.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить: $e')),
      );
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

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
                isDense: true,
              ),
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
    );
  }

  Widget _buildBody(List<BoardGame> visibleGames) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ошибка: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadGames,
                child: const Text('Обновить'),
              ),
            ],
          ),
        ),
      );
    }
    if (visibleGames.isEmpty) {
      return const Center(
        child: Text('Ничего не нашлось', style: TextStyle(fontSize: 16)),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleGames = _onlyFavorites
        ? _games.where((game) => _favoriteIds.contains(game.id)).toList()
        : _games;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 166, 228),
      body: SafeArea(
        child: Column(
          children: [
            // Шапка каталога
            Container(
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
                        onPressed: () =>
                            setState(() => _showForm = !_showForm),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'В каталоге: ${_games.length} · '
                    'В избранном: ${_favoriteIds.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF858585),
                    ),
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
                          color: _onlyFavorites
                              ? const Color(0xFFE3F0EF)
                              : Colors.white,
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
                              _onlyFavorites
                                  ? Icons.favorite
                                  : Icons.favorite_border,
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
            ),

            // Форма добавления (сворачиваемая)
            if (_showForm) _buildForm(),

            // Список игр / загрузка / ошибка
            Expanded(child: _buildBody(visibleGames)),
          ],
        ),
      ),
    );
  }
}