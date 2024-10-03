import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final log = Logger('NotificationService');
  final CollectionReference _userActionsRef = FirebaseFirestore.instance.collection('user_actions');

  NotificationService() {
    initializeNotifications();
  }

  // Initialize the notification plugin
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('andletlogosf');
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Ensure the notification channel exists and is properly configured
    const AndroidNotificationChannel notificationChannel = AndroidNotificationChannel(
      'contact_channel', // Same ID as used in showNotification()
      'ContactReminder', // Name for the channel
      description: 'Notifications to remind users about contacting landlords', // Optional description
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
  }

  // Show notification
  Future<void> _showNotification(String userEmail) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'contact_channel',
      'ContactReminder',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'andletlogosf',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'It\'s been a while!',
      'It seems like you haven\'t contacted a landlord in the last two weeks. Your ideal home might be waiting for you on Andlet!',
      platformChannelSpecifics,
    );
  }

  // Check the last contact action for a specific user
  Future<void> checkLastContactAction(String userEmail) async {
    try {
      // Query user actions to find the latest contact action
      QuerySnapshot querySnapshot = await _userActionsRef
          .where('user_id', isEqualTo: userEmail)
          .where('action', isEqualTo: 'contact')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the most recent action
        var lastAction = querySnapshot.docs.first;
        Timestamp actionTimestamp = lastAction['date'];
        DateTime lastContactDate = actionTimestamp.toDate();
        DateTime currentDate = DateTime.now();

        // Check if the last contact was more than 14 days ago
        if (currentDate.difference(lastContactDate).inDays > 14) {
          log.info('User $userEmail has not contacted a landlord in the last two weeks');
          // Show notification
          await _showNotification(userEmail);
        }
      } else {
        log.info('No contact actions found for user $userEmail');
      }
    } catch (e) {
      log.shout('Error checking last contact action: $e');
    }
  }
}

