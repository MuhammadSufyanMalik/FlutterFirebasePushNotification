import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Request permission for receiving notifications
      await _fcm.requestPermission();

      // ignore: avoid_print
      getFirebaseToken().then((value) => print('Firebase Token: $value'));
      // Initialize the local notification plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Listen for incoming messages while the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("onMessage:Foreground message");
          print(message.data);
        }
        _showForegroundNotification(message);
      });

      // Listen for when the app is opened from a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("onMessageOpenedApp: $message");
        }
        if (message.data.containsKey('userId')) {
          final userId = message.data['userId'];
          if (kDebugMode) {
            print('onMessageOpenedApp: $userId');
          }
        }

        if (kDebugMode) {
          print(message.data);
        }
        // You can handle the message here or delegate it to another function
      });

      // Register the background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase Messaging: $e');
      }
    }
  }

  // Background message handler function
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (kDebugMode) {
      if (message.data.containsKey('userId')) {
        final userId = message.data['userId'];
        if (kDebugMode) {
          print('Handling a background message for user id: $userId');
        }
      }
      print("Handling a background message: ${message.messageId}");
    }
    // Handle the background message here
  }

  // Show a notification when the app is in the foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        color: Colors.deepPurple,
        'your channel id',
        'your channel name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        channelDescription: 'your channel description',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }

  //get Firebase token
  Future<String?> getFirebaseToken() async {
    return await _fcm.getToken();
  }
}
