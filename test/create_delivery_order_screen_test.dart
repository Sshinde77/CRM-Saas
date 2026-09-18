import 'dart:convert';

import 'package:crm_saas/models/auth_models.dart';
import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/constants/app_colors.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/admin/orders/new_admin_order_screen.dart';
import 'package:crm_saas/screens/delivery/orders/create_delivery_order_screen.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:crm_saas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _OrderProvider extends ApiProvider {
  bool warehouseFails = true;
  bool inventoryDenied = false;
  bool? requestedIsActive;
  List<Map<String, dynamic>> warehouseRows = [
    {
      'id': 'main',
      'name': 'Main Warehouse',
      'code': 'WH001',
      'is_active': true,
    },
    {'id': 'old', 'name': 'Old Warehouse', 'is_active': false},
  ];
  int productRequests = 0;
  int extraProducts = 0;
  bool includeCustomer = false;
  Map<String, dynamic>? createdOrder;
  ApiException? orderError;

  @override
  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async => includeCustomer
      ? [
          CustomerModel.fromJson({
            'id': 'customer-1',
            'name': 'Riyal Retail Store',
            'address': '12 MG Road, Bengaluru',
            'outstanding': 2500,
          }),
        ]
      : [];

  @override
  Future<Map<String, dynamic>> createOrder({
    required Map<String, dynamic> request,
  }) async {
    if (orderError != null) throw orderError!;
    createdOrder = request;
    return {'id': 'order-1'};
  }

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
  Future<List<Map<String, dynamic>>> fetchWarehouses({bool? isActive}) async {
    requestedIsActive = isActive;
    if (warehouseFails) {
      throw ApiException(
        statusCode: 403,
        message: inventoryDenied
            ? "You don't have permission to view inventory"
            : 'Forbidden',
      );
    }
    return warehouseRows;
  }
}

void main() {
  for (final salesManager in [false, true]) {
    testWidgets(
      '${salesManager ? 'Sales Manager' : 'Admin'} Create Order opens the shared live form',
      (tester) async {
        final provider = _OrderProvider()
          ..warehouseFails = false
          ..includeCustomer = true;
        addTearDown(provider.dispose);
        await tester.pumpWidget(
          ApiProviderScope(
            notifier: provider,
            child: MaterialApp(
              home: NewAdminOrderScreen(useSalesManagerShell: salesManager),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Customer *'), findsOneWidget);
        expect(find.text('Warehouse *'), findsOneWidget);
        expect(find.text('Preview Sales Order'), findsOneWidget);
        expect(provider.productRequests, 1);
        expect(find.text('Create Order is not wired yet'), findsNothing);

        await tester.tap(find.byType(DropdownButtonFormField<CustomerModel>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Riyal Retail Store').last);
        await tester.pumpAndSettle();
        final warehouseField = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(warehouseField);
        await tester.tap(warehouseField);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Main Warehouse (WH001)').last);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byTooltip('Add one Rice 10kg'));
        await tester.tap(find.byTooltip('Add one Rice 10kg'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Preview Sales Order'));
        await tester.pumpAndSettle();
        expect(find.text('Sales Order Preview'), findsOneWidget);
        await tester.tap(find.text('Create Order'));
        await tester.pumpAndSettle();
        expect(provider.createdOrder?['customer_id'], 'customer-1');
        expect(provider.createdOrder?['warehouse_id'], 'main');
        expect(tester.takeException(), isNull);
      },
    );
  }

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
        expect(
          request.url.toString(),
          'https://api.asynk.in/warehouses?is_active=true',
        );
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer test-session-token');
        return http.Response(
          '[{"id":"main","name":"Main Warehouse","is_active":true}]',
          200,
        );
      }),
    );
    addTearDown(service.close);
    final warehouses = await service.fetchWarehouses(isActive: true);
    expect(warehouses.single['name'], 'Main Warehouse');
  });

  test('API diagnostics include status without logging credentials', () async {
    final logs = <String>[];
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) logs.add(message);
    };
    addTearDown(() => debugPrint = previousDebugPrint);
    ApiService.setAccessToken('secret-token-for-test');
    addTearDown(() => ApiService.setAccessToken(null));
    final service = ApiService(
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response('{"detail":"private-login-response"}', 401);
        }
        return http.Response(
          '{"detail":"You don\'t have permission to view inventory"}',
          403,
        );
      }),
    );
    addTearDown(service.close);

    await expectLater(
      service.login(
        request: const LoginRequest(
          email: 'test@example.com',
          password: 'private-password-for-test',
        ),
      ),
      throwsA(isA<ApiException>()),
    );
    await expectLater(
      service.fetchWarehouses(isActive: true),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 403)),
    );

    final output = logs.join('\n');
    expect(
      output,
      contains('GET https://api.asynk.in/warehouses?is_active=true'),
    );
    expect(output, contains('-> 403'));
    expect(output, contains('Bearer attached'));
    expect(output, isNot(contains('secret-token-for-test')));
    expect(output, isNot(contains('private-password-for-test')));
    expect(output, isNot(contains('private-login-response')));
  });

  testWidgets('warehouse failure preserves form and products; retry recovers', (
    tester,
  ) async {
    final provider = _OrderProvider()..inventoryDenied = true;
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
      find.text(
        "Warehouses: HTTP 403: You don't have permission to view inventory",
      ),
      findsOneWidget,
    );
    expect(find.text('Retry warehouses'), findsOneWidget);
    expect(
      find.text("HTTP 403: You don't have permission to view inventory"),
      findsOneWidget,
    );
    expect(provider.requestedIsActive, isTrue);
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
    expect(tester.state<FormFieldState<String>>(warehouseField).value, isNull);
    expect(find.text('Old Warehouse'), findsNothing);
    await tester.tap(find.text('Main Warehouse (WH001)').last);
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

  testWidgets('empty active warehouse list leaves the order unavailable', (
    tester,
  ) async {
    final provider = _OrderProvider()
      ..warehouseFails = false
      ..warehouseRows = [];
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: CreateDeliveryOrderScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(provider.requestedIsActive, isTrue);
    expect(find.text('No warehouses available'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preview Sales Order'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview opens as a page and creates the selected order', (
    tester,
  ) async {
    final provider = _OrderProvider()
      ..warehouseFails = false
      ..includeCustomer = true;
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CreateDeliveryOrderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final customerField = find.byType(DropdownButtonFormField<CustomerModel>);
    await tester.tap(customerField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riyal Retail Store').last);
    await tester.pumpAndSettle();

    final warehouseField = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(warehouseField);
    await tester.tap(warehouseField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main Warehouse (WH001)').last);
    await tester.pumpAndSettle();

    final addProduct = find.byTooltip('Add one Rice 10kg');
    await tester.ensureVisible(addProduct);
    await tester.tap(addProduct);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview Sales Order'));
    await tester.pumpAndSettle();

    expect(find.text('Sales Order Preview'), findsOneWidget);
    expect(find.text('Draft Sales Order'), findsOneWidget);
    expect(find.text('Riyal Retail Store'), findsOneWidget);
    expect(find.text('Previous Balance'), findsOneWidget);
    expect(find.text('Create Order'), findsOneWidget);
    expect(
      tester.widget<AppBar>(find.byType(AppBar).last).backgroundColor,
      AppColors.deliveryDashboardHeaderEnd,
    );
    expect(
      tester
          .widget<TextField>(find.byType(TextField).last)
          .decoration
          ?.fillColor,
      AppColors.surface,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create Order'),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      AppColors.deliveryGreen,
    );
    expect(provider.createdOrder, isNull);

    await tester.ensureVisible(find.text('Create Order'));
    await tester.tap(find.text('Create Order'));
    await tester.pumpAndSettle();
    expect(provider.createdOrder?['customer_id'], 'customer-1');
    expect(provider.createdOrder?['warehouse_id'], 'main');
    expect((provider.createdOrder?['items'] as List).single['quantity'], 1);
    expect(find.text('Sales order created successfully.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stock shortage shows a clear error and lets the user edit', (
    tester,
  ) async {
    final provider = _OrderProvider()
      ..warehouseFails = false
      ..includeCustomer = true
      ..orderError = ApiException(
        statusCode: 409,
        message: jsonEncode({
          'detail': {
            'error': 'INSUFFICIENT_STOCK',
            'shortages': [
              {
                'product_id': 'rice',
                'product_name': 'Rice 10kg',
                'required_quantity': 1,
                'available_quantity': 0,
              },
            ],
          },
        }),
      );
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: CreateDeliveryOrderScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stock checked when order is created'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<CustomerModel>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riyal Retail Store').last);
    await tester.pumpAndSettle();
    final warehouseField = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(warehouseField);
    await tester.tap(warehouseField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Main Warehouse (WH001)').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Add one Rice 10kg'));
    await tester.tap(find.byTooltip('Add one Rice 10kg'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview Sales Order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Order'));
    await tester.pumpAndSettle();

    expect(
      find.text('Not enough stock in Main Warehouse to create this order.'),
      findsOneWidget,
    );
    expect(find.text('Rice 10kg: 0 available, 1 needed.'), findsOneWidget);
    expect(find.textContaining('INSUFFICIENT_STOCK'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Create Order'),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Back to Edit'));
    await tester.tap(find.text('Back to Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Sales Order Preview'), findsNothing);
    expect(find.text('Create Order'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
