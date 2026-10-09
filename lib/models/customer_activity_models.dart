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
      orderNumber:
          _readString(json, const [
            'order_number',
            'order_no',
            'number',
            'sales_order_number',
          ]) ??
          '-',
      date: _readDate(json, const [
        'date',
        'order_date',
        'created_at',
        'createdAt',
      ]),
      status: _readString(json, const ['status', 'order_status']) ?? '-',
      fulfillment:
          _readString(json, const [
            'fulfillment',
            'fulfillment_status',
            'delivery_status',
          ]) ??
          '-',
      total: _readDouble(json, const [
        'total',
        'grand_total',
        'total_amount',
        'amount_total',
        'amount',
      ]),
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
  final String? paymentProofUrl;

  const CustomerPaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.referenceNumber,
    required this.method,
    required this.status,
    this.paymentProofUrl,
  });

  factory CustomerPaymentRecord.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentRecord(
      id: _readString(json, const ['id', 'collection_id', 'payment_id']) ?? '',
      amount: _readDouble(json, const [
        'amount',
        'collected_amount',
        'paid_amount',
        'received_amount',
        'payment_amount',
      ]),
      date: _readDate(json, const [
        'date',
        'collection_date',
        'collected_at',
        'payment_date',
        'paid_at',
        'created_at',
        'createdAt',
      ]),
      referenceNumber:
          _readString(json, const [
            'reference_number',
            'transaction_reference',
            'collection_number',
            'invoice_number',
            'receipt_number',
            'reference',
            'invoice_no',
          ]) ??
          '-',
      method:
          _readString(json, const [
            'payment_method',
            'collection_mode',
            'method',
            'payment_mode',
            'mode',
          ]) ??
          '-',
      status: _readString(json, const ['status']) ?? '-',
      paymentProofUrl: _readString(json, const [
        'payment_proof_url',
        'paymentProofUrl',
      ]),
    );
  }
}

class CustomerVisitRecord {
  final String id;
  final DateTime? date;
  final String purpose;
  final String outcome;
  final String status;
  final String? notes;

  const CustomerVisitRecord({
    required this.id,
    required this.date,
    required this.purpose,
    required this.outcome,
    required this.status,
    this.notes,
  });

  factory CustomerVisitRecord.fromJson(Map<String, dynamic> json) {
    return CustomerVisitRecord(
      id: _readString(json, const ['id', 'visit_id']) ?? '',
      date: _readDate(json, const [
        'visit_date',
        'scheduled_at',
        'check_in_time',
        'created_at',
        'date',
      ]),
      purpose:
          _readString(json, const ['purpose', 'visit_purpose', 'type']) ??
          'Customer visit',
      outcome:
          _readString(json, const ['outcome', 'result', 'visit_outcome']) ??
          '-',
      status: _readString(json, const ['status', 'visit_status']) ?? '-',
      notes: _readString(json, const ['notes', 'remarks', 'description']),
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
