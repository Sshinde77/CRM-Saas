class CustomerOrderRecord {
  final String id;
  final String orderNumber;
  final DateTime? date;
  final String status;
  final String fulfillment;
  final double total;

  const CustomerOrderRecord({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.fulfillment,
    required this.total,
  });

  factory CustomerOrderRecord.fromJson(Map<String, dynamic> json) {
    return CustomerOrderRecord(
      id: _readString(json, const ['id', 'order_id']) ?? '',
      orderNumber: _readString(
            json,
            const ['order_number', 'order_no', 'number', 'sales_order_number'],
          ) ??
          '-',
      date: _readDate(
        json,
        const ['date', 'order_date', 'created_at', 'createdAt'],
      ),
      status: _readString(json, const ['status', 'order_status']) ?? '-',
      fulfillment:
          _readString(
            json,
            const ['fulfillment', 'fulfillment_status', 'delivery_status'],
          ) ??
          '-',
      total: _readDouble(
        json,
        const ['total', 'grand_total', 'total_amount', 'amount_total', 'amount'],
      ),
    );
  }
}

class CustomerPaymentRecord {
  final String id;
  final double amount;
  final DateTime? date;
  final String referenceNumber;
  final String method;
  final String status;

  const CustomerPaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.referenceNumber,
    required this.method,
    required this.status,
  });

  factory CustomerPaymentRecord.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentRecord(
      id: _readString(json, const ['id', 'payment_id']) ?? '',
      amount: _readDouble(
        json,
        const ['amount', 'paid_amount', 'received_amount', 'payment_amount'],
      ),
      date: _readDate(
        json,
        const ['date', 'payment_date', 'paid_at', 'created_at', 'createdAt'],
      ),
      referenceNumber:
          _readString(
            json,
            const [
              'reference_number',
              'invoice_number',
              'receipt_number',
              'reference',
              'invoice_no',
            ],
          ) ??
          '-',
      method:
          _readString(
            json,
            const ['payment_method', 'method', 'payment_mode', 'mode'],
          ) ??
          '-',
      status: _readString(json, const ['status']) ?? '-',
    );
  }
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is bool || value == null) {
      continue;
    }
    final parsed = double.tryParse(value.toString().trim());
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

DateTime? _readDate(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}
