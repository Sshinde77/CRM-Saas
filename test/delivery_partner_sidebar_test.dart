import 'package:crm_saas/providers/api_provider.dart';
import 'package:crm_saas/routes/app_router.dart';
import 'package:crm_saas/screens/auth/login_screen.dart';
import 'package:crm_saas/widgets/delivery/delivery_partner_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LogoutProvider extends ApiProvider {
  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

class _RouteObserver extends NavigatorObserver {
  final pushed = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('Delivery menu confirms logout and returns to login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _LogoutProvider();
    final routes = _RouteObserver();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ApiProviderScope(
        notifier: provider,
        child: MaterialApp(
          navigatorObservers: [routes],
          home: const Scaffold(
            drawer: DeliveryPartnerSidebar(
              currentRoute: AppRoutes.deliveryDashboard,
            ),
            body: Text('Delivery dashboard'),
          ),
        ),
      ),
    );

    tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('delivery_logout')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Logout'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(provider.logoutCalls, 0);

    await tester.tap(find.byKey(const Key('delivery_logout')));
    await tester.pumpAndSettle();
    final sidebarContext = tester.element(find.byType(DeliveryPartnerSidebar));
    await tester.tap(find.text('Sign Out'));
    await tester.runAsync(() async => Future<void>.delayed(Duration.zero));
    expect(provider.logoutCalls, 1);
    final loginRoute = routes.pushed.last as MaterialPageRoute<dynamic>;
    expect(loginRoute.builder(sidebarContext), isA<LoginScreen>());
  });
}
