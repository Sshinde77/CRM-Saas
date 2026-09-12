import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/orders/create_delivery_order_screen.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _OrderProvider extends ApiProvider {
  bool warehouseFails = true;
  int productRequests = 0;
  int extraProducts = 0;

  @override
  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    String? barcode,
  }) async {
    productRequests++;
    return [
      {'id': 'rice', 'name': 'Rice 10kg', 'price': 620},
      for (var i = 0; i < extraProducts; i++)
        {'id': 'product-$i', 'name': 'Product $i', 'price': 100},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWarehouses() async {
    if (warehouseFails) {
      throw const ApiException(statusCode: 403, message: 'Forbidden');
    }
    return [
      {'id': 'main', 'name': 'Main Warehouse'},
    ];
  }
}

void main() {
  testWidgets('products scroll independently of the order form', (
    tester,
  ) async {
    final provider = _OrderProvider()
      ..warehouseFails = false
      ..extraProducts = 11;
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: CreateDeliveryOrderScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final products = find.byKey(const ValueKey('order-product-list'));
    await tester.scrollUntilVisible(
      products,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final outer = tester.state<ScrollableState>(find.byType(Scrollable).first);
    final inner = tester.state<ScrollableState>(
      find.descendant(of: products, matching: find.byType(Scrollable)),
    );
    final outerOffset = outer.position.pixels;
    await tester.drag(products, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(inner.position.pixels, greaterThan(0));
    expect(outer.position.pixels, outerOffset);
    expect(tester.takeException(), isNull);
  });

  test('warehouses request uses the authenticated GET endpoint', () async {
    ApiService.setAccessToken('test-session-token');
    addTearDown(() => ApiService.setAccessToken(null));
    final service = ApiService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://api.asynk.in/warehouses');
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer test-session-token');
        return http.Response('[{"id":"main","name":"Main Warehouse"}]', 200);
      }),
    );
    addTearDown(service.close);
    final warehouses = await service.fetchWarehouses();
    expect(warehouses.single['name'], 'Main Warehouse');
  });

  testWidgets('warehouse failure preserves form and products; retry recovers', (
    tester,
  ) async {
    final provider = _OrderProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: CreateDeliveryOrderScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Customer *'), findsOneWidget);
    expect(
      find.text('Warehouses: Your account does not have access.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preview Sales Order'),
          )
          .onPressed,
      isNull,
    );

    final pageScroll = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Rice 10kg'),
      200,
      scrollable: pageScroll,
    );
    expect(find.text('Rice 10kg'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Retry'),
      -200,
      scrollable: pageScroll,
    );
    provider.warehouseFails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Some order details are unavailable'), findsNothing);
    expect(provider.productRequests, 1);
    final warehouseField = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(warehouseField);
    await tester.tap(warehouseField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main Warehouse').last);
    await tester.pumpAndSettle();
    expect(tester.state<FormFieldState<String>>(warehouseField).value, 'main');
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preview Sales Order'),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
