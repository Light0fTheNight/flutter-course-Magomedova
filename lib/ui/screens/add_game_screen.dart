import 'package:flutter/material.dart';

import '../../domain/entities/board_game.dart';
import '../widgets/category_view.dart';

const placeholderImage = 'https://placehold.co/300x360.png';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _imageController = TextEditingController();
  final _genresController = TextEditingController();
  final _descriptionController = TextEditingController();

  BoardGameCategory _category = BoardGameCategory.strategy;
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageController.dispose();
    _genresController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Введите название');
      return;
    }

    final image = _imageController.text.trim();
    final genres = _genresController.text
        .split(',')
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();

    final game = BoardGame(
      id: '',
      title: title,
      subtitle: _subtitleController.text.trim(),
      category: _category,
      image: image.isEmpty ? placeholderImage : image,
      genres: genres,
      description: _descriptionController.text.trim(),
    );
    Navigator.pop(context, game);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 166, 228),
      appBar: AppBar(
        title: const Text('Новая игра'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _titleController,
                      onChanged: (_) {
                        if (_titleError != null) {
                          setState(() => _titleError = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Название *',
                        errorText: _titleError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  _field(_subtitleController, 'Автор | год'),
                  _field(_imageController, 'Ссылка на картинку'),
                  _field(_genresController, 'Жанры через запятую'),
                  _field(_descriptionController, 'Описание', maxLines: 4),
                  DropdownButton<BoardGameCategory>(
                    value: _category,
                    isExpanded: true,
                    items: [
                      for (final category in BoardGameCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(categoryIcon(category), size: 18),
                              const SizedBox(width: 8),
                              Text(categoryLabel(category)),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}