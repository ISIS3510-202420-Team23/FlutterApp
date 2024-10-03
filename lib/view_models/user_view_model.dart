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

  /// Method to fetch users from Firestore and decode emails
  Future<void> fetchUsers() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _usersRef.get();
      _users = snapshot.docs.expand((doc) {
        final userData = doc.data() as Map<String, dynamic>;

        return userData.entries.map((entry) {
          // Decode email back to its original form
          final email = _decodeEmail(entry.key);
          final details = entry.value as Map<String, dynamic>;

          return User(
            email: email,
            name: details['name'] ?? '',
            phone: details['phone'] ?? 0,
            photo: details['photo'] ?? '',
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

  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    try {
      // Encode userId (replace dots with underscores)
      String encodedUserId = userId.replaceAll('.', '_');
      DocumentSnapshot usersDoc = await _usersRef.doc('eBbttobInFQe6i9wLHSF').get(); // Fixed document ID

      if (usersDoc.exists) {
        var userData = usersDoc[encodedUserId] as Map<String, dynamic>;
        return userData;
      } else {
        throw Exception('User not found for id: $userId');
      }
    } catch (e) {
      log.shout('Error fetching user by id: $e');
      rethrow;
    }
  }

  // Method to create user_views document if it doesn't exist
  Future<void> createUserViewsDocumentIfNotExists(String userEmail) async {
    final CollectionReference userViewsRef = FirebaseFirestore.instance.collection('user_views');

    DocumentSnapshot userDoc = await userViewsRef.doc(userEmail).get();
    if (!userDoc.exists) {
      // Create a new document with 0 values for views
      await userViewsRef.doc(userEmail).set({
        'roommates_views': 0,
        'no_roommates_views': 0,
      });
    }
  }

  /// Method to add a new user as a subfield inside a single Firestore document
  Future<void> addUser(User user) async {
    try {
      // Reference to the specific document where users will be stored as subfields
      final usersDocRef = _usersRef.doc('eBbttobInFQe6i9wLHSF'); // Fixed document ID

      // Encode email to avoid dots causing nesting
      final String emailKey = _encodeEmail(user.email);

      // Prepare the user data to be nested under the encoded email
      final userData = {
        emailKey: {
          'email': user.email,
          'name': user.name,
          'phone': user.phone,
          'photo': user.photo,
          'is_andes': user.is_andes,
          'type_user': user.type_user,
          'favorite_offers': user.favorite_offers,
        }
      };

      // Check if the document exists and update or set accordingly
      final doc = await usersDocRef.get();
      if (doc.exists) {
        // If document exists, update the subfield (user data inside the document)
        await usersDocRef.update(userData);
      } else {
        // If the document does not exist, create it with the user data
        await usersDocRef.set(userData);
      }

      // Fetch the updated users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error adding user: $e');
    }
  }

  /// Method to remove a user from Firestore by email
  Future<void> removeUser(String email) async {
    try {
      final usersDocRef = _usersRef.doc('eBbttobInFQe6i9wLHSF');
      final String emailKey = _encodeEmail(email);

      // To remove the specific user entry within the document
      await usersDocRef.update({
        emailKey: FieldValue.delete(),
      });

      // Fetch the updated users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error removing user: $e');
    }
  }


  /// Method to encode email by replacing dots to prevent Firestore nesting
  String _encodeEmail(String email) {
    return email.replaceAll('.', '_');
  }

  /// Method to decode email by reversing the encoding
  String _decodeEmail(String encodedEmail) {
    return encodedEmail.replaceAll('_', '.');
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
