# Firebase Push and In-App Notification Integration Requirements

This document describes everything required to complete Firebase push notifications and in-app notifications for the Beassuite CRM Flutter application.

## 1. Project details

| Item | Value |
|---|---|
| Android package name | `com.beassuite.app` |
| iOS bundle ID | `com.beassuite.app` |
| Firebase project ID | `crm-saas-platform-671a7` |
| Android Firebase file | `android/app/google-services.json` |
| iOS Firebase file | `ios/Runner/GoogleService-Info.plist` |
| Android push platform value | `android` |
| iOS push platform value | `ios` |
| Device registration endpoint | `POST /notifications/devices/register` |
| Device removal endpoint | `DELETE /notifications/devices/{device_id}` |
| Test notification endpoint | `POST /notifications/devices/test` |

The Firebase service-account JSON is a private backend credential. It must never be placed in the Flutter project, Firebase configuration files, app assets, source code, or mobile application binary.

## 2. Flutter client integration already included

The Flutter app includes:

- Firebase initialization on Android and iOS.
- FCM token retrieval after a user signs in.
- Notification permission request before email or Google login begins.
- Registration of the FCM token with the CRM backend.
- FCM token refresh handling.
- Device removal during logout.
- Android 13+ notification permission handling.
- Foreground notification display using `flutter_local_notifications`.
- Background and terminated-state notification handling.
- Android notification channel configuration.
- iOS remote-notification background mode and APNs entitlements.

The main implementation is in:

```text
lib/services/push_notification_service.dart
```

Firebase is initialized in:

```text
lib/main.dart
```

The backend API calls are implemented in:

```text
lib/services/api_service.dart
```

### Permission timing

The app requests notification permission when the user starts either email login or Google login. This happens before the authentication request begins on both Android and iOS.

If the user denies permission, CRM login is still allowed. The user will not see operating-system push alerts until notification permission is enabled in the device settings. After successful authentication, the app retrieves and registers the FCM token.

## 3. Firebase Console requirements

### 3.1 Android Firebase app

The Firebase project must contain an Android app with:

```text
Package name: com.beassuite.app
```

The downloaded file must be:

```text
android/app/google-services.json
```

The Android Firebase configuration must belong to project:

```text
crm-saas-platform-671a7
```

Register all signing fingerprints used by the app:

- Local debug SHA-1:

  ```text
  59:D8:5F:39:ED:A1:E0:9C:CB:7A:20:88:70:E9:9F:C2:64:55:05:40
  ```

- Release/upload SHA-1: obtain this from the keystore used to sign the Play Store build.

The release SHA-1 must be registered before testing Google Sign-In or Firebase services in a release build.

### 3.2 iOS Firebase app

The Firebase project must contain an iOS app with:

```text
Bundle ID: com.beassuite.app
```

The downloaded file must be:

```text
ios/Runner/GoogleService-Info.plist
```

The iOS Firebase file must contain values for the same Firebase project, including:

```text
GOOGLE_APP_ID
GCM_SENDER_ID
API_KEY
PROJECT_ID
BUNDLE_ID
```

### 3.3 APNs configuration for iOS

For iOS push delivery, configure Apple Push Notification service in Firebase:

1. Open the Apple Developer account for the app.
2. Enable Push Notifications for the App ID `com.beassuite.app`.
3. Create an APNs Authentication Key, or use an APNs certificate.
4. Upload the APNs key/certificate to Firebase Console.
5. Confirm the Apple Team ID, Key ID, and APNs environment are correct.
6. Enable Push Notifications capability for the iOS Runner target in Xcode.
7. Test on a real iPhone. iOS push delivery should not be validated only on the simulator.

## 4. Backend environment configuration

The backend must configure Firebase Admin SDK using a service-account credential.

Required settings:

```text
PUSH_NOTIFICATIONS_ENABLED=true
FIREBASE_PROJECT_ID=crm-saas-platform-671a7
FIREBASE_SERVICE_ACCOUNT_JSON=<service-account JSON or base64-encoded JSON>
```

The service-account credential must contain and validate these fields:

```text
type=service_account
project_id
private_key_id
private_key
client_email
token_uri
```

The `project_id` inside the service-account JSON must be:

```text
crm-saas-platform-671a7
```

The backend must not use the Android `google-services.json` as its service-account credential. These are different files with different purposes.

## 5. Device registration API

The Flutter app registers a device after successful CRM authentication.

### Request

```http
POST /notifications/devices/register
Authorization: Bearer <CRM_ACCESS_TOKEN>
Content-Type: application/json
```

Android request:

```json
{
  "token": "<FCM_REGISTRATION_TOKEN>",
  "platform": "android"
}
```

iOS request:

```json
{
  "token": "<FCM_REGISTRATION_TOKEN>",
  "platform": "ios"
}
```

The optional label may be included:

```json
{
  "token": "<FCM_REGISTRATION_TOKEN>",
  "platform": "android",
  "label": "Pixel 7"
}
```

### Backend validation rules

- Require a non-empty FCM token.
- Reject tokens containing whitespace.
- Accept tokens between 20 and 1024 characters after trimming.
- Accept exactly `android` and `ios` for mobile clients.
- Continue accepting `web` if the web application uses this API.
- Reject unknown platform values with HTTP `422`.
- Determine the user and organization from the authenticated access token.
- Never accept user ID or organization ID from the request body.

### Expected response

Return HTTP `201` for a new device and HTTP `200` when refreshing an existing device:

```json
{
  "id": "<DEVICE_ID>",
  "platform": "android",
  "label": "Pixel 7",
  "created_at": "2026-10-22T09:35:31.363826",
  "updated_at": "2026-10-22T09:35:31.363826",
  "last_seen_at": "2026-10-22T09:35:31.363826",
  "token_suffix": "AbC123"
}
```

Do not return the complete FCM token in the response.

### Device ownership

- A device token should belong to one user in one organization.
- Re-registering the same token for the same user should refresh `last_seen_at`.
- If the token is moved to another user in the same organization, update its owner.
- If the token belongs to another organization, return HTTP `409`.
- The client will delete its FCM token and request a new token after a `409`.
- Limit the number of active devices per user, for example 20 devices.

## 6. Device removal on logout

The Flutter app calls the delete endpoint before clearing the CRM session:

```http
DELETE /notifications/devices/<DEVICE_ID>
Authorization: Bearer <CRM_ACCESS_TOKEN>
```

Expected behavior:

- Return `204 No Content` when deleted.
- Return `404` when already deleted or not found.
- Treat repeated `404` deletion as successful cleanup.
- Do not delete a device belonging to another user or organization.

The client must unregister while the access token is still valid.

## 7. FCM token refresh

FCM tokens can change. The backend must support repeated registration of a new token.

The Flutter app:

- Calls `getToken()` after sign-in and app startup.
- Listens to `onTokenRefresh`.
- Registers every new token with the backend.
- Stores the returned backend device ID locally.

The backend should update or create the device record safely when the same token is registered concurrently.

## 8. Push message format

Every push message should include a notification title, body, and a data payload.

Example:

```json
{
  "notification": {
    "title": "New delivery assigned",
    "body": "A new delivery has been assigned to you."
  },
  "data": {
    "type": "delivery_assigned",
    "delivery_id": "12345",
    "organization_id": "67890"
  }
}
```

Data values should be strings because FCM data payloads are string maps.

The backend should define and document notification types before implementing business-event notifications.

Recommended initial types:

```text
push_test
order_created
order_status_changed
delivery_assigned
delivery_status_changed
payment_received
expense_created
leave_status_changed
announcement
```

## 9. Android push requirements

The backend must send Android messages with high priority when immediate delivery is important.

The Android app includes:

- `POST_NOTIFICATIONS` permission for Android 13+.
- A notification channel named `crm_notifications`.
- Foreground notification display.
- Background and terminated notification handling.

The user can still deny notification permission. Device registration may succeed even when permission is denied, but the operating system will not display the notification.

Test Android on:

- A physical Android device, or
- An emulator with Google Play services.

FCM will not work correctly on an emulator without Google Play services.

## 10. iOS push requirements

The current backend documentation only accepts `android` and `web`. It must be updated to accept `ios` before the iOS client can register successfully.

For iOS Firebase Admin messages, include APNs configuration. The notification must contain an APNs alert, sound, and optionally badge:

```json
{
  "apns": {
    "payload": {
      "aps": {
        "alert": {
          "title": "Beassuite",
          "body": "You have a new notification."
        },
        "sound": "default",
        "badge": 1
      }
    }
  }
}
```

The backend should not send Android-specific configuration to iOS devices.

Test iOS on a real device with:

- Push Notifications capability enabled.
- A valid Apple provisioning profile.
- APNs configured in Firebase.
- The app notification permission accepted.

## 11. Foreground, background, and terminated behavior

### Foreground

When the app is open, the operating system may not automatically display an FCM notification. The Flutter client displays it locally using `flutter_local_notifications`.

The client should show:

- Notification title.
- Notification body.
- Sound according to platform settings.
- Badge where supported.

### Background

When the app is in the background:

- Android normally displays a notification payload in the system tray.
- iOS displays the APNs notification when permission and APNs configuration are correct.
- Tapping the notification triggers the app-open handler.

### Terminated

When the app is terminated:

- The operating system displays notification payloads.
- The app reads the initial message when launched from a notification tap.

The backend must provide enough data fields for the app to navigate to the correct screen.

## 12. Notification tap navigation

The backend must define a stable data contract for notification taps.

Example:

```json
{
  "type": "delivery_assigned",
  "delivery_id": "12345"
}
```

The Flutter app can then route based on `type`:

```text
delivery_assigned       -> delivery details
order_created           -> order details
payment_received        -> payment or order details
announcement            -> notifications screen
push_test               -> notification test result
```

Do not put sensitive information such as passwords, access tokens, or complete customer records in the FCM payload.

## 13. In-app notifications

In-app notifications are different from push notifications.

### Push notification

- Delivered through Firebase Cloud Messaging.
- Can appear when the app is closed or in the background.
- Requires an FCM token and device registration.

### In-app notification

- Stored in the CRM backend database.
- Displayed inside the app's Notifications screen.
- Available even if push permission is denied.
- Should support unread/read state.

The backend should implement an in-app notification table with fields similar to:

```text
id
organization_id
recipient_user_id
type
title
body
data_json
is_read
created_at
read_at
deleted_at (optional)
```

Recommended in-app notification endpoints:

```text
GET    /notifications
GET    /notifications/unread-count
PATCH  /notifications/{notification_id}/read
POST   /notifications/read-all
DELETE /notifications/{notification_id}
```

Every endpoint must use the authenticated CRM user and organization. The client must not be able to read another user's notifications.

### In-app notification response example

```json
{
  "items": [
    {
      "id": "notification-123",
      "type": "delivery_assigned",
      "title": "New delivery assigned",
      "body": "Delivery #12345 has been assigned to you.",
      "data": {
        "delivery_id": "12345"
      },
      "is_read": false,
      "created_at": "2026-10-22T09:35:31Z",
      "read_at": null
    }
  ],
  "unread_count": 1
}
```

### In-app and push relationship

For important business events, create the in-app notification first, then send a push notification using the same notification ID and type.

Example flow:

```text
Business event occurs
        |
        v
Create in-app notification
        |
        v
Send FCM push to registered devices
        |
        v
User taps notification
        |
        v
Open the in-app notification or related CRM record
```

If push delivery fails, the in-app notification should still remain available.

## 14. Test endpoint

The test endpoint should send a notification only to the authenticated user's registered devices:

```http
POST /notifications/devices/test
Authorization: Bearer <CRM_ACCESS_TOKEN>
```

Expected response:

```json
{
  "enabled": true,
  "attempted": 1,
  "accepted": 1,
  "invalid_tokens_removed": 0,
  "transient_failures": 0,
  "detail": null
}
```

The test notification should use:

```text
Title: Test notification
Body: Push notifications are working for this device.
Data: {"type": "push_test"}
```

`accepted` means Firebase accepted the message. It does not guarantee that the user saw the notification.

## 15. Error handling

The backend must return predictable errors:

| Status | Meaning | Client behavior |
|---|---|---|
| `200` | Existing device refreshed | Save returned device ID |
| `201` | New device registered | Save returned device ID |
| `204` | Device deleted | Clear local device ID |
| `401` | Access token expired or invalid | Refresh session and retry once |
| `403` | Missing authentication | Do not retry without authentication |
| `409` | Token belongs to another organization | Delete FCM token and request a new one |
| `422` | Invalid token/platform/label | Fix client or backend validation; do not retry unchanged |
| `500` | Backend error | Log safely and retry later when appropriate |

Firebase invalid-token responses such as `UNREGISTERED`, `INVALID_ARGUMENT`, or sender-ID mismatch should remove the dead device record.

Temporary Firebase/network failures should not immediately delete a valid token.

## 16. Security requirements

- Never expose the Firebase service-account JSON to the mobile app.
- Never log complete FCM tokens.
- Never put access tokens, passwords, or private customer data into FCM payloads.
- Use the CRM bearer token for device API calls.
- Derive user and organization from the authenticated CRM token.
- Restrict notification reads and updates to the owning user.
- Validate every notification data ID on the backend and again when navigating in the app.
- Keep Firebase API keys restricted where practical; mobile Firebase API keys are identifiers, not service-account secrets.

## 17. Database requirements

The backend must apply the `push_devices` migration in every deployed environment.

The database should enforce:

- A unique or safely upsertable FCM token.
- User ownership.
- Organization ownership.
- Platform value.
- Last-seen timestamp.
- Created and updated timestamps.
- Optional device label.

For in-app notifications, index at least:

- `recipient_user_id` and `created_at`.
- `recipient_user_id` and `is_read`.
- `organization_id` and `created_at`.

## 18. End-to-end acceptance checklist

### Android

- [ ] Firebase Android app uses package `com.beassuite.app`.
- [ ] `google-services.json` belongs to project `crm-saas-platform-671a7`.
- [ ] Debug SHA-1 is registered.
- [ ] Release/upload SHA-1 is registered.
- [ ] Android app requests notification permission on Android 13+.
- [ ] Login registers an FCM token.
- [ ] Token refresh registers the new token.
- [ ] Logout removes the device registration.
- [ ] Foreground notification is displayed.
- [ ] Background notification is displayed.
- [ ] Terminated notification is displayed.
- [ ] Tapping a notification opens the expected screen.

### iOS

- [ ] Firebase iOS app uses bundle ID `com.beassuite.app`.
- [ ] `GoogleService-Info.plist` belongs to project `crm-saas-platform-671a7`.
- [ ] APNs key/certificate is uploaded to Firebase.
- [ ] Push Notifications capability is enabled in Xcode.
- [ ] Backend accepts `platform: "ios"`.
- [ ] Login registers an iOS FCM token.
- [ ] Foreground notification is displayed.
- [ ] Background notification is displayed.
- [ ] Terminated notification is displayed.
- [ ] Notification tap navigation works.

### Backend

- [ ] Firebase Admin SDK is installed.
- [ ] Service-account secret is configured securely.
- [ ] `FIREBASE_PROJECT_ID` matches the service account.
- [ ] `PUSH_NOTIFICATIONS_ENABLED=true` is set in the deployed environment.
- [ ] `push_devices` migration is applied.
- [ ] Device registration endpoint is protected by authentication.
- [ ] Device ownership is enforced.
- [ ] Invalid FCM tokens are removed.
- [ ] Test endpoint works for Android.
- [ ] Test endpoint works for iOS.
- [ ] In-app notification endpoints are implemented.
- [ ] Business events create in-app notifications.
- [ ] Business events send push notifications.

## 19. Current known limitations

- The supplied backend documentation currently supports only `android` and `web`; iOS support requires the backend changes described above.
- Push notifications are disabled until the deployment environment enables Firebase Admin and `PUSH_NOTIFICATIONS_ENABLED`.
- The test endpoint is not the same as automatic business-event notifications.
- Automatic order, delivery, expense, payment, and announcement notifications require backend event rules.
- Push delivery should be tested on real Android and iOS devices after deployment.
