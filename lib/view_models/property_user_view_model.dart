import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../models/entities/property_user.dart';

class PropertyUserViewModel extends ChangeNotifier {
  // List of property_user relationships
  final List<PropertyUser> _propertyUsers = [];

  static final log = Logger('PropertyUserViewModel');

  // Reference to Firestore 'property_saved_by' collection
  final CollectionReference _propertyUsersRef =
      FirebaseFirestore.instance.collection('property_saved_by');

  /// Getter for property users
  List<PropertyUser> get propertyUsers => _propertyUsers;

  /// Fetch all users who have saved a specific property by property ID
  Future<void> fetchAllByPropertyId(String propertyId) async {
    try {
      // Fetch the document with the given property ID
      DocumentSnapshot docSnapshot =
          await _propertyUsersRef.doc(propertyId).get();
      _propertyUsers.clear(); // Clear the existing list

      if (docSnapshot.exists) {
        // The data is a map where keys are user emails and values are datetimes
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          data.forEach((userEmail, dateTimeValue) {
            DateTime savedDate;

            // Convert Firestore Timestamp or String to DateTime
            if (dateTimeValue is Timestamp) {
              savedDate = dateTimeValue.toDate();
            } else if (dateTimeValue is String) {
              savedDate = DateTime.parse(dateTimeValue);
            } else {
              savedDate = DateTime.now(); // Default value if parsing fails
            }

            // Create a PropertyUser instance and add it to the list
            PropertyUser propertyUser = PropertyUser(
              id: propertyId as int,
              user_email: userEmail,
              date: savedDate,
            );
            _propertyUsers.add(propertyUser);
          });
        }
      } else {
        // Document does not exist
        log.warning('No property found with ID: $propertyId');
      }

      notifyListeners(); // Notify UI listeners
    } catch (e, stackTrace) {
      log.severe(
          'Failed to fetch property users for property ID $propertyId: $e',
          e,
          stackTrace);
    }
  }

  /// Add a user to the list of users who have saved a property
  Future<void> addPropertyUser(int id, String userEmail) async {
    try {
      // Convert property ID to string if necessary
      String propertyId = id.toString();

      // Reference to the specific property document
      DocumentReference propertyDocRef = _propertyUsersRef.doc(propertyId);

      // Get the current datetime
      DateTime now = DateTime.now();

      // Update the document by setting the user email as key and datetime as value
      await propertyDocRef.set(
        {userEmail: Timestamp.fromDate(now)},
        SetOptions(merge: true),
      );

      log.info('User $userEmail added to property $propertyId successfully.');
    } catch (e, stackTrace) {
      log.severe(
          'Failed to add user $userEmail to property $id: $e', e, stackTrace);
    }
  }
}
