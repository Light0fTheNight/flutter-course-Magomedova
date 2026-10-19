
import 'package:flutter/material.dart';

import '../../domain/entities/board_game.dart';
import '../widgets/board_game_card.dart';

const List<BoardGame> games = [
  BoardGame(
    id: 1,
    title: 'Колонизаторы',
    subtitle: 'Klaus Teuber · 1995',
    category: BoardGameCategory.strategy,
    genres: ['Стратегия', 'Семейная'],
    image: 'https://www.igroved.ru/db/games/images/4/4/01.jpg',
  ),
  BoardGame(
    id: 2,
    title: 'Эпичные схватки боевых магов: Крутагидон',
    subtitle: 'Ben Stoll · 2019',
    category: BoardGameCategory.card,
    genres: ['Стратегия', 'Колодостроительная'],
    image:
        'https://hobbygames.ru/image/data/HobbyWorld/Shvatki_Magov/Krutagidon/ESW_Deckbuilding_box_3d-roznica.jpg',
  ),
  BoardGame(
    id: 3,
    title: 'Каркассон',
    subtitle: 'Klaus-Jürgen Wrede · 2000',
    category: BoardGameCategory.strategy,
    genres: ['Стратегия', 'Семейная'],
    image:
        'https://hobbygames.ru/image/data/HobbyWorld/Karkasson/2022/carcassonne_2022_00.jpg',
  ),
  BoardGame(
    id: 4,
    title: 'Восходящее Солнце',
    subtitle: 'Eric M. Lang · 2018',
    category: BoardGameCategory.strategy,
    genres: [
      'Стратегия',
      'Контроль территории',
      'Варгейм',
      'Дипломатия',
    ],
    image:
        'https://hobbygames.ru/image/cache/hobbygames_beta/data/HobbyWorld/Voskhodyaschee_Solntse/2021_Tirazh/Voshodyashchee_solnce_00-1024x1024-wm.jpg',
  ),
  BoardGame(
    id: 5,
    title: 'За бортом',
    subtitle: 'Jeff Siadek · 2002',
    category: BoardGameCategory.psychological,
    genres: ['Психологическая'],
    image:
        'https://igrrai.ru/image/catalog/Magellan/Za%20bortom%202/DSC_0868.jpg',
  ),
  BoardGame(
    id: 6,
    title: 'Манчкин',
    subtitle: 'Steve Jackson · 2001',
    category: BoardGameCategory.card,
    genres: ['Карточная', 'Приключения', 'Пародия'],
    image:
        'https://hobbygames.ru/image/data/HobbyWorld/Munchkin/1000/Munchkin_Deluxe00.jpg',
  ),
  BoardGame(
    id: 7,
    title: 'Бункер',
    subtitle: 'Оксана Солдатова · 2018',
    category: BoardGameCategory.psychological,
    genres: ['Психологическая', 'Дискуссионная', 'Ролевая'],
    image:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnhP_J7pKeGthXiavyGhau5OxvHAgpDF43P05JCjzGS9cmKoa9PYd2CXs&s=10',
  ),
  BoardGame(
    id: 8,
    title: 'Предназначение',
    subtitle: 'Michał Gołębiowski · 2021',
    category: BoardGameCategory.rolePlaying,
    genres: ['Приключение', 'Дарк-фэнтези', 'Ролевая'],
    image:
        'https://migames.ru/wa-data/public/shop/products/21/60/16021/images/26073/26073.970.jpg',
  ),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _favoriteIds = {};
  bool _onlyFavorites = false;

  void _toggleFavorite(int gameId) {
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

  @override
  Widget build(BuildContext context) {
    final visibleGames = _onlyFavorites
        ? games.where((game) => _favoriteIds.contains(game.id)).toList()
        : games;

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
                  const Text(
                    'Настольные игры',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'В каталоге: ${games.length} · '
                    'В избранном: ${_favoriteIds.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF858585),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Кнопка фильтра под статистикой
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

            // Список игр
            Expanded(
              child: visibleGames.isEmpty
                  ? const Center(
                      child: Text(
                        'Ничего не нашлось',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
