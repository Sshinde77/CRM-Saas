class DeliveryDetail {
  final String id;
  final String deliveryNumber;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String partnerName;
  final String partnerPhone;
  final String partnerEmail;
  final String status;
  final bool partialDelivery;
  final String vehicleNumber;
  final String vehicleType;
  final String capacity;
  final String warehouseName;
  final String deliveryAddress;
  final DateTime? scheduledDate;
  final DateTime? dispatchedAt;
  final DateTime? confirmedAt;
  final double previousPendingBalance;
  final double amountDue;
  final String failureReason;
  final List<DeliveryDetailItem> items;
  final String notes;
  final List<String> podPhotos;
  final String signatureUrl;

  const DeliveryDetail({
    required this.id,
    required this.deliveryNumber,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.partnerName,
    required this.partnerPhone,
    required this.partnerEmail,
    required this.status,
    required this.partialDelivery,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
    required this.warehouseName,
    required this.deliveryAddress,
    required this.scheduledDate,
    required this.dispatchedAt,
    required this.confirmedAt,
    required this.previousPendingBalance,
    required this.amountDue,
    required this.failureReason,
    required this.items,
    required this.notes,
    required this.podPhotos,
    required this.signatureUrl,
  });

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    final data = _map(json['delivery']) ??
        _map(json['data']) ??
        _map(json['item']) ??
        _map(json['result']) ??
        json;
    final order = _map(data['order']) ?? const {};
    final customer = _map(data['customer']) ?? _map(order['customer']) ?? const {};
    final partner = _map(data['delivery_partner']) ??
        _map(data['deliveryPartner']) ??
        _map(data['partner']) ??
        const {};
    final vehicle = _map(data['vehicle']) ?? const {};
    final warehouse = _map(data['warehouse']) ?? const {};
    final items = _list(data['delivery_items'] ?? data['items'] ?? data['order_items'])
        .map(_map)
        .whereType<Map<String, dynamic>>()
        .map(DeliveryDetailItem.fromJson)
        .toList();

    return DeliveryDetail(
      id: _text(data, const ['id', 'delivery_id', '_id']),
      deliveryNumber: _text(data, const [
        'delivery_number',
        'deliveryNumber',
        'deliveryNo',
        'number',
      ], fallback: 'DLV-NEW'),
      orderNumber: _text(data, const ['order_number', 'orderNumber'], fallback: _text(order, const ['order_number', 'orderNumber', 'number'], fallback: 'ORD-NEW')),
      customerName: _text(data, const ['customer_name', 'customerName'], fallback: _text(customer, const ['name', 'full_name'], fallback: 'Customer')),
      customerPhone: _text(data, const ['customer_phone', 'customerPhone'], fallback: _text(customer, const ['phone', 'mobile', 'contact_number'])),
      customerEmail: _text(data, const ['customer_email', 'customerEmail'], fallback: _text(customer, const ['email'])),
      partnerName: _text(data, const ['delivery_partner_name', 'deliveryPartnerName'], fallback: _text(partner, const ['name', 'full_name'], fallback: 'Delivery Partner')),
      partnerPhone: _text(data, const ['delivery_partner_phone', 'deliveryPartnerPhone'], fallback: _text(partner, const ['phone', 'mobile', 'contact_number'])),
      partnerEmail: _text(data, const ['delivery_partner_email', 'deliveryPartnerEmail'], fallback: _text(partner, const ['email'])),
      status: _normalize(_text(data, const ['status', 'delivery_status'], fallback: 'planned')),
      partialDelivery: _bool(data['partial_delivery'] ?? data['partialDelivery']) || _normalize(_text(data, const ['status'])) == 'partially_delivered',
      vehicleNumber: _text(data, const ['vehicle_number', 'vehicleNumber'], fallback: _text(vehicle, const ['vehicle_number', 'number', 'registration_number'])),
      vehicleType: _text(data, const ['vehicle_type', 'vehicleType'], fallback: _text(vehicle, const ['type', 'vehicle_type', 'name'])),
      capacity: _text(data, const ['capacity'], fallback: _text(vehicle, const ['capacity', 'load_capacity'])),
      warehouseName: _text(data, const ['warehouse_name', 'warehouseName'], fallback: _text(warehouse, const ['name'])),
      deliveryAddress: _text(data, const ['delivery_address', 'deliveryAddress', 'address'], fallback: _text(order, const ['delivery_address', 'shipping_address'])),
      scheduledDate: _date(_text(data, const ['scheduled_date', 'scheduledDate', 'scheduled_at'])),
      dispatchedAt: _date(_text(data, const ['dispatched_at', 'dispatchedAt'])),
      confirmedAt: _date(_text(data, const ['confirmed_at', 'confirmedAt', 'delivered_at'])),
      previousPendingBalance: _number(data['previous_pending_balance'] ?? data['previousPendingBalance']),
      amountDue: _number(data['amount_due'] ?? data['amountDue'] ?? data['due_amount'] ?? order['amount_due']),
      failureReason: _text(data, const ['failure_reason', 'failureReason', 'reject_reason', 'rejection_reason']),
      items: items,
      notes: _text(data, const ['notes', 'delivery_notes']),
      podPhotos: _list(data['pod_photos'] ?? data['podPhotos'] ?? data['proof_photos']).map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList(),
      signatureUrl: _text(data, const ['signature_url', 'signatureUrl', 'signature']),
    );
  }

  DeliveryTotals get totals {
    return DeliveryTotals(
      planned: items.fold<int>(0, (sum, item) => sum + item.planned),
      picked: items.fold<int>(0, (sum, item) => sum + item.picked),
      loaded: items.fold<int>(0, (sum, item) => sum + item.loaded),
      delivered: items.fold<int>(0, (sum, item) => sum + item.delivered),
      pending: items.fold<int>(0, (sum, item) => sum + item.pending),
    );
  }

  bool get canConfirm => status == 'in_transit' || status == 'loaded';
}

class DeliveryDetailItem {
  final String id;
  final String productId;
  final String productName;
  final String variant;
  final String imageUrl;
  final int planned;
  final int picked;
  final int loaded;
  final int delivered;
  final int pending;
  final String batch;
  final String expiry;

  const DeliveryDetailItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.variant,
    required this.imageUrl,
    required this.planned,
    required this.picked,
    required this.loaded,
    required this.delivered,
    required this.pending,
    required this.batch,
    required this.expiry,
  });

  factory DeliveryDetailItem.fromJson(Map<String, dynamic> json) {
    final product = _map(json['product']) ?? const {};
    final variant = _map(json['variant']) ?? const {};
    final planned = _int(json['planned'] ?? json['planned_quantity'] ?? json['quantity']);
    final delivered = _int(json['delivered'] ?? json['delivered_quantity']);
    return DeliveryDetailItem(
      id: _text(json, const ['id', 'delivery_item_id', '_id']),
      productId: _text(json, const ['product_id', 'productId'], fallback: _text(product, const ['id', '_id'])),
      productName: _text(json, const ['product_name', 'productName', 'name'], fallback: _text(product, const ['name'], fallback: 'Product')),
      variant: _text(json, const ['variant_name', 'variantName', 'variant'], fallback: _text(variant, const ['name', 'title'])),
      imageUrl: _text(json, const ['image_url', 'imageUrl', 'image'], fallback: _text(product, const ['image_url', 'image'])),
      planned: planned,
      picked: _int(json['picked'] ?? json['picked_quantity'], fallback: planned),
      loaded: _int(json['loaded'] ?? json['loaded_quantity'], fallback: planned),
      delivered: delivered,
      pending: _int(json['pending'] ?? json['pending_quantity'], fallback: mathMax(0, planned - delivered)),
      batch: _text(json, const ['batch', 'batch_number', 'batchNumber']),
      expiry: _text(json, const ['expiry', 'expiry_date', 'expiryDate']),
    );
  }
}

class DeliveryTotals {
  final int planned;
  final int picked;
  final int loaded;
  final int delivered;
  final int pending;

  const DeliveryTotals({
    required this.planned,
    required this.picked,
    required this.loaded,
    required this.delivered,
    required this.pending,
  });
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String _text(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  final text = (value?.toString() ?? '').replaceAll(',', '').replaceAll('Rs.', '').trim();
  return double.tryParse(text) ?? 0;
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'yes';
}

DateTime? _date(String value) {
  if (value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

int mathMax(int a, int b) => a > b ? a : b;
