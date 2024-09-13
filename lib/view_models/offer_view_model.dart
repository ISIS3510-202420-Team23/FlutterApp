import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/entities/offer.dart';

class OfferViewModel extends ChangeNotifier {
  /// List of offers, this can be fetched from a data source (e.g., API, Firebase, etc.)
  final List<Offer> _offers = [];
  bool _isLoading = false;

  static final log = Logger('OfferViewModel');

  /// Getter for offers
  List<Offer> get offers => _offers;

  /// Getter for loading state
  bool get isLoading => _isLoading;

  /// Method to fetch offers from a data source
  Future<void> fetchOffers() async {
    _setLoading(true);

    try {
      // TODO: fetching logic here

      // Notify listeners that data has changed
      notifyListeners();
    } catch (e) {
      // Handle error if something goes wrong
      log.shout('Error fetching offers: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Method to add a new offer
  void addOffer(Offer offer) {
    _offers.add(offer);
    notifyListeners();
  }

  /// Method to remove an offer
  void removeOffer(int index) {
    _offers.removeAt(index);
    notifyListeners();
  }

  /// Method to update loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
