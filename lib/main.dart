import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/api_service.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In release builds suppress stack-trace noise from the Flutter framework and
  // native platform errors — log a terse message only.
  if (!kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      return true;
    };
  }

  // Lock the app to portrait on phones; tablets can rotate freely via their
  // own widget-level handling.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final isMobile =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (isMobile) await Firebase.initializeApp();
  await ApiService.restorePersistedAuthState();
  if (isMobile) await PushNotificationService.instance.initialize();
  if (isMobile && (ApiService.accessToken ?? '').trim().isNotEmpty) {
    unawaited(PushNotificationService.instance.registerForSignedInUser());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const BeassuiteApp();
  }
}
