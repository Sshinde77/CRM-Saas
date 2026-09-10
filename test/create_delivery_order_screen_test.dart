import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/orders/create_delivery_order_screen.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _OrderProvider extends ApiProvider {
  bool warehouseFails = true;
  int productRequests = 0;

  @override
  Future<List<CustomerModel>> fetchCustomers({String? search, String? category,
    bool? isActive, String? assignedSalesOfficerId}) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchProducts({String? search,
    String? categoryId, bool? isActive, String? barcode}) async {
    productRequests++;
    return [{'id': 'rice', 'name': 'Rice 10kg', 'price': 620}];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWarehouses() async {
    if (warehouseFails) {
      throw const ApiException(statusCode: 403, message: 'Forbidden');
    }
    return [{'id': 'main', 'name': 'Main Warehouse'}];
  }
}

void main() {
  testWidgets('warehouse failure preserves form and products; retry recovers', (tester) async {
    final provider = _OrderProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(ApiProviderScope(notifier: provider,
      child: const MaterialApp(home: CreateDeliveryOrderScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Customer *'), findsOneWidget);
    expect(find.text('Warehouses: Your account does not have access.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Preview Sales Order')).onPressed, isNull);

    final pageScroll = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('Rice 10kg'), 200, scrollable: pageScroll);
    expect(find.text('Rice 10kg'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Retry'), -200, scrollable: pageScroll);
    provider.warehouseFails = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Some order details are unavailable'), findsNothing);
    expect(provider.productRequests, 1);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Preview Sales Order')).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
