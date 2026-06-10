import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _auth = AuthService.instance;

  static const _androidChannel = AndroidNotificationChannel(
    'lunchquest_high_importance',
    'LunchQuest Bildirimleri',
    description: 'LunchQuest uygulama bildirimleri',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupLocalNotifications();
    await _createAndroidChannel();
    _listenForeground();
    _listenOnMessageOpenedApp();
    await _checkInitialMessage();

    // Token al ve Supabase'e kaydet
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _savePushToken(token);
    }

    // Token yenilenirse güncelle
    _messaging.onTokenRefresh.listen(_savePushToken);
  }

  // ── Token Kaydı ─────────────────────────────────────────────────────────

  Future<void> _savePushToken(String token) async {
    final userId = _auth.userId;
    if (userId == null) return;

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await Supabase.instance.client.from('push_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      // profiles.fcm_token da güncelle
      await Supabase.instance.client
          .from('profiles')
          .update({
            'fcm_token': token,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('Push token saved to Supabase ✓');
    } catch (e) {
      debugPrint('Push token save error: $e');
    }
  }

  // ── İzin ────────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  // ── Local Notifications Kurulum ──────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _createAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // ── Dinleyiciler ─────────────────────────────────────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['route'],
      );
    });
  }

  void _listenOnMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) _handleMessage(message);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Notification tapped — data: ${message.data}');
    // TODO: navigate based on message.data['route']
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped — payload: ${response.payload}');
    // TODO: navigate based on response.payload
  }

  // ── Public API ───────────────────────────────────────────────────────────

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
