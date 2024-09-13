import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user_action.dart';

class UserActionsViewModel extends ChangeNotifier {
  /// List of user actions, can be fetched from a data source (e.g., API, Firebase, etc.)
  final List<UserAction> _userActions = [];
  bool _isLoading = false;

  static final log = Logger('UserActionsViewModel');

  /// Getter for user actions
  List<UserAction> get userActions => _userActions;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch user actions from a data source
  Future<void> fetchUserActions() async {
    _setLoading(true);

    try {
      // TODO: Add fetching logic here, possibly from an API or database

      // Notify listeners that data has changed
      notifyListeners();
    } catch (e) {
      // Handle error if something goes wrong
      log.shout('Error fetching user actions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user action
  void addUserAction(UserAction userAction) {
    _userActions.add(userAction);
    notifyListeners();
  }

  /// Method to remove a user action
  void removeUserAction(int index) {
    _userActions.removeAt(index);
    notifyListeners();
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
