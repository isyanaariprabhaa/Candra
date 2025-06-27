class Kuliner {
  final int id;
  final String name;
  final String description;
  final String category;
  final String priceRange;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final double rating;
  final int userId;
  final DateTime createdAt;

  Kuliner({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priceRange,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.rating = 0.0,
    required this.userId,
    required this.createdAt,
  });

  Kuliner copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? priceRange,
    String? address,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    int? userId,
    DateTime? createdAt,
  }) {
    return Kuliner(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      priceRange: priceRange ?? this.priceRange,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'description': description,
      'category': category,
      'price_range': priceRange,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'rating': rating,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Kuliner.fromMap(Map<String, dynamic> map) {
    return Kuliner(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      priceRange: map['price_range'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrl: map['image_url'],
      rating: map['rating'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
