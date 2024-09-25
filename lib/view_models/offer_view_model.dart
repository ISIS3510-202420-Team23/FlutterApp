import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/offer.dart';

class OfferViewModel extends ChangeNotifier {
  /// List of offers
  List<Offer> _offers = [];
  bool _isLoading = false;

  static final log = Logger('OfferViewModel');

  // Reference to Firestore 'offers' collection
  final CollectionReference _offersRef =
      FirebaseFirestore.instance.collection('offers');

  /// Getter for offers
  List<Offer> get offers => _offers;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch offers from Firestore
  Future<void> fetchOffers() async {
    _setLoading(true);

    try {
      QuerySnapshot snapshot = await _offersRef.get();

      _offers = snapshot.docs.expand((doc) {
        final offerData = doc.data() as Map<String, dynamic>;

        // Iterate over each entry in the map where the key is the ID and the value is the offer details
        return offerData.entries.map((entry) {
          // final id = entry.key;
          final details = entry.value as Map<String, dynamic>;

          // Create an Offer object using the details map
          return Offer(
            final_date: details['final_date'] as Timestamp,
            user_id: details['user_id'] ?? '',
            property_id: details['id_property'] ?? 0,
            initial_date: details['initial_date'] as Timestamp,
            is_active: details['is_active'] ?? false,
            num_baths: details['num_baths'] ?? 0,
            num_beds: details['num_beds'] ?? 0,
            num_rooms: details['num_rooms'] ?? 0,
            only_andes: details['only_andes'] ?? false,
            price_per_month: details['price_per_month'] ?? 0,
            roommates: details['roommates'] ?? 0,
            type: details['type'] ?? '',
          );
        });
      }).toList();

      notifyListeners();
    } catch (e, stacktrace) {
      log.shout('Error fetching offers: $e\nStacktrace: $stacktrace');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new offer to Firestore
  Future<void> addOffer(Offer offer) async {
    try {
      await _offersRef.add({
        'final_date': offer.final_date, // Convert String to Timestamp
        'user_id': offer.user_id,
        'id_property': offer.property_id,
        'initial_date': offer.initial_date, // Convert String to Timestamp
        'is_active': offer.is_active,
        'num_baths': offer.num_baths,
        'num_beds': offer.num_beds,
        'num_rooms': offer.num_rooms,
        'only_andes': offer.only_andes,
        'price_per_month': offer.price_per_month,
        'roommates': offer.roommates,
        'type': offer.type,
      });

      // Fetch the updated offers list
      await fetchOffers();
    } catch (e) {
      log.shout('Error adding offer: $e');
    }
  }

  /// Method to remove an offer from Firestore by document ID
  Future<void> removeOffer(String documentId) async {
    try {
      await _offersRef.doc(documentId).delete();

      // Fetch the updated offers list
      await fetchOffers();
    } catch (e) {
      log.shout('Error removing offer: $e');
    }
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
