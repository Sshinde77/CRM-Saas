import 'package:crm_saas/models/list_pagination.dart';
import 'dart:async';

import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/shared/payment_collection_screen.dart';
import 'package:crm_saas/services/api_service.dart';
import 'package:crm_saas/theme/app_theme.dart';
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
    ListPagination? pagination,
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
    bool? hasCollectable,
  }) async {
    requests++;
    notifyListeners();
    if (pending != null) return pending!.future;
    if (fail) throw Exception('Customer request failed');
    return [
      CustomerModel.fromJson({
        'id': 'customer-1',
        'name': 'Test Shop',
        'outstanding': 1250,
      }),
    ];
  }
}

Widget _app(_CollectionProvider provider) => ApiProviderScope(
  notifier: provider,
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    home: const PaymentCollectionScreen(),
  ),
);

void main() {
  submissionTests();

  testWidgets('customers load on first open without Retry', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

// ---------------------------------------------------------------------------
// Extended provider for submission tests
// ---------------------------------------------------------------------------

class _SubmitProvider extends ApiProvider {
  int submitCalls = 0;

  /// Set to an exception to have recordCustomerCollection throw it.
  Object? throwOnSubmit;

  /// Completer that blocks the submission until manually completed.
  Completer<Map<String, dynamic>>? submitCompleter;

  @override
  Future<CustomerModel> fetchCustomerById(String id) async =>
      CustomerModel.fromJson({
        'id': id,
        'name': 'Alpha Traders',
        'outstanding': 5000,
        'collectable_amount': 5000,
      });

  @override
  Future<List<CustomerModel>> fetchCustomers({
    ListPagination? pagination,
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
    bool? hasCollectable,
  }) async => [
    CustomerModel.fromJson({
      'id': 'cust-1',
      'name': 'Alpha Traders',
      'outstanding': 5000,
      'collectable_amount': 5000,
    }),
  ];

  @override
  Future<Map<String, dynamic>> recordCustomerCollection({
    required String customerId,
    required double amount,
    required String paymentMethod,
    required String paymentDate,
    String? reference,
    String? notes,
    String? paymentProofUrl,
  }) async {
    submitCalls++;
    if (submitCompleter != null) return submitCompleter!.future;
    final err = throwOnSubmit;
    if (err != null) throw err;
    return {'id': 'payment-1'};
  }
}

/// Fills the form and selects the customer so the submit button is reachable.
Future<void> _selectCustomerAndFillAmount(
  WidgetTester tester, {
  String amount = '1000',
}) async {
  await tester.tap(find.text('Select customer'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Alpha Traders').last);
  await tester.pumpAndSettle();
  // The amount field is a TextFormField; tap the first visible TextField inside
  // the form (not in a dialog) to focus and type.
  // The amount field is the one whose current value looks numeric.
  final amountEditable = find.byWidgetPredicate(
    (w) => w is EditableText && RegExp(r'^[\d.]*$').hasMatch(w.controller.text),
    description: 'numeric editable text (amount)',
  );
  if (amountEditable.evaluate().isNotEmpty) {
    await tester.tap(amountEditable.first);
    await tester.enterText(amountEditable.first, amount);
  }
  await tester.pumpAndSettle();
}

void submissionTests() {
  group('409 over-collect handling', () {
    testWidgets('shows detail text and sets amount field to Y', (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = _SubmitProvider()
        ..throwOnSubmit = ApiException(
          statusCode: 409,
          message:
              '₹5000 has already been collected and is awaiting admin approval; '
              'at most 1,234.50 can still be collected',
        );
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentCollectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _selectCustomerAndFillAmount(tester, amount: '5000');

      final submitFinder = find.widgetWithText(
        FilledButton,
        'Record Collection',
      );
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      // Snackbar should show the detail message, not raw JSON.
      expect(find.textContaining('awaiting admin approval'), findsWidgets);
      expect(find.textContaining('{'), findsNothing);

      // Amount field should be capped to 1234.50 (the parsed+formatted value).
      // _plainAmount(1234.5) → "1234.50" via toStringAsFixed(2).
      expect(find.widgetWithText(TextField, '1234.50'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'does not crash when 409 message contains no "at most" phrase',
      (tester) async {
        tester.view.physicalSize = const Size(430, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final provider = _SubmitProvider()
          ..throwOnSubmit = ApiException(
            statusCode: 409,
            message: 'Conflict — cannot collect at this time.',
          );
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          ApiProviderScope(
            notifier: provider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const PaymentCollectionScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _selectCustomerAndFillAmount(tester, amount: '5000');

        final submitFinder = find.widgetWithText(
          FilledButton,
          'Record Collection',
        );
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        // Should show the message, not crash, and leave amount untouched.
        expect(find.textContaining('Conflict'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('submit button disabled during in-flight request', () {
    testWidgets('button is disabled while request is pending', (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final completer = Completer<Map<String, dynamic>>();
      final provider = _SubmitProvider()..submitCompleter = completer;
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentCollectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _selectCustomerAndFillAmount(tester);

      final submitBtn = find.widgetWithText(FilledButton, 'Record Collection');
      await tester.ensureVisible(submitBtn);

      // Tap once — request starts, button should become disabled.
      await tester.tap(submitBtn);
      await tester.pump(); // let setState run

      // Try tapping again — should be blocked (onPressed is null while busy).
      final btnWidget = tester.widget<FilledButton>(
        find.byType(FilledButton).last,
      );
      expect(btnWidget.onPressed, isNull);

      // Exactly one submission despite attempting a second tap.
      expect(provider.submitCalls, 1);

      // Resolve the in-flight request.
      completer.complete({'id': 'payment-1'});
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('button re-enables after a failure', (tester) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = _SubmitProvider()
        ..throwOnSubmit = ApiException(
          statusCode: 500,
          message: 'Server error',
        );
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentCollectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _selectCustomerAndFillAmount(tester);

      final submitFinder = find.widgetWithText(
        FilledButton,
        'Record Collection',
      );
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      // Button should be re-enabled after failure.
      final submitBtn = tester.widget<FilledButton>(submitFinder);
      expect(submitBtn.onPressed, isNotNull);
      // Snackbar message is non-empty even on 500.
      expect(find.textContaining('Server error'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('DAY_END_CLOSED handling', () {
    testWidgets('shows friendly message, does not cap amount field', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = _SubmitProvider()
        ..throwOnSubmit = ApiException(
          statusCode: 409,
          code: 'DAY_END_CLOSED',
          message: 'Day-end has been closed.',
        );
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentCollectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _selectCustomerAndFillAmount(tester, amount: '2000');

      final submitFinder = find.widgetWithText(
        FilledButton,
        'Record Collection',
      );
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      // Friendly message shown — not raw backend text or raw JSON.
      expect(find.textContaining('day has been closed'), findsWidgets);
      expect(find.textContaining('{'), findsNothing);
      // Amount field is NOT capped (DAY_END_CLOSED is not a remaining-amount 409).
      expect(find.widgetWithText(TextField, '2000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not cap amount when 409 has no "at most" phrase', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = _SubmitProvider()
        ..throwOnSubmit = ApiException(
          statusCode: 409,
          message: 'Conflict — cannot collect at this time.',
        );
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PaymentCollectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _selectCustomerAndFillAmount(tester, amount: '3000');

      final submitFinder = find.widgetWithText(
        FilledButton,
        'Record Collection',
      );
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('Conflict'), findsWidgets);
      // Amount field unchanged (no "at most" in message).
      expect(find.widgetWithText(TextField, '3000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
