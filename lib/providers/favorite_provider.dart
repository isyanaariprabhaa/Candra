import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  static const String _key = 'favorite_kuliner_ids';
  List<int> _favoriteIds = [];

  FavoriteProvider(this.prefs) {
    loadFavorites();
  }

  List<int> get favoriteIds => _favoriteIds;

  void loadFavorites() {
    final ids = prefs.getStringList(_key) ?? [];
    _favoriteIds = ids
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e > 0) // Hanya ID yang valid (lebih dari 0)
        .toList();
    print('Loaded favorites: $_favoriteIds');
    notifyListeners();
  }

  void toggleFavorite(int kulinerId) {
    if (kulinerId <= 0) {
      print('Warning: Attempting to toggle favorite for invalid kuliner ID: $kulinerId');
      return;
    }
    
    if (_favoriteIds.contains(kulinerId)) {
      _favoriteIds.remove(kulinerId);
      print('Removed kuliner ID $kulinerId from favorites');
    } else {
      _favoriteIds.add(kulinerId);
      print('Added kuliner ID $kulinerId to favorites');
    }
    prefs.setStringList(_key, _favoriteIds.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isFavorite(int kulinerId) {
    if (kulinerId <= 0) {
      print('Checking favorite for invalid ID: $kulinerId - returning false');
      return false;
    }
    final result = _favoriteIds.contains(kulinerId);
    print('Checking favorite for ID: $kulinerId - result: $result');
    return result;
  }
}
