class PlanModel {
  final String id;
  final String name;
  final num priceMonthly;
  final num priceYearly;
  final num? originalPriceMonthly;
  final num? originalPriceYearly;
  final int? maxUsers;
  final int? maxOrders;
  final List<String> features;
  final bool isActive;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlanModel({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.originalPriceMonthly,
    required this.originalPriceYearly,
    required this.maxUsers,
    required this.maxOrders,
    required this.features,
    required this.isActive,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      priceMonthly: (json['price_monthly'] as num?) ?? 0,
      priceYearly: (json['price_yearly'] as num?) ?? 0,
      originalPriceMonthly: json['original_price_monthly'] as num?,
      originalPriceYearly: json['original_price_yearly'] as num?,
      maxUsers: json['max_users'] as int?,
      maxOrders: json['max_orders'] as int?,
      features: (json['features'] as List<dynamic>? ?? const [])
          .map((feature) => feature.toString())
          .toList(),
      isActive: json['is_active'] == true,
      isDefault: json['is_default'] == true,
      createdAt: _tryParseDateTime(json['created_at']?.toString()),
      updatedAt: _tryParseDateTime(json['updated_at']?.toString()),
    );
  }

  static DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
