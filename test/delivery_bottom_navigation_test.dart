import 'package:crm_saas/routes/app_router.dart';
import 'package:crm_saas/models/customer_model.dart';
import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/screens/delivery/orders/create_delivery_order_screen.dart';
import 'package:crm_saas/widgets/delivery/delivery_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ActionProvider extends ApiProvider {
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
  }) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchWarehouses({bool? isActive}) async =>
      [];
}

void main() {
  for (final action in [
    'Create Orders',
    'Create Customer',
    'Create Collection',
  ]) {
    for (final success in [true, false]) {
      testWidgets(
        '$action ${success ? 'success redirects' : 'cancel returns'}',
        (tester) async {
          final provider = _ActionProvider();
          addTearDown(provider.dispose);
          final navigator = GlobalKey<NavigatorState>();
          await tester.pumpWidget(
            ApiProviderScope(
              notifier: provider,
              child: MaterialApp(
                navigatorKey: navigator,
                routes: {
                  AppRoutes.deliveryDeliveries: (_) =>
                      const Scaffold(body: Text('Orders destination')),
                  AppRoutes.deliveryCollections: (_) =>
                      const Scaffold(body: Text('Collections destination')),
                  AppRoutes.deliveryCustomers: (_) =>
                      const Scaffold(body: Text('Customers destination')),
                },
                home: const Scaffold(
                  body: Text('Original page'),
                  bottomNavigationBar: DeliveryBottomNavigation(
                    currentIndex: 0,
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byTooltip('Create actions'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(action));
          await tester.pumpAndSettle();
          if (!success) {
            navigator.currentState!.pop();
          } else if (action == 'Create Orders') {
            tester
                .widget<CreateDeliveryOrderScreen>(
                  find.byType(CreateDeliveryOrderScreen),
                )
                .onCreated!();
          } else if (action == 'Create Customer') {
            navigator.currentState!.pop(
              CustomerModel.fromJson({'id': 'new', 'name': 'New customer'}),
            );
          } else {
            navigator.currentState!.pop(true);
          }
          await tester.pumpAndSettle();
          final destination = action == 'Create Collection'
              ? 'Collections destination'
              : action == 'Create Customer'
              ? 'Customers destination'
              : 'Orders destination';
          expect(
            find.text(success ? destination : 'Original page'),
            findsOneWidget,
          );
          expect(navigator.currentState!.canPop(), isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final index in [0, 1, 3, 4]) {
    testWidgets('tab $index opens create actions on a small screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: DeliveryBottomNavigation(currentIndex: index),
          ),
        ),
      );
      expect(find.text('More'), findsNothing);
      await tester.tap(find.byTooltip('Create actions'));
      await tester.pumpAndSettle();
      expect(find.text('Create Collection'), findsOneWidget);
      expect(find.text('Create Orders'), findsOneWidget);
      expect(find.text('Create Customer'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('Create Collection'), findsNothing);
    });
  }

  testWidgets('Orders tab navigates to Collections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          AppRoutes.deliveryCollections: (_) =>
              const Scaffold(body: Text('Collection list destination')),
        },
        home: const Scaffold(
          bottomNavigationBar: DeliveryBottomNavigation(currentIndex: 1),
        ),
      ),
    );
    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    expect(find.text('Collection list destination'), findsOneWidget);
  });
}
