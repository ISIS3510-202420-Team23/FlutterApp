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

      _offers = snapshot.docs.map((doc) {
        final offerData = doc.data() as Map<String, dynamic>;

        return Offer(
          final_date: (offerData['final_date'] as Timestamp),
          user_id: offerData['user_id'] ?? '',
          property_id: offerData['id_property'] ?? 0,
          initial_date: (offerData['initial_date'] as Timestamp),
          is_active: offerData['is_active'] ?? false,
          num_baths: offerData['num_baths'] ?? 0,
          num_beds: offerData['num_beds'] ?? 0,
          num_rooms: offerData['num_rooms'] ?? 0,
          only_andes: offerData['only_andes'] ?? false,
          price_per_month: offerData['price_per_month'] ?? 0,
          roommates: offerData['roommates'] ?? 0,
          type: offerData['type'] ?? '',
        );
      }).toList();
      print('Offers fetched: ${_offers}');
      notifyListeners();
    } catch (e) {
      log.shout('Error fetching offers: $e');
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
