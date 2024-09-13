import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  /// List of users
  List<User> _users = [];
  bool _isLoading = false;

  static final log = Logger('UserViewModel');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  /// Getter for users
  List<User> get users => _users;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch users from Firebase Realtime Database
  Future<void> fetchUsers() async {
    _setLoading(true);

    try {
      final DataSnapshot snapshot = await _usersRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _users = data.entries.map((entry) {
          final userData = entry.value as Map<dynamic, dynamic>;

          return User(
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? 0,
            is_andes: userData['is_andes'] ?? false,
            type_user: userData['type_user'] ?? '',
            favorite_offers: List<int>.from(userData['favorite_offers'] ?? []),
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      log.shout('Error fetching users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user to Firebase
  Future<void> addUser(User user) async {
    try {
      final newUserRef = _usersRef.push();
      await newUserRef.set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'is_andes': user.is_andes,
        'type_user': user.type_user,
        'favorite_offers': user.favorite_offers,
      });

      // Fetch the updated users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error adding user: $e');
    }
  }

  /// Method to remove a user from Firebase by key
  Future<void> removeUser(String userKey) async {
    try {
      await _usersRef.child(userKey).remove();

      // Fetch the updated users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error removing user: $e');
    }
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
