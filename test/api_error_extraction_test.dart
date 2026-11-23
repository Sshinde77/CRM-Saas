/// Tests for ApiService error-body extraction and dispatchDelivery idempotency.
///
/// Coverage:
///   - error body shapes: detail string, 422 list, HTML/502, empty body
///   - dispatchDelivery: 200 no-op succeeds; 4xx/5xx throws with message
library;

import 'dart:convert';
import 'package:crm_saas/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Returns a service that always responds with [response] to any request.
ApiService makeService(http.Response response) {
  return ApiService(client: MockClient((_) async => response));
}

/// Calls a simple authenticated GET (fetchCurrentUserProfile) so the error
/// path in _send is exercised regardless of the specific method under test.
Future<void> triggerError(ApiService service) =>
    service.fetchCurrentUserProfile();

void main() {
  setUp(() => ApiService.setAccessToken('test-token'));
  tearDown(() => ApiService.setAccessToken(null));

  // ---------------------------------------------------------------------------
  // Error-body extraction
  // ---------------------------------------------------------------------------
  group('error body extraction', () {
    test('{"detail":"…"} string is surfaced verbatim', () async {
      final service = makeService(
        http.Response(
          jsonEncode({'detail': 'X has already been collected'}),
          409,
        ),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 409);
        expect(e.message, 'X has already been collected');
        expect(e.message, isNot(startsWith('{')));
      }
    });

    test('{"message":"…"} string is surfaced verbatim', () async {
      final service = makeService(
        http.Response(jsonEncode({'message': 'Custom message text'}), 400),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Custom message text');
        expect(e.message, isNot(startsWith('{')));
      }
    });

    test('422 list of error objects is joined and not raw JSON', () async {
      final service = makeService(
        http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'field required'},
              {'msg': 'value is not a valid number'},
            ],
          }),
          422,
        ),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 422);
        expect(e.message, contains('field required'));
        expect(e.message, contains('value is not a valid number'));
        expect(e.message, isNot(startsWith('{')));
        expect(e.message, isNot(startsWith('[')));
      }
    });

    test('HTML 502 gateway page does not leak raw HTML', () async {
      final service = makeService(
        http.Response('<html><body>Bad Gateway</body></html>', 502),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 502);
        expect(e.message, isNot(contains('<html')));
        expect(e.message, isNot(startsWith('<')));
        expect(e.message, isNotEmpty);
      }
    });

    test('empty body falls back to code-based message', () async {
      final service = makeService(http.Response('', 500));
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 500);
        expect(e.message, isNotEmpty);
        expect(e.message, isNot(startsWith('{')));
      }
    });

    test('short plain-text body is surfaced as-is', () async {
      final service = makeService(http.Response('Quota exceeded', 429));
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.message, 'Quota exceeded');
      }
    });

    test('JSON body without known keys falls back to code-based message',
        () async {
      final service = makeService(
        http.Response(jsonEncode({'status': 'error', 'code': 42}), 400),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        // No detail/message/error key → code-based fallback, never raw JSON
        expect(e.message, isNot(startsWith('{')));
        expect(e.message, isNotEmpty);
      }
    });

    test('DAY_END_CLOSED code is extracted from 409 JSON body', () async {
      final service = makeService(
        http.Response(
          jsonEncode({
            'code': 'DAY_END_CLOSED',
            'detail': 'Day-end has been closed.',
          }),
          409,
        ),
      );
      addTearDown(service.close);
      try {
        await triggerError(service);
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 409);
        expect(e.code, 'DAY_END_CLOSED');
        expect(e.message, 'Day-end has been closed.');
        expect(e.message, isNot(startsWith('{')));
      }
    });

    test('non-empty message is always present on any 4xx/5xx', () async {
      for (final code in [400, 401, 403, 404, 409, 422, 500, 502, 503]) {
        final service = makeService(http.Response('', code));
        addTearDown(service.close);
        try {
          await triggerError(service);
          fail('expected ApiException for $code');
        } on ApiException catch (e) {
          expect(e.message, isNotEmpty,
              reason: 'message must not be blank for status $code');
          expect(e.message, isNot(startsWith('{')),
              reason: 'message must not be raw JSON for status $code');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // dispatchDelivery idempotency
  // ---------------------------------------------------------------------------
  group('dispatchDelivery', () {
    test('200 with full delivery body returns parsed map', () async {
      final service = makeService(
        http.Response(
          jsonEncode({'id': 'delivery-1', 'status': 'in_transit'}),
          200,
        ),
      );
      addTearDown(service.close);
      final result = await service.dispatchDelivery('delivery-1');
      expect(result['id'], 'delivery-1');
    });

    test('200 idempotent re-send with minimal body returns map without throw',
        () async {
      final service = makeService(http.Response('{}', 200));
      addTearDown(service.close);
      final result = await service.dispatchDelivery('delivery-1');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('200 with unparseable body returns empty map without throwing',
        () async {
      final service = makeService(http.Response('OK', 200));
      addTearDown(service.close);
      final result = await service.dispatchDelivery('delivery-1');
      expect(result, isEmpty);
    });

    test('404 throws ApiException with detail from body', () async {
      final service = makeService(
        http.Response(jsonEncode({'detail': 'Delivery not found'}), 404),
      );
      addTearDown(service.close);
      try {
        await service.dispatchDelivery('delivery-1');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 404);
        expect(e.message, 'Delivery not found');
      }
    });

    test('500 throws ApiException (never swallowed by body-parse catch)',
        () async {
      final service = makeService(http.Response('', 500));
      addTearDown(service.close);
      await expectLater(
        () => service.dispatchDelivery('delivery-1'),
        throwsA(isA<ApiException>()),
      );
    });

    test('403 throws ApiException (never swallowed)', () async {
      final service = makeService(
        http.Response(jsonEncode({'detail': 'Forbidden'}), 403),
      );
      addTearDown(service.close);
      try {
        await service.dispatchDelivery('delivery-1');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 403);
        expect(e.message, 'Forbidden');
      }
    });
  });
}
