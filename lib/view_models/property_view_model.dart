import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  int _batchSize = 10;
  DocumentSnapshot? _lastDocument;
  Completer<bool>? _permissionCompleter;
  String? _appDocumentsPath; // Store the documents directory path

  final Dio _dio = Dio();
  static final log = Logger('PropertyViewModel');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference _propertiesRef =
      FirebaseFirestore.instance.collection('properties');
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  PropertyViewModel() {
    _initializePermissions();
    _initializeAppDirectory(); // Initialize the app directory path
  }

  Future<void> _initializePermissions() async {
    bool granted = await _requestStoragePermissions();
    if (!granted) {
      log.warning(
          'Storage permission not granted. Some features may not work as expected.');
    }
  }

  Future<bool> _requestStoragePermissions() async {
    if (_permissionCompleter != null) {
      return _permissionCompleter!.future;
    }

    _permissionCompleter = Completer<bool>();
    try {
      if (await Permission.storage.isGranted) {
        _permissionCompleter!.complete(true);
        return true;
      }

      var status = await Permission.storage.request();
      _permissionCompleter!.complete(status.isGranted);
      if (status.isPermanentlyDenied) await openAppSettings();

      return _permissionCompleter!.future;
    } finally {
      _permissionCompleter = null;
    }
  }

  /// Fetch the application directory path
  Future<void> _initializeAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    _appDocumentsPath = directory.path;
  }

  /// Fetch properties in batches with Firestore pagination
  Future<void> fetchPropertiesInBatches() async {
    if (_isLoading || _appDocumentsPath == null)
      return; // Ensure directory path is initialized
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

          _properties.addAll(batchProperties);

          // Download images for the batch in a separate isolate
          await _downloadImagesInIsolate(batchProperties, _appDocumentsPath!);

          _cacheProperties(); // Optionally cache this batch
        }
      } else {
        await loadFromCache();
      }
    } catch (e, stacktrace) {
      log.shout('Error fetching properties: $e\nStacktrace: $stacktrace');
      await loadFromCache();
    } finally {
      _setLoading(false);
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

  /// Download images for a batch of properties using an isolate
  Future<void> _downloadImagesInIsolate(
      List<Property> properties, String appDocumentsPath) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_downloadImagesIsolate,
        [receivePort.sendPort, properties, appDocumentsPath]);
    await for (var message in receivePort) {
      if (message is String && message == 'done') break;
    }
    notifyListeners();
  }

  /// Isolate function for downloading images
  static Future<void> _downloadImagesIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    List<Property> properties = args[1];
    String appDocumentsPath = args[2];

    for (var property in properties) {
      for (int i = 0; i < property.photos.length; i++) {
        String filename = property.photos[i];
        final filePath = '$appDocumentsPath/$filename';
        final file = File(filePath);

        if (await file.exists()) {
          property.photos[i] = filePath;
          continue;
        }

        try {
          String url = await FirebaseStorage.instance
              .ref('properties/$filename')
              .getDownloadURL();
          await Dio().download(url, filePath);
          property.photos[i] = filePath;
        } catch (e) {
          log.shout('Error downloading image: $e');
        }
      }
    }

    sendPort.send('done');
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
    await box.clear();
    await box.addAll(_properties);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
