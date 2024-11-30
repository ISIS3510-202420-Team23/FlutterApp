import 'dart:io';
import 'package:andlet/models/entities/offer_property.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import '../connectivity/connectivity_service.dart';
import '../models/entities/offer.dart';
import '../models/entities/property.dart';
import '../models/entities/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';

class OfferViewModel extends ChangeNotifier {
  List<OfferProperty> _offersWithProperties = [];
  List<OfferProperty> _savedOfferProperties = [];
  bool _isLoading = false;
  bool? userRoommatePreference;

  static final log = Logger('OfferViewModel');

  final CollectionReference _offersRef =
      FirebaseFirestore.instance.collection('offers');
  final CollectionReference _propertiesRef =
      FirebaseFirestore.instance.collection('properties');
  final CollectionReference _userViewsRef =
      FirebaseFirestore.instance.collection('user_views');
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users'); // For agents
  final ConnectivityService _connectivityService = ConnectivityService();
  final CollectionReference _userSavedRef =
      FirebaseFirestore.instance.collection('user_saved');
  final CollectionReference _propertySavedByRef =
      FirebaseFirestore.instance.collection('property_saved_by');
  final _savedPropertiesBox = Hive.box<OfferProperty>('saved_properties');

  List<OfferProperty> get offersWithProperties => _offersWithProperties;
  List<OfferProperty> get savedOfferProperties => _savedOfferProperties;

  bool get isLoading => _isLoading;

  /// Save an offer for a user
  Future<void> saveOffer(String userEmail, int offerId) async {
    try {
      DateTime now = DateTime.now();

      // Save in `user_saved` collection
      await _userSavedRef.doc(userEmail).set(
        {offerId.toString(): Timestamp.fromDate(now)},
        SetOptions(merge: true), // Merge to preserve existing data
      );

      // Save in `property_saved_by` collection
      await _propertySavedByRef.doc(offerId.toString()).set(
        {userEmail: Timestamp.fromDate(now)},
        SetOptions(merge: true),
      );

      log.info('Offer $offerId saved for user $userEmail successfully.');
    } catch (e, stackTrace) {
      log.severe('Failed to save offer $offerId for user $userEmail: $e', e,
          stackTrace);
      throw e; // Propagate the error
    }
  }

  /// Unsave an offer for a user
  Future<void> unsaveOffer(String userEmail, int offerId) async {
    try {
      // Remove from user_saved collection
      await FirebaseFirestore.instance
          .collection('user_saved')
          .doc(userEmail)
          .update({
        offerId.toString(): FieldValue.delete(),
      });

      // Remove from property_saved_by collection
      await FirebaseFirestore.instance
          .collection('property_saved_by')
          .doc(offerId.toString())
          .update({
        userEmail: FieldValue.delete(),
      });

      // Optionally: Update local state if necessary
      _savedOfferProperties.removeWhere(
          (offerProperty) => offerProperty.offer.offerId == offerId);

      notifyListeners();

      print('Offer $offerId unsaved successfully for user $userEmail');
    } catch (e) {
      print('Failed to unsave offer: $e');
      throw Exception('Failed to unsave offer');
    }
  }

  Future<void> fetchSavedPropertiesForUser(String userEmail) async {
    try {
      _setLoading(true);

      bool isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        // Fetch saved property IDs from Firestore
        DocumentSnapshot userDoc = await _userSavedRef.doc(userEmail).get();

        if (userDoc.exists) {
          final Map<String, dynamic> savedData =
          userDoc.data() as Map<String, dynamic>;
          List<int> savedOfferIds =
          savedData.keys.map((id) => int.parse(id)).toList();

          // Fetch all offers and properties
          await fetchOffersWithFilters();

          // Filter saved properties
          _savedOfferProperties = _offersWithProperties
              .where((offerProperty) =>
              savedOfferIds.contains(offerProperty.offer.offerId))
              .toList();

          // Cache saved properties locally
          await _cacheSavedProperties();
        } else {
          log.warning('No saved properties found for user $userEmail');
          _savedOfferProperties = [];
        }
      } else {
        log.info('Loading saved properties from local cache');
        await _loadSavedPropertiesFromCache();
      }
    } catch (e) {
      log.severe('Error fetching saved properties for user $userEmail: $e');
      await _loadSavedPropertiesFromCache();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _cacheSavedProperties() async {
    await _savedPropertiesBox.clear(); // Clear previous cache
    await _savedPropertiesBox.addAll(_savedOfferProperties);
    log.info('Cached ${_savedOfferProperties.length} saved properties locally.');
  }

  /// Load saved properties from local cache
  Future<void> _loadSavedPropertiesFromCache() async {
    if (_savedPropertiesBox.isNotEmpty) {
      _savedOfferProperties = _savedPropertiesBox.values.toList();
      log.info('Loaded ${_savedOfferProperties.length} saved properties from cache.');
    } else {
      log.warning('No cached saved properties available.');
      _savedOfferProperties = [];
    }
  }

  List<OfferProperty> getFilteredSavedProperties({
    double? minPrice,
    double? maxPrice,
    double? maxMinutes,
    DateTimeRange? dateRange,
  }) {
    return _savedOfferProperties.where((offerProperty) {
      return _applyFilters(
        offerProperty.offer,
        offerProperty.property,
        minPrice,
        maxPrice,
        maxMinutes,
        dateRange,
      );
    }).toList();
  }

  /// Fetch user's roommate preferences
  Future<bool?> fetchUserRoommatePreferences(String userEmail) async {
    try {
      DocumentSnapshot userViewsDoc = await _userViewsRef.doc(userEmail).get();

      if (userViewsDoc.exists) {
        int roommateViews = userViewsDoc['roommates_views'] ?? 0;
        int noRoommateViews = userViewsDoc['no_roommates_views'] ?? 0;
        return roommateViews > noRoommateViews;
      } else {
        log.info('User preference not found for $userEmail');
        return null;
      }
    } catch (e) {
      log.shout('Error fetching user preferences: $e');
      return null;
    }
  }

  Future<void> incrementUserViewCounter(
      String userEmail, bool hasRoommates) async {
    try {
      DocumentReference docRef = _userViewsRef.doc(userEmail);

      if (hasRoommates) {
        await docRef.update({'roommates_views': FieldValue.increment(1)});
      } else {
        await docRef.update({'no_roommates_views': FieldValue.increment(1)});
      }
    } catch (e) {
      log.shout('Error incrementing view counter: $e');
    }
  }

  /// Increment the view counter for a specific offer within a single document
  Future<void> incrementOfferViewCounter(int offerId) async {
    final offerRef =
        _offersRef.doc('E2amoJzmIbhtLq65ScpY'); // Reference the single document

    try {
      DocumentSnapshot offerDoc = await offerRef.get();

      if (offerDoc.exists) {
        Map<String, dynamic> offersData =
            offerDoc.data() as Map<String, dynamic>;

        if (offersData.containsKey(offerId.toString())) {
          Map<String, dynamic> offerData = offersData[offerId.toString()];
          int currentViews = offerData['views'] ?? 0;
          offerData['views'] = currentViews + 1;

          await offerRef.update({
            '$offerId': offerData,
          });
        } else {
          log.shout('Offer with ID $offerId not found.');
        }
      }
    } catch (e) {
      log.shout('Error incrementing offer view counter: $e');
    }
  }

  /// Fetch and cache agent data when online
  Future<void> fetchAgentAndCache(String userId) async {
    final box = Hive.box<User>('agent_cache');
    if (!box.containsKey(userId)) {
      // Only fetch if not already in cache
      try {
        DocumentSnapshot agentSnapshot = await _usersRef.doc(userId).get();
        if (agentSnapshot.exists) {
          User agent = User(
            email: agentSnapshot['email'] ?? 'Unknown Email',
            name: agentSnapshot['name'] ?? 'Unknown Agent',
            phone: agentSnapshot['phone'] ?? 0,
            photo: agentSnapshot['photo'] ?? '',
            is_andes: agentSnapshot['is_andes'] ?? false,
            type_user: agentSnapshot['type_user'] ?? '',
            favorite_offers:
                (agentSnapshot['favorite_offers'] as List<dynamic>?)
                        ?.cast<int>() ??
                    [],
          );
          await box.put(userId, agent); // Cache the fetched agent
        }
      } catch (e) {
        log.shout('Error fetching and caching agent data: $e');
      }
    }
  }

  /// Retrieve cached agent data when offline
  Future<User?> getCachedAgent(String userId) async {
    final box = Hive.box<User>('agent_cache');
    return box.get(userId);
  }

  /// Fetch all offers and associated properties, then apply filters
  Future<void> fetchOffersWithFilters({
    double? minPrice,
    double? maxPrice,
    double? maxMinutes,
    DateTimeRange? dateRange,
  }) async {
    _setLoading(true);

    try {
      bool isConnected = await _connectivityService.isConnected();
      if (isConnected) {
        DocumentSnapshot propertyDoc =
            await _propertiesRef.doc('VPIeQgk7wcFsZ3kfjAfo').get();
        Map<String, Property> propertyMap =
            await _mapSnapshotToProperties(propertyDoc);

        DocumentSnapshot offersDoc =
            await _offersRef.doc('E2amoJzmIbhtLq65ScpY').get();
        if (offersDoc.exists && offersDoc.data() != null) {
          var offersData = offersDoc.data() as Map<String, dynamic>;
          List<OfferProperty> tempOffersWithProperties = [];

          for (var entry in offersData.entries) {
            var offerData = entry.value;
            if (offerData['is_active'] == true) {
              String propertyId = offerData['id_property'].toString();
              Property? property = propertyMap[propertyId];

              if (property != null) {
                Offer offer = Offer(
                  final_date: (offerData['final_date'] as Timestamp).toDate(),
                  initial_date:
                      (offerData['initial_date'] as Timestamp).toDate(),
                  user_id: offerData['user_id'],
                  property_id: offerData['id_property'],
                  is_active: offerData['is_active'],
                  num_baths: offerData['num_baths'],
                  num_beds: offerData['num_beds'],
                  num_rooms: offerData['num_rooms'],
                  roommates: offerData['roommates'],
                  only_andes: offerData['only_andes'],
                  price_per_month: offerData['price_per_month'].toDouble(),
                  type: offerData['type'],
                  offerId: int.tryParse(entry.key) ?? 0,
                );

                if (_applyFilters(offer, property, minPrice, maxPrice,
                    maxMinutes, dateRange)) {
                  tempOffersWithProperties
                      .add(OfferProperty(offer: offer, property: property));
                }
              }
            }
          }

          final box = Hive.box<OfferProperty>('offer_properties');
          await box.clear();
          await box.addAll(tempOffersWithProperties);

          _offersWithProperties = tempOffersWithProperties;
          notifyListeners();
        }
      } else {
        await loadFromCache();
        applyFiltersOnCachedData(
            minPrice: minPrice,
            maxPrice: maxPrice,
            maxMinutes: maxMinutes,
            dateRange: dateRange);
      }
    } catch (e, stacktrace) {
      log.shout('Error fetching offers: $e\nStacktrace: $stacktrace');
      await loadFromCache();
      applyFiltersOnCachedData(
          minPrice: minPrice,
          maxPrice: maxPrice,
          maxMinutes: maxMinutes,
          dateRange: dateRange);
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, Property>> _mapSnapshotToProperties(
      DocumentSnapshot snapshot) async {
    Map<String, Property> propertyMap = {};

    if (snapshot.exists && snapshot.data() != null) {
      var propertiesData = snapshot.data() as Map<String, dynamic>;
      log.info('Mapping properties from data: $propertiesData');

      for (var entry in propertiesData.entries) {
        try {
          final propertyId = entry.key;
          final propertyData = entry.value as Map<String, dynamic>;
          Property? property =
              await _createPropertyWithLocalImages(propertyId, propertyData);
          if (property != null) {
            propertyMap[propertyId] = property;
          }
        } catch (e) {
          log.warning("Error mapping property with key ${entry.key}: $e");
        }
      }
    } else {
      log.warning("Property document does not exist or is empty");
    }

    return propertyMap;
  }

  Future<Property?> _createPropertyWithLocalImages(
      String propertyId, Map<String, dynamic> propertyData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      List<String> photos = List<String>.from(propertyData['photos'] ?? []);

      // Download and cache each image
      for (int i = 0; i < photos.length; i++) {
        String filename = photos[i];
        final filePath = '${directory.path}/$filename';
        final file = File(filePath);

        // Only download if the image does not exist locally
        if (!await file.exists()) {
          try {
            String url = await FirebaseStorage.instance
                .ref('properties/$filename')
                .getDownloadURL();
            await Dio().download(url, filePath);
          } catch (e) {
            log.warning('Failed to download image $filename: $e');
          }
        }
        photos[i] = filePath; // Update with local path
      }

      GeoPoint geoPoint = propertyData['location'] is GeoPoint
          ? propertyData['location'] as GeoPoint
          : const GeoPoint(0, 0);

      return Property(
        id: int.tryParse(propertyId) ?? 0,
        address: propertyData['address'] ?? 'No address provided',
        complex_name: propertyData['complex_name'] ?? 'Unnamed complex',
        description: propertyData['description'] ?? 'No description provided',
        location: geoPoint,
        photos: photos,
        minutesFromCampus:
            (propertyData['minutes_from_campus'] as num?)?.toDouble() ?? 0,
        title: propertyData['title'] ?? 'Untitled Property',
      );
    } catch (e) {
      log.warning('Error creating property with images: $e');
      return null;
    }
  }

  /// Load offers from cache without clearing it
  Future<void> loadFromCache() async {
    final box = Hive.box<OfferProperty>('offer_properties');
    if (box.isNotEmpty) {
      _offersWithProperties = box.values.toList();
      log.info('Loaded ${_offersWithProperties.length} offers from cache');
    } else {
      log.warning('No cached offers available');
      _offersWithProperties = [];
    }
    notifyListeners();
  }

  /// Apply filters on cached data when offline
  Future<void> applyFiltersOnCachedData({
    double? minPrice,
    double? maxPrice,
    double? maxMinutes,
    DateTimeRange? dateRange,
  }) async {
    final box = Hive.box<OfferProperty>('offer_properties');
    _offersWithProperties = box.values
        .where((offerProperty) => _applyFilters(
              offerProperty.offer,
              offerProperty.property,
              minPrice,
              maxPrice,
              maxMinutes,
              dateRange,
            ))
        .toList();

    log.info(
        'Applied filters on cached data, found ${_offersWithProperties.length} matching offers');
    notifyListeners();
  }

  Future<void> cacheOffers() async {
    final box = Hive.box<OfferProperty>('offer_properties');
    await box.clear(); // Clear previous cache
    await box.addAll(
        _offersWithProperties); // Add all offers with properties to cache
    log.info("Offers cached successfully.");
  }

  /// Apply filters on offers and properties
  bool _applyFilters(
    Offer offer,
    Property property,
    double? minPrice,
    double? maxPrice,
    double? maxMinutes,
    DateTimeRange? dateRange,
  ) {
    minPrice ??= 0;

    if (offer.price_per_month < minPrice) return false;
    if (maxPrice != null && offer.price_per_month > maxPrice) return false;

    if (dateRange != null) {
      DateTime initialDate = offer.initial_date;
      DateTime finalDate = offer.final_date;

      if (finalDate.isBefore(dateRange.start) ||
          initialDate.isAfter(dateRange.end)) {
        return false;
      }
    }

    if (maxMinutes != null && property.minutesFromCampus > maxMinutes) {
      return false;
    }

    return true;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
