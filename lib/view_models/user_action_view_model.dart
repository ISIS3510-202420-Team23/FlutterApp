import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user_action.dart';

class UserActionsViewModel extends ChangeNotifier {
  /// List of user actions
  List<UserAction> _userActions = [];
  bool _isLoading = false;

  static final log = Logger('UserActionsViewModel');
  final DatabaseReference _userActionsRef =
      FirebaseDatabase.instance.ref().child('user_actions');

  /// Getter for user actions
  List<UserAction> get userActions => _userActions;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch user actions from Firebase Realtime Database
  Future<void> fetchUserActions() async {
    _setLoading(true);

    try {
      final DataSnapshot snapshot = await _userActionsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _userActions = data.entries.map((entry) {
          final actionData = entry.value as Map<dynamic, dynamic>;

          return UserAction(
            action: actionData['action'] ?? '',
            user_id: actionData['user_id'] ?? '',
            property_id: actionData['property_id'] ?? 0,
            timestamp: DateTime.parse(actionData['timestamp']),
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      log.shout('Error fetching user actions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user action to Firebase
  Future<void> addUserAction(UserAction userAction) async {
    try {
      final newActionRef = _userActionsRef.push();
      await newActionRef.set({
        'action': userAction.action,
        'user_id': userAction.user_id,
        'property_id': userAction.property_id,
        'timestamp': userAction.timestamp.toIso8601String(),
      });

      // Fetch the updated user actions list
      await fetchUserActions();
    } catch (e) {
      log.shout('Error adding user action: $e');
    }
  }

  /// Method to remove a user action from Firebase by key
  Future<void> removeUserAction(String actionKey) async {
    try {
      await _userActionsRef.child(actionKey).remove();

      // Fetch the updated user actions list
      await fetchUserActions();
    } catch (e) {
      log.shout('Error removing user action: $e');
    }
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
