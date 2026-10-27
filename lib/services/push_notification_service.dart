import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Notification payloads are displayed by Android/iOS automatically while
  // the app is backgrounded. Keep this handler for data-only messages and
  // future background processing.
  debugPrint('[FCM] background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const _deviceIdKey = 'push.device_id';
  static const _tokenKey = 'push.fcm_token';
  static const _channelId = 'crm_notifications';

  // Firebase Messaging is mobile-only in this app. Keep it lazy so merely
  // accessing PushNotificationService on web does not require Firebase.app().
  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenSubscription;
  bool _initialized = false;
  bool _registrationInProgress = false;

  Future<void> initialize() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    if (_initialized) return;

    _messaging = FirebaseMessaging.instance;

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[FCM] notification tapped: ${response.payload}');
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'CRM notifications',
      description: 'Notifications from Beassuite CRM',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleOpenedMessage(initialMessage);

    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      if ((ApiService.accessToken ?? '').trim().isNotEmpty) {
        await _registerToken(token);
      }
    });

    _initialized = true;
  }

  Future<void> registerForSignedInUser() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    debugPrint('[FCM] signed-in registration started');
    await initialize();
    final authorizationStatus = await requestPermissionBeforeLogin();
    if (authorizationStatus == AuthorizationStatus.denied) {
      // Login must still succeed. Android can often issue an FCM token even
      // when alerts are denied, so continue and attempt device registration.
      debugPrint(
        '[FCM] notification permission denied; continuing token registration',
      );
    }

    // iOS may need a short delay before APNs returns its token.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      for (var attempt = 0; attempt < 5; attempt++) {
        if (await _messaging.getAPNSToken() != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    final token = await _messaging.getToken();
    debugPrint('[FCM] getToken result: ${token == null ? '<null>' : token}');
    if (token != null && token.trim().isNotEmpty) {
      await _registerToken(token);
    } else {
      debugPrint('[FCM] no FCM token returned; registration API not called');
    }
  }

  /// Requests notification permission before authentication starts.
  /// Denying permission does not block CRM login; it only prevents push alerts
  /// from being displayed by the operating system.
  Future<AuthorizationStatus> requestPermissionBeforeLogin() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return AuthorizationStatus.denied;
    }

    await initialize();
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus;
  }

  Future<void> _registerToken(String token) async {
    if (_registrationInProgress || token.trim().isEmpty) return;
    _registrationInProgress = true;
    try {
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';
      debugPrint('[FCM] token: $token');
      debugPrint(
        '[FCM] POST /notifications/devices/register platform=$platform',
      );
      final response = await ApiService().registerPushDevice(
        token: token,
        platform: platform,
      );
      debugPrint('[FCM] device registration response: $response');
      final deviceId = response['id']?.toString().trim();
      if (deviceId == null || deviceId.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, deviceId);
      await prefs.setString(_tokenKey, token);
    } catch (error) {
      // Push registration must never prevent login or app startup.
      debugPrint('[FCM] registration failed: $error');
    } finally {
      _registrationInProgress = false;
    }
  }

  Future<void> unregisterForSignedOutUser() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString(_deviceIdKey)?.trim();
    if (deviceId != null &&
        deviceId.isNotEmpty &&
        (ApiService.accessToken ?? '').trim().isNotEmpty) {
      try {
        debugPrint('[FCM] DELETE /notifications/devices/$deviceId');
        await ApiService().unregisterPushDevice(deviceId);
        debugPrint('[FCM] device unregister response: success');
      } catch (error) {
        debugPrint('[FCM] unregister failed: $error');
      }
    }
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_tokenKey);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'Beassuite',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'CRM notifications',
          channelDescription: 'Notifications from Beassuite CRM',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint('[FCM] opened notification: ${message.data}');
    // Add route handling here when the backend defines business-event types.
  }
}
