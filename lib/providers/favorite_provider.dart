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
    _favoriteIds =
        ids.map((e) => int.tryParse(e) ?? 0).where((e) => e != 0).toList();
    notifyListeners();
  }

  void toggleFavorite(int kulinerId) {
    if (_favoriteIds.contains(kulinerId)) {
      _favoriteIds.remove(kulinerId);
    } else {
      _favoriteIds.add(kulinerId);
    }
    prefs.setStringList(_key, _favoriteIds.map((e) => e.toString()).toList());
    notifyListeners();
  }

  bool isFavorite(int kulinerId) {
    return _favoriteIds.contains(kulinerId);
  }
}
