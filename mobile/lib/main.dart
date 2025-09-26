import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'config/env.dart';

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.demo) {
    runApp(const FitCoachApp());
    return;
  }

  await Firebase.initializeApp();

  // Messaging init
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final notif = NotificationService();
  await notif.init();

  try {
    final token = await FirebaseMessaging.instance.getToken();
    // ignore: avoid_print
    print('FCM Token: $token');
  } catch (_) {}

  // Handle notification that opened the app (cold start)
  await notif.handleInitialMessage();

  // Streams
  FirebaseMessaging.onMessage.listen(notif.onMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(notif.onMessageOpenedApp);

  runApp(const FitCoachApp());
}
