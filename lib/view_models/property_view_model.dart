import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  /// List of properties, this can be fetched from a data source (e.g., API, Firebase, etc.)
  final List<Property> _properties = [];
  bool _isLoading = false;

  static final log = Logger('PropertyViewModel');

  /// Getter for properties
  List<Property> get properties => _properties;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch properties from a data source
  Future<void> fetchProperties() async {
    _setLoading(true);

    try {
      // TODO: Fetching logic here, possibly from an API or database

      // Notify listeners that data has changed
      notifyListeners();
    } catch (e) {
      // Handle error if something goes wrong
      log.shout('Error fetching properties: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new property
  void addProperty(Property property) {
    _properties.add(property);
    notifyListeners();
  }

  /// Method to remove a property
  void removeProperty(int index) {
    _properties.removeAt(index);
    notifyListeners();
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
