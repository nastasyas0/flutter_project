import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:test_flutter_app/FavoritesService/cityModel.dart';

class FavoritesService {
  static const String favoritesKey = 'favorites';

  Future<void> addCityToFavorites(City city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];

    // Проверка на дубликаты
    if (!favorites.contains(city.id)) {
      favorites.add(jsonEncode(city.toJson()));
      await prefs.setStringList(favoritesKey, favorites);
    }
  }

  Future<bool> isCityFavorite(String cityId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];
    return favorites.any((item) {
      final city = City.fromJson(jsonDecode(item));
      return city.id == cityId;
    });
  }

  Future<void> removeCityFromFavorites(String cityId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];

    favorites.removeWhere((item) {
      final city = City.fromJson(jsonDecode(item));
      return city.id == cityId;
    });

    await prefs.setStringList(favoritesKey, favorites);
  }

  Future<List<City>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(favoritesKey) ?? [];

    return favorites.map((item) => City.fromJson(jsonDecode(item))).toList();
  }
}
