import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/routes/app_router.dart';
import 'package:crm_saas/screens/delivery/customers/create_delivery_customer_screen.dart';
import 'package:crm_saas/screens/delivery/customers/delivery_customers_screen.dart';
import 'package:crm_saas/widgets/delivery/delivery_partner_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CustomersProvider extends ApiProvider {
  bool fail = false;
  int requests = 0;
  List<CustomerModel> customers = [
    CustomerModel.fromJson({
      'id': 'one',
      'name': 'Green Store',
      'phone': '9876543210',
    }),
    CustomerModel.fromJson({
      'id': 'two',
      'name': 'City Shop',
      'phone': '9123456780',
    }),
  ];

  @override
  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async {
    requests++;
    notifyListeners();
    if (fail) throw Exception('Unavailable');
    return customers;
  }
}

void main() {
  testWidgets(
    'sidebar opens searchable customers and refreshes after creation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = _CustomersProvider();
      addTearDown(provider.dispose);
      await tester.pumpWidget(
        ApiProviderScope(
          notifier: provider,
          child: MaterialApp(
            routes: AppRouter.routes,
            home: const Scaffold(
              drawer: DeliveryPartnerSidebar(
                currentRoute: AppRoutes.deliveryDashboard,
              ),
            ),
          ),
        ),
      );
      tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Customers'));
      await tester.pumpAndSettle();
      expect(find.byType(DeliveryCustomersScreen), findsOneWidget);
      expect(find.text('Green Store'), findsOneWidget);
      expect(provider.requests, 1);
      await tester.enterText(find.byType(TextField), '9123');
      await tester.pumpAndSettle();
      expect(find.text('City Shop'), findsOneWidget);
      expect(find.text('Green Store'), findsNothing);
      await tester.enterText(find.byType(TextField), 'unknown');
      await tester.pumpAndSettle();
      expect(find.text('No customers match your search.'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Customer'));
      await tester.pumpAndSettle();
      final created = CustomerModel.fromJson({
        'id': 'new',
        'name': 'New Store',
      });
      provider.customers = [...provider.customers, created];
      Navigator.of(
        tester.element(find.byType(CreateDeliveryCustomerScreen)),
      ).pop(created);
      await tester.pumpAndSettle();
      expect(provider.requests, 2);
      expect(find.text('New Store'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('customer load failure retries and displays an empty list', (
    tester,
  ) async {
    final provider = _CustomersProvider()..fail = true;
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: const MaterialApp(home: DeliveryCustomersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Could not load customers. Please try again.'),
      findsOneWidget,
    );
    provider.fail = false;
    provider.customers = [];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.text('No customers yet. Create your first customer.'),
      findsOneWidget,
    );
    expect(provider.requests, 2);
    expect(tester.takeException(), isNull);
  });
}
