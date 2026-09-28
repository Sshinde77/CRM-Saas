import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/customers/create_delivery_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;

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
  testWidgets('second voice entry updates only spoken fields', (tester) async {
    final transcripts = <String>[
      'Shop name Riyal Retail Store, contact person Ramesh Kumar, mobile number 9876543210, customer type General Trade, address 23 5th Cross, city Bengaluru, pincode 560034',
      'city Mysuru',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: CreateDeliveryCustomerScreen(
          voiceTranscriptPicker: (_) async => transcripts.removeAt(0),
        ),
      ),
    );

    Future<void> useVoice() async {
      final startButton = find.widgetWithText(FilledButton, 'Start');
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }

    TextEditingController controllerAt(int index) {
      return tester.widget<TextFormField>(
        find.byType(TextFormField).at(index),
      ).controller!;
    }

    await useVoice();
    expect(controllerAt(0).text, 'Riyal Retail Store');
    expect(controllerAt(1).text, 'Ramesh Kumar');
    expect(controllerAt(2).text, '9876543210');
    expect(controllerAt(4).text, '23 5th Cross');
    expect(controllerAt(5).text, 'Bengaluru');
    expect(controllerAt(6).text, '560034');

    await useVoice();
    expect(controllerAt(0).text, 'Riyal Retail Store');
    expect(controllerAt(1).text, 'Ramesh Kumar');
    expect(controllerAt(2).text, '9876543210');
    expect(controllerAt(4).text, '23 5th Cross');
    expect(controllerAt(5).text, 'Mysuru');
    expect(controllerAt(6).text, '560034');
    expect(
      find.text(
        'We updated 1 field from what you said. Please review before submitting.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('map pin fills place name and cancellation preserves it', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateDeliveryCustomerScreen()),
    );
    final locationField = find.byType(TextFormField).last;
    await tester.ensureVisible(locationField);
    await tester.tap(find.byTooltip('Pick on Google Maps'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm location'),
          )
          .onPressed,
      isNull,
    );
    final map = tester.widget<google_maps.GoogleMap>(
      find.byType(google_maps.GoogleMap),
    );
    map.onTap?.call(const google_maps.LatLng(12.9352, 77.6245));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm location'));
    await tester.pumpAndSettle();
    final placeName = tester
        .widget<TextFormField>(locationField)
        .controller!
        .text;
    expect(placeName, isNotEmpty);
    expect(placeName, isNot(matches(RegExp(r'^-?\d+\.\d{6}, -?\d+\.\d{6}$'))));

    await tester.tap(find.byTooltip('Pick on Google Maps'));
    await tester.pumpAndSettle();
    expect(find.text(placeName), findsWidgets);
    final reopenedMap = tester.widget<google_maps.GoogleMap>(
      find.byType(google_maps.GoogleMap),
    );
    reopenedMap.onTap?.call(const google_maps.LatLng(13.0001, 77.7001));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(locationField).controller!.text,
      placeName,
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
    expect(provider.saved?.mapLatitude, 12.9352);
    expect(provider.saved?.mapLongitude, 77.6245);
    expect(provider.saved?.notes, contains('Ramesh Kumar'));
    expect(provider.saved?.notes, contains('12.9352, 77.6245'));
    expect(find.text('Open customer form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
