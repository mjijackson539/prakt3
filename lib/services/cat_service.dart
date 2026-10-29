
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class CatService {
  final Dio dio = GetIt.instance<Dio>();

  Future<List<Map<String, dynamic>>> fetchCats(
    String name, {
    int? familyFriendly,
    int? playfulness,
    int? intelligence,
    int? shedding,
  }) async {
    final response = await dio.get('/cats', queryParameters: {
      'name': name,
      if (familyFriendly != null) 'family_friendly': familyFriendly,
      if (playfulness != null) 'playfulness': playfulness,
    });

    final data = response.data as List<dynamic>;

    final cats = data
        .map((cat) => Map<String, dynamic>.from(cat as Map))
        .toList();

    return cats.where((cat) {
      final matchesIntelligence = intelligence == null ||
          cat['intelligence'] == intelligence;

      final matchesShedding =
          shedding == null || cat['shedding'] == shedding;

      return matchesIntelligence && matchesShedding;
    }).toList();
  }
}
