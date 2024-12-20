import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlacesListPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  PlacesListPage({required this.cityId, required this.cityName});

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('${cityName}'),
        ),
        body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cities')
            .doc(cityId)
            .collection('attractions')
            .snapshots(),
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

            final attractions = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4 / 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: attractions.length,
              itemBuilder: (context, index) {
                final city = attractions[index];
                final imageUrl = city['imageUrl'];

                return GestureDetector(
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
                      Text(
                        city['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
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