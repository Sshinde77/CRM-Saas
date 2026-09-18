# Browser login setup

The Flutter web app sends `POST /auth/login` to `https://api.asynk.in` by default. Browsers send a CORS preflight before this JSON request. If the API rejects the browser origin, Flutter reports it as a `ClientException` before the app can read a login status.

To run the app from another web origin, add that exact origin (scheme, host, and port) to the API server's CORS allowlist. Permit `POST`, `GET`, `OPTIONS`, and the `Content-Type` and `Authorization` request headers. This must be configured on the API server; a Flutter response header cannot grant access to a cross-origin request.

For local web development against the hosted API, the API must allow the exact Flutter web origin shown in Chrome, for example `http://localhost:52643`.

You can verify the API's CORS response without submitting credentials:

```sh
curl -i -X OPTIONS https://api.asynk.in/auth/login \
  -H 'Origin: http://localhost:52643' \
  -H 'Access-Control-Request-Method: POST' \
  -H 'Access-Control-Request-Headers: content-type'
```

The preflight needs a successful status and an `Access-Control-Allow-Origin` header matching the browser origin. After login, authenticated requests also need the API to allow the `Authorization` header.

If the hosted API cannot allow local browser origins, run the included local proxy in one terminal:

```sh
dart run tool/local_api_proxy.dart
```

Then run Flutter web in another terminal:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

The proxy answers browser preflight requests locally and forwards API requests to `https://api.asynk.in`.

You can override the API base URL explicitly for any environment:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Alternatively, deploy a reverse proxy at the same origin as the web app and point the Flutter build at it:

```sh
flutter build web --dart-define=API_BASE_URL=https://your-frontend.example/api
```

The proxy should forward `/api/auth/login` and the other `/api/*` requests to `https://api.asynk.in/*` while preserving methods, headers, and bodies. Serve the web app and proxy from the same scheme, host, and port. Use HTTPS when the web app is served over HTTPS.
