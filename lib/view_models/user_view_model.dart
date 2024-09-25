import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  /// List of users
  List<User> _users = [];
  bool _isLoading = false;

  static final log = Logger('UserViewModel');

  // Reference to Firestore 'users' collection
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  /// Getter for users
  List<User> get users => _users;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch users from Firestore
  Future<void> fetchUsers() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _usersRef.get();
      _users = snapshot.docs.expand((doc) {
        final userData = doc.data() as Map<String, dynamic>;

        return userData.entries.map((entry) {
          final email = entry.key;
          final details = entry.value as Map<String, dynamic>;

          return User(
            email: email,
            name: details['name'] ?? '',
            phone: details['phone'] ?? 0,
            is_andes: details['is_andes'] ?? false,
            type_user: details['type_user'] ?? '',
            favorite_offers: List<int>.from(details['favorite_offers'] ?? []),
          );
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      log.shout('Error fetching users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user to Firestore
  Future<void> addUser(User user) async {
    try {
      await _usersRef.doc(user.email).set({
        'name': user.name,
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

  /// Method to remove a user from Firestore by email (document ID)
  Future<void> removeUser(String email) async {
    try {
      await _usersRef.doc(email).delete();

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
