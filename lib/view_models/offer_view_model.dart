import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/offer.dart';
import '../models/entities/property.dart';
import 'property_view_model.dart'; // To access PropertyViewModel internally

class OfferViewModel extends ChangeNotifier {
  List<Offer> _offers = [];
  bool _isLoading = false;

  static final log = Logger('OfferViewModel');

  final CollectionReference _offersRef = FirebaseFirestore.instance.collection('offers');
  final PropertyViewModel _propertyViewModel = PropertyViewModel(); // Instantiate PropertyViewModel

  List<Offer> get offers => _offers;
  bool get isLoading => _isLoading;

  /// Method to fetch all offers without any filters
  Future<void> fetchOffersWithoutFilters() async {
    try {
      QuerySnapshot snapshot = await _offersRef.get();
      _offers = _mapSnapshotToOffers(snapshot);
      log.info('Fetched ${_offers.length} offers without filters');
      notifyListeners();
    } catch (e, stacktrace) {
      log.shout('Error fetching offers without filters: $e\nStacktrace: $stacktrace');
    }
  }

  /// Method to fetch offers by applying filters, including property filters
  Future<void> fetchOffers({
    double? price,
    double? minutes,
    DateTimeRange? dateRange,
  }) async {
    _setLoading(true);

    try {
      List<Offer> priceFilteredOffers = [];
      List<Offer> dateRangeFilteredOffers = [];

      // Query for price filter (if applied)
      if (price != null) {
        QuerySnapshot priceSnapshot = await _offersRef
            .where('price_per_month', isLessThanOrEqualTo: price)
            .get();
        priceFilteredOffers = _mapSnapshotToOffers(priceSnapshot);
        log.info('Price filtered offers: ${priceFilteredOffers.length}');
      }

      // Query for date range filter (if applied)
      if (dateRange != null) {
        QuerySnapshot dateSnapshot = await _offersRef
            .where('initial_date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.start))
            .where('final_date', isLessThanOrEqualTo: Timestamp.fromDate(dateRange.end))
            .get();
        dateRangeFilteredOffers = _mapSnapshotToOffers(dateSnapshot);
        log.info('Date range filtered offers: ${dateRangeFilteredOffers.length}');
      }

      // Combine the results from price and date filters
      List<Offer> combinedOffers = _combineResults(priceFilteredOffers, [], dateRangeFilteredOffers);

      // Fetch properties related to these offers and apply the minutes filter
      List<Offer> filteredOffers = await _applyPropertyFilter(
        offers: combinedOffers,
        minutes: minutes,
      );

      // Set the final filtered offers
      _offers = filteredOffers;
      log.info('Offers fetched: ${_offers.length} for price: $price, minutes: $minutes, dateRange: $dateRange');
      notifyListeners();
    } catch (e, stacktrace) {
      log.shout('Error fetching offers: $e\nStacktrace: $stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  /// Helper function to map Firestore snapshot to Offer objects
  List<Offer> _mapSnapshotToOffers(QuerySnapshot snapshot) {
    return snapshot.docs.expand((doc) {
      final offerData = doc.data() as Map<String, dynamic>;

      return offerData.entries.map((entry) {
        final details = entry.value as Map<String, dynamic>;

        return Offer(
          final_date: details['final_date'] != null
              ? details['final_date'] as Timestamp
              : Timestamp.now(),
          user_id: details['user_id'] ?? '',
          property_id: details['id_property'] ?? 0,
          initial_date: details['initial_date'] != null
              ? details['initial_date'] as Timestamp
              : Timestamp.now(),
          is_active: details['is_active'] ?? false,
          num_baths: (details['num_baths'] as num?)?.toInt() ?? 0,  // Casting num to int
          num_beds: (details['num_beds'] as num?)?.toInt() ?? 0,    // Casting num to int
          num_rooms: (details['num_rooms'] as num?)?.toInt() ?? 0,  // Casting num to int
          only_andes: details['only_andes'] ?? false,
          price_per_month: (details['price_per_month'] as num?)?.toDouble() ?? 0.0,  // Casting num to double
          roommates: (details['roommates'] as num?)?.toInt() ?? 0,   // Casting num to int
          type: details['type'] ?? '',
        );
      }).toList();
    }).toList();
  }

  /// Combine results from multiple queries
  List<Offer> _combineResults(List<Offer> priceOffers, List<Offer> minutesOffers, List<Offer> dateOffers) {
    Set<Offer> combinedResults = {};

    // Initialize combinedResults with priceOffers, if available
    if (priceOffers.isNotEmpty) {
      combinedResults = Set<Offer>.from(priceOffers);
    }

    // Intersect with dateFilteredOffers
    if (dateOffers.isNotEmpty) {
      if (combinedResults.isEmpty) {
        combinedResults = Set<Offer>.from(dateOffers);
      } else {
        combinedResults = combinedResults.intersection(Set<Offer>.from(dateOffers));
      }
    }

    return combinedResults.toList();
  }

  /// Apply property filter using the minutes from campus
  Future<List<Offer>> _applyPropertyFilter({
    required List<Offer> offers,
    required double? minutes,
  }) async {
    if (minutes == null) return offers;

    List<Offer> filteredOffers = [];

    // Fetch properties to apply the minutes filter
    await _propertyViewModel.fetchProperties();

    // Loop through each offer, fetch its associated property, and apply the minutes filter
    for (Offer offer in offers) {
      Property? property = await _propertyViewModel.getPropertyById(offer.property_id);
      if (property != null && property.minutesFromCampus <= minutes) {
        filteredOffers.add(offer);
      }
    }
    log.info('Offers filtered by minutes: ${filteredOffers.length}');
    return filteredOffers;
  }

  /// Update the loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
