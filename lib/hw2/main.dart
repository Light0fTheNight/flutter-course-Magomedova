import 'package:flutter/material.dart';

void main() {
  runApp(const Hw2App());
}

class Hw2App extends StatelessWidget {
  const Hw2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 209, 166, 228),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Настольные игры'),
              Text(
                '${games.length} игр в каталоге',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final game in games)
                buildGameCard(game),
            ],
          ),
        ),
      ),
    );
  }
}

class BoardGame {
  final String title;
  final String designer;
  final String year;
  final List<String> genres;
  final String image;
  final IconData categoryIcon;

  const BoardGame({
    required this.title,
    required this.designer,
    required this.year,
    required this.genres,
    required this.image,
    required this.categoryIcon,
  });
}

const games = [
  BoardGame(
    title: 'Колонизаторы',
    designer: 'Klaus Teuber',
    year: '1995',
    genres: ['Стратегия', 'Семейная'],
    image: 'https://www.igroved.ru/db/games/images/4/4/01.jpg',
    categoryIcon: Icons.wb_twilight,
  ),

  BoardGame(
    title: 'Эпичные схватки боевых магов: Крутагидон',
    designer: 'Ben Stoll',
    year: '2019',
    genres: ['Стратегия', 'Колодостроительная'],
    image: 'https://hobbygames.ru/image/data/HobbyWorld/Shvatki_Magov/Krutagidon/ESW_Deckbuilding_box_3d-roznica.jpg',
    categoryIcon: Icons.emoji_events,
  ),

  BoardGame(
    title: 'Каркассон',
    designer: 'Klaus-Jürgen Wrede',
    year: '2000',
    genres: ['Стратегия', 'Семейная'],
    image: 'https://hobbygames.ru/image/data/HobbyWorld/Karkasson/2022/carcassonne_2022_00.jpg',
    categoryIcon: Icons.castle,
  ),

  BoardGame(
    title: 'Восходящее Солнце',
    designer: 'Eric M. Lang',
    year: '2018',
    genres: ['Стратегия', 'Контроль территории', 'Варгейм', 'Дипломатия'],
    image: 'https://hobbygames.ru/image/cache/hobbygames_beta/data/HobbyWorld/Voskhodyaschee_Solntse/2021_Tirazh/Voshodyashchee_solnce_00-1024x1024-wm.jpg',
    categoryIcon: Icons.rice_bowl,
  ),

  BoardGame(
    title: 'За бортом',
    designer: 'Jeff Siadek',
    year: '2002',
    genres: ['Психологическая'],
    image: 'https://igrrai.ru/image/catalog/Magellan/Za%20bortom%202/DSC_0868.jpg',
    categoryIcon: Icons.sailing,
  ),

  BoardGame(
    title: 'Манчкин',
    designer: 'Steve Jackson',
    year: '2001',
    genres: ['Карточная', 'Приключения', 'Пародия'],
    image: 'https://hobbygames.ru/image/data/HobbyWorld/Munchkin/1000/Munchkin_Deluxe00.jpg',
    categoryIcon: Icons.style,
  ),

  BoardGame(
    title: 'Бункер',
    designer: 'Оксана Солдатова',
    year: '2018',
    genres: ['Психологическая', 'Дискуссионная', 'Ролевая'],
    image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnhP_J7pKeGthXiavyGhau5OxvHAgpDF43P05JCjzGS9cmKoa9PYd2CXs&s=10',
    categoryIcon: Icons.home_max,
  ),

  BoardGame(
    title: 'Предназначение',
    designer: 'Michał Gołębiowski',
    year: '2021',
    genres: ['Приключение', 'Дарк-фэнтези', 'Ролевая'],
    image: 'https://migames.ru/wa-data/public/shop/products/21/60/16021/images/26073/26073.970.jpg',
    categoryIcon: Icons.description,
  ),
];

Widget buildGameCard(BoardGame game) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 120,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    game.image,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      game.categoryIcon,
                      size: 16,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        '${game.designer} · ${game.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: game.genres.map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}