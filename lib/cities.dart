import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_flutter_app/places_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_flutter_app/FavoritesService/cityModel.dart';
import 'package:test_flutter_app/FavoritesService/shared_pref.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  @override
  _CitiesPageState createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<City> favoriteCities = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteCities();
  }

  Future<void> _loadFavoriteCities() async {
    final cities = await _favoritesService.getFavoriteCities();
    setState(() {
      favoriteCities = cities;
    });
  }

  Future<void> _toggleFavorite(City city) async {
    if (favoriteCities.any((c) => c.id == city.id)) {
      await _favoritesService.removeCityFromFavorites(city.id);
      setState(() {
        favoriteCities.removeWhere((c) => c.id == city.id);
      });
    } else {
      await _favoritesService.addCityToFavorites(city);
      setState(() {
        favoriteCities.add(city);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Города России'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Нет данных'));
          }

          final cities = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4 / 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              final imageUrl = city['imageUrl'];
              final cityName = city['name'];
              final cityId = city.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacesListPage(cityId: cityId, cityName: cityName),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: imageUrl != null
                        //     ? Image.network(  // Загрузка данных по сети
                        //   imageUrl,
                        //   fit: BoxFit.cover,
                        // )
                              ? CachedNetworkImage(  // Кэширование данных
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey,  // Фон для ошибки загрузки изображения
                            child: Icon(Icons.error),
                          ),
                        )
                            : Container(
                          color: Colors.grey, // Фон для отсутствующего изображения
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cityName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            favoriteCities.any((c) => c.id == cityId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          onPressed: () => _toggleFavorite(City(id: cityId, name: cityName, imageUrl: imageUrl)),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

