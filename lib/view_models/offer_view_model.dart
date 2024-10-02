import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/offer.dart';
import '../models/entities/property.dart';

class OfferViewModel extends ChangeNotifier {
  List<OfferWithProperty> _offersWithProperties = [];
  bool _isLoading = false;
  bool? userRoommatePreference;

  static final log = Logger('OfferViewModel');

  final CollectionReference _offersRef =
      FirebaseFirestore.instance.collection('offers');
  final CollectionReference _propertiesRef =
      FirebaseFirestore.instance.collection('properties');
  final CollectionReference _userViewsRef =
      FirebaseFirestore.instance.collection('user_views');

  List<OfferWithProperty> get offersWithProperties => _offersWithProperties;
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
    final userViewsRef = FirebaseFirestore.instance.collection('user_views');

    try {
      DocumentReference docRef = userViewsRef.doc(userEmail);

      // Update the respective counter based on whether the property has roommates
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
    final offerRef = FirebaseFirestore.instance
        .collection('offers')
        .doc('E2amoJzmIbhtLq65ScpY'); // Reference the single document

    try {
      // Get the current offer data from the document
      DocumentSnapshot offerDoc = await offerRef.get();

      if (offerDoc.exists) {
        Map<String, dynamic> offersData =
            offerDoc.data() as Map<String, dynamic>;

        // Check if the offer with the given offerId exists
        if (offersData.containsKey(offerId.toString())) {
          // Increment the views for the specific offer
          Map<String, dynamic> offerData = offersData[offerId.toString()];
          int currentViews =
              offerData.containsKey('views') ? offerData['views'] : 0;
          offerData['views'] = currentViews + 1;

          // Update the offer inside the document
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

  /// Fetch all offers and associated properties, then apply filters
  Future<void> fetchOffersWithFilters({
    double? minPrice,
    double? maxPrice,
    double? maxMinutes,
    DateTimeRange? dateRange,
  }) async {
    _setLoading(true);

    try {
      // Fetch properties
      DocumentSnapshot propertyDoc =
          await _propertiesRef.doc('X8qn8e6UXKberOSYZnXk').get();
      log.info(
          'Fetched propertyDoc: ${propertyDoc.data()}'); // Log the propertyDoc data
      Map<String, Property> propertyMap = _mapSnapshotToProperties(propertyDoc);

      // Safeguard in case the properties document is missing or has no data
      if (propertyMap.isEmpty) {
        log.warning(
            'No properties found. Cannot proceed with offer filtering.');
        _setLoading(false);
        return;
      }

      // Fetch offers
      DocumentSnapshot offersDoc =
          await _offersRef.doc('E2amoJzmIbhtLq65ScpY').get();
      log.info(
          'Fetched offersDoc: ${offersDoc.data()}'); // Log the offersDoc data

      // Check if the offers document exists and has the expected structure
      if (offersDoc.exists && offersDoc.data() != null) {
        var offersData = offersDoc.data() as Map<String, dynamic>;
        List<OfferWithProperty> tempOffersWithProperties = [];

        offersData.forEach((key, offerData) {
          log.info('Processing offer data: $offerData'); // Log the offer data

          if (offerData['is_active'] == true) {
            String propertyId = offerData['id_property'].toString();
            log.info(
                'Looking for property with id_property: $propertyId'); // Log the propertyId
            Property? property = propertyMap[propertyId];

            if (property != null) {
              Offer offer = Offer(
                final_date: offerData['final_date'],
                initial_date: offerData['initial_date'],
                user_id: offerData['user_id'],
                property_id: offerData['id_property'],
                is_active: offerData['is_active'],

                // Ensure fields are cast to int when necessary
                num_baths: (offerData['num_baths'] is double)
                    ? (offerData['num_baths'] as double).toInt()
                    : offerData['num_baths'],
                num_beds: (offerData['num_beds'] is double)
                    ? (offerData['num_beds'] as double).toInt()
                    : offerData['num_beds'],
                num_rooms: (offerData['num_rooms'] is double)
                    ? (offerData['num_rooms'] as double).toInt()
                    : offerData['num_rooms'],
                roommates: (offerData['roommates'] is double)
                    ? (offerData['roommates'] as double).toInt()
                    : offerData['roommates'],

                only_andes: offerData['only_andes'],

                // Similarly handle price_per_month, cast to double
                price_per_month: (offerData['price_per_month'] is int)
                    ? (offerData['price_per_month'] as int).toDouble()
                    : offerData['price_per_month'],

                type: offerData['type'],
                offerId: int.tryParse(key) ?? 0,
              );

              log.info('Created offer: $offer'); // Log the created offer

              // Apply filters if necessary
              if (_applyFilters(
                  offer, property, minPrice, maxPrice, maxMinutes, dateRange)) {
                tempOffersWithProperties
                    .add(OfferWithProperty(offer: offer, property: property));
              }
            } else {
              log.warning("Property not found for id_property $propertyId");
            }
          }
        });

        // Set filtered results
        _offersWithProperties = tempOffersWithProperties;
        log.info('Filtered offers count: ${_offersWithProperties.length}');
        notifyListeners();
      } else {
        log.warning("Offer document does not exist or is empty");
      }
    } catch (e, stacktrace) {
      log.shout('Error fetching offers: $e\nStacktrace: $stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  /// Map Firestore snapshot to Property model considering nested structure
  Map<String, Property> _mapSnapshotToProperties(DocumentSnapshot snapshot) {
    Map<String, Property> propertyMap = {};

    if (snapshot.exists && snapshot.data() != null) {
      var propertiesData = snapshot.data() as Map<String, dynamic>;
      log.info(
          'Mapping properties from data: $propertiesData'); // Log the properties data

      propertiesData.forEach((key, propertyData) {
        try {
          int propertyId = int.tryParse(key) ?? 0;

          // Handle both int and double for minutes_from_campus
          double minutesFromCampus;
          if (propertyData['minutes_from_campus'] is int) {
            minutesFromCampus =
                (propertyData['minutes_from_campus'] as int).toDouble();
          } else if (propertyData['minutes_from_campus'] is double) {
            minutesFromCampus = propertyData['minutes_from_campus'];
          } else {
            // Default to 0 if the value is not valid
            minutesFromCampus = 0;
          }

          // Handle optional fields
          String? description =
              propertyData['description'] ?? "No description provided";
          List<String> photos = List<String>.from(propertyData['photos'] ?? []);

          // Handle GeoPoint - allow empty or invalid locations
          var location = propertyData['location'];
          GeoPoint? geoPoint;
          if (location is GeoPoint) {
            geoPoint = location;
          } else {
            geoPoint = null; // Default to null if not a valid GeoPoint
          }

          Property property = Property(
            id: propertyId,
            address: propertyData['address'] ??
                'No address provided', // Default to a placeholder if no address
            complex_name: propertyData['complex_name'] ??
                'Unnamed complex', // Default if complex_name is missing
            description: description,
            location: geoPoint, // Accepting null locations
            photos: photos,
            minutesFromCampus: minutesFromCampus,
            title: propertyData['title'] ??
                'Untitled Property', // Default if title is missing
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
    // Ensure minPrice defaults to 0
    minPrice ??= 0;

    log.info(
        'Applying filters on offer: $offer and property: $property with minPrice $minPrice and maxPrice $maxPrice');

    // Price filter: apply minPrice (which is now guaranteed to be at least 0) and apply maxPrice only if it's provided
    if (offer.price_per_month < minPrice) {
      return false;
    }
    if (maxPrice != null && offer.price_per_month > maxPrice) {
      return false;
    }

    // Date range filter: Check if the offer is available within the provided date range
    if (dateRange != null) {
      DateTime initialDate = offer.initial_date.toDate(); // Convert to DateTime
      DateTime finalDate = offer.final_date.toDate(); // Convert to DateTime

      // Check if the offer's date range overlaps with the provided date range
      if (finalDate.isBefore(dateRange.start) ||
          initialDate.isAfter(dateRange.end)) {
        return false;
      }
    }

    // Minutes from campus filter
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

class OfferWithProperty {
  final Offer offer;
  final Property property;

  OfferWithProperty({required this.offer, required this.property});
}
