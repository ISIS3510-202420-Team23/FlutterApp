import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import '../connectivity/connectivity_service.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  List<Property> _properties = [];
  bool _isLoading = false;

  static final log = Logger('PropertyViewModel');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _propertiesRef = FirebaseFirestore.instance.collection('properties');
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  /// Fetch properties from Firestore or load from cache if offline
  Future<void> fetchProperties() async {
    _setLoading(true);

    try {
      bool isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        log.info('Fetching properties from Firestore...');
        QuerySnapshot snapshot = await _propertiesRef.get();
        _properties = _mapSnapshotToProperties(snapshot);

        // Store properties in Hive for offline access
        final box = Hive.box<Property>('properties');
        await box.clear();
        await box.addAll(_properties);
      } else {
        log.warning('Offline - Loading properties from cache...');
        loadFromCache();
      }
    } catch (e, stacktrace) {
      log.shout('Error fetching properties: $e\nStacktrace: $stacktrace');
      loadFromCache();
    } finally {
      _setLoading(false);
    }
  }

  /// Load properties from cache (Hive) when offline or in case of error
  void loadFromCache() {
    final box = Hive.box<Property>('properties');
    if (box.isNotEmpty) {
      _properties = box.values.toList();
      log.info('Loaded ${_properties.length} properties from cache');
    } else {
      log.warning('No cached properties available');
      _properties = [];
    }
    notifyListeners();
  }

  /// Helper method to fetch image URLs from Firebase Storage for a list of property images
  Future<List<String>> getImageUrls(List<String> imagePaths) async {
    final box = Hive.box<List<String>>('image_cache');
    final cachedUrls = box.get(imagePaths.join(',')); // Key as a joined path string
    bool isConnected = await _connectivityService.isConnected();

    // Use cached URLs if offline
    if (!isConnected && cachedUrls != null) {
      log.info('Loading cached image URLs for paths: $imagePaths');
      return cachedUrls;
    }

    // Fetch URLs from Firebase Storage if online
    List<String> imageUrls = [];
    for (String path in imagePaths) {
      try {
        String downloadUrl = await _storage.ref('properties/$path').getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        log.severe('Error fetching image URL for $path: $e');
      }
    }

    // Cache the fetched URLs for offline usage
    if (imageUrls.isNotEmpty) {
      await box.put(imagePaths.join(','), imageUrls);
      log.info('Caching image URLs for paths: $imagePaths');
    }

    return imageUrls;
  }


  /// Map Firestore snapshot to a list of Property models
  List<Property> _mapSnapshotToProperties(QuerySnapshot snapshot) {
    List<Property> properties = [];

    for (var doc in snapshot.docs) {
      final propertyData = doc.data() as Map<String, dynamic>;
      properties.addAll(propertyData.entries.map((entry) {
        final id = int.tryParse(entry.key) ?? -1;
        final details = entry.value as Map<String, dynamic>;

        GeoPoint location = details['location'] is GeoPoint
            ? details['location'] as GeoPoint
            : const GeoPoint(0, 0);

        return Property(
          id: id,
          address: details['address'] ?? '',
          complex_name: details['complex_name'] ?? '',
          description: details['description'] ?? '',
          location: location,
          photos: List<String>.from(details['photos'] ?? []),
          title: details['title'] ?? '',
          minutesFromCampus: details['minutes_from_campus'] != null
              ? (details['minutes_from_campus'] as num).toDouble()
              : 0.0,
        );
      }));
    }

    return properties;
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
