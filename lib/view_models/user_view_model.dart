import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import '../models/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  static final log = Logger('UserViewModel');

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _userViewsRef =
      FirebaseFirestore.instance.collection('user_views');

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  /// Fetch users from Firestore or load from cache if offline
  Future<void> fetchUsers() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _usersRef.get();
      _users = _mapSnapshotToUsers(snapshot);

      // Store the users in Hive for offline access
      final box = Hive.box<User>('user_cache');
      await box.clear();
      await box.addAll(_users);

      notifyListeners();
    } catch (e, stacktrace) {
      log.shout(
          'Error fetching users from Firestore: $e\nStacktrace: $stacktrace');
      _loadUsersFromCache();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch a specific user by ID, using cache if offline
  Future<User?> fetchUserById(String userId) async {
    final box = Hive.box<User>('user_cache');

    // Check if there's a cached user before attempting to fetch from Firestore
    final cachedUser = box.get(userId);
    if (cachedUser != null) {
      // Return cached user if available
      return cachedUser;
    }

    try {
      // Proceed to fetch from Firestore if connected and no cached data
      String encodedUserId = _encodeEmail(userId);
      DocumentSnapshot usersDoc = await _usersRef.doc('eBbttobInFQe6i9wLHSF').get();

      if (usersDoc.exists && usersDoc.data() != null) {
        var userData = usersDoc[encodedUserId] as Map<String, dynamic>? ?? {};

        User user = User(
          email: userData['email'] as String? ?? 'Unknown Email',
          name: userData['name'] as String? ?? 'Unknown Agent',
          phone: (userData['phone'] is int ? userData['phone'] : int.tryParse(userData['phone']?.toString() ?? '0')) ?? 0,
          photo: userData['photo'] as String? ?? '',
          is_andes: userData['is_andes'] as bool? ?? false,
          type_user: userData['type_user'] as String? ?? 'Unknown Type',
          favorite_offers: (userData['favorite_offers'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
        );

        // Cache the fetched user data for future offline use
        await box.put(userId, user);
        return user;
      } else {
        throw Exception('User not found for id: $userId');
      }
    } catch (e) {
      log.shout('Error fetching user by id: $e');
      // Return the cached user as a fallback if Firestore fetch fails
      return cachedUser ??
          User(
            email: 'Unknown',
            name: 'Unknown Agent',
            phone: 0,
            photo: '',
            is_andes: false,
            type_user: 'Unknown Type',
            favorite_offers: [],
          );
    }
  }


  /// Method to create user_views document if it doesn't exist
  Future<void> createUserViewsDocumentIfNotExists(String userEmail) async {
    try {
      DocumentSnapshot userDoc = await _userViewsRef.doc(userEmail).get();
      if (!userDoc.exists) {
        await _userViewsRef.doc(userEmail).set({
          'roommates_views': 0,
          'no_roommates_views': 0,
        });
        log.info('Created user_views document for $userEmail');
      } else {
        log.info('user_views document already exists for $userEmail');
      }
    } catch (e) {
      log.severe('Error creating user_views document: $e');
    }
  }

  /// Add a new user and update Firestore and cache
  Future<void> addUser(User user) async {
    try {
      final usersDocRef = _usersRef.doc('eBbttobInFQe6i9wLHSF');
      final String emailKey = _encodeEmail(user.email);

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

      final doc = await usersDocRef.get();
      if (doc.exists) {
        await usersDocRef.update(userData);
      } else {
        await usersDocRef.set(userData);
      }

      // Update the cached users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error adding user: $e');
    }
  }

  /// Remove a user and update Firestore and cache
  Future<void> removeUser(String email) async {
    try {
      final usersDocRef = _usersRef.doc('eBbttobInFQe6i9wLHSF');
      final String emailKey = _encodeEmail(email);

      await usersDocRef.update({
        emailKey: FieldValue.delete(),
      });

      // Update the cached users list
      await fetchUsers();
    } catch (e) {
      log.shout('Error removing user: $e');
    }
  }

  /// Load users from cache when offline or in case of error
  Future<void> _loadUsersFromCache() async {
    final box = Hive.box<User>('user_cache');
    await box.clear();
    if (box.isNotEmpty) {
      _users = box.values.toList();
      log.info('Loaded ${_users.length} users from cache');
    } else {
      log.warning('No cached users available');
      _users = [];
    }
    notifyListeners();
  }

  /// Helper method to map Firestore snapshot to a list of User models
  List<User> _mapSnapshotToUsers(QuerySnapshot snapshot) {
    return snapshot.docs.expand((doc) {
      final userData = doc.data() as Map<String, dynamic>;
      return userData.entries.map((entry) {
        final email = _decodeEmail(entry.key);
        final details = entry.value as Map<String, dynamic>;

        return User(
          email: email,
          name: details['name'] ?? '',
          phone: int.tryParse(details['phone'].toString()) ?? 0,
          photo: details['photo'] ?? '',
          is_andes: details['is_andes'] ?? false,
          type_user: details['type_user'] ?? '',
          favorite_offers: List<int>.from(details['favorite_offers'] ?? []),
        );
      });
    }).toList();
  }

  /// Encode email by replacing dots with underscores
  String _encodeEmail(String email) {
    return email.replaceAll('.', '_');
  }

  /// Decode email by reversing the encoding
  String _decodeEmail(String encodedEmail) {
    return encodedEmail.replaceAll('_', '.');
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
