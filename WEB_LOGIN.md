# Browser login setup

The Flutter web app sends `POST /auth/login` to `https://api.asynk.in` by default. Browsers send a CORS preflight before this JSON request. The API currently accepts `https://asynk.in`, but rejects `http://localhost:5000` with `400 Disallowed CORS origin`. That rejection appears in the app as a network failure even when the email and password are correct.

To run the app from another web origin, add that exact origin (scheme, host, and port) to the API server's CORS allowlist. Permit `POST`, `GET`, `OPTIONS`, and the `Content-Type` and `Authorization` request headers. This must be configured on the API server; a Flutter response header cannot grant access to a cross-origin request.

Alternatively, deploy a reverse proxy at the same origin as the web app and point the Flutter build at it:

```sh
flutter build web --dart-define=API_BASE_URL=https://your-frontend.example/api
```

The proxy should forward `/api/auth/login` and the other `/api/*` requests to `https://api.asynk.in/*` while preserving methods, headers, and bodies. Serve the web app and proxy from the same scheme, host, and port. Use HTTPS when the web app is served over HTTPS.

You can verify the API's CORS response without submitting credentials:

```sh
curl -i -X OPTIONS https://api.asynk.in/auth/login \
  -H 'Origin: http://localhost:5000' \
  -H 'Access-Control-Request-Method: POST' \
  -H 'Access-Control-Request-Headers: content-type'
```

Replace the `Origin` value with the exact address shown in the browser. The preflight needs a successful status and an `Access-Control-Allow-Origin` header matching it. After login, authenticated requests also need the API to allow the `Authorization` header.
