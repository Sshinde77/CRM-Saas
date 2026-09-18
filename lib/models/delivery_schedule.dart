/// Returns the planned delivery date from a delivery record or its order.
DateTime? deliveryScheduledDate(Map<String, dynamic> delivery) {
  const keys = [
    'scheduled_date',
    'scheduledDate',
    'scheduled_at',
    'delivery_date',
    'deliveryDate',
  ];

  DateTime? from(Map<String, dynamic> source) {
    for (final key in keys) {
      final raw = source[key];
      if (raw is DateTime) return raw.toLocal();
      final value = raw?.toString().trim();
      if (value == null || value.isEmpty) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toLocal();
    }
    return null;
  }

  final direct = from(delivery);
  if (direct != null) return direct;
  for (final key in ['order', 'sales_order']) {
    final order = delivery[key];
    if (order is Map<String, dynamic>) {
      final linkedDate = from(order);
      if (linkedDate != null) return linkedDate;
    }
  }

  final fallback = delivery['date']?.toString().trim();
  return fallback == null || fallback.isEmpty
      ? null
      : DateTime.tryParse(fallback)?.toLocal();
}
