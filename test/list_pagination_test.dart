import 'dart:convert';

import 'package:crm_saas/models/list_pagination.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:crm_saas/widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'all API list methods send pagination and preserve server totals',
    () async {
      ApiService.setAccessToken('test-token');
      addTearDown(() => ApiService.setAccessToken(null));
      final service = ApiService(
        client: MockClient((request) async {
          expect(request.url.queryParameters['page'], '3');
          expect(request.url.queryParameters['page_size'], '25');
          if (request.url.path.contains('dashboard/orders')) {
            expect(request.url.queryParameters['offset'], '50');
            expect(request.url.queryParameters['limit'], '25');
          }
          return http.Response(
            '{"items":[],"total":100,"page":3,"page_size":25,"total_pages":4}',
            200,
          );
        }),
      );
      addTearDown(service.close);
      final loaders = <Future<dynamic> Function(ListPagination)>[
        (p) => service.fetchUsers(pagination: p),
        (p) => service.fetchCustomers(pagination: p),
        (p) => service.fetchLeads(pagination: p),
        (p) => service.fetchQuotations(pagination: p),
        (p) => service.fetchCategories(pagination: p),
        (p) => service.fetchProducts(pagination: p),
        (p) => service.fetchSuppliers(pagination: p),
        (p) => service.fetchStockBoard(pagination: p),
        (p) => service.fetchVehicleStockSessions(pagination: p),
        (p) => service.fetchDeliveryPartnerDeliveries(
          deliveryPartnerId: 'partner',
          pagination: p,
        ),
        (p) => service.fetchDeliveryCollections(pagination: p),
        (p) => service.fetchDeliveryPartnerCompanyOrders(pagination: p),
        (p) => service.fetchMyLeaves(pagination: p),
        (p) => service.fetchMyAttendance(pagination: p),
        (p) => service.fetchExpenses(pagination: p),
      ];
      for (final load in loaders) {
        final pagination = ListPagination()
          ..page = 3
          ..pageSize = 25;
        await load(pagination);
        expect(pagination.total, 100);
        expect(pagination.totalPages, 4);
      }
      final orders = await service.fetchPaginatedOrders(page: 3, limit: 25);
      expect(orders.totalItems, 100);
      expect(orders.totalPages, 4);
    },
  );

  test(
    'customers use page/page_size and the supplied response envelope',
    () async {
      ApiService.setAccessToken('test-token');
      addTearDown(() => ApiService.setAccessToken(null));
      final pagination = ListPagination()..page = 2;
      final service = ApiService(
        client: MockClient((request) async {
          expect(request.url.path, '/customers');
          expect(request.url.queryParameters['page'], '2');
          expect(request.url.queryParameters['page_size'], '10');
          return http.Response(
            jsonEncode({
              'items': [
                {'id': 'one', 'name': 'Harsh'},
                {'id': 'two', 'name': 'Shree'},
              ],
              'total': 12,
              'page': 2,
              'page_size': 10,
              'total_pages': 2,
            }),
            200,
          );
        }),
      );
      addTearDown(service.close);
      final customers = await service.fetchCustomers(pagination: pagination);
      expect(customers.map((c) => c.name), ['Harsh', 'Shree']);
      expect(pagination.total, 12);
      expect(pagination.page, 2);
      expect(pagination.totalPages, 2);
    },
  );

  test(
    'lookups keep upstream defaults and list requests remain independent',
    () async {
      ApiService.setAccessToken('test-token');
      addTearDown(() => ApiService.setAccessToken(null));
      final requests = <Map<String, String>>[];
      final service = ApiService(
        client: MockClient((request) async {
          requests.add(request.url.queryParameters);
          return http.Response(
            '{"items":[],"total":0,"page":1,"page_size":25,"total_pages":0}',
            200,
          );
        }),
      );
      addTearDown(service.close);
      await service.fetchProducts(pagination: ListPagination()..pageSize = 25);
      await service.fetchCustomers(search: 'store');
      expect(requests.first['page_size'], '25');
      expect(requests.last, {
        'search': 'store',
        'page': '1',
        'page_size': '100',
      });
    },
  );

  test(
    'legacy arrays paginate locally and clamp after records are deleted',
    () {
      final pagination = ListPagination()..page = 3;
      final records = List.generate(24, (i) => i);
      expect(pagination.read(records, records), [20, 21, 22, 23]);
      expect(pagination.totalPages, 3);
      expect(pagination.local([1, 2]), [1, 2]);
      expect(pagination.page, 1);
      expect(pagination.local(<int>[]), isEmpty);
      expect(pagination.totalPages, 1);
    },
  );

  test('stale responses cannot replace current page metadata', () {
    final pagination = ListPagination();
    final oldKey = pagination.requestKey;
    pagination.page = 2;
    pagination.read(
      {'total': 99, 'page': 1, 'page_size': 10, 'total_pages': 10},
      [1],
      requestKey: oldKey,
    );
    expect(pagination.page, 2);
    expect(pagination.total, 0);
  });

  testWidgets('footer navigates, selects page size, and fits a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pagination = ListPagination()
      ..page = 5
      ..total = 200
      ..totalPages = 20;
    var changes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ListPaginationBar(
                pagination: pagination,
                onChanged: () => setState(() {
                  changes++;
                }),
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('…'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();
    expect(pagination.page, 6);
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25').last);
    await tester.pumpAndSettle();
    expect(pagination.pageSize, 25);
    expect(pagination.page, 1);
    expect(changes, 2);
    expect(tester.takeException(), isNull);
  });
}
