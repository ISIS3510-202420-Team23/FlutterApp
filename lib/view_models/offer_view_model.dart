import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/offer.dart';

class OfferViewModel extends ChangeNotifier {
  /// List of offers
  List<Offer> _offers = [];
  bool _isLoading = false;

  static final log = Logger('OfferViewModel');
  final DatabaseReference _offersRef =
      FirebaseDatabase.instance.ref().child('offers');

  /// Getter for offers
  List<Offer> get offers => _offers;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch offers from Firebase Realtime Database
  Future<void> fetchOffers() async {
    _setLoading(true);

    try {
      final DataSnapshot snapshot = await _offersRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        _offers = data.entries.map((entry) {
          final offerData = entry.value as Map<dynamic, dynamic>;

          return Offer(
            final_date: offerData['final_date'] ?? '',
            user_id: offerData['user_id'] ?? '',
            property_id: offerData['id_property'] ?? 0,
            initial_date: offerData['initial_date'] ?? '',
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

        notifyListeners();
      }
    } catch (e) {
      log.shout('Error fetching offers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new offer to Firebase
  Future<void> addOffer(Offer offer) async {
    try {
      final newOfferRef = _offersRef.push();
      await newOfferRef.set({
        'final_date': offer.final_date,
        'user_id': offer.user_id,
        'id_property': offer.property_id,
        'initial_date': offer.initial_date,
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

  /// Method to remove an offer from Firebase by key
  Future<void> removeOffer(String offerKey) async {
    try {
      await _offersRef.child(offerKey).remove();

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
