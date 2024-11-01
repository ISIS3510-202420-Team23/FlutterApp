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

      _userActions = snapshot.docs.expand((doc) {
        final userActionData = doc.data() as Map<String, dynamic>;

        return userActionData.entries.map((entry) {
          // final id = doc.id;
          final details = entry.value as Map<String, dynamic>;

          return UserAction(
            action: details['action'] ?? '',
            property_id: details['property_related'] ?? '',
            timestamp: details['time'] as Timestamp,
          );
        });
      }).toList();

      notifyListeners();
    } catch (e) {
      log.shout('Error fetching user actions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new user action to Firestore for a specific user
  Future<void> addUserAction(String userId, String action) async {
    String initial_num;

    if (action == 'filter') {
      initial_num = '1';
    } else if (action == 'contact') {
      initial_num = '2';
    } else if (action == 'landlordContacted') {
      initial_num = '4';
    } else if (action == 'peak') {
      initial_num = '5';
    } else {
      initial_num = '';
    }

    try {
      // Add the action under the specific user's document in 'user_actions' collection
      await _userActionsRef
          .doc('${initial_num}_${userId}_${DateTime.now().toIso8601String()}')
          .set({
        'action': action,
        'app': 'flutter', // Set the app field as 'swift' based on the image
        'date': Timestamp.now(), // Use Firestore Timestamp for date
        'user_id': userId, // User ID as shown in the image
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
