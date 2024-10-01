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

  final CollectionReference _offersRef = FirebaseFirestore.instance.collection('offers');
  final CollectionReference _propertiesRef = FirebaseFirestore.instance.collection('properties');
  final CollectionReference _userViewsRef = FirebaseFirestore.instance.collection('user_views');

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
      DocumentSnapshot propertyDoc = await _propertiesRef.doc('X8qn8e6UXKberOSYZnXk').get();
      log.info('Fetched propertyDoc: ${propertyDoc.data()}');  // Log the propertyDoc data
      Map<String, Property> propertyMap = _mapSnapshotToProperties(propertyDoc);

      // Safeguard in case the properties document is missing or has no data
      if (propertyMap.isEmpty) {
        log.warning('No properties found. Cannot proceed with offer filtering.');
        _setLoading(false);
        return;
      }

      // Fetch offers
      DocumentSnapshot offersDoc = await _offersRef.doc('E2amoJzmIbhtLq65ScpY').get();
      log.info('Fetched offersDoc: ${offersDoc.data()}');  // Log the offersDoc data

      // Check if the offers document exists and has the expected structure
      if (offersDoc.exists && offersDoc.data() != null) {
        var offersData = offersDoc.data() as Map<String, dynamic>;
        List<OfferWithProperty> tempOffersWithProperties = [];

        offersData.forEach((key, offerData) {
          log.info('Processing offer data: $offerData');  // Log the offer data

          if (offerData['is_active'] == true) {
            String propertyId = offerData['id_property'].toString();
            log.info('Looking for property with id_property: $propertyId');  // Log the propertyId
            Property? property = propertyMap[propertyId];

            if (property != null) {
              Offer offer = Offer(
                final_date: offerData['final_date'],
                initial_date: offerData['initial_date'],
                user_id: offerData['user_id'],
                property_id: offerData['id_property'],
                is_active: offerData['is_active'],

                // Ensure fields are cast to int when necessary
                num_baths: (offerData['num_baths'] is double) ? (offerData['num_baths'] as double).toInt() : offerData['num_baths'],
                num_beds: (offerData['num_beds'] is double) ? (offerData['num_beds'] as double).toInt() : offerData['num_beds'],
                num_rooms: (offerData['num_rooms'] is double) ? (offerData['num_rooms'] as double).toInt() : offerData['num_rooms'],
                roommates: (offerData['roommates'] is double) ? (offerData['roommates'] as double).toInt() : offerData['roommates'],

                only_andes: offerData['only_andes'],

                // Similarly handle price_per_month, cast to double
                price_per_month: (offerData['price_per_month'] is int) ? (offerData['price_per_month'] as int).toDouble() : offerData['price_per_month'],

                type: offerData['type'],
              );



              log.info('Created offer: $offer');  // Log the created offer

              // Apply filters if necessary
              if (_applyFilters(offer, property, minPrice, maxPrice, maxMinutes, dateRange)) {
                tempOffersWithProperties.add(OfferWithProperty(offer: offer, property: property));
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
      log.info('Mapping properties from data: $propertiesData');  // Log the properties data

      // Iterate over the fields and use the key as the property id
      propertiesData.forEach((key, propertyData) {
        try {
          // Using the 'key' as the 'id' since the 'id' field is missing
          int propertyId = int.tryParse(key) ?? 0;

          // Handle both int and double for minutes_from_campus
          double minutesFromCampus;
          if (propertyData['minutes_from_campus'] is int) {
            minutesFromCampus = (propertyData['minutes_from_campus'] as int).toDouble();
          } else if (propertyData['minutes_from_campus'] is double) {
            minutesFromCampus = propertyData['minutes_from_campus'];
          } else {
            throw Exception("Invalid type for minutes_from_campus");
          }

          Property property = Property(
            id: propertyId,  // Assign the key as the id
            address: propertyData['address'],
            complex_name: propertyData['complex_name'],
            description: propertyData['description'],
            location: propertyData['location'],
            photos: List<String>.from(propertyData['photos']),
            minutesFromCampus: minutesFromCampus,
            title: propertyData['title'],
          );

          // Use the property ID to map the property
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

    log.info('Applying filters on offer: $offer and property: $property with minPrice $minPrice and maxPrice $maxPrice' );

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
      if (finalDate.isBefore(dateRange.start) || initialDate.isAfter(dateRange.end)) {
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
