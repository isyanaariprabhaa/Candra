import 'package:flutter/material.dart';
import '../models/kuliner.dart';
import '../models/review.dart';
import '../database/database_helper.dart';

class KulinerProvider extends ChangeNotifier {
  List<Kuliner> _kulinerList = [];
  List<Kuliner> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Kuliner> get kulinerList => _kulinerList;
  List<Kuliner> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadKuliner() async {
    _isLoading = true;
    notifyListeners();

    try {
      _kulinerList = await DatabaseHelper.instance.getAllKuliner();
    } catch (e) {
      print('Error loading kuliner: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchKuliner(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = await DatabaseHelper.instance.searchKuliner(query);
      }
    } catch (e) {
      print('Error searching kuliner: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addKuliner(Kuliner kuliner) async {
    try {
      print('Adding kuliner: ${kuliner.name}');
      print('Kuliner data: ${kuliner.toMap()}');

      final id = await DatabaseHelper.instance.insertKuliner(kuliner);
      print('Insert result ID: $id');

      if (id > 0) {
        print('Successfully added kuliner with ID: $id');
        await loadKuliner(); // Reload the list
        return true;
      } else {
        print('Failed to add kuliner - ID is 0 or negative');
        return false;
      }
    } catch (e) {
      print('Error adding kuliner: $e');
      print('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<Kuliner?> getKulinerById(int id) async {
    try {
      return await DatabaseHelper.instance.getKulinerById(id);
    } catch (e) {
      print('Error getting kuliner by ID: $e');
      return null;
    }
  }

  Future<bool> updateKuliner(Kuliner kuliner) async {
    try {
      final result = await DatabaseHelper.instance.updateKuliner(kuliner);
      if (result > 0) {
        await loadKuliner(); // Reload the list
        return true;
      }
    } catch (e) {
      print('Error updating kuliner: $e');
    }
    return false;
  }

  Future<bool> deleteKuliner(int id) async {
    try {
      final result = await DatabaseHelper.instance.deleteKuliner(id);
      if (result > 0) {
        await loadKuliner(); // Reload the list
        return true;
      }
    } catch (e) {
      print('Error deleting kuliner: $e');
    }
    return false;
  }

  Future<bool> addReview(Review review) async {
    try {
      final id = await DatabaseHelper.instance.insertReview(review);
      if (id > 0) {
        await loadKuliner(); // Reload to update ratings
        return true;
      }
    } catch (e) {
      print('Error adding review: $e');
    }
    return false;
  }

  Future<List<Review>> getReviewsForKuliner(int kulinerId) async {
    try {
      return await DatabaseHelper.instance.getReviewsForKuliner(kulinerId);
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  Future<Review?> getReviewById(int id) async {
    try {
      return await DatabaseHelper.instance.getReviewById(id);
    } catch (e) {
      print('Error getting review by ID: $e');
      return null;
    }
  }

  Future<bool> updateReview(Review review) async {
    try {
      final result = await DatabaseHelper.instance.updateReview(review);
      if (result > 0) {
        await loadKuliner(); // Reload to update ratings
        return true;
      }
    } catch (e) {
      print('Error updating review: $e');
    }
    return false;
  }

  Future<bool> deleteReview(int id) async {
    try {
      final result = await DatabaseHelper.instance.deleteReview(id);
      if (result > 0) {
        await loadKuliner(); // Reload to update ratings
        return true;
      }
    } catch (e) {
      print('Error deleting review: $e');
    }
    return false;
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  List<Kuliner> getKulinerByCategory(String category) {
    return _kulinerList
        .where((kuliner) => kuliner.category == category)
        .toList();
  }

  List<Kuliner> getTopRatedKuliner({int limit = 5}) {
    final sorted = List<Kuliner>.from(_kulinerList);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  List<Kuliner> getKulinerByPriceRange(String priceRange) {
    return _kulinerList
        .where((kuliner) => kuliner.priceRange == priceRange)
        .toList();
  }

  List<Kuliner> getKulinerByIds(List<int> ids) {
    return _kulinerList.where((k) => ids.contains(k.id)).toList();
  }
}
