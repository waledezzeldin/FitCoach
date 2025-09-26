import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigation/app_navigator.dart';
import '../config/env.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  static const _kEnabled = 'fc_notifications_enabled';
  static const _kOrders = 'fc_notify_orders';
  static const _kChat = 'fc_notify_chat';
  static const _kCalls = 'fc_notify_calls';

  final _fm = FirebaseMessaging.instance;
  final _fln = FlutterLocalNotificationsPlugin();

  bool _enabled = true;
  bool get enabled => _enabled;

  bool _ordersEnabled = true;
  bool _chatEnabled = true;
  bool _callsEnabled = true;

  bool get ordersEnabled => _ordersEnabled;
  bool get chatEnabled => _chatEnabled;
  bool get callsEnabled => _callsEnabled;

  Future<void> init() async {
    if (Env.demo) return;

    // Load preference
    try {
      final p = await SharedPreferences.getInstance();
      _enabled = p.getBool(_kEnabled) ?? true;
      _ordersEnabled = p.getBool(_kOrders) ?? true;
      _chatEnabled = p.getBool(_kChat) ?? true;
      _callsEnabled = p.getBool(_kCalls) ?? true;
    } catch (_) {
      _enabled = true;
      _ordersEnabled = true;
      _chatEnabled = true;
      _callsEnabled = true;
    }

    // Local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) => _handlePayload(resp.payload),
    );

    // Android channel
    const channel = AndroidNotificationChannel(
      'fc_high_importance',
      'High Importance',
      description: 'FitCoach notifications',
      importance: Importance.high,
    );
    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Ask permission (noop if already granted)
    await _ensurePermissions();
    await _fm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, value);
    } catch (_) {}
    if (value) {
      await _ensurePermissions();
    }
  }

  Future<void> setOrdersEnabled(bool v) async {
    _ordersEnabled = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kOrders, v);
    } catch (_) {}
  }

  Future<void> setChatEnabled(bool v) async {
    _chatEnabled = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kChat, v);
    } catch (_) {}
  }

  Future<void> setCallsEnabled(bool v) async {
    _callsEnabled = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kCalls, v);
    } catch (_) {}
  }

  Future<void> _ensurePermissions() async {
    try {
      await _fm.requestPermission(alert: true, badge: true, sound: true);
      // No need to request permission for Android local notifications here
    } catch (_) {}
  }

  Future<void> handleInitialMessage() async {
    final msg = await _fm.getInitialMessage();
    if (msg != null) _routeFromData(msg.data);
  }

  bool _allowedForRoute(Map data) {
    final route = (data['route'] ?? data['target'] ?? '').toString();
    if (!_enabled) return false;
    switch (route) {
      case 'orders':
      case 'order_details':
        return _ordersEnabled;
      case 'chat':
        return _chatEnabled;
      case 'video_calls':
        return _callsEnabled;
      default:
        return true;
    }
  }

  // Foreground
  Future<void> onMessage(RemoteMessage m) async {
    if (!_allowedForRoute(m.data)) return;

    final n = m.notification;
    final title = n?.title ?? 'FitCoach';
    final body = n?.body ?? '';
    final payload = _encodePayload(m.data);

    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'fc_high_importance',
        'High Importance',
        channelDescription: 'FitCoach notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    // Local notification
    await _fln.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details, payload: payload);

    // In-app banner (e.g., chat or generic)
    _showInAppBanner(title, body, m.data);
  }

  // Background tap
  void onMessageOpenedApp(RemoteMessage m) {
    if (!_allowedForRoute(m.data)) return;
    _routeFromData(m.data);
  }

  // Helpers
  String _encodePayload(Map<String, dynamic> data) =>
      data.isEmpty ? '' : data.entries.map((e) => '${e.key}=${e.value}').join('&');

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final map = <String, String>{};
    for (final part in payload.split('&')) {
      final i = part.indexOf('=');
      if (i > 0) map[part.substring(0, i)] = part.substring(i + 1);
    }
    _routeFromData(map);
  }

  void _routeFromData(Map data) {
    final route = (data['route'] ?? data['target'] ?? '').toString();
    final id = (data['id'] ?? data['conversationId'] ?? '').toString();
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;

    switch (route) {
      case 'orders':
        nav.pushNamed('/orders');
        break;
      case 'order_details':
        if (id.isNotEmpty) nav.pushNamed('/order_details', arguments: {'id': id});
        break;
      case 'video_calls':
        nav.pushNamed('/video_calls');
        break;
      case 'chat':
        if (id.isNotEmpty) {
          nav.pushNamed('/chat_thread', arguments: {'id': id});
        } else {
          nav.pushNamed('/chat');
        }
        break;
      default:
        break;
    }
  }

  void _showInAppBanner(String title, String body, Map data) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: const Duration(seconds: 4),
        action: (data['route'] != null || data['target'] != null)
            ? SnackBarAction(
                label: 'Open',
                onPressed: () => _routeFromData(data),
              )
            : null,
      ),
    );
  }
}