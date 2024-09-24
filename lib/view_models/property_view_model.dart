import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  /// List of properties
  List<Property> _properties = [];
  bool _isLoading = false;

  static final log = Logger('PropertyViewModel');

  final CollectionReference _propertiesRef =
      FirebaseFirestore.instance.collection('properties');

  /// Getter for properties
  List<Property> get properties => _properties;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch properties from Firestore
  Future<void> fetchProperties() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _propertiesRef.get();

      _properties = snapshot.docs.expand((doc) {
        final propertyData = doc.data() as Map<String, dynamic>;

        // Iterate over each entry in the map where the key is the ID and the value is the property details
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
          );
        });
      }).toList();

      notifyListeners();
    } catch (e, stacktrace) {
      log.shout('Error fetching properties: $e\nStacktrace: $stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new property to Firestore
  Future<void> addProperty(Property property) async {
    try {
      await _propertiesRef.add({
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

  /// Method to remove a property from Firestore by document ID
  Future<void> removeProperty(String documentId) async {
    try {
      await _propertiesRef.doc(documentId).delete();

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
