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

class OfferViewModel extends ChangeNotifier {
  List<OfferProperty> _offersWithProperties = [];
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

  List<OfferProperty> get offersWithProperties => _offersWithProperties;
  bool get isLoading => _isLoading;

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
            await _propertiesRef.doc('X8qn8e6UXKberOSYZnXk').get();
        Map<String, Property> propertyMap =
            _mapSnapshotToProperties(propertyDoc);

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
                // Update property photos with local paths
                for (int i = 0; i < property.photos.length; i++) {
                  property.photos[i] =
                      await _getLocalPathForImage(property.photos[i]);
                }

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

  Future<String> _getLocalPathForImage(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
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

  /// Map Firestore snapshot to Property model considering nested structure
  Map<String, Property> _mapSnapshotToProperties(DocumentSnapshot snapshot) {
    Map<String, Property> propertyMap = {};

    if (snapshot.exists && snapshot.data() != null) {
      var propertiesData = snapshot.data() as Map<String, dynamic>;
      log.info('Mapping properties from data: $propertiesData');

      propertiesData.forEach((key, propertyData) {
        try {
          int propertyId = int.tryParse(key) ?? 0;

          double minutesFromCampus;
          if (propertyData['minutes_from_campus'] is int) {
            minutesFromCampus =
                (propertyData['minutes_from_campus'] as int).toDouble();
          } else if (propertyData['minutes_from_campus'] is double) {
            minutesFromCampus = propertyData['minutes_from_campus'];
          } else {
            minutesFromCampus = 0;
          }

          String description =
              propertyData['description'] ?? "No description provided";
          List<String> photos = List<String>.from(propertyData['photos'] ?? []);

          GeoPoint geoPoint = propertyData['location'] is GeoPoint
              ? propertyData['location'] as GeoPoint
              : const GeoPoint(0, 0);

          Property property = Property(
            id: propertyId,
            address: propertyData['address'] ?? 'No address provided',
            complex_name: propertyData['complex_name'] ?? 'Unnamed complex',
            description: description,
            location: geoPoint,
            photos: photos,
            minutesFromCampus: minutesFromCampus,
            title: propertyData['title'] ?? 'Untitled Property',
          );

          propertyMap[propertyId.toString()] = property;
        } catch (e) {
          log.warning("Error mapping property with key $key: $e");
        }
      });
    } else {
      log.warning("Property document does not exist or is empty");
    }

    return propertyMap;
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
