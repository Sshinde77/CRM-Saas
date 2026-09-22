import 'dart:convert';

import 'package:crm_saas/models/auth_models.dart';
import 'package:crm_saas/models/delivery_detail_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/deliveries/assigned_deliveries_screen.dart';
import 'package:crm_saas/screens/delivery/deliveries/delivery_detail_screen.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _DeliveryWorkflowProvider extends ApiProvider {
  String internalStatus = 'accepted';
  final actions = <String>[];
  Map<String, dynamic>? confirmedPayload;

  @override
  Future<AuthMeResponse?> fetchAuthMe({bool force = false}) async =>
      const AuthMeResponse(
        user: CurrentUserProfile(
          id: 'partner-1',
          name: 'Delivery Partner',
          role: 'delivery_partner',
        ),
        organization: null,
        fullAccess: false,
        dataScope: null,
        permissions: {},
      );

  @override
  Future<List<Map<String, dynamic>>> fetchDeliveryPartnerDeliveries({
    required String deliveryPartnerId,
  }) async => [
    {
      'id': 'delivery-1',
      'order_number': 'SO-2026-1033',
      'customer_name': 'R1',
      'status': internalStatus == 'in_transit' ? 'in_transit' : 'accepted',
      'internal_status': internalStatus,
    },
  ];

  @override
  Future<DeliveryDetail> fetchDeliveryById(String deliveryId) async =>
      DeliveryDetail.fromJson({
        'id': deliveryId,
        'status': internalStatus,
        'items': [
          {
            'id': 'line-1',
            'product_name': 'Rice 10kg',
            'planned_quantity': 2,
            'picked_quantity': 0,
            'loaded_quantity': internalStatus == 'in_transit' ? 2 : 0,
          },
        ],
      });

  @override
  Future<Map<String, dynamic>> pickDelivery({
    required String deliveryId,
    required List<Map<String, dynamic>> items,
  }) async {
    expect(items.single, {'delivery_item_id': 'line-1', 'picked_quantity': 2});
    actions.add('pick');
    return {'id': deliveryId};
  }

  @override
  Future<Map<String, dynamic>> markDeliveryReady(String deliveryId) async {
    actions.add('ready');
    internalStatus = 'ready';
    return {'id': deliveryId};
  }

  @override
  Future<Map<String, dynamic>> loadDelivery(String deliveryId) async {
    actions.add('load');
    internalStatus = 'loaded';
    return {'id': deliveryId};
  }

  @override
  Future<Map<String, dynamic>> dispatchDelivery(String deliveryId) async {
    actions.add('dispatch');
    internalStatus = 'in_transit';
    return {'id': deliveryId};
  }

  @override
  Future<Map<String, dynamic>> confirmDelivery({
    required String deliveryId,
    required Map<String, dynamic> payload,
  }) async {
    confirmedPayload = payload;
    internalStatus = 'delivered';
    return {'id': deliveryId};
  }
}

void main() {
  test('delivery stages use their documented API routes', () async {
    ApiService.setAccessToken('test-token');
    addTearDown(() => ApiService.setAccessToken(null));
    final requests = <String>[];
    final service = ApiService(
      client: MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        if (request.url.path.endsWith('/pick')) {
          expect(jsonDecode(request.body), {
            'items': [
              {'delivery_item_id': 'line-1', 'picked_quantity': 2},
            ],
          });
        }
        if (request.method == 'PATCH') {
          expect(jsonDecode(request.body), {'status': 'in_transit'});
        }
        return http.Response('{"id":"delivery-1"}', 200);
      }),
    );
    addTearDown(service.close);
    await service.pickDelivery(
      deliveryId: 'delivery-1',
      items: [
        {'delivery_item_id': 'line-1', 'picked_quantity': 2},
      ],
    );
    await service.markDeliveryReady('delivery-1');
    await service.loadDelivery('delivery-1');
    await service.dispatchDelivery('delivery-1');
    expect(requests, [
      'POST /deliveries/delivery-1/pick',
      'POST /deliveries/delivery-1/ready',
      'POST /deliveries/delivery-1/load',
      'PATCH /deliveries/by-id/delivery-1',
    ]);
  });

  testWidgets('Delivery actions follow pick, ready, load, then dispatch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _DeliveryWorkflowProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: AssignedDeliveriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Prepare Delivery'));
    await tester.tap(find.text('Prepare Delivery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(provider.actions, ['pick', 'ready']);

    await tester.ensureVisible(find.text('Load Vehicle'));
    await tester.tap(find.text('Load Vehicle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(provider.actions, ['pick', 'ready', 'load']);

    await tester.ensureVisible(find.text('Start Delivery'));
    await tester.tap(find.text('Start Delivery'));
    await tester.pumpAndSettle();
    expect(provider.actions, ['pick', 'ready', 'load', 'dispatch']);
    expect(find.text('Mark Delivered'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirming delivery sends item quantities to the outcome API', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _DeliveryWorkflowProvider()..internalStatus = 'in_transit';
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(
          home: DeliveryDetailScreen(deliveryId: 'delivery-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirm Delivery'));
    await tester.tap(find.text('Confirm Delivery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(provider.confirmedPayload, {
      'items': [
        {'delivery_item_id': 'line-1', 'delivered_quantity': 2},
      ],
    });
    expect(tester.takeException(), isNull);
  });
}
