class Review {
  final int? id;
  final int kulinerId;
  final int userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? username; // For display purposes when joined with users table
  final double? latitude;
  final double? longitude;

  Review({
    this.id,
    required this.kulinerId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.username,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kuliner_id': kulinerId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      kulinerId: map['kuliner_id'],
      userId: map['user_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
      username: map['username'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Review copyWith({
    int? id,
    int? kulinerId,
    int? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    String? username,
    double? latitude,
    double? longitude,
  }) {
    return Review(
      id: id ?? this.id,
      kulinerId: kulinerId ?? this.kulinerId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
