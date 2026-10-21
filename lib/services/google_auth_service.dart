import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/google_auth_config.dart';
import 'api_service.dart';

class GoogleAuthService {
  static Future<void>? _initialization;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<String?> signIn() async {
    if (!isSupported) {
      throw const ApiException(
        message: 'Google sign-in is currently available on Android and iOS.',
      );
    }
    if (GoogleAuthConfig.serverClientId.trim().isEmpty) {
      throw const ApiException(
        message: 'Google sign-in setup requires a Web OAuth client ID.',
      );
    }
    try {
      await _initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException(
          message: 'Google did not return an identity token. Please try again.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw const ApiException(
        message:
            'Google sign-in failed. Check your connection and Google OAuth '
            'configuration, including the Android signing certificate.',
      );
    }
  }

  Future<void> _initialize() async {
    final initialization = _initialization ??= GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? GoogleAuthConfig.iosClientId
          : null,
      serverClientId: GoogleAuthConfig.serverClientId.trim(),
    );
    try {
      await initialization;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }
}
