class City {
  final String id;
  final String name;
  final String imageUrl;

  City({required this.id, required this.name, required this.imageUrl});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
  };

  static City fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
