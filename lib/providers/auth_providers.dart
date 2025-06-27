import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._prefs) {
    _loadUserFromPrefs();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  void _loadUserFromPrefs() async {
    final userId = _prefs.getInt('user_id');
    final email = _prefs.getString('email');
    if (userId != null && email != null) {
      // Ambil user lengkap dari database
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        _currentUser = user;
      } else {
        _currentUser = null;
      }
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  // CREATE - Register new user
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await DatabaseHelper.instance.getUserByEmail(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      // Create new user
      final newUser = User(
        username: username,
        email: email,
        password: password, // In real app, hash this password
        createdAt: DateTime.now(),
      );

      final userId = await DatabaseHelper.instance.insertUser(newUser);
      if (userId > 0) {
        _currentUser = newUser.copyWith(id: userId);
        await _saveUserToPrefs(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error registering user: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // READ - Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user != null && user.password == password) {
        // In real app, verify hashed password
        _currentUser = user;
        await _saveUserToPrefs(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error logging in: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // READ - Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      return await DatabaseHelper.instance.getUserById(id);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // UPDATE - Update user profile
  Future<bool> updateUser(User user) async {
    try {
      final result = await DatabaseHelper.instance.updateUser(user);
      if (result > 0) {
        // Update current user if it's the same user
        if (_currentUser?.id == user.id) {
          _currentUser = user;
          await _saveUserToPrefs(user);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error updating user: $e');
    }
    return false;
  }

  // DELETE - Delete user account
  Future<bool> deleteUser(int id) async {
    try {
      final result = await DatabaseHelper.instance.deleteUser(id);
      if (result > 0) {
        // Logout if current user is deleted
        if (_currentUser?.id == id) {
          await logout();
        }
        return true;
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
    return false;
  }

  // READ - Get all users (for admin)
  Future<List<User>> getAllUsers() async {
    try {
      return await DatabaseHelper.instance.getAllUsers();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove('user_id');
    await _prefs.remove('username');
    await _prefs.remove('email');
    notifyListeners();
  }

  Future<void> _saveUserToPrefs(User user) async {
    await _prefs.setInt('user_id', user.id!);
    await _prefs.setString('username', user.username);
    await _prefs.setString('email', user.email);
  }

  // Utility methods
  bool isCurrentUser(int userId) {
    return _currentUser?.id == userId;
  }

  bool isAdmin() {
    return _currentUser?.email == 'candra@balikuliner.com';
  }

  // Update current user's profile
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? avatar,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(
      username: username,
      email: email,
      avatar: avatar,
    );

    return await updateUser(updatedUser);
  }

  // Change password
  Future<bool> changePassword(String newPassword) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.copyWith(password: newPassword);
    return await updateUser(updatedUser);
  }
}

extension UserCopyWith on User {
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
