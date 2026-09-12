import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/customers/create_delivery_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

class _CustomerProvider extends ApiProvider {
  CustomerCreateRequest? saved;
  @override
  Future<CustomerModel> createCustomer({
    required CustomerCreateRequest request,
  }) async {
    saved = request;
    return CustomerModel.fromJson({'id': 'new-customer', 'name': request.name});
  }
}

void main() {
  testWidgets('map pin fills coordinates and cancellation preserves them', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateDeliveryCustomerScreen()),
    );
    final locationField = find.byType(TextFormField).last;
    await tester.ensureVisible(locationField);
    await tester.tap(find.byTooltip('Pin location on map'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm location'),
          )
          .onPressed,
      isNull,
    );
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm location'));
    await tester.pumpAndSettle();
    final coordinates = tester
        .widget<TextFormField>(locationField)
        .controller!
        .text;
    expect(coordinates, matches(RegExp(r'^-?\d+\.\d{6}, -?\d+\.\d{6}$')));

    await tester.tap(find.byTooltip('Pin location on map'));
    await tester.pumpAndSettle();
    expect(find.text(coordinates), findsOneWidget);
    await tester.tapAt(
      tester.getCenter(find.byType(FlutterMap)) + const Offset(30, 30),
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(locationField).controller!.text,
      coordinates,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates required fields and saves customer details', (
    tester,
  ) async {
    final provider = _CustomerProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateDeliveryCustomerScreen(),
                  ),
                ),
                child: const Text('Open customer form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open customer form'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CREATE CUSTOMER'));
    await tester.tap(find.text('CREATE CUSTOMER'));
    await tester.pumpAndSettle();
    expect(provider.saved, isNull);

    final values = [
      'Riyal Retail Store',
      'Ramesh Kumar',
      '9876543210',
      '',
      '23, 5th Cross',
      'Bengaluru',
      '560034',
      '12.9352, 77.6245',
    ];
    for (var i = 0; i < values.length; i++) {
      final field = find.byType(TextFormField).at(i);
      await tester.ensureVisible(field);
      await tester.enterText(field, values[i]);
    }
    final type = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(type);
    await tester.tap(type);
    await tester.pumpAndSettle();
    await tester.tap(find.text('General Trade').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CREATE CUSTOMER'));
    await tester.tap(find.text('CREATE CUSTOMER'));
    await tester.pumpAndSettle();
    expect(provider.saved?.name, 'Riyal Retail Store');
    expect(provider.saved?.category, 'General Trade');
    expect(provider.saved?.deliveryAddress, contains('Bengaluru - 560034'));
    expect(provider.saved?.notes, contains('Ramesh Kumar'));
    expect(provider.saved?.notes, contains('12.9352, 77.6245'));
    expect(find.text('Open customer form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
