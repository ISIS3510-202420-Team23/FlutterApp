import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  /// List of users, can be fetched from a data source (e.g., API, Firebase, etc.)
  final List<User> _users = [];
  bool _isLoading = false;

  static final log = Logger('UserViewModel');

  /// Getter for users
  List<User> get users => _users;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch users from a data source
  Future<void> fetchUsers() async {
    _setLoading(true);

    try {
      // TODO: Add fetching logic here, possibly from an API or database

      // Notify listeners that data has changed
      notifyListeners();
    } catch (e) {
      // Handle error if something goes wrong
      log.shout('Error fetching users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  /// Method to remove a user
  void removeUser(int index) {
    _users.removeAt(index);
    notifyListeners();
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
