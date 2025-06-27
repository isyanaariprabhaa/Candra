import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast_web/sembast_web.dart' as sembast_web;
import 'package:sembast/sembast_io.dart' as sembast_io;
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

  // Sembast database for web
  static sembast.Database? _sembastDatabase;
  static sembast.StoreRef<String, Map<String, dynamic>>? _userStore;
  static sembast.StoreRef<String, Map<String, dynamic>>? _kulinerStore;
  static sembast.StoreRef<String, Map<String, dynamic>>? _reviewStore;

  Future<dynamic> get database async {
    if (kIsWeb) {
      return await _getSembastDatabase();
    } else {
      return await _getSqliteDatabase();
    }
  }

  Future<sqflite.Database> _getSqliteDatabase() async {
    if (_database != null) return _database!;

    String path = join(await sqflite.getDatabasesPath(), 'balikuliner.db');

    // Delete existing database to force recreation with new schema
    // try {
    //   await sqflite.deleteDatabase(path);
    //   print('Deleted existing database to recreate with new schema');
    // } catch (e) {
    //   print('Error deleting database: $e');
    // }

    _database = await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<sembast.Database> _getSembastDatabase() async {
    if (_sembastDatabase != null) return _sembastDatabase!;
    if (kIsWeb) {
      _sembastDatabase =
          await sembast_web.databaseFactoryWeb.openDatabase('balikuliner.db');
    } else {
      _sembastDatabase =
          await sembast_io.databaseFactoryIo.openDatabase('balikuliner.db');
    }
    _userStore = sembast.stringMapStoreFactory.store('users');
    _kulinerStore = sembast.stringMapStoreFactory.store('kuliners');
    _reviewStore = sembast.stringMapStoreFactory.store('reviews');
    // Tambahkan user default jika belum ada
    final db = _sembastDatabase!;
    final finderCandra = sembast.Finder(
        filter: sembast.Filter.equals('email', 'candra@balikuliner.com'));
    final recordsCandra = await _userStore!.find(db, finder: finderCandra);
    if (recordsCandra.isEmpty) {
      await _userStore!.add(db, {
        'username': 'candra',
        'email': 'candra@balikuliner.com',
        'password': 'admin123',
        'avatar': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return _sembastDatabase!;
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
        FOREIGN KEY (kuliner_id) REFERENCES kuliners (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);

    // Tambahkan user default candra
    await db.insert('users', {
      'username': 'candra',
      'email': 'candra@balikuliner.com',
      'password': 'admin123',
      'avatar': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

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
      });
    }
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      return await _insertUserSembast(user);
    } else {
      return await _insertUserSqlite(user);
    }
  }

  Future<int> _insertUserSqlite(User user) async {
    final db = await database as sqflite.Database;
    return await db.insert('users', user.toMap());
  }

  Future<int> _insertUserSembast(User user) async {
    final db = await database as sembast.Database;
    final id = DateTime.now().millisecondsSinceEpoch;
    final userWithId = user.copyWith(id: id);
    await _userStore!.add(db, userWithId.toMap());
    return id;
  }

  Future<User?> getUserByEmail(String email) async {
    if (kIsWeb) {
      return await _getUserByEmailSembast(email);
    } else {
      return await _getUserByEmailSqlite(email);
    }
  }

  Future<User?> _getUserByEmailSqlite(String email) async {
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

  Future<User?> _getUserByEmailSembast(String email) async {
    final db = await database as sembast.Database;
    final finder =
        sembast.Finder(filter: sembast.Filter.equals('email', email));
    final records = await _userStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      return User.fromMap(records.first.value);
    }
    return null;
  }

  // Kuliner CRUD operations
  Future<int> insertKuliner(Kuliner kuliner) async {
    if (kIsWeb) {
      return await _insertKulinerSembast(kuliner);
    } else {
      return await _insertKulinerSqlite(kuliner);
    }
  }

  Future<int> _insertKulinerSqlite(Kuliner kuliner) async {
    try {
      final db = await database as sqflite.Database;
      print('Inserting kuliner to SQLite: ${kuliner.toMap()}');
      final result = await db.insert('kuliners', kuliner.toMap());
      print('SQLite insert result: $result');
      return result;
    } catch (e) {
      print('SQLite insert error: $e');
      rethrow;
    }
  }

  Future<int> _insertKulinerSembast(Kuliner kuliner) async {
    try {
      final db = await database as sembast.Database;
      final id = DateTime.now().millisecondsSinceEpoch;
      final kulinerWithId = kuliner.copyWith(id: id);
      print('Inserting kuliner to Sembast: ${kulinerWithId.toMap()}');
      await _kulinerStore!.add(db, kulinerWithId.toMap());
      print('Sembast insert result: $id');
      return id;
    } catch (e) {
      print('Sembast insert error: $e');
      rethrow;
    }
  }

  Future<List<Kuliner>> getAllKuliner() async {
    if (kIsWeb) {
      final db = await database as sembast.Database;
      final records = await _kulinerStore!.find(db);
      return records.map((record) => Kuliner.fromMap(record.value)).toList();
    } else {
      final db = await database as sqflite.Database;
      final List<Map<String, dynamic>> maps = await db.query('kuliners');
      return List.generate(maps.length, (i) => Kuliner.fromMap(maps[i]));
    }
  }

  Future<List<Kuliner>> searchKuliner(String query) async {
    if (kIsWeb) {
      return await _searchKulinerSembast(query);
    } else {
      return await _searchKulinerSqlite(query);
    }
  }

  Future<List<Kuliner>> _searchKulinerSqlite(String query) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kuliners',
      where: 'name LIKE ? OR description LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Kuliner.fromMap(maps[i]));
  }

  Future<List<Kuliner>> _searchKulinerSembast(String query) async {
    final db = await database as sembast.Database;
    final records = await _kulinerStore!.find(db);
    return records
        .map((record) => Kuliner.fromMap(record.value))
        .where((kuliner) =>
            kuliner.name.toLowerCase().contains(query.toLowerCase()) ||
            kuliner.description.toLowerCase().contains(query.toLowerCase()) ||
            kuliner.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Review CRUD operations
  Future<int> insertReview(Review review) async {
    if (kIsWeb) {
      return await _insertReviewSembast(review);
    } else {
      return await _insertReviewSqlite(review);
    }
  }

  Future<int> _insertReviewSqlite(Review review) async {
    final db = await database as sqflite.Database;
    return await db.insert('reviews', review.toMap());
  }

  Future<int> _insertReviewSembast(Review review) async {
    final db = await database as sembast.Database;
    final id = DateTime.now().millisecondsSinceEpoch;
    final reviewWithId = review.copyWith(id: id);
    await _reviewStore!.add(db, reviewWithId.toMap());
    return id;
  }

  Future<List<Review>> getReviewsForKuliner(int kulinerId) async {
    if (kIsWeb) {
      return await _getReviewsForKulinerSembast(kulinerId);
    } else {
      return await _getReviewsForKulinerSqlite(kulinerId);
    }
  }

  Future<List<Review>> _getReviewsForKulinerSqlite(int kulinerId) async {
    final db = await database as sqflite.Database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'kuliner_id = ?',
      whereArgs: [kulinerId],
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<List<Review>> _getReviewsForKulinerSembast(int kulinerId) async {
    final db = await database as sembast.Database;
    final finder =
        sembast.Finder(filter: sembast.Filter.equals('kuliner_id', kulinerId));
    final records = await _reviewStore!.find(db, finder: finder);
    return records.map((record) => Review.fromMap(record.value)).toList();
  }

  Future<void> _updateKulinerRating(int kulinerId) async {
    sqflite.Database db = await database as sqflite.Database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT AVG(rating) as avg_rating 
      FROM reviews 
      WHERE kuliner_id = ?
    ''', [kulinerId]);

    double avgRating = result.first['avg_rating'] ?? 0.0;
    await db.update(
      'kuliners',
      {'rating': avgRating},
      where: 'id = ?',
      whereArgs: [kulinerId],
    );
  }

  // Additional CRUD operations for User
  Future<User?> getUserById(int id) async {
    if (kIsWeb) {
      return await _getUserByIdSembast(id);
    } else {
      return await _getUserByIdSqlite(id);
    }
  }

  Future<User?> _getUserByIdSqlite(int id) async {
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

  Future<User?> _getUserByIdSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _userStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      return User.fromMap(records.first.value);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    if (kIsWeb) {
      return await _updateUserSembast(user);
    } else {
      return await _updateUserSqlite(user);
    }
  }

  Future<int> _updateUserSqlite(User user) async {
    final db = await database as sqflite.Database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> _updateUserSembast(User user) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', user.id));
    final records = await _userStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      await _userStore!.record(records.first.key).update(db, user.toMap());
      return 1;
    }
    return 0;
  }

  Future<int> deleteUser(int id) async {
    if (kIsWeb) {
      return await _deleteUserSembast(id);
    } else {
      return await _deleteUserSqlite(id);
    }
  }

  Future<int> _deleteUserSqlite(int id) async {
    final db = await database as sqflite.Database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> _deleteUserSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _userStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      await _userStore!.record(records.first.key).delete(db);
      return 1;
    }
    return 0;
  }

  // Additional CRUD operations for Kuliner
  Future<Kuliner?> getKulinerById(int id) async {
    if (kIsWeb) {
      return await _getKulinerByIdSembast(id);
    } else {
      return await _getKulinerByIdSqlite(id);
    }
  }

  Future<Kuliner?> _getKulinerByIdSqlite(int id) async {
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

  Future<Kuliner?> _getKulinerByIdSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _kulinerStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      return Kuliner.fromMap(records.first.value);
    }
    return null;
  }

  Future<int> updateKuliner(Kuliner kuliner) async {
    if (kIsWeb) {
      return await _updateKulinerSembast(kuliner);
    } else {
      return await _updateKulinerSqlite(kuliner);
    }
  }

  Future<int> _updateKulinerSqlite(Kuliner kuliner) async {
    final db = await database as sqflite.Database;
    return await db.update(
      'kuliners',
      kuliner.toMap(),
      where: 'id = ?',
      whereArgs: [kuliner.id],
    );
  }

  Future<int> _updateKulinerSembast(Kuliner kuliner) async {
    final db = await database as sembast.Database;
    final finder =
        sembast.Finder(filter: sembast.Filter.equals('id', kuliner.id));
    final records = await _kulinerStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      await _kulinerStore!
          .record(records.first.key)
          .update(db, kuliner.toMap());
      return 1;
    }
    return 0;
  }

  Future<int> deleteKuliner(int id) async {
    if (kIsWeb) {
      return await _deleteKulinerSembast(id);
    } else {
      return await _deleteKulinerSqlite(id);
    }
  }

  Future<int> _deleteKulinerSqlite(int id) async {
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

  Future<int> _deleteKulinerSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _kulinerStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      // Delete related reviews first
      final reviewFinder =
          sembast.Finder(filter: sembast.Filter.equals('kuliner_id', id));
      final reviewRecords = await _reviewStore!.find(db, finder: reviewFinder);
      for (var record in reviewRecords) {
        await _reviewStore!.record(record.key).delete(db);
      }

      await _kulinerStore!.record(records.first.key).delete(db);
      return 1;
    }
    return 0;
  }

  // Additional CRUD operations for Review
  Future<Review?> getReviewById(int id) async {
    if (kIsWeb) {
      return await _getReviewByIdSembast(id);
    } else {
      return await _getReviewByIdSqlite(id);
    }
  }

  Future<Review?> _getReviewByIdSqlite(int id) async {
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

  Future<Review?> _getReviewByIdSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _reviewStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      return Review.fromMap(records.first.value);
    }
    return null;
  }

  Future<int> updateReview(Review review) async {
    if (kIsWeb) {
      return await _updateReviewSembast(review);
    } else {
      return await _updateReviewSqlite(review);
    }
  }

  Future<int> _updateReviewSqlite(Review review) async {
    final db = await database as sqflite.Database;
    final result = await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );

    // Update kuliner rating after review update
    if (result > 0) {
      await _updateKulinerRating(review.kulinerId);
    }

    return result;
  }

  Future<int> _updateReviewSembast(Review review) async {
    final db = await database as sembast.Database;
    final finder =
        sembast.Finder(filter: sembast.Filter.equals('id', review.id));
    final records = await _reviewStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      await _reviewStore!.record(records.first.key).update(db, review.toMap());
      // Update kuliner rating after review update
      await _updateKulinerRatingSembast(review.kulinerId);
      return 1;
    }
    return 0;
  }

  Future<int> deleteReview(int id) async {
    if (kIsWeb) {
      return await _deleteReviewSembast(id);
    } else {
      return await _deleteReviewSqlite(id);
    }
  }

  Future<int> _deleteReviewSqlite(int id) async {
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
      await _updateKulinerRating(kulinerId);
    }

    return result;
  }

  Future<int> _deleteReviewSembast(int id) async {
    final db = await database as sembast.Database;
    final finder = sembast.Finder(filter: sembast.Filter.equals('id', id));
    final records = await _reviewStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      int kulinerId = records.first.value['kuliner_id'] as int;
      await _reviewStore!.record(records.first.key).delete(db);
      // Update kuliner rating after review deletion
      await _updateKulinerRatingSembast(kulinerId);
      return 1;
    }
    return 0;
  }

  Future<void> _updateKulinerRatingSembast(int kulinerId) async {
    final db = await database as sembast.Database;
    final finder =
        sembast.Finder(filter: sembast.Filter.equals('kuliner_id', kulinerId));
    final records = await _reviewStore!.find(db, finder: finder);

    if (records.isNotEmpty) {
      double totalRating = 0;
      for (var record in records) {
        totalRating += record.value['rating'] as double;
      }
      double avgRating = totalRating / records.length;

      // Update kuliner rating
      final kulinerFinder =
          sembast.Finder(filter: sembast.Filter.equals('id', kulinerId));
      final kulinerRecords =
          await _kulinerStore!.find(db, finder: kulinerFinder);
      if (kulinerRecords.isNotEmpty) {
        final updatedKuliner =
            Map<String, dynamic>.from(kulinerRecords.first.value);
        updatedKuliner['rating'] = avgRating;
        await _kulinerStore!
            .record(kulinerRecords.first.key)
            .update(db, updatedKuliner);
      }
    }
  }

  // Get all users (for admin purposes)
  Future<List<User>> getAllUsers() async {
    if (kIsWeb) {
      final db = await database as sembast.Database;
      final records = await _userStore!.find(db);
      return records.map((record) => User.fromMap(record.value)).toList();
    } else {
      final db = await database as sqflite.Database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    }
  }

  // Get all reviews (for admin purposes)
  Future<List<Review>> getAllReviews() async {
    if (kIsWeb) {
      final db = await database as sembast.Database;
      final records = await _reviewStore!.find(db);
      return records.map((record) => Review.fromMap(record.value)).toList();
    } else {
      final db = await database as sqflite.Database;
      final List<Map<String, dynamic>> maps = await db.query('reviews');
      return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
  }
}
