import 'dart:async';

import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/payment_collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CollectionProvider extends ApiProvider {
  int requests = 0;
  bool fail = false;
  Completer<List<CustomerModel>>? pending;
  String? detailCustomerId;

  @override
  Future<CustomerModel> fetchCustomerById(String id) async {
    detailCustomerId = id;
    return CustomerModel.fromJson({
      'id': id,
      'name': 'Test Shop',
      'outstanding': 1250,
    });
  }

  @override
  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async {
    requests++;
    notifyListeners();
    if (pending != null) return pending!.future;
    if (fail) throw Exception('Customer request failed');
    return [
      CustomerModel.fromJson({'id': 'customer-1', 'name': 'Test Shop'}),
    ];
  }
}

Widget _app(_CollectionProvider provider) => ApiProviderScope(
  notifier: provider,
  child: const MaterialApp(home: PaymentCollectionScreen()),
);

void main() {
  testWidgets('customers load on first open without Retry', (tester) async {
    final provider = _CollectionProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();

    expect(provider.requests, 1);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Select customer'), findsOneWidget);
    await tester.tap(find.text('Select customer'));
    await tester.pumpAndSettle();
    expect(find.text('Search Customer'), findsOneWidget);
    expect(find.text('Create Customer'), findsOneWidget);
    final search = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(search, 'missing');
    await tester.pumpAndSettle();
    expect(
      find.text('No customers found. Try another search.'),
      findsOneWidget,
    );
    await tester.enterText(search, 'Test');
    await tester.pumpAndSettle();
    expect(find.text('Test Shop').last, findsOneWidget);
    await tester.tap(find.text('Test Shop').last);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Test Shop'), findsOneWidget);
    expect(provider.detailCustomerId, 'customer-1');
    expect(find.widgetWithText(TextFormField, '1250'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed customer request can still be retried', (tester) async {
    final provider = _CollectionProvider()..fail = true;
    addTearDown(provider.dispose);
    await tester.pumpWidget(_app(provider));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load customers. Please try again.'),
      findsOneWidget,
    );
    expect(provider.requests, 1);
    provider.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(provider.requests, 2);
    expect(find.text('Select customer'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving while customers load handles a late failure', (
    tester,
  ) async {
    final pending = Completer<List<CustomerModel>>();
    final provider = _CollectionProvider()..pending = pending;
    addTearDown(provider.dispose);
    await tester.pumpWidget(_app(provider));
    expect(provider.requests, 1);
    await tester.pumpWidget(const SizedBox());
    pending.completeError(Exception('Request failed after leaving'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
