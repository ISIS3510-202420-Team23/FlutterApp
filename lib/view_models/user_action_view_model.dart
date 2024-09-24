import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user_action.dart';

class UserActionsViewModel extends ChangeNotifier {
  /// List of user actions
  List<UserAction> _userActions = [];
  bool _isLoading = false;

  static final log = Logger('UserActionsViewModel');

  // Reference to Firestore 'user_actions' collection
  final CollectionReference _userActionsRef =
      FirebaseFirestore.instance.collection('user_actions');

  /// Getter for user actions
  List<UserAction> get userActions => _userActions;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch user actions from Firestore for a specific user
  Future<void> fetchUserActions(String userId) async {
    _setLoading(true);

    try {
      // Fetch user-specific actions from Firestore
      QuerySnapshot snapshot =
          await _userActionsRef.doc(userId).collection('actions').get();

      _userActions = snapshot.docs.map((doc) {
        final actionData = doc.data() as Map<String, dynamic>;

        return UserAction(
          action: actionData['action'] ?? '',
          property_id: actionData['property_related'] ?? 0,
          timestamp: actionData['time']
              as Timestamp, // Convert Firestore timestamp to DateTime
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      log.shout('Error fetching user actions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user action to Firestore for a specific user
  Future<void> addUserAction(String userId, UserAction userAction) async {
    try {
      // Add the action under the specific user's collection
      await _userActionsRef.doc(userId).collection('actions').add({
        'action': userAction.action,
        'property_related': userAction.property_id,
        'time': DateTime.timestamp(), // Convert DateTime to Firestore timestamp
      });

      // Fetch the updated user actions list
      await fetchUserActions(userId);
    } catch (e) {
      log.shout('Error adding user action: $e');
    }
  }

  /// Method to remove a user action from Firestore for a specific user by action ID
  Future<void> removeUserAction(String userId, String actionId) async {
    try {
      await _userActionsRef
          .doc(userId)
          .collection('actions')
          .doc(actionId)
          .delete();

      // Fetch the updated user actions list
      await fetchUserActions(userId);
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
