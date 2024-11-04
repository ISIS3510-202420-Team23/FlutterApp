import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../connectivity/connectivity_service.dart';
import '../models/entities/property.dart';

class PropertyViewModel extends ChangeNotifier {
  List<Property> _properties = [];
  bool _isLoading = false;
  final int _batchSize = 10;
  DocumentSnapshot? _lastDocument;
  String? _appDocumentsPath; // Store the directory path for local storage

  static final log = Logger('PropertyViewModel');
  final CollectionReference _propertiesRef =
  FirebaseFirestore.instance.collection('properties');
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  PropertyViewModel() {
    _initialize(); // Initialize permissions and local path
  }

  Future<void> _initialize() async {
    bool permissionGranted = await _requestStoragePermissions();
    if (permissionGranted) {
      _appDocumentsPath = (await getApplicationDocumentsDirectory()).path;
    } else {
      _appDocumentsPath = (await getApplicationDocumentsDirectory()).path;
      log.warning('Storage permission not granted. Images might not save.');
    }
  }

  Future<bool> _requestStoragePermissions() async {
    PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> fetchPropertiesInBatches() async {
    if (_isLoading || _appDocumentsPath == null) return; // Ensure local path is set
    _setLoading(true);

    try {
      bool isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        Query query = _propertiesRef.limit(_batchSize);
        if (_lastDocument != null) {
          query = query.startAfterDocument(_lastDocument!);
        }

        QuerySnapshot snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          _lastDocument = snapshot.docs.last;
          List<Property> batchProperties = _mapSnapshotToProperties(snapshot);

          // Ensure images are downloaded before adding to properties
          for (var property in batchProperties) {
            await _downloadImages(property);
          }

          _properties.addAll(batchProperties);
          _cacheProperties(); // Cache the properties locally
          notifyListeners();
        }
      } else {
        await loadFromCache();
      }
    } catch (e, stacktrace) {
      log.severe('Error fetching properties: $e\nStacktrace: $stacktrace');
      await loadFromCache(); // Load cached data in case of error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _downloadImages(Property property) async {
    if (_appDocumentsPath == null) return;

    for (int i = 0; i < property.photos.length; i++) {
      String filename = property.photos[i];
      final filePath = '$_appDocumentsPath/$filename';
      final file = File(filePath);

      // Check if file exists before attempting download
      if (await file.exists()) {
        property.photos[i] = filePath; // Update to local path
        continue;
      }

      try {
        // Download from Firebase Storage if not found locally
        String url = await FirebaseStorage.instance
            .ref('properties/$filename')
            .getDownloadURL();
        await Dio().download(url, filePath);
        property.photos[i] = filePath; // Update to local path after download
      } catch (e) {
        log.warning('Failed to download image: $filename - $e');
        property.photos[i] = ''; // Placeholder for missing images
      }
    }
  }

  Future<void> loadFromCache() async {
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

  Future<void> clearLocalImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory(directory.path);
    if (await imageDir.exists()) {
      final images = imageDir.listSync();
      for (var image in images) {
        if (image is File) await image.delete();
      }
    }
  }

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

  Future<void> _cacheProperties() async {
    final box = Hive.box<Property>('properties');
    await box.clear(); // Clear previous cache
    await box.addAll(_properties);
  }

  Future<void> cacheProperties() async {
    final box = Hive.box<Property>('properties');
    await box.clear(); // Clear previous cache
    await box.addAll(_properties); // Add all properties to cache
    log.info("Properties cached successfully.");
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Property? getPropertyById(int id) {
    return _properties.firstWhere((property) => property.id == id);
  }
}
