import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static bool _localReady = false;
  static bool _firebaseReady = false;
  static bool _foregroundListenerAttached = false;

  static Future<void> initFirebase() async {
    await _initLocalNotifications();
    if (_firebaseReady) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      if (!_foregroundListenerAttached) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          final notification = message.notification;
          if (notification != null) {
            await _showLocalNotification(
              notification.title ?? 'Notification',
              notification.body ?? 'You have a new message',
            );
          }
        });
        _foregroundListenerAttached = true;
      }

      try {
        await FirebaseMessaging.instance.requestPermission();
        await FirebaseMessaging.instance.subscribeToTopic('all');
      } catch (error, stackTrace) {
        debugPrint('FCM permission/topic setup skipped: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      _firebaseReady = true;
    } catch (error, stackTrace) {
      debugPrint('Firebase init skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> _initLocalNotifications() async {
    if (_localReady) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _local.initialize(initializationSettings);
    _localReady = true;
  }

  static Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'maintenance_channel',
          'Maintenance',
          channelDescription: 'Channel for maintenance notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _local.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> broadcastMaintenance(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final serverKey = prefs.getString('fcm_server_key') ?? '';
    if (serverKey.isEmpty) return;

    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final body = jsonEncode({
      'to': '/topics/all',
      'notification': {
        'title': 'Maintenance',
        'body': message,
        'sound': 'default',
      },
      'data': {'maintenance': '1'},
    });

    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: body,
      );
    } catch (_) {}
  }
}

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (error, stackTrace) {
    debugPrint('Background Firebase init skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
