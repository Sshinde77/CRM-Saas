import 'package:crm_saas/models/delivery_detail_model.dart';
import 'package:crm_saas/models/delivery_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the selected order delivery date when scheduling is absent', () {
    final delivery = {
      'id': 'delivery-1',
      'scheduled_date': null,
      'order': {'delivery_date': '2026-09-24', 'order_date': '2026-09-18'},
    };

    expect(deliveryScheduledDate(delivery), DateTime(2026, 9, 24));
    expect(
      DeliveryDetail.fromJson(delivery).scheduledDate,
      DateTime(2026, 9, 24),
    );
  });

  test('prefers the explicit schedule and accepts top-level delivery date', () {
    expect(
      deliveryScheduledDate({
        'scheduled_date': '2026-09-25',
        'order': {'delivery_date': '2026-09-24'},
      }),
      DateTime(2026, 9, 25),
    );
    expect(
      deliveryScheduledDate({'delivery_date': '2026-09-24'}),
      DateTime(2026, 9, 24),
    );
  });
}
