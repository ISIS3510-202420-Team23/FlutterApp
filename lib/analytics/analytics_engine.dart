import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsEngine {
  static final _instance = FirebaseAnalytics.instance;

  /// Initialize Firebase Analytics
  static Future<void> initializeAnalytics() async {
    _instance.setAnalyticsCollectionEnabled(true);
  }

  /// Log an event when the user presses the contact button
  static void logContactButtonPressed() {
    _instance.logEvent(name: 'contact_button_pressed', parameters: {
      'time': DateTime.now().toIso8601String(),
    });
  }

  /// Log an event when the user views property details
  static void logViewPropertyDetails(int propertyId) {
    _instance.logEvent(
      name: 'view_property_details',
      parameters: {
        'property_id': propertyId,
        'time': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log an event when the user presses the filter button
  static void logFilterButtonPressed() {
    _instance.logEvent(name: 'filter_button_pressed', parameters: {
      'time': DateTime.now().toIso8601String(),
    });
  }
}
