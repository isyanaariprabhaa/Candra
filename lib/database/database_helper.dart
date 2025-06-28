import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/kuliner.dart';
import '../models/review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  DatabaseHelper._internal();

  // SQLite database
  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    return await _getSqliteDatabase();
  }

  Future<sqflite.Database> _getSqliteDatabase() async {
    if (_database != null) return _database!;

    String path = join(await sqflite.getDatabasesPath(), 'balikuliner.db');

    _database = await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatar TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Kuliner table
    await db.execute('''
      CREATE TABLE kuliners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        address TEXT,
        category TEXT,
        price_range TEXT,
        rating REAL DEFAULT 0,
        latitude REAL,
        longitude REAL,
        image_url TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Reviews table
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kuliner_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        username TEXT,
        latitude REAL,
        longitude REAL,
        FOREIGN KEY (kuliner_id) REFERENCES kuliners (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tambahkan user default candra
    final userId = await db.insert('users', {
      'username': 'candra',
      'email': 'candra@balikuliner.com',
      'password': 'admin123',
      'avatar': null,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Data dummy 1 per kategori
    await db.insert('kuliners', {
      'name': 'Ayam Betutu Bali',
      'description': 'Ayam betutu khas Bali dengan bumbu rempah tradisional',
      'category': 'Makanan Utama',
      'price_range': 'Rp 50.000 - 75.000',
      'address': 'Jl. Raya Ubud, Bali',
      'latitude': -8.5069,
      'longitude': 115.2625,
      'image_url': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80',
      'rating': 4.5,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('kuliners', {
      'name': 'Es Daluman',
      'description': 'Minuman segar khas Bali dengan cincau hijau dan santan',
      'category': 'Minuman',
      'price_range': 'Rp 10.000 - 15.000',
      'address': 'Jl. Teuku Umar, Denpasar',
      'latitude': -8.6705,
      'longitude': 115.2126,
      'image_url': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
      'rating': 4.2,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('kuliners', {
      'name': 'Pie Susu Bali',
      'description': 'Cemilan manis khas Bali dengan isian susu lembut',
      'category': 'Snack',
      'price_range': 'Rp 2.000 - 5.000',
      'address': 'Jl. By Pass Ngurah Rai, Bali',
      'latitude': -8.7482,
      'longitude': 115.1675,
      'image_url': 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=600&q=80',
      'rating': 4.6,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('kuliners', {
      'name': 'Dadar Gulung',
      'description': 'Dessert tradisional berisi kelapa parut dan gula merah',
      'category': 'Dessert',
      'price_range': 'Rp 3.000 - 7.000',
      'address': 'Jl. Diponegoro, Denpasar',
      'latitude': -8.6556,
      'longitude': 115.2167,
      'image_url': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=600&q=80',
      'rating': 4.3,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('kuliners', {
      'name': 'Sate Lilit Ikan',
      'description': 'Sate lilit ikan khas Bali dengan bumbu tradisional',
      'category': 'Seafood',
      'price_range': 'Rp 15.000 - 25.000',
      'address': 'Jl. Gatot Subroto, Denpasar',
      'latitude': -8.6386,
      'longitude': 115.2167,
      'image_url': 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=80',
      'rating': 4.4,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('kuliners', {
      'name': 'Gado-gado Bali',
      'description': 'Gado-gado khas Bali dengan bumbu kacang dan sayuran segar',
      'category': 'Vegetarian',
      'price_range': 'Rp 12.000 - 20.000',
      'address': 'Jl. Raya Kuta, Kuta',
      'latitude': -8.7237,
      'longitude': 115.1750,
      'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      'rating': 4.1,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
    print('Added dummy data for all categories');
  }

  // Method untuk insert sample data - DICOMMENT UNTUK MENGHILANGKAN DATA DUMMY
  /*
  Future<void> _insertSampleData(sqflite.Database db) async {
    // Insert sample user
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@balikuliner.com',
      'password': 'admin123',
      'avatar': null,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Sample kuliner data
    final kulinerList = [
      {
        'name': 'Ayam Betutu Gilimanuk',
        'description': 'Ayam betutu khas Bali dengan bumbu rempah tradisional',
        'category': 'Makanan Utama',
        'price_range': 'Rp 50.000 - 75.000',
        'address': 'Jl. Monkey Forest Road, Ubud',
        'latitude': -8.5069,
        'longitude': 115.2625,
        'image_url':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80',
        'rating': 4.5,
      },
      {
        'name': 'Bebek Bengil Dirty Duck',
        'description': 'Bebek goreng crispy dengan sambal matah khas Bali',
        'category': 'Makanan Utama',
        'price_range': 'Rp 60.000 - 80.000',
        'address': 'Jl. Hanoman, Ubud',
        'latitude': -8.5081,
        'longitude': 115.2656,
        'image_url':
            'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=600&q=80',
        'rating': 4.7,
      },
      {
        'name': 'Nasi Campur Bali Men Weti',
        'description':
            'Nasi campur khas Bali dengan lauk lengkap dan sambal pedas.',
        'category': 'Makanan Utama',
        'price_range': 'Rp 25.000 - 40.000',
        'address': 'Jl. Segara Ayu, Sanur',
        'latitude': -8.6935,
        'longitude': 115.2603,
        'image_url':
            'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=600&q=80',
        'rating': 4.8,
      },
      {
        'name': 'Sate Lilit Warung Mak Beng',
        'description': 'Sate lilit ikan khas Bali, gurih dan wangi daun jeruk.',
        'category': 'Seafood',
        'price_range': 'Rp 20.000 - 35.000',
        'address': 'Jl. Hang Tuah, Sanur',
        'latitude': -8.6705,
        'longitude': 115.2551,
        'image_url':
            'https://images.unsplash.com/photo-1559847844-5315695dadae?auto=format&fit=crop&w=600&q=80',
        'rating': 4.6,
      },
      {
        'name': 'Es Daluman Segar',
        'description': 'Minuman tradisional Bali dari cincau hijau dan santan.',
        'category': 'Minuman',
        'price_range': 'Rp 8.000 - 15.000',
        'address': 'Jl. Raya Kuta, Kuta',
        'latitude': -8.7237,
        'longitude': 115.1750,
        'image_url':
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
        'rating': 4.3,
      },
      {
        'name': 'Pie Susu Bali',
        'description': 'Pie susu khas Bali, manis dan renyah.',
        'category': 'Dessert',
        'price_range': 'Rp 5.000 - 10.000',
        'address': 'Jl. By Pass Ngurah Rai, Denpasar',
        'latitude': -8.7231,
        'longitude': 115.1843,
        'image_url':
            'https://images.unsplash.com/photo-1505250469679-203ad9ced0cb?auto=format&fit=crop&w=600&q=80',
        'rating': 4.4,
      },
      {
        'name': 'Jaje Bali',
        'description': 'Aneka jajanan pasar tradisional Bali.',
        'category': 'Jajanan',
        'price_range': 'Rp 2.000 - 10.000',
        'address': 'Pasar Badung, Denpasar',
        'latitude': -8.6586,
        'longitude': 115.2167,
        'image_url':
            'https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=600&q=80',
        'rating': 4.2,
      },
      {
        'name': 'Kopi Bali',
        'description': 'Kopi robusta khas Bali, nikmat dan harum.',
        'category': 'Minuman',
        'price_range': 'Rp 10.000 - 25.000',
        'address': 'Jl. Veteran, Denpasar',
        'latitude': -8.6700,
        'longitude': 115.2123,
        'image_url':
            'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=600&q=80',
        'rating': 4.6,
      },
      {
        'name': 'Lawar Bali',
        'description': 'Lawar khas Bali, campuran sayur dan daging berbumbu.',
        'category': 'Makanan Utama',
        'price_range': 'Rp 15.000 - 30.000',
        'address': 'Jl. Gatot Subroto, Denpasar',
        'latitude': -8.6520,
        'longitude': 115.2160,
        'image_url':
            'https://images.unsplash.com/photo-1506089676908-3592f7389d4d?auto=format&fit=crop&w=600&q=80',
        'rating': 4.5,
      },
      {
        'name': 'Tipat Cantok',
        'description': 'Tipat cantok, ketupat dengan sayur dan bumbu kacang.',
        'category': 'Jajanan',
        'price_range': 'Rp 8.000 - 15.000',
        'address': 'Jl. Diponegoro, Denpasar',
        'latitude': -8.6702,
        'longitude': 115.2125,
        'image_url':
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=600&q=80',
        'rating': 4.1,
      },
    ];
    int userId = 1;
    for (final kuliner in kulinerList) {
      final kulinerId = await db.insert('kuliners', {
        ...kuliner,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      // Insert dummy review for each kuliner
      await db.insert('reviews', {
        'kuliner_id': kulinerId,
        'user_id': userId,
        'rating': kuliner['rating'],
        'comment': 'Enak banget! Wajib coba.',
        'created_at': DateTime.now().toIso8601String(),
        'username': 'admin',
        'latitude': kuliner['latitude'],
        'longitude': kuliner['longitude'],
      });
    }
  }
  */

  // User CRUD operations
  Future<int> insertUser(User user) async {
    final db = await database as sqflite.Database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Kuliner CRUD operations
  Future<int> insertKuliner(Kuliner kuliner) async {
    final db = await database as sqflite.Database;
    print('Inserting kuliner to SQLite: ${kuliner.toMap()}');
    final result = await db.insert('kuliners', kuliner.toMap());
    print('SQLite insert result: $result');
    return result;
  }

  Future<List<Kuliner>> getAllKuliner() async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query('kuliners');
    return List.generate(maps.length, (i) => Kuliner.fromMap(maps[i]));
  }

  Future<List<Kuliner>> searchKuliner(String query) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kuliners',
      where: 'name LIKE ? OR description LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Kuliner.fromMap(maps[i]));
  }

  // Review CRUD operations
  Future<int> insertReview(Review review) async {
    final db = await database as sqflite.Database;
    print('Inserting review to SQLite: ${review.toMap()}');
    final result = await db.insert('reviews', review.toMap());
    print('SQLite review insert result: $result');
    return result;
  }

  Future<List<Review>> getReviewsForKuliner(int kulinerId) async {
    final db = await database as sqflite.Database;
    print('Querying SQLite for reviews with kuliner_id: $kulinerId');
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'kuliner_id = ?',
      whereArgs: [kulinerId],
    );
    print('SQLite found ${maps.length} reviews for kuliner $kulinerId');
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<void> updateKulinerRating(int kulinerId) async {
    try {
      print('Updating kuliner rating for kuliner ID: $kulinerId');
      sqflite.Database db = await database as sqflite.Database;
      List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT AVG(rating) as avg_rating 
        FROM reviews 
        WHERE kuliner_id = ?
      ''', [kulinerId]);

      double avgRating = result.first['avg_rating'] ?? 0.0;
      print('Calculated average rating: $avgRating');

      final updateResult = await db.update(
        'kuliners',
        {'rating': avgRating},
        where: 'id = ?',
        whereArgs: [kulinerId],
      );
      print('Updated kuliner rating. Rows affected: $updateResult');
    } catch (e) {
      print('Error updating kuliner rating: $e');
    }
  }

  // Additional CRUD operations for User
  Future<User?> getUserById(int id) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database as sqflite.Database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database as sqflite.Database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Additional CRUD operations for Kuliner
  Future<Kuliner?> getKulinerById(int id) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kuliners',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Kuliner.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateKuliner(Kuliner kuliner) async {
    final db = await database as sqflite.Database;
    return await db.update(
      'kuliners',
      kuliner.toMap(),
      where: 'id = ?',
      whereArgs: [kuliner.id],
    );
  }

  Future<int> deleteKuliner(int id) async {
    final db = await database as sqflite.Database;
    // Delete related reviews first
    await db.delete(
      'reviews',
      where: 'kuliner_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'kuliners',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Additional CRUD operations for Review
  Future<Review?> getReviewById(int id) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Review.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReview(Review review) async {
    final db = await database as sqflite.Database;
    final result = await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );

    // Update kuliner rating after review update
    if (result > 0) {
      await updateKulinerRating(review.kulinerId);
    }

    return result;
  }

  Future<int> deleteReview(int id) async {
    final db = await database as sqflite.Database;
    // Get kuliner_id before deleting
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );

    int kulinerId = 0;
    if (maps.isNotEmpty) {
      kulinerId = maps.first['kuliner_id'] as int;
    }

    final result = await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Update kuliner rating after review deletion
    if (result > 0 && kulinerId > 0) {
      await updateKulinerRating(kulinerId);
    }

    return result;
  }

  // Get all users (for admin purposes)
  Future<List<User>> getAllUsers() async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Get all reviews (for admin purposes)
  Future<List<Review>> getAllReviews() async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query('reviews');
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
  }
}
