class CustomerModel {
  final String id;
  final String name;
  final String? businessName;
  final String? category;
  final String? email;
  final String? phone;
  final String? gstNumber;
  final String? billingAddress;
  final String? deliveryAddress;
  final String? assignedSalesOfficerId;
  final String? assignedSalesOfficerName;
  final bool? isActive;
  final int? creditLimit;
  final int? openingBalance;
  final int? totalBilled;
  final int? totalReceived;
  final int? outstanding;
  final String? notes;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.businessName,
    required this.category,
    required this.email,
    required this.phone,
    required this.gstNumber,
    required this.billingAddress,
    required this.deliveryAddress,
    required this.assignedSalesOfficerId,
    required this.assignedSalesOfficerName,
    required this.isActive,
    required this.creditLimit,
    required this.openingBalance,
    required this.totalBilled,
    required this.totalReceived,
    required this.outstanding,
    required this.notes,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final assignedSalesOfficer =
        _asMap(json['assigned_sales_officer']) ??
        _asMap(json['sales_officer']) ??
        _asMap(json['assigned_sales_officer_detail']);

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: _stringValue(json, const [
        'name',
        'customer_name',
        'full_name',
        'contact_person',
      ]),
      businessName: _nullableStringValue(json, const [
        'business_name',
        'business',
        'company_name',
        'organization_name',
      ]),
      category: _nullableStringValue(json, const [
        'category',
        'customer_category',
        'type',
        'business_type',
      ]),
      email: _nullableStringValue(json, const ['email']),
      phone: _nullableStringValue(json, const [
        'phone',
        'phone_number',
        'mobile',
        'mobile_no',
      ]),
      gstNumber: _nullableStringValue(json, const [
        'gst_number',
        'gst',
        'gstin',
      ]),
      billingAddress: _nullableStringValue(json, const [
        'billing_address',
        'billingAddress',
      ]),
      deliveryAddress: _nullableStringValue(json, const [
        'delivery_address',
        'deliveryAddress',
      ]),
      assignedSalesOfficerId: _stringFromNested(
        json,
        assignedSalesOfficer,
        const ['assigned_sales_officer_id', 'sales_officer_id'],
      ),
      assignedSalesOfficerName: _stringFromNested(
        json,
        assignedSalesOfficer,
        const ['assigned_sales_officer_name', 'sales_officer_name', 'name'],
      ),
      isActive: _boolFromJson(json),
      creditLimit: _intValue(json, const ['credit_limit', 'limit']),
      openingBalance: _intValue(json, const ['opening_balance']),
      totalBilled: _intValue(json, const ['total_billed']),
      totalReceived: _intValue(json, const ['total_received']),
      outstanding: _intValue(json, const [
        'outstanding_balance',
        'outstanding',
        'due_amount',
      ]),
      notes: _nullableStringValue(json, const ['notes']),
      address: _nullableStringValue(json, const [
        'address',
        'billing_address',
        'delivery_address',
        'shipping_address',
      ]),
      createdAt: _tryParseDateTime(
        json['created_at']?.toString() ?? json['createdAt']?.toString(),
      ),
      updatedAt: _tryParseDateTime(
        json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
      ),
    );
  }

  String get statusLabel => isActive == false ? 'Inactive' : 'Active';

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final values = parts.toList();
    if (values.isEmpty) {
      return 'CU';
    }
    if (values.length == 1) {
      final text = values.first;
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }
    return '${values.first[0]}${values.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'category': category,
      'email': email,
      'phone': phone,
      'gst_number': gstNumber,
      'billing_address': billingAddress,
      'delivery_address': deliveryAddress,
      'assigned_sales_officer_id': assignedSalesOfficerId,
      'assigned_sales_officer_name': assignedSalesOfficerName,
      'is_active': isActive,
      'credit_limit': creditLimit,
      'opening_balance': openingBalance,
      'total_billed': totalBilled,
      'total_received': totalReceived,
      'outstanding': outstanding,
      'notes': notes,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static String _stringValue(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = 'Customer',
  }) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  static String? _nullableStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static String? _stringFromNested(
    Map<String, dynamic> json,
    Map<String, dynamic>? nested,
    List<String> keys,
  ) {
    final sources = <Map<String, dynamic>>[json];
    if (nested != null) {
      sources.add(nested);
    }
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  static int? _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  static bool? _boolFromJson(Map<String, dynamic> json) {
    final direct = json['is_active'];
    if (direct is bool) return direct;
    if (direct is num) return direct != 0;
    if (direct is String) {
      final normalized = direct.trim().toLowerCase();
      if (normalized.isEmpty) return null;
      if (['true', '1', 'yes', 'active'].contains(normalized)) return true;
      if (['false', '0', 'no', 'inactive'].contains(normalized)) return false;
    }

    final status = json['status']?.toString().trim().toLowerCase();
    if (status == null || status.isEmpty) {
      return null;
    }
    if (status == 'active') return true;
    if (status == 'inactive' || status == 'blocked') return false;
    return null;
  }

  static DateTime? _tryParseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class CustomerListQuery {
  final String? search;
  final String? category;
  final bool? isActive;
  final String? assignedSalesOfficerId;

  const CustomerListQuery({
    this.search,
    this.category,
    this.isActive,
    this.assignedSalesOfficerId,
  });

  Map<String, String> toQueryParameters() {
    final query = <String, String>{};

    void put(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        query[key] = normalized;
      }
    }

    put('search', search);
    put('category', category);
    if (isActive != null) {
      query['is_active'] = isActive.toString();
    }
    put('assigned_sales_officer_id', assignedSalesOfficerId);

    return query;
  }
}

class CustomerCreateRequest {
  final String? name;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? billingAddress;
  final String? deliveryAddress;
  final String? assignedSalesOfficerId;
  final int? creditLimit;
  final int? openingBalance;
  final String? category;
  final String? notes;

  const CustomerCreateRequest({
    this.name,
    this.businessName,
    this.phone,
    this.email,
    this.gstNumber,
    this.billingAddress,
    this.deliveryAddress,
    this.assignedSalesOfficerId,
    this.creditLimit,
    this.openingBalance,
    this.category,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    put('name', name);
    put('business_name', businessName);
    put('phone', phone);
    put('email', email);
    put('gst_number', gstNumber);
    put('billing_address', billingAddress);
    put('delivery_address', deliveryAddress);
    put('assigned_sales_officer_id', assignedSalesOfficerId);
    put('credit_limit', creditLimit);
    put('opening_balance', openingBalance);
    put('category', category);
    put('notes', notes);
    return json;
  }
}

class CustomerUpdateRequest {
  final String? name;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? billingAddress;
  final String? deliveryAddress;
  final String? assignedSalesOfficerId;
  final int? creditLimit;
  final String? category;
  final String? notes;
  final bool? isActive;

  const CustomerUpdateRequest({
    this.name,
    this.businessName,
    this.phone,
    this.email,
    this.gstNumber,
    this.billingAddress,
    this.deliveryAddress,
    this.assignedSalesOfficerId,
    this.creditLimit,
    this.category,
    this.notes,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    put('name', name);
    put('business_name', businessName);
    put('phone', phone);
    put('email', email);
    put('gst_number', gstNumber);
    put('billing_address', billingAddress);
    put('delivery_address', deliveryAddress);
    put('assigned_sales_officer_id', assignedSalesOfficerId);
    put('credit_limit', creditLimit);
    put('category', category);
    put('notes', notes);
    put('is_active', isActive);
    return json;
  }
}
