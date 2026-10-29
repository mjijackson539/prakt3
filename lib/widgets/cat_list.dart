
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/cat_service.dart';

class CatList extends StatefulWidget {
  const CatList({super.key});

  @override
  State<CatList> createState() => _CatListState();
}

class _CatListState extends State<CatList> {
  final CatService service = CatService();
  final TextEditingController controller =
      TextEditingController(text: 'a');

  List<Map<String, dynamic>> cats = [];
  bool isLoading = false;
  String? error;

  int? familyFriendly;
  int? playfulness;
  int? intelligence;
  int? shedding;

  @override
  void initState() {
    super.initState();
    loadCats();
  }

  Future<void> loadCats() async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        cats = [];
        error = 'Введите название породы на английском';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await service.fetchCats(
        name,
        familyFriendly: familyFriendly,
        playfulness: playfulness,
        intelligence: intelligence,
        shedding: shedding,
      );

      if (!mounted) return;

      setState(() => cats = result);
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        cats = [];
        error = 'Ошибка сети: ${e.response?.statusCode ?? e.message}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cats = [];
        error = 'Не удалось получить данные: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showDetails(Map<String, dynamic> cat) {
    String field(String key) =>
        cat[key]?.toString() ?? 'Нет данных';

    String rating(String key) {
      final value = cat[key];
      return value == null ? 'Нет данных' : '$value/5';
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(field('name')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (field('image_link').startsWith('http'))
                Image.network(
                  field('image_link'),
                  height: 160,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              const SizedBox(height: 12),
              Text('Происхождение: ${field('origin')}'),
              Text(
                'Продолжительность жизни: '
                '${field('min_life_expectancy')}–'
                '${field('max_life_expectancy')} лет',
              ),
              Text('Интеллект: ${rating('intelligence')}'),
              Text('Дружелюбие: ${rating('family_friendly')}'),
              Text('Игривость: ${rating('playfulness')}'),
              Text('Линька: ${rating('shedding')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget buildFilter(
    String title,
    int? value,
    ValueChanged<int?> onChanged,
  ) {
    return DropdownButton<int?>(
      value: value,
      hint: Text(title),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('$title: любой'),
        ),
        for (var i = 1; i <= 5; i++)
          DropdownMenuItem<int?>(
            value: i,
            child: Text('$title: $i/5'),
          ),
      ],
      onChanged: isLoading ? null : onChanged,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Порода на английском',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => loadCats(),
                ),
              ),
              IconButton(
                onPressed: isLoading ? null : loadCats,
                icon: const Icon(Icons.search),
                tooltip: 'Найти',
              ),
              IconButton(
                onPressed: isLoading ? null : loadCats,
                icon: const Icon(Icons.refresh),
                tooltip: 'Обновить',
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              buildFilter(
                'Дружелюбие',
                familyFriendly,
                (value) {
                  setState(() => familyFriendly = value);
                },
              ),
              buildFilter(
                'Игривость',
                playfulness,
                (value) {
                  setState(() => playfulness = value);
                },
              ),
              buildFilter(
                'Интеллект',
                intelligence,
                (value) {
                  setState(() => intelligence = value);
                },
              ),
              buildFilter(
                'Линька',
                shedding,
                (value) {
                  setState(() => shedding = value);
                },
              ),
              ElevatedButton(
                onPressed: isLoading ? null : loadCats,
                child: const Text('Применить'),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          familyFriendly = null;
                          playfulness = null;
                          intelligence = null;
                          shedding = null;
                        });
                        loadCats();
                      },
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ),

        if (isLoading) const LinearProgressIndicator(),

        if (error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error!),
          ),

        Expanded(
          child: !isLoading && error == null && cats.isEmpty
              ? const Center(child: Text('Породы не найдены'))
              : ListView.builder(
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final cat = cats[index];
                    final image =
                        cat['image_link']?.toString() ?? '';

                    return ListTile(
                      leading: image.startsWith('http')
                          ? Image.network(
                              image,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.pets),
                            )
                          : const Icon(Icons.pets),
                      title: Text(
                        cat['name']?.toString() ??
                            'Без названия',
                      ),
                      subtitle: Text(
                        cat['origin']?.toString() ??
                            'Происхождение неизвестно',
                      ),
                      trailing:
                          const Icon(Icons.chevron_right),
                      onTap: () => showDetails(cat),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
