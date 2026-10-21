import 'dart:convert';

import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiService.clearAccessToken();
  });
  tearDown(ApiService.clearAccessToken);

  test(
    'exchanges credential for a persisted CRM session and restores it',
    () async {
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          expect(request.url.path, '/auth/google');
          expect(request.method, 'POST');
          expect(jsonDecode(request.body), {'credential': 'google-identity'});
          expect(request.headers.containsKey('Authorization'), isFalse);
          return http.Response(
            jsonEncode({
              'access_token': 'crm-session',
              'refresh_token': 'crm-refresh',
              'user': {'id': 'staff-1', 'role': 'admin'},
            }),
            200,
          );
        }),
      );
      addTearDown(service.close);
      final session = await service.loginWithGoogle(idToken: 'google-identity');
      expect(session.accessToken, 'crm-session');
      expect(session.refreshToken, 'crm-refresh');
      expect(ApiService.accessToken, 'crm-session');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth.access_token'), 'crm-session');
      expect(prefs.getString('auth.refresh_token'), 'crm-refresh');
      ApiService.clearAccessToken();
      expect(await ApiService.restorePersistedAuthState(), isTrue);
      expect(ApiService.accessToken, 'crm-session');
      expect(ApiService.refreshToken, 'crm-refresh');
    },
  );

  test('does not authenticate from a Google profile alone', () async {
    final service = ApiService(
      client: MockClient(
        (_) async =>
            http.Response('{"user":{"email":"staff@example.test"}}', 200),
      ),
    );
    addTearDown(service.close);
    await expectLater(
      service.loginWithGoogle(idToken: 'google-identity'),
      throwsA(isA<ApiException>()),
    );
    expect(ApiService.accessToken, isNull);
  });

  test('empty credentials do not send a request', () async {
    final service = ApiService(
      client: MockClient((_) async {
        fail('Empty credentials must not send a request.');
      }),
    );
    addTearDown(service.close);
    await expectLater(
      service.loginWithGoogle(idToken: '  '),
      throwsA(isA<ApiException>()),
    );
  });

  for (final status in [200, 400, 404]) {
    test(
      'registration_required ($status) does not establish a session',
      () async {
        final service = ApiService(
          client: MockClient(
            (_) async =>
                http.Response('{"status":"registration_required"}', status),
          ),
        );
        addTearDown(service.close);
        final provider = ApiProvider(apiService: service);
        addTearDown(provider.dispose);
        await expectLater(
          provider.loginWithGoogle(idToken: 'google-identity'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.code, 'code', 'registration_required')
                .having((e) => e.message, 'message', contains('registration')),
          ),
        );
        expect(provider.isAuthenticated, isFalse);
        expect(ApiService.accessToken, isNull);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth.access_token'), isNull);
        expect(prefs.getString('auth.refresh_token'), isNull);
      },
    );
  }

  for (final entry in {
    409: 'conflicts',
    403: 'deactivated',
    503: 'unavailable',
  }.entries) {
    test(
      'HTTP ${entry.key} has actionable feedback without storing tokens',
      () async {
        var requests = 0;
        final service = ApiService(
          client: MockClient((_) async {
            requests++;
            return http.Response('{"detail":"Backend rejection"}', entry.key);
          }),
        );
        addTearDown(service.close);
        await expectLater(
          service.loginWithGoogle(idToken: 'google-identity'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'status', entry.key)
                .having((e) => e.message, 'message', contains(entry.value)),
          ),
        );
        expect(requests, 1);
        expect(ApiService.accessToken, isNull);
        expect(ApiService.refreshToken, isNull);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth.access_token'), isNull);
      },
    );
  }

  test(
    'Google login uses existing profile and refresh flow with persisted rotation',
    () async {
      var profileRequests = 0;
      final paths = <String>[];
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          paths.add(request.url.path);
          switch (request.url.path) {
            case '/auth/google':
              return http.Response(
                '{"access_token":"expired","refresh_token":"refresh-1"}',
                200,
              );
            case '/auth/me':
              profileRequests++;
              expect(
                request.headers['Authorization'],
                profileRequests == 1 ? 'Bearer expired' : 'Bearer renewed',
              );
              if (profileRequests == 1) {
                return http.Response('{"detail":"Expired"}', 401);
              }
              return http.Response(
                '{"user":{"id":"staff-1","name":"Staff","role":"admin"},"full_access":true}',
                200,
              );
            case '/auth/refresh':
              expect(jsonDecode(request.body), {'refresh_token': 'refresh-1'});
              expect(request.headers.containsKey('Authorization'), isFalse);
              return http.Response(
                '{"access_token":"renewed","refresh_token":"refresh-2"}',
                200,
              );
            default:
              fail('Unexpected request: ${request.url.path}');
          }
        }),
      );
      addTearDown(service.close);
      final provider = ApiProvider(apiService: service);
      addTearDown(provider.dispose);
      await provider.loginWithGoogle(idToken: 'google-identity');
      expect(provider.isAuthenticated, isTrue);
      expect(provider.currentUser?.id, 'staff-1');
      expect(provider.authMe?.fullAccess, isTrue);
      expect(paths, ['/auth/google', '/auth/me', '/auth/refresh', '/auth/me']);
      ApiService.clearAccessToken();
      expect(await ApiService.restorePersistedAuthState(), isTrue);
      expect(ApiService.accessToken, 'renewed');
      expect(ApiService.refreshToken, 'refresh-2');
    },
  );
}
