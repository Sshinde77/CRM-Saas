class EndOfDaySession {
  final String id;
  final String deliveryPartnerId;
  final String vehicleNumber;
  final String vehicleType;
  final String status;
  final List<EndOfDayStockItem> items;

  const EndOfDaySession({
    required this.id,
    required this.deliveryPartnerId,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.status,
    required this.items,
  });

  factory EndOfDaySession.fromJson(Map<String, dynamic> json) {
    final nested = _readMap(json, const ['session', 'vehicle_stock', 'vehicleStock']);
    final source = nested.isEmpty ? json : <String, dynamic>{...json, ...nested};
    final vehicle = _readMap(source, const ['vehicle']);
    final items = _readList(source, const [
      'items',
      'stock_items',
      'stockItems',
      'loaded_items',
      'loadedItems',
      'products',
    ]);

    return EndOfDaySession(
      id: _readString(source, const ['id', '_id', 'session_id', 'sessionId']),
      deliveryPartnerId: _readString(source, const [
        'delivery_partner_id',
        'deliveryPartnerId',
        'partner_id',
      ]),
      vehicleNumber: _firstNonEmpty([
        _readString(source, const ['vehicle_number', 'vehicleNumber']),
        _readString(vehicle, const ['number', 'vehicle_number', 'vehicleNumber']),
      ]),
      vehicleType: _firstNonEmpty([
        _readString(source, const ['vehicle_type', 'vehicleType']),
        _readString(vehicle, const ['type', 'model', 'vehicle_type']),
      ]),
      status: _readString(source, const ['status', 'session_status', 'sessionStatus']),
      items: items.map(EndOfDayStockItem.fromJson).toList(),
    );
  }

  EndOfDaySession copyWithItems(List<EndOfDayStockItem> nextItems) {
    return EndOfDaySession(
      id: id,
      deliveryPartnerId: deliveryPartnerId,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      status: status,
      items: nextItems,
    );
  }
}

class EndOfDayStockItem {
  final String id;
  final String productId;
  final String variantId;
  final String productName;
  final String imageUrl;
  final double loadedQuantity;
  final double deliveredQuantity;
  final double returnedQuantity;
  final double expectedClosingQuantity;

  const EndOfDayStockItem({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.imageUrl,
    required this.loadedQuantity,
    required this.deliveredQuantity,
    required this.returnedQuantity,
    required this.expectedClosingQuantity,
  });

  factory EndOfDayStockItem.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final productId = _firstNonEmpty([
      _readString(json, const ['product_id', 'productId']),
      _readString(product, const ['id', '_id', 'product_id', 'productId']),
    ]);
    final variantId = _firstNonEmpty([
      _readString(json, const ['variant_id', 'variantId', 'variant']),
      _readString(product, const ['variant_id', 'variantId']),
    ]);
    final productName = _firstNonEmpty([
      _readString(json, const ['product_name', 'productName', 'name']),
      _readString(product, const ['name', 'product_name', 'productName']),
    ]);
    final id = _firstNonEmpty([
      _readString(json, const ['id', '_id', 'loading_item_id', 'loadingItemId']),
      productId,
      variantId,
      productName,
    ]);
    final loaded = _readDouble(json, const [
      'loaded_quantity',
      'loadedQuantity',
      'loaded_qty',
      'loaded',
      'quantity',
    ]);
    final delivered = _readDouble(json, const [
      'delivered_quantity',
      'deliveredQuantity',
      'delivered_qty',
      'delivered',
      'sold_quantity',
      'soldQuantity',
    ]);
    final returned = _readDouble(json, const [
      'returned_quantity',
      'returnedQuantity',
      'returned_qty',
      'returned',
    ]);
    final expected = _readNullableDouble(json, const [
          'expected_closing_quantity',
          'expectedClosingQuantity',
          'expected_closing_qty',
          'remaining_quantity',
          'remainingQuantity',
          'remaining',
        ]) ??
        (loaded - delivered - returned);

    return EndOfDayStockItem(
      id: id,
      productId: productId,
      variantId: variantId,
      productName: productName,
      imageUrl: _firstNonEmpty([
        _readString(json, const ['image', 'image_url', 'imageUrl', 'photo']),
        _readString(product, const ['image', 'image_url', 'imageUrl', 'photo']),
      ]),
      loadedQuantity: loaded,
      deliveredQuantity: delivered,
      returnedQuantity: returned,
      expectedClosingQuantity: expected < 0 ? 0 : expected,
    );
  }

  EndOfDayStockItem copyWithReturn(double returned) {
    final expected = loadedQuantity - deliveredQuantity - returned;
    return EndOfDayStockItem(
      id: id,
      productId: productId,
      variantId: variantId,
      productName: productName,
      imageUrl: imageUrl,
      loadedQuantity: loadedQuantity,
      deliveredQuantity: deliveredQuantity,
      returnedQuantity: returned,
      expectedClosingQuantity: expected < 0 ? 0 : expected,
    );
  }
}

class ReconciliationLine {
  final EndOfDayStockItem item;
  final double expected;
  final double physical;

  const ReconciliationLine({
    required this.item,
    required this.expected,
    required this.physical,
  });

  double get variance => physical - expected;
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return const {};
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  return _readNullableDouble(json, keys) ?? 0;
}

double? _readNullableDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}
