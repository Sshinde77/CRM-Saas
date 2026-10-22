# Firebase push notifications — Flutter (Android) integration

**Audience:** Flutter developer (CRM mobile app, Android).
**Purpose:** Explain the push-notification backend that is already built and exactly how the Flutter Android app must integrate with it.
**Backend commit audited:** `c9bff8e` ("Implement Firebase Cloud Messaging (FCM) support for push notifications").

The backend API contract in sections 4–5 is identical to the one in `saas_firebase_web.md`; only the client steps differ.

## Status at a glance

| Item | Status |
|---|---|
| Device registration, unregistration and test-send endpoints | **Implemented** in backend code |
| Registration, ownership, 409 conflict, invalid-token cleanup, disabled mode | **Verified by automated tests** (`tests/test_push_notifications.py`, 32 tests, Firebase mocked) |
| Push enabled in a deployed environment | **Still pending verification** — the feature is off by default |
| Real notification delivered to an Android device | **Still pending verification** — no real FCM delivery test exists |
| Automatic notifications for business events (orders, deliveries, …) | **Not implemented** — only the infrastructure and the test send exist |
| `push_devices` migration applied to the production database | **Still pending verification** |
| Flutter client integration | **Not started / needs verification** — no Flutter code was available for this audit |
| iOS | **Not supported by the backend** — it accepts only `"web"` and `"android"` |

Nothing in this document is "verified in a deployed environment".

---

## 1. Summary of backend changes

- **Firebase Admin SDK:** `firebase-admin==7.7.0` sends push notifications through Firebase Cloud Messaging (FCM) using a service account.
- **Device table:** `push_devices` stores one row per FCM registration token, owned by a CRM user and their organization.
- **Endpoints:**
  - `POST /notifications/devices/register`
  - `DELETE /notifications/devices/{device_id}`
  - `POST /notifications/devices/test`
- **Sending:** a backend service sends to a user's own registered devices. Tokens that Firebase reports as dead are removed automatically.
- **Disabled by default:** push is controlled by a feature flag. Registration works even while sending is disabled.

## 2. Firebase project and backend configuration

**Firebase project ID:** `crm-saas-platform-671a7`
- Supplied by the project owner.
- **Needs verification:** this value is not in the backend repository or the local configuration. It must be set in the deployed backend (see below), and the web app's Firebase config must belong to the same project.

**Backend settings** (deployment team only; listed so you know what state the backend is in):

| Setting | Required | Default | Meaning |
|---|---|---|---|
| `PUSH_NOTIFICATIONS_ENABLED` | yes, to send | `false` | When not `true`, nothing is sent. |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | yes, when enabled | empty | Firebase service-account key. Accepted as **raw JSON** or **base64-encoded JSON**. Private backend secret. |
| `FIREBASE_PROJECT_ID` | optional | empty | If set, must equal the key's `project_id` (expected `crm-saas-platform-671a7`). Otherwise sending reports a configuration error. |

**How credentials are used:**
- The backend only uses the explicit service-account key. It never uses Google Application Default Credentials.
- The key is validated as type `service_account`, with `project_id`, `private_key_id`, `private_key` (PEM), `client_email` and `token_uri`.

**When push is not available**, every endpoint still responds normally; only sending is skipped:

| Backend state | Register / unregister | `POST /devices/test` response |
|---|---|---|
| `PUSH_NOTIFICATIONS_ENABLED` false (default) | work normally | `200`, `enabled: false`, `detail: "Push notifications are disabled (PUSH_NOTIFICATIONS_ENABLED is not true)"` |
| Enabled, key missing or invalid | work normally | `200`, `enabled: false`, `detail` names the problem (e.g. `"FIREBASE_SERVICE_ACCOUNT_JSON is not set"`) |
| Enabled, `firebase-admin` not installed | work normally | `200`, `enabled: false`, `detail: "Push notifications are enabled but the firebase-admin package is not installed"` |

> 🔒 The **service-account JSON is a private backend credential**. It must never appear in the Flutter project, `google-services.json`, assets, or the app binary. The app needs only the Android Firebase config (`google-services.json`).

## 3. What the Android app needs from the Firebase owner

From the Firebase console, project `crm-saas-platform-671a7`:
1. **An Android app registered with the app's exact package name** (Gradle `applicationId`). The package name is not stored in the backend, and no Flutter project was available for this audit, so it **needs verification** with the Flutter team.
2. **`google-services.json`** for that Android app.
   - It contains the project ID, sender ID and Android API key, which are public app identifiers, **not** the service-account key.
   - It belongs in the Android module (typically `android/app/`).
   - If you use FlutterFire CLI (`flutterfire configure`), it also generates `firebase_options.dart`.
3. If the Firebase project has App Check or API-key restrictions, the matching SHA-1/SHA-256 signing fingerprints (**needs verification**; not required for FCM token retrieval by default).

---

## 4. Endpoint contract (shared with Web)

**Base URL:** `<CRM_API_BASE_URL>`. The deployed backend URL could not be verified from the repositories. Use the same base URL and HTTP client the Flutter app already uses for CRM APIs (**needs verification** — no Flutter code was available for this audit).

**Authentication** (all three endpoints):
- Send `Authorization: Bearer <ACCESS_TOKEN>`, the same CRM access token used for every other API call.
- The backend takes the **user and organization from that token**. No request contains a user ID or organization ID, and the client cannot choose them.
- No extra plan entitlement or role permission is required beyond being a signed-in, active user.

### 4.1 `POST /notifications/devices/register`

Registers this Android install for push, or refreshes an existing registration.

**Request body** (JSON):

| Field | Type | Required | Rules |
|---|---|---|---|
| `token` | string | **yes** | FCM registration token. 20–1024 characters after trimming; must not contain whitespace. Leading/trailing spaces are trimmed. |
| `platform` | string | **yes** | Exactly `"web"` or `"android"`. **The Flutter Android app uses `"android"`.** `"ios"` and anything else is rejected with `422`. |
| `label` | string \| null | no | ≤100 characters, e.g. `"Pixel 7"`. If omitted on a refresh, the stored label is kept. |

```http
POST <CRM_API_BASE_URL>/notifications/devices/register
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{"token": "<FCM_REGISTRATION_TOKEN>", "platform": "android", "label": "Pixel 7"}
```

**Response** — `201 Created` (new registration) or `200 OK` (token already registered in your organization, refreshed):
```json
{
  "id": "<DEVICE_ID>",
  "platform": "android",
  "label": "Pixel 7",
  "created_at": "2026-10-22T09:35:31.363826",
  "updated_at": "2026-10-22T09:35:31.363826",
  "last_seen_at": "2026-10-22T09:35:31.357826",
  "token_suffix": "AbC123"
}
```
- The full token is **never** returned; `token_suffix` is its last 6 characters.
- **Store `id`** — you need it to unregister.
- Timestamps are ISO-8601 in UTC. Whether a timezone suffix appears depends on the database (the example came from local SQLite); parse both forms.

**Behaviour:**

| Situation | Result |
|---|---|
| Token not registered yet | `201`, new row owned by the signed-in user and their organization |
| Same token already registered by **you** | `200`, same `id`; platform/label/`last_seen_at` refreshed |
| Same token registered by **another user in your organization** (shared phone) | `200`, same `id`, moved to you; the previous user no longer receives pushes on it |
| Same token registered in **a different organization** | `409` — nothing changes (see 6.3) |
| Two simultaneous requests with the same new token | handled; one creates, the other refreshes — one row results |
| You already have 20 registered devices | the new one is kept and your least-recently-seen device is removed (limit **20 per user**) |

### 4.2 `DELETE /notifications/devices/{device_id}`

Unregisters one of **your** devices (call on logout).

```http
DELETE <CRM_API_BASE_URL>/notifications/devices/<DEVICE_ID>
Authorization: Bearer <ACCESS_TOKEN>
```

| Result | When |
|---|---|
| `204 No Content` (empty body) | Removed. |
| `404 {"detail": "Device not found"}` | Not yours, another organization's, unknown, or already removed. A repeat delete also returns 404, so treat 404 as "already gone". |

### 4.3 `POST /notifications/devices/test`

Sends a test notification to **the caller's own registered devices only**. There is no request body, and it can never reach another user.

```http
POST <CRM_API_BASE_URL>/notifications/devices/test
Authorization: Bearer <ACCESS_TOKEN>
```

**Response** — always `200`:
```json
{"enabled": true, "attempted": 1, "accepted": 1, "invalid_tokens_removed": 0, "transient_failures": 0, "detail": null}
```

| Field | Meaning |
|---|---|
| `enabled` | `false` when push is disabled/misconfigured; `detail` says why and nothing was sent |
| `attempted` | your devices it tried (≤20) |
| `accepted` | messages **Firebase accepted** — not proof the device showed them |
| `invalid_tokens_removed` | tokens Firebase reported dead; those registrations were deleted |
| `transient_failures` | temporary failures (network/quota/outage); those tokens are kept |
| `detail` | `null`, `"no registered devices"`, or the configuration reason |

**What the test message contains:**
- Notification title `Test notification`, body `Push notifications are working for this device.`
- Data `{"type": "push_test"}`.
- For Android it is sent with `priority: high`.

### 4.4 Common errors (all endpoints)

| Status | Body | Cause |
|---|---|---|
| `403` | `{"detail": "Not authenticated"}` | No `Authorization` header |
| `401` | `{"detail": "Could not validate credentials"}` | Invalid or expired access token, or inactive user — refresh the session or sign in again |
| `422` | `{"detail": [{"type": "literal_error", "loc": ["body","platform"], "msg": "Input should be 'web' or 'android'", …}]}` | Validation error (wrong platform, token too short/long or containing whitespace, label too long) |
| `409` | `{"detail": "This device is registered to another organization. Unregister it there first, or request a new push token on the device."}` | Token belongs to a different organization (register only) |

## 5. How sending works (backend, for context)

- The backend builds one FCM message per device:
  - a notification (title + body);
  - an optional string-only data map;
  - `android` options with `priority: high` for Android devices (web devices get `webpush` options instead).
- Messages go out through `send_each`, in batches of up to 500.
- **Invalid tokens:** when Firebase answers *unregistered*, *sender-ID mismatch* or *invalid registration token*, that registration is deleted. Network, quota and outage errors keep the token.
- **No business events yet:** nothing in the CRM sends push automatically. The only way to trigger a push today is `POST /notifications/devices/test`. Order, delivery, expense and similar notifications are still in-app only, until product defines push rules.

---

---

## 6. Flutter integration steps

> Everything in this section is a **recommendation**. No Flutter code was available, so file names, state management and the HTTP client are up to the existing app.

### 6.1 Setup
- Add `firebase_core` and `firebase_messaging`. Add `flutter_local_notifications` if you want notifications displayed while the app is in the foreground.
- Add `google-services.json` and the Google services Gradle plugin, per the current FlutterFire docs. Then call `await Firebase.initializeApp(...)` before using messaging.
- Register a **top-level** background handler: `FirebaseMessaging.onBackgroundMessage(handler)`, where `handler` is annotated `@pragma('vm:entry-point')`.

### 6.2 Permission and token (after the user is signed in)
1. **Android 13+ (API 33):** notifications need the runtime `POST_NOTIFICATIONS` permission. Request it via `FirebaseMessaging.instance.requestPermission()`, or a permissions plugin, at a sensible moment with an explanation. On older Android it's granted at install.
2. `final token = await FirebaseMessaging.instance.getToken();`
3. Call `POST /notifications/devices/register` with `{ "token": token, "platform": "android", "label": "<device model>" }`. Persist the returned `id` (and the token) per signed-in user.
4. Registration also works while permission is denied. Notifications just won't be displayed, so prompt the user to enable them in settings if you want push.

### 6.3 Handling responses
- `201` / `200`: registered. Store `id`.
- `401`: refresh the session through the app's existing auth flow, then retry once.
- `422`: client bug (e.g. wrong `platform`, malformed token). Log it; don't retry unchanged.
- `409` (token registered to another organization):
  - Do **not** retry the same token, and don't try to work around it.
  - Recovery: `await FirebaseMessaging.instance.deleteToken();`, then `getToken()` for a **new** token, and register that.
  - Prevention: always unregister on logout (6.5).

### 6.4 Token refresh
- Listen to `FirebaseMessaging.instance.onTokenRefresh` while a user is signed in, and register each new token.
- Also re-check `getToken()` on app start or sign-in.
- Optionally `DELETE` the old device `id`; the backend also removes dead tokens when Firebase reports them.
- Re-registering an unchanged token is safe (`200`) and refreshes `last_seen_at`.

### 6.5 Logout
1. Call `DELETE /notifications/devices/{device_id}` **while the access token is still valid**. Treat `204` and `404` as done.
2. Optionally `deleteToken()`.
3. Clear the stored device `id` for that user.

### 6.6 Receiving messages
Messages carry a `notification` (title/body) plus `data`.

| App state | Behaviour |
|---|---|
| **Background / terminated** | Android shows the notification in the system tray automatically. Tapping it opens the app: `getInitialMessage()` (when terminated) or `onMessageOpenedApp` (when backgrounded). |
| **Foreground** | Android does **not** show it automatically. Handle `FirebaseMessaging.onMessage` and display it yourself (e.g. `flutter_local_notifications` with an Android notification channel) or show an in-app banner. |

- **Navigation:** route on `message.data` (e.g. `type: "push_test"`). Future business events will define their own `data` keys, which haven't been designed yet.

### 6.7 Android specifics
- The backend sends Android messages with `priority: high`.
- Create a notification channel if you display foreground notifications yourself.
- Test on a device or emulator **with Google Play services**; FCM doesn't work without them.
- Battery optimisation, "Do not disturb" and per-app notification settings can hide notifications that FCM accepted.
- **iOS:** not supported. Supporting it would need a backend change to accept a new `platform` value, plus APNs setup in Firebase.

---

## 7. Security requirements
- Never put the Firebase **service-account JSON**, private keys, or server credentials in the app or repository. `google-services.json` is the only Firebase file the app needs.
- Don't log full FCM tokens or send them to analytics.
- Always call the backend with the signed-in user's access token. There is nothing to set for user or organization.
- The test endpoint is per-user and harmless, but expose it only in a settings or debug screen.

## 8. Testing
1. With push **disabled** on the backend (today's default): register → `201`; register again → `200` (same `id`); `POST /devices/test` → `enabled: false`; logout → `DELETE` `204`, repeated → `404`.
2. **Validation:** `platform: "ios"` → `422`; token `"abc"` → `422`.
3. **Organization conflict:** sign in as an organization A user and register; without logging out, sign in on the same device as an organization B user and register the same token → `409`. Then `deleteToken()` + `getToken()` → register `201`.
4. **Once the backend is enabled with the real key:** `POST /devices/test` → `attempted ≥ 1`, `accepted ≥ 1`. Confirm the notification **appears** with the app in the foreground (via `onMessage`), in the background and when terminated, and that tapping opens the app.
5. **Token refresh:** call `deleteToken()` and confirm `onTokenRefresh` / `getToken()` registers the new token.

## 9. Acceptance checklist
- [ ] Android app registered in Firebase with the correct package name; `google-services.json` added; no service-account data in the app
- [ ] Firebase initialised; top-level background handler registered
- [ ] `POST_NOTIFICATIONS` requested on Android 13+, with handling for denied permission
- [ ] Token registered with `platform: "android"` after sign-in; device `id` stored per user
- [ ] `onTokenRefresh` re-registers; token re-checked on start/sign-in
- [ ] `DELETE` called on logout before the session is cleared; `404` treated as success
- [ ] `401`, `422` and `409` handled as in 6.3 (409 → new token)
- [ ] Foreground, background and terminated notifications display; taps open the app
- [ ] `POST /notifications/devices/test` shows a real notification on a physical device in a deployed environment

## 10. Known limitations and outstanding dependencies
- **Push is off** until the deployment team sets `FIREBASE_SERVICE_ACCOUNT_JSON`, optionally `FIREBASE_PROJECT_ID=crm-saas-platform-671a7`, and `PUSH_NOTIFICATIONS_ENABLED=true`.
- **Cloudflare runtime not verified:** image build with `firebase-admin`/`grpcio`, outbound access to `oauth2.googleapis.com` / `fcm.googleapis.com`, memory and timeouts.
- **Database:** migration `b6c7d8e9f0a1` (table `push_devices`) is in the repository; whether it has been applied to production is unverified. It was tested on SQLite only; the PostgreSQL SQL was compiled, not executed.
- **No real delivery tested:** the automated tests mock Firebase entirely.
- **No business-event pushes yet;** only the test send.
- **iOS** is not supported by the backend contract.
- `accepted` in the test response means Firebase accepted the message, not that the user saw it.
