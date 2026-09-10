import 'package:crm_saas/routes/app_router.dart';
import 'package:crm_saas/widgets/delivery/delivery_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final index in [0, 1, 3, 4]) {
    testWidgets('tab $index opens all three create actions on a small screen', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        bottomNavigationBar: DeliveryBottomNavigation(currentIndex: index),
      )));
      expect(find.text('More'), findsNothing);
      await tester.tap(find.byTooltip('Create actions'));
      await tester.pumpAndSettle();
      expect(find.text('Create Collection'), findsOneWidget);
      expect(find.text('Create Orders'), findsOneWidget);
      expect(find.text('Create Customer'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('Create Customer'), findsNothing);
    });
  }

  testWidgets('Orders tab can navigate to Collections', (tester) async {
    await tester.pumpWidget(MaterialApp(
      routes: {AppRoutes.deliveryCollections: (_) => const Scaffold(body: Text('Collection list destination'))},
      home: const Scaffold(bottomNavigationBar: DeliveryBottomNavigation(currentIndex: 1)),
    ));
    await tester.tap(find.text('Collections'));
    await tester.pumpAndSettle();
    expect(find.text('Collection list destination'), findsOneWidget);
  });
}
