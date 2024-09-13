import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  /// List of properties
  List<Property> _properties = [];
  bool _isLoading = false;

  static final log = Logger('PropertyViewModel');
  final DatabaseReference _propertiesRef =
      FirebaseDatabase.instance.ref().child('properties');

  /// Getter for properties
  List<Property> get properties => _properties;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch properties from Firebase Realtime Database
  Future<void> fetchProperties() async {
    _setLoading(true);

    try {
      final DataSnapshot snapshot = await _propertiesRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _properties = data.entries.map((entry) {
          final propertyData = entry.value as Map<dynamic, dynamic>;

          return Property(
            id: propertyData['id'] ?? 0,
            address: propertyData['address'] ?? '',
            complex_name: propertyData['complex_name'] ?? '',
            description: propertyData['description'] ?? '',
            location: propertyData['location'] ?? '',
            photos: List<String>.from(propertyData['photos'] ?? []),
            title: propertyData['title'] ?? '',
          );
        }).toList();

        notifyListeners();
      }
    } catch (e) {
      log.shout('Error fetching properties: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new property to Firebase
  Future<void> addProperty(Property property) async {
    try {
      final newPropertyRef = _propertiesRef.push();
      await newPropertyRef.set({
        'id': property.id,
        'address': property.address,
        'complex_name': property.complex_name,
        'description': property.description,
        'location': property.location,
        'photos': property.photos,
        'title': property.title,
      });

      // Fetch the updated properties list
      await fetchProperties();
    } catch (e) {
      log.shout('Error adding property: $e');
    }
  }

  /// Method to remove a property from Firebase by key
  Future<void> removeProperty(String propertyKey) async {
    try {
      await _propertiesRef.child(propertyKey).remove();

      // Fetch the updated properties list
      await fetchProperties();
    } catch (e) {
      log.shout('Error removing property: $e');
    }
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
