class LeadDetailModel {
  final String id;
  final String leadCode;
  final String contactName;
  final String companyName;
  final String phone;
  final String email;
  final String source;
  final String status;
  final String interestedProduct;
  final String assignedTo;
  final String existingCustomer;
  final String notes;
  final String address;
  final String city;
  final String state;
  final String country;
  final String createdAt;
  final String updatedAt;
  final String followUpDate;
  final String expectedClosingDate;
  final String budget;
  final String priority;
  final String avatarUrl;

  const LeadDetailModel({
    required this.id,
    required this.leadCode,
    required this.contactName,
    required this.companyName,
    required this.phone,
    required this.email,
    required this.source,
    required this.status,
    required this.interestedProduct,
    required this.assignedTo,
    required this.existingCustomer,
    required this.notes,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.createdAt,
    required this.updatedAt,
    required this.followUpDate,
    required this.expectedClosingDate,
    required this.budget,
    required this.priority,
    required this.avatarUrl,
  });

  factory LeadDetailModel.fromJson(Map<String, dynamic> json) {
    final contactName = _readString(json, const [
      'contact_person',
      'contactPerson',
      'name',
      'full_name',
    ], fallback: '-');
    final companyName = _readString(
      json,
      const ['company_name', 'companyName', 'customer_name', 'customerName'],
      nestedKeys: const ['customer'],
      fallback: '-',
    );
    final existingCustomer = _readString(
      json,
      const [
        'existing_customer_name',
        'existingCustomerName',
        'customer_name',
        'customerName',
      ],
      nestedKeys: const ['existing_customer', 'customer'],
      fallback: '-',
    );
    final assignedTo = _readString(
      json,
      const [
        'assigned_salesperson_name',
        'assignedSalespersonName',
        'owner_name',
      ],
      nestedKeys: const [
        'assigned_salesperson',
        'assigned_user',
        'owner',
        'user',
      ],
      fallback: '-',
    );

    return LeadDetailModel(
      id: _readString(json, const ['id', 'lead_id', 'leadId'], fallback: ''),
      leadCode: _readString(json, const [
        'lead_code',
        'leadCode',
        'lead_number',
        'leadNumber',
      ], fallback: '-'),
      contactName: contactName,
      companyName: companyName,
      phone: _readString(json, const [
        'mobile_number',
        'mobileNumber',
        'phone',
        'phone_number',
      ], fallback: '-'),
      email: _readString(json, const [
        'email',
        'email_address',
        'emailAddress',
      ], fallback: '-'),
      source: _readString(json, const [
        'lead_source',
        'leadSource',
        'source',
      ], fallback: '-'),
      status: _readString(json, const [
        'lead_status',
        'leadStatus',
        'status',
      ], fallback: 'New'),
      interestedProduct: _readString(json, const [
        'interested_product',
        'interestedProduct',
        'product',
        'category',
      ], fallback: '-'),
      assignedTo: assignedTo,
      existingCustomer: existingCustomer,
      notes: _readString(json, const [
        'notes',
        'description',
        'remark',
        'remarks',
      ], fallback: '-'),
      address: _composeAddress(json),
      city: _readString(json, const ['city', 'district'], fallback: '-'),
      state: _readString(json, const ['state', 'province'], fallback: '-'),
      country: _readString(json, const ['country'], fallback: '-'),
      createdAt: _readString(json, const [
        'created_at',
        'createdAt',
      ], fallback: ''),
      updatedAt: _readString(json, const [
        'updated_at',
        'updatedAt',
      ], fallback: ''),
      followUpDate: _readString(json, const [
        'follow_up_date',
        'followUpDate',
        'next_follow_up',
        'nextFollowUp',
      ], fallback: ''),
      expectedClosingDate: _readString(json, const [
        'expected_closing_date',
        'expectedClosingDate',
        'closing_date',
        'closingDate',
      ], fallback: ''),
      budget: _readString(json, const [
        'budget',
        'expected_value',
        'expectedValue',
        'deal_value',
        'dealValue',
      ], fallback: '-'),
      priority: _readString(json, const [
        'priority',
        'lead_priority',
        'leadPriority',
      ], fallback: '-'),
      avatarUrl: _readString(json, const [
        'avatar_url',
        'avatarUrl',
        'profile_photo',
        'profilePhoto',
      ], fallback: ''),
    );
  }

  String get displayName {
    if (contactName.trim().isNotEmpty && contactName.trim() != '-') {
      return contactName;
    }
    if (companyName.trim().isNotEmpty && companyName.trim() != '-') {
      return companyName;
    }
    return 'Lead';
  }

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'LD';
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  List<String> nestedKeys = const [],
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final normalized = value.toString().trim();
    if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
      return normalized;
    }
  }

  for (final key in nestedKeys) {
    final nested = json[key];
    if (nested is Map<String, dynamic>) {
      final candidate = _readString(nested, const [
        'name',
        'full_name',
        'business_name',
        'company_name',
      ]);
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }
  }

  return fallback;
}

String _composeAddress(Map<String, dynamic> json) {
  final direct = _readString(json, const [
    'address',
    'full_address',
    'fullAddress',
    'street_address',
    'streetAddress',
  ]);
  if (direct.isNotEmpty) {
    return direct;
  }

  final parts = <String>[
    _readString(json, const ['address_line_1', 'addressLine1']),
    _readString(json, const ['address_line_2', 'addressLine2']),
    _readString(json, const ['city']),
    _readString(json, const ['state']),
    _readString(json, const ['country']),
  ].where((value) => value.isNotEmpty).toList();

  if (parts.isEmpty) {
    return '-';
  }

  return parts.join(', ');
}
