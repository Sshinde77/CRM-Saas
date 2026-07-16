import 'package:flutter_test/flutter_test.dart';

import 'package:crm_saas/app.dart';

void main() {
  testWidgets('app loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CrmSaasApp());

    expect(find.text('CRM SaaS'), findsOneWidget);
    expect(find.text('Sign in to continue to your dashboard.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
