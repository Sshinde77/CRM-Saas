class CustomerModel {
  final String id;
  final String name;
  final String? businessName;
  final String? category;
  final String? email;
  final String? phone;
  final String? contactPerson;
  final String? designation;
  final String? alternatePhone;
  final String? website;
  final String? communicationPreference;
  final String? gstNumber;
  final String? panNumber;
  final String? taxCategory;
  final bool? taxExempt;
  final String? currency;
  final String? billingAddress;
  final String? deliveryAddress;
  final String? country;
  final String? state;
  final String? city;
  final String? pinCode;
  final String? assignedSalesOfficerId;
  final String? assignedSalesOfficerName;
  final String? leadSource;
  final String? territory;
  final String? customerPriority;
  final String? customerTags;
  final bool? isActive;
  final int? creditLimit;
  final int? openingBalance;
  final int? totalBilled;
  final int? totalReceived;
  final int? outstanding;
  final String? paymentMethod;
  final String? notes;
  final String? address;
  final DateTime? customerSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.businessName,
    required this.category,
    required this.email,
    required this.phone,
    required this.contactPerson,
    required this.designation,
    required this.alternatePhone,
    required this.website,
    required this.communicationPreference,
    required this.gstNumber,
    required this.panNumber,
    required this.taxCategory,
    required this.taxExempt,
    required this.currency,
    required this.billingAddress,
    required this.deliveryAddress,
    required this.country,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.assignedSalesOfficerId,
    required this.assignedSalesOfficerName,
    required this.leadSource,
    required this.territory,
    required this.customerPriority,
    required this.customerTags,
    required this.isActive,
    required this.creditLimit,
    required this.openingBalance,
    required this.totalBilled,
    required this.totalReceived,
    required this.outstanding,
    required this.paymentMethod,
    required this.notes,
    required this.address,
    required this.customerSince,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final basicInformation = _asMap(json['basic_information']);
    final contactInformation = _asMap(json['contact_information']);
    final addressInformation = _asMap(json['address_information']);
    final businessTaxInformation = _asMap(json['business_tax_information']);
    final paymentInformation = _asMap(json['payment_information']);
    final salesCrmInformation = _asMap(json['sales_crm_information']);
    final financialSummary = _asMap(json['financial_summary']);
    final salesSummary = _asMap(json['sales_summary']);
    final additionalInformation = _asMap(json['additional_information']);
    final assignedSalesOfficer =
        _asMap(json['assigned_sales_officer']) ??
        _asMap(json['sales_officer']) ??
        _asMap(json['assigned_sales_officer_detail']) ??
        _asMap(salesCrmInformation?['sales_representative']);
    final stringSources = <Map<String, dynamic>>[
      json,
      if (basicInformation != null) basicInformation,
      if (contactInformation != null) contactInformation,
      if (addressInformation != null) addressInformation,
      if (businessTaxInformation != null) businessTaxInformation,
      if (paymentInformation != null) paymentInformation,
      if (salesCrmInformation != null) salesCrmInformation,
      if (financialSummary != null) financialSummary,
      if (salesSummary != null) salesSummary,
      if (additionalInformation != null) additionalInformation,
    ];
    final numericSources = <Map<String, dynamic>>[
      json,
      if (paymentInformation != null) paymentInformation,
      if (financialSummary != null) financialSummary,
      if (salesSummary != null) salesSummary,
    ];

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: _stringValueFromSources(stringSources, const [
        'name',
        'customer_name',
        'full_name',
        'contact_person',
      ]),
      businessName: _nullableStringValueFromSources(stringSources, const [
        'business_name',
        'business',
        'company_name',
        'organization_name',
        'legal_business_name',
        'display_name',
      ]),
      category: _nullableStringValueFromSources(stringSources, const [
        'category',
        'customer_category',
        'type',
        'business_type',
        'industry',
      ]),
      email: _nullableStringValueFromSources(stringSources, const [
        'email',
        'email_address',
      ]),
      phone: _nullableStringValueFromSources(stringSources, const [
        'phone',
        'phone_number',
        'mobile',
        'mobile_no',
        'mobile_number',
        'alternate_mobile_number',
      ]),
      contactPerson: _nullableStringValueFromSources(stringSources, const [
        'contact_person',
        'primary_contact_person',
      ]),
      designation: _nullableStringValueFromSources(stringSources, const [
        'designation',
        'job_title',
      ]),
      alternatePhone: _nullableStringValueFromSources(stringSources, const [
        'alternate_mobile_number',
        'alternate_mobile',
        'alternate_phone',
        'secondary_phone',
      ]),
      website: _nullableStringValueFromSources(stringSources, const [
        'website',
        'website_url',
      ]),
      communicationPreference: _nullableStringValueFromSources(
        stringSources,
        const [
          'communication_preference',
          'preferred_communication',
          'preferred_communication_mode',
        ],
      ),
      gstNumber: _nullableStringValueFromSources(stringSources, const [
        'gst_number',
        'gst',
        'gstin',
        'gstin_tax_id',
      ]),
      panNumber: _nullableStringValueFromSources(stringSources, const [
        'pan_number',
        'pan',
        'registration_number',
        'business_registration_number',
      ]),
      taxCategory: _nullableStringValueFromSources(stringSources, const [
        'tax_category',
      ]),
      taxExempt: _boolValueFromSources(stringSources, const [
        'tax_exempt',
        'is_tax_exempt',
      ]),
      currency: _nullableStringValueFromSources(stringSources, const [
        'currency',
        'currency_code',
      ]),
      billingAddress: _nullableStringValueFromSources(stringSources, const [
        'billing_address',
        'billingAddress',
      ]),
      deliveryAddress: _nullableStringValueFromSources(stringSources, const [
        'delivery_address',
        'deliveryAddress',
        'shipping_address',
      ]),
      country: _nullableStringValueFromSources(stringSources, const ['country']),
      state: _nullableStringValueFromSources(stringSources, const ['state']),
      city: _nullableStringValueFromSources(stringSources, const ['city']),
      pinCode: _nullableStringValueFromSources(stringSources, const [
        'pin_code',
        'postal_code',
        'zip_code',
      ]),
      assignedSalesOfficerId: _stringFromNested(
        salesCrmInformation ?? json,
        assignedSalesOfficer,
        const [
          'assigned_sales_officer_id',
          'sales_officer_id',
          'sales_representative_id',
        ],
      ),
      assignedSalesOfficerName: _stringFromNested(
        salesCrmInformation ?? json,
        assignedSalesOfficer,
        const [
          'assigned_sales_officer_name',
          'sales_officer_name',
          'name',
        ],
      ),
      leadSource: _nullableStringValueFromSources(stringSources, const [
        'lead_source',
      ]),
      territory: _nullableStringValueFromSources(stringSources, const [
        'territory',
      ]),
      customerPriority: _nullableStringValueFromSources(stringSources, const [
        'customer_priority',
        'priority',
      ]),
      customerTags: _nullableStringValueFromSources(stringSources, const [
        'customer_tags',
        'tags',
      ]),
      isActive: _boolFromJson(json),
      creditLimit: _intValueFromSources(numericSources, const [
        'credit_limit',
        'limit',
      ]),
      openingBalance: _intValueFromSources(numericSources, const [
        'opening_balance',
      ]),
      totalBilled: _intValueFromSources(numericSources, const [
        'total_billed',
        'customer_lifetime_value',
      ]),
      totalReceived: _intValueFromSources(numericSources, const [
        'total_received',
      ]),
      outstanding: _intValueFromSources(numericSources, const [
        'outstanding_balance',
        'outstanding',
        'due_amount',
      ]),
      paymentMethod: _nullableStringValueFromSources(stringSources, const [
        'payment_method',
        'preferred_payment_method',
      ]),
      notes: _nullableStringValueFromSources(stringSources, const ['notes']),
      address: _nullableStringValueFromSources(stringSources, const [
        'address',
        'billing_address',
        'delivery_address',
        'shipping_address',
        'city',
        'state',
        'country',
      ]),
      customerSince: _dateTimeFromSources(stringSources, const [
        'customer_since',
        'customer_since_date',
        'onboarded_at',
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
      'contact_person': contactPerson,
      'designation': designation,
      'alternate_mobile_number': alternatePhone,
      'website': website,
      'communication_preference': communicationPreference,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'tax_category': taxCategory,
      'tax_exempt': taxExempt,
      'currency': currency,
      'billing_address': billingAddress,
      'delivery_address': deliveryAddress,
      'country': country,
      'state': state,
      'city': city,
      'pin_code': pinCode,
      'assigned_sales_officer_id': assignedSalesOfficerId,
      'assigned_sales_officer_name': assignedSalesOfficerName,
      'lead_source': leadSource,
      'territory': territory,
      'customer_priority': customerPriority,
      'customer_tags': customerTags,
      'is_active': isActive,
      'credit_limit': creditLimit,
      'opening_balance': openingBalance,
      'total_billed': totalBilled,
      'total_received': totalReceived,
      'outstanding': outstanding,
      'payment_method': paymentMethod,
      'notes': notes,
      'address': address,
      'customer_since': customerSince?.toIso8601String(),
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

  static String _stringValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys, {
    String fallback = 'Customer',
  }) {
    for (final source in sources) {
      final value = _nullableStringValue(source, keys);
      if (value != null) {
        return value;
      }
    }
    return fallback;
  }

  static String? _nullableStringValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _nullableStringValue(source, keys);
      if (value != null) {
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

  static bool? _boolValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is bool) return value;
        final text = value?.toString().trim().toLowerCase();
        if (text == 'true' || text == 'yes' || text == '1') return true;
        if (text == 'false' || text == 'no' || text == '0') return false;
      }
    }
    return null;
  }

  static DateTime? _dateTimeFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      for (final key in keys) {
        final parsed = _tryParseDateTime(source[key]?.toString());
        if (parsed != null) return parsed;
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

  static int? _intValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _intValue(source, keys);
      if (value != null) {
        return value;
      }
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
