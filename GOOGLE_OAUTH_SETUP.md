# Google Sign-In for Android and iOS

The Flutter app uses `google_sign_in` directly with Google Cloud OAuth. Firebase
is not required. The Google button obtains a Google ID token, sends it to a
configured CRM endpoint, and uses the returned CRM session for permissions and
role-based navigation. Canceling the Google picker leaves the login screen open.

## Configuration checked locally

- Android application ID: `com.beassuite.app`.
- Android signing SHA-1 supplied by the user:
  `B9:A0:C6:01:49:AA:A1:2C:2A:DC:D9:7B:76:11:D0:B5:51:8A:6A:9A`.
  This has valid SHA-1 fingerprint syntax, but has not been matched against an
  APK or signing certificate locally. No APK or default debug keystore was
  available during this check. Both debug and release currently use the debug
  signing configuration in `android/app/build.gradle.kts`.
- iOS bundle ID: `com.beassuite.app` (Debug, Profile, Release).
- Android OAuth client supplied:
  `927283577805-jur6jhjf77aa0kie28ql0aim339s3nq0.apps.googleusercontent.com`.
- iOS OAuth client supplied:
  `927283577805-ukh55c2bnj607jlekle5s4of8056ca6r.apps.googleusercontent.com`.
- Web/server OAuth client supplied and configured:
  `927283577805-00t0qi845ppv18dhpa7rjmtmjkqk7se5.apps.googleusercontent.com`.
- The iOS plist's `CLIENT_ID`, `REVERSED_CLIENT_ID`, and `BUNDLE_ID` agree.
  The required `GIDClientID` and callback URL scheme are in `ios/Runner/Info.plist`.

`android/app/google-services.json` is actually an OAuth download with an
`installed` object. It is not a Firebase configuration (which has `project_info`
and `client` entries). Direct Google Sign-In does not consume that file. Do not
apply the Google Services Gradle plugin to it. The supplied iOS plist is also an
OAuth configuration; this integration reads the client ID from Dart/Info.plist
and does not require adding the downloaded file to the Xcode target.

Local files cannot confirm that the clients are enabled or correctly registered
in Google Cloud, or that Android's signing SHA-1 matches.

## Remaining Google Cloud setup

1. In Google Cloud project `crm-backend-506508`, check the Android OAuth client
   has package `com.beassuite.app` and the SHA-1 of the certificate signing the
   installed app. Run `./gradlew signingReport` from `android` to inspect local
   variants. Register release/Play App Signing certificates when distributing.
   In Google Cloud Console, open **APIs & Services > Credentials**, edit the
   Android OAuth client
   `927283577805-jur6jhjf77aa0kie28ql0aim339s3nq0.apps.googleusercontent.com`,
   and set package name `com.beassuite.app` and certificate SHA-1
   `B9:A0:C6:01:49:AA:A1:2C:2A:DC:D9:7B:76:11:D0:B5:51:8A:6A:9A`, provided
   this fingerprint belongs to the certificate signing the installed APK.
   This registration lives in Google Cloud; the fingerprint is not a Dart,
   Gradle, JSON, or plist setting. A fingerprint alone cannot change the app's
   signing certificate; signing requires the matching keystore.
2. Check the iOS OAuth client has bundle ID `com.beassuite.app`.
3. Confirm the supplied Web/server client is of type **Web application** in the
   same project. It is configured by default on both platforms and can be
   overridden with `GOOGLE_SERVER_CLIENT_ID`.
   The native Android and iOS client IDs are not substitutes for this value.
4. Configure the OAuth consent screen and add test users if the app is in testing.
   Client secrets belong on the backend, never in Flutter.

## Confirmed backend contract

The app now uses the confirmed endpoint without an endpoint build override:

```http
POST /auth/google
Content-Type: application/json

{"credential":"<Google ID token>"}
```

Successful responses use the same CRM session storage, permissions lookup, and
role navigation as email login. Google profiles alone never establish a session.
`registration_required` presents a Register action opening the existing organization
registration form. HTTP 409 explains the account conflict, 403 explains account
deactivation, and 503 offers email login while Google Sign-In is unavailable.
No account linking or automatic registration is performed by Flutter.

The handoff names `registration_required` without its full response schema. The
client recognizes it as `status`, `code`, `error`, `detail`, or a true
`registration_required` flag, including structured error details. Confirm the exact
response envelope during staging testing.

The web OAuth client ID is passed as `serverClientId` on both Android and iOS.
The backend's `GOOGLE_CLIENT_ID` must match this web client ID:
`927283577805-00t0qi845ppv18dhpa7rjmtmjkqk7se5.apps.googleusercontent.com`.
Production configuration remains unverified; backend changes have not yet been
deployed according to the backend handoff.

To test a deployed staging backend:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-staging-api.example
```

If staging uses another web OAuth client, also supply
`--dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>` and configure the same
value on the backend. `GOOGLE_LOGIN_ENDPOINT` is no longer used.
This flow supports Android and iOS. Web requires Google's SDK-rendered button and
separate web setup.

## Validation

```powershell
flutter test test/google_login_test.dart test/widget_test.dart
```

Finally test on an Android device/emulator with Google Play services and on iOS
from a Mac with Xcode. Verify account selection, cancel, backend rejection,
successful role routing, logout, and login after restart. Local tests do not
validate Google Cloud registrations or live backend token verification.

References:
- https://pub.dev/packages/google_sign_in_android
- https://pub.dev/packages/google_sign_in_ios



no brother sarvan sathi vegla vegla mahun apun jevha create karto key tevha option yeto selecte karai cha 
jasa tu web 
tasa me ekdha android kela ani ekdha 
