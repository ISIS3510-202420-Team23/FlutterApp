import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  static final log = Logger('LocationService');

  // Start location tracking
  void startTracking() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Start listening to position updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Fetch updates only when user moves by 10 meters
      ),
    ).listen((Position position) {
      // Handle the location updates (you can send it to the server or save in local DB)
      log.info('Current Position: ${position.latitude}, ${position.longitude}');
    });
  }

  // Stop location tracking
  void stopTracking() {
    _positionStream?.cancel();
  }
}
