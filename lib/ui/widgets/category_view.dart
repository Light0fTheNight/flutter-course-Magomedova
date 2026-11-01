import 'package:flutter/material.dart';

import '../../domain/entities/board_game.dart';

String categoryLabel(BoardGameCategory category) {
  switch (category) {
    case BoardGameCategory.strategy:
      return 'Стратегия';
    case BoardGameCategory.psychological:
      return 'Психологическая';
    case BoardGameCategory.card:
      return 'Карточная';
    case BoardGameCategory.rolePlaying:
      return 'Ролевая';
  }
}

IconData categoryIcon(BoardGameCategory category) {
  switch (category) {
    case BoardGameCategory.strategy:
      return Icons.flag;
    case BoardGameCategory.psychological:
      return Icons.psychology;
    case BoardGameCategory.card:
      return Icons.style;
    case BoardGameCategory.rolePlaying:
      return Icons.auto_stories;
  }
}