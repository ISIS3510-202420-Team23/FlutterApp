import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/user_property.dart';

class UserPropertyViewModel extends ChangeNotifier {
  final List<UserProperty> _userProperties = [];

  static final log = Logger('UserPropertyViewModel');

  // Reference to Firestore 'user_saved' collection
  final CollectionReference _userPropertiesRef =
      FirebaseFirestore.instance.collection('user_saved');

  /// Getter for user properties
  List<UserProperty> get userProperties => _userProperties;

  /// Fetch all properties saved by a specific user by user email
  Future<void> fetchAllByUserEmail(String userEmail) async {
    try {
      // Fetch the document with the given user email
      DocumentSnapshot docSnapshot =
          await _userPropertiesRef.doc(userEmail).get();
      _userProperties.clear(); // Clear the existing list

      if (docSnapshot.exists) {
        // The data is a map where keys are property IDs and values are datetimes
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          data.forEach((propertyId, dateTimeValue) {
            DateTime savedDate;

            // Convert Firestore Timestamp or String to DateTime
            if (dateTimeValue is Timestamp) {
              savedDate = dateTimeValue.toDate();
            } else if (dateTimeValue is String) {
              savedDate = DateTime.parse(dateTimeValue);
            } else {
              savedDate = DateTime.now(); // Default value if parsing fails
            }

            // Create a UserProperty instance and add it to the list
            UserProperty userProperty = UserProperty(
              id: userEmail,
              property_id: propertyId as int,
              date: savedDate,
            );
            _userProperties.add(userProperty);
          });
        }
      } else {
        // Document does not exist
        log.warning('No user found with email: $userEmail');
      }

      notifyListeners(); // Notify UI listeners
    } catch (e, stackTrace) {
      log.severe(
          'Failed to fetch properties for user $userEmail: $e', e, stackTrace);
    }
  }

  /// Add a property to the list of properties saved by a user
  Future<void> addUserProperty(String userEmail, int propertyId) async {
    try {
      // Convert property ID to string if necessary
      String propertyIdStr = propertyId.toString();

      // Reference to the specific user document
      DocumentReference userDocRef = _userPropertiesRef.doc(userEmail);

      // Get the current datetime
      DateTime now = DateTime.now();

      // Update the document by setting the property ID as key and datetime as value
      await userDocRef.set(
        {propertyIdStr: Timestamp.fromDate(now)},
        SetOptions(merge: true),
      );

      log.info('Property $propertyId added to user $userEmail successfully.');
    } catch (e, stackTrace) {
      log.severe('Failed to add property $propertyId to user $userEmail: $e', e,
          stackTrace);
    }
  }
}
