class GoogleAuthConfig {
  const GoogleAuthConfig._();

  static const iosClientId =
      '927283577805-ukh55c2bnj607jlekle5s4of8056ca6r.apps.googleusercontent.com';

  // This must be a Web application OAuth client, not the Android client ID.
  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '927283577805-00t0qi845ppv18dhpa7rjmtmjkqk7se5.apps.googleusercontent.com',
  );

  static const loginEndpoint = '/auth/google';
}
