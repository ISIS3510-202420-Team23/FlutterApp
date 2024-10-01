import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;
  static final log = Logger('LocationService');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 4.601501064189732, -74.066132237862
  final double targetLatitude = 4.601501064189732;
  final double targetLongitude = -74.066132237862;
  final double radiusInMeters =
      3000; // Radius in meters to trigger notification

  // Initialize the notification plugin
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('andletlogosf');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a notification
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'LocationNotification',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'andletlogosf',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'You are near Universidad de los Andes!',
      'You have entered the designated area.',
      platformChannelSpecifics,
    );
  }

  /// Calculate the distance between two points (in meters)
  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Start location tracking
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
    ).listen((Position position) async {
      log.info('Current Position: ${position.latitude}, ${position.longitude}');

      // Calculate the distance to the target
      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );
      log.info('Distance to target: $distance meters');

      // If within the radius, trigger the notification
      if (distance <= radiusInMeters) {
        await _showNotification();
      }
    });
  }

  /// Stop location tracking
  void stopTracking() {
    _positionStream?.cancel();
  }
}
