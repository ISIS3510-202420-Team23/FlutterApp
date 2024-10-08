import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  List<Property> _properties = [];
  bool _isLoading = false;

  static final log = Logger('PropertyViewModel');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final CollectionReference _propertiesRef = FirebaseFirestore.instance.collection('properties');

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  /// Method to fetch properties from Firestore with nested fields
  Future<void> fetchProperties() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _propertiesRef.get();

      _properties = snapshot.docs.expand((doc) {
        final propertyData = doc.data() as Map<String, dynamic>;

        // Now we iterate through the nested fields inside the document
        return propertyData.entries.map((entry) {
          final id = entry.key;
          final details = entry.value as Map<String, dynamic>;

          // Create a Property object using the details map
          return Property(
            id: int.tryParse(id) ?? -1, // Convert the key (ID) to an int
            address: details['address'] ?? '',
            complex_name: details['complex_name'] ?? '',
            description: details['description'] ?? '',
            location: details['location'] ?? const GeoPoint(0, 0),
            photos: List<String>.from(details['photos'] ?? []),
            title: details['title'] ?? '',
            minutesFromCampus: details['minutes_from_campus'] != null
                ? (details['minutes_from_campus'] as num).toDouble()
                : 0.0,
          );
        }).toList();
      }).toList();

      notifyListeners();
    } catch (e, stacktrace) {
      log.shout('Error fetching properties: $e\nStacktrace: $stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to fetch image URLs from Firebase Storage
  Future<List<String>> getImageUrls(List<String> imagePaths) async {
    List<String> imageUrls = [];
    for (String path in imagePaths) {
      try {
        String downloadUrl =
        await _storage.ref('properties/$path').getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        log.shout('Error fetching image URL for $path: $e');
      }
    }
    return imageUrls;
  }
  /// Method to get a property by its ID
  Future<Property?> getPropertyById(int id) async {
    try {
      // Fetch all documents in the collection
      QuerySnapshot snapshot = await _propertiesRef.get();
      // Iterate through each document to find the property with the matching ID
      for (var doc in snapshot.docs) {
        final propertyData = doc.data() as Map<String, dynamic>;

        // Check if the document contains the property with the given ID
        if (propertyData.containsKey(id.toString())) {
          final details = propertyData[id.toString()] as Map<String, dynamic>;

          // Return the property mapped from the details
          return Property(
            id: id, // Use the int ID here
            address: details['address'] ?? '',
            complex_name: details['complex_name'] ?? '',
            description: details['description'] ?? '',
            location: details['location'] ?? const GeoPoint(0, 0),
            photos: List<String>.from(details['photos'] ?? []),
            title: details['title'] ?? '',
            minutesFromCampus: (details['minutes_from_campus'] as num?)?.toDouble() ?? 0.0,
          );
        }
      }

      // If no property with the given ID was found
      log.info('Property with ID $id not found');
    } catch (e, stacktrace) {
      log.shout('Error fetching property by ID $id: $e\nStacktrace: $stacktrace');
    }

    return null;
  }

  /// Method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
