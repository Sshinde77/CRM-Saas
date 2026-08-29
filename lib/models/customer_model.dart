class CustomerDocument {
  final String name;
  final String? url;
  final String? type;
  final String? documentType;
  final String? fileId;

  const CustomerDocument({
    required this.name,
    required this.url,
    required this.type,
    this.documentType,
    this.fileId,
  });

  factory CustomerDocument.fromJson(Map<String, dynamic> json) {
    final fileId = _readString(json, const [
      'file_id',
      'fileId',
      'id',
      'document_id',
      'attachment_id',
    ]);
    final url = _readString(json, const [
      'url',
      'file_url',
      'fileUrl',
      'document_url',
      'preview_url',
      'download_url',
      'attachment_url',
      'path',
      'file_path',
    ]);
    final name =
        _readString(json, const [
          'name',
          'document_name',
          'file_name',
          'filename',
          'title',
          'label',
        ]) ??
        (url == null ? 'Document' : fileNameFromUrl(url));

    return CustomerDocument(
      name: name,
      url: url,
      type: _readString(json, const [
        'content_type',
        'mime_type',
        'mimeType',
        'file_type',
        'extension',
      ]),
      documentType: _readString(json, const ['document_type', 'documentType']),
      fileId: fileId,
    );
  }

  bool get hasUrl => url?.trim().isNotEmpty == true;
  bool get hasFileId => fileId?.trim().isNotEmpty == true;

  bool get isImage {
    final value = '${type ?? ''} ${url ?? ''}'.toLowerCase();
    return value.contains('image/') ||
        value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp') ||
        value.endsWith('.gif');
  }

  bool get isPdf {
    final value = '${type ?? ''} ${url ?? ''}'.toLowerCase();
    return value.contains('pdf') || value.endsWith('.pdf');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'document_type': documentType,
      'file_id': fileId,
    };
  }

  static String fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final segment = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    final decoded = Uri.decodeComponent(segment).trim();
    return decoded.isEmpty ? 'Document' : decoded;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

class CustomerModel {
  final String id;
  final String? customerId;
  final String name;
  final String? businessName;
  final String? industry;
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
  final double? mapLatitude;
  final double? mapLongitude;
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
  final DateTime? lastOrderDate;
  final DateTime? lastVisitDate;
  final String? paymentMethod;
  final String? notes;
  final String? address;
  final DateTime? customerSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CustomerDocument> documents;

  const CustomerModel({
    required this.id,
    required this.customerId,
    required this.name,
    required this.businessName,
    required this.industry,
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
    required this.mapLatitude,
    required this.mapLongitude,
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
    required this.lastOrderDate,
    required this.lastVisitDate,
    required this.paymentMethod,
    required this.notes,
    required this.address,
    required this.customerSince,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
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
    final googleMapsLocation = _asMap(
      addressInformation?['google_maps_location'],
    );
    final assignedSalesOfficer =
        _asMap(json['assigned_sales_officer']) ??
        _asMap(json['sales_officer']) ??
        _asMap(json['assigned_sales_officer_detail']) ??
        _asMap(salesCrmInformation?['sales_representative']);
    final stringSources = <Map<String, dynamic>>[
      json,
      ..._nonNullMaps([
        basicInformation,
        contactInformation,
        addressInformation,
        businessTaxInformation,
        paymentInformation,
        salesCrmInformation,
        financialSummary,
        salesSummary,
        additionalInformation,
      ]),
    ];
    final numericSources = <Map<String, dynamic>>[
      json,
      ..._nonNullMaps([paymentInformation, financialSummary, salesSummary]),
    ];

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      customerId: _nullableStringValueFromSources(stringSources, const [
        'customer_id',
        'customerId',
      ]),
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
      industry: _nullableStringValueFromSources(stringSources, const [
        'industry',
      ]),
      category: _nullableStringValueFromSources(stringSources, const [
        'category',
        'customer_category',
        'type',
        'business_type',
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
      communicationPreference:
          _listOrStringValueFromSources(stringSources, const [
            'communication_preference',
            'preferred_communication',
            'preferred_communication_mode',
          ]),
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
      country: _nullableStringValueFromSources(stringSources, const [
        'country',
      ]),
      state: _nullableStringValueFromSources(stringSources, const ['state']),
      city: _nullableStringValueFromSources(stringSources, const ['city']),
      pinCode: _nullableStringValueFromSources(stringSources, const [
        'pin_code',
        'postal_code',
        'zip_code',
        'pin_zip_code',
      ]),
      mapLatitude: _doubleFromMap(googleMapsLocation, 'latitude'),
      mapLongitude: _doubleFromMap(googleMapsLocation, 'longitude'),
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
        const ['assigned_sales_officer_name', 'sales_officer_name', 'name'],
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
      customerTags: _listOrStringValueFromSources(stringSources, const [
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
      lastOrderDate: _dateTimeFromSources(stringSources, const [
        'last_order_date',
        'lastOrderDate',
        'recent_order_date',
        'last_ordered_at',
        'last_purchase_date',
      ]),
      lastVisitDate: _dateTimeFromSources(stringSources, const [
        'last_visit_date',
        'lastVisitDate',
        'recent_visit_date',
        'last_visited_at',
        'last_visit_at',
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
      documents: _documentsFromSources(json, stringSources),
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
      'customer_id': customerId,
      'name': name,
      'business_name': businessName,
      'industry': industry,
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
      'map_latitude': mapLatitude,
      'map_longitude': mapLongitude,
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
      'last_order_date': lastOrderDate?.toIso8601String(),
      'last_visit_date': lastVisitDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'address': address,
      'customer_since': customerSince?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'documents': documents.map((document) => document.toJson()).toList(),
    };
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static List<Map<String, dynamic>> _nonNullMaps(
    List<Map<String, dynamic>?> values,
  ) {
    return values.whereType<Map<String, dynamic>>().toList();
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

  static List<CustomerDocument> _documentsFromSources(
    Map<String, dynamic> root,
    List<Map<String, dynamic>> sources,
  ) {
    final documents = <CustomerDocument>[];
    final seen = <String>{};

    void addDocument({
      required String name,
      String? url,
      String? type,
      String? fileId,
      String? documentType,
    }) {
      final normalizedName = name.trim();
      final normalizedUrl = url?.trim();
      final normalizedFileId = fileId?.trim();
      if (normalizedName.isEmpty &&
          (normalizedUrl == null || normalizedUrl.isEmpty) &&
          (normalizedFileId == null || normalizedFileId.isEmpty)) {
        return;
      }

      final document = CustomerDocument(
        name: normalizedName.isEmpty
            ? normalizedUrl == null || normalizedUrl.isEmpty
                  ? 'Document'
                  : CustomerDocument.fileNameFromUrl(normalizedUrl)
            : normalizedName,
        url: normalizedUrl?.isEmpty == true ? null : normalizedUrl,
        type: type?.trim().isEmpty == true ? null : type?.trim(),
        documentType: documentType?.trim().isEmpty == true
            ? null
            : documentType?.trim(),
        fileId: normalizedFileId?.isEmpty == true ? null : normalizedFileId,
      );
      final key =
          '${document.name}|${document.url ?? ''}|${document.fileId ?? ''}'
              .toLowerCase();
      if (seen.add(key)) {
        documents.add(document);
      }
    }

    void parseDocument(dynamic value, String fallbackName) {
      if (value == null) return;
      if (value is List) {
        for (final item in value) {
          parseDocument(item, fallbackName);
        }
        return;
      }
      if (value is Map) {
        final map = value.map(
          (key, mapValue) => MapEntry(key.toString(), mapValue),
        );
        final name =
            _nullableStringValue(map, const [
              'name',
              'document_name',
              'file_name',
              'filename',
              'title',
              'label',
              'document_type',
              'type',
            ]) ??
            fallbackName;
        final url = _nullableStringValue(map, const [
          'url',
          'file_url',
          'fileUrl',
          'document_url',
          'preview_url',
          'download_url',
          'attachment_url',
          'path',
          'file_path',
        ]);
        final fileId = _nullableStringValue(map, const [
          'file_id',
          'fileId',
          'document_id',
          'attachment_id',
        ]);
        final type = _nullableStringValue(map, const [
          'mime_type',
          'mimeType',
          'content_type',
          'file_type',
          'extension',
        ]);
        final documentType = _nullableStringValue(map, const [
          'document_type',
          'documentType',
          'type',
        ]);

        final addedDirectDocument =
            url != null || fileId != null || name.trim() != fallbackName.trim();
        if (addedDirectDocument) {
          addDocument(
            name: name,
            url: url,
            type: type,
            fileId: fileId,
            documentType: documentType,
          );
        }

        for (final entry in map.entries) {
          if (entry.value is List || entry.value is Map) {
            parseDocument(entry.value, _documentLabelFromKey(entry.key));
          } else if (!addedDirectDocument) {
            parseDocument(entry.value, _documentLabelFromKey(entry.key));
          }
        }
        return;
      }

      final text = value.toString().trim();
      if (text.isEmpty || text == '[]') return;
      final looksLikeFile =
          text.startsWith('http') ||
          text.contains('/') ||
          RegExp(
            r'\.(pdf|png|jpe?g|webp|docx?|xlsx?)$',
            caseSensitive: false,
          ).hasMatch(text);
      if (looksLikeFile) {
        addDocument(name: fallbackName, url: text);
      } else if (_looksLikeFileIdKey(fallbackName)) {
        addDocument(
          name: fallbackName.replaceAll(
            RegExp(r'\s+Ids?$', caseSensitive: false),
            '',
          ),
          fileId: text,
          documentType: fallbackName,
        );
      }
    }

    const documentKeys = [
      'documents',
      'document',
      'document_information',
      'documents_information',
      'document_uploads',
      'uploaded_documents',
      'customer_documents',
      'attachments',
      'files',
      'gst_certificate',
      'gst_certificate_id',
      'gst_certificate_file',
      'pan_card',
      'pan_card_id',
      'pan_card_file',
      'business_registration_certificate',
      'business_registration_certificate_id',
      'business_registration_file',
      'address_proof',
      'address_proof_id',
      'address_proof_file',
      'purchase_agreement',
      'purchase_agreement_id',
      'purchase_agreement_file',
      'other_documents',
      'other_document_ids',
      'other_document',
    ];

    for (final source in [root, ...sources]) {
      for (final key in documentKeys) {
        if (source.containsKey(key)) {
          parseDocument(source[key], _documentLabelFromKey(key));
        }
      }
    }

    return documents;
  }

  static bool _looksLikeFileIdKey(String key) {
    final normalized = key.trim().toLowerCase();
    return normalized.endsWith('_id') ||
        normalized.endsWith('_ids') ||
        normalized.endsWith(' id') ||
        normalized.endsWith(' ids') ||
        normalized == 'id' ||
        normalized == 'fileid' ||
        normalized == 'file id';
  }

  static String _documentLabelFromKey(String key) {
    return key
        .replaceAll(RegExp(r'_?file$'), '')
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  static String? _listOrStringValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      for (final key in keys) {
        final value = source[key];
        if (value is List) {
          final items = value
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList();
          if (items.isNotEmpty) {
            return items.join(', ');
          }
          continue;
        }
        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty && text != '[]') {
          return text;
        }
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

  static double? _doubleFromMap(Map<String, dynamic>? source, String key) {
    if (source == null) {
      return null;
    }
    final value = source[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
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

class CustomerLedgerSummary {
  final double totalBilled;
  final double totalReceived;
  final double openingBalance;
  final double outstanding;
  final double creditLimit;
  final double availableCredit;
  final double overdueAmount;

  const CustomerLedgerSummary({
    required this.totalBilled,
    required this.totalReceived,
    required this.openingBalance,
    required this.outstanding,
    required this.creditLimit,
    required this.availableCredit,
    required this.overdueAmount,
  });

  factory CustomerLedgerSummary.fromJson(Map<String, dynamic>? json) {
    return CustomerLedgerSummary(
      totalBilled: _readDouble(json?['total_billed']),
      totalReceived: _readDouble(json?['total_received']),
      openingBalance: _readDouble(json?['opening_balance']),
      outstanding: _readDouble(json?['outstanding']),
      creditLimit: _readDouble(json?['credit_limit']),
      availableCredit: _readDouble(json?['available_credit']),
      overdueAmount: _readDouble(json?['overdue_amount']),
    );
  }
}

class CustomerLedgerAgeing {
  final double zeroTo30;
  final double days31To60;
  final double days61To90;
  final double days90Plus;

  const CustomerLedgerAgeing({
    required this.zeroTo30,
    required this.days31To60,
    required this.days61To90,
    required this.days90Plus,
  });

  factory CustomerLedgerAgeing.fromJson(Map<String, dynamic>? json) {
    return CustomerLedgerAgeing(
      zeroTo30: _readDouble(json?['0_30']),
      days31To60: _readDouble(json?['31_60']),
      days61To90: _readDouble(json?['61_90']),
      days90Plus: _readDouble(json?['90_plus']),
    );
  }
}

class CustomerLedgerTransaction {
  final String type;
  final String? referenceId;
  final String? referenceNumber;
  final DateTime? date;
  final String description;
  final double debit;
  final double credit;
  final double balance;
  final DateTime? dueDate;
  final String? status;

  const CustomerLedgerTransaction({
    required this.type,
    required this.referenceId,
    required this.referenceNumber,
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.dueDate,
    required this.status,
  });

  factory CustomerLedgerTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerLedgerTransaction(
      type: json['type']?.toString().trim().isNotEmpty == true
          ? json['type'].toString().trim()
          : '-',
      referenceId: _readNullableString(json['reference_id']),
      referenceNumber: _readNullableString(json['reference_number']),
      date: _readDate(json['date']),
      description: _readNullableString(json['description']) ?? '-',
      debit: _readDouble(json['debit']),
      credit: _readDouble(json['credit']),
      balance: _readDouble(json['balance']),
      dueDate: _readDate(json['due_date']),
      status: _readNullableString(json['status']),
    );
  }
}

class CustomerLedger {
  final String customerId;
  final String customerName;
  final CustomerLedgerSummary summary;
  final CustomerLedgerAgeing ageing;
  final List<CustomerLedgerTransaction> transactions;

  const CustomerLedger({
    required this.customerId,
    required this.customerName,
    required this.summary,
    required this.ageing,
    required this.transactions,
  });

  factory CustomerLedger.fromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'];
    return CustomerLedger(
      customerId: _readNullableString(json['customer_id']) ?? '',
      customerName: _readNullableString(json['customer_name']) ?? 'Customer',
      summary: CustomerLedgerSummary.fromJson(
        json['summary'] is Map<String, dynamic>
            ? json['summary'] as Map<String, dynamic>
            : null,
      ),
      ageing: CustomerLedgerAgeing.fromJson(
        json['ageing'] is Map<String, dynamic>
            ? json['ageing'] as Map<String, dynamic>
            : null,
      ),
      transactions: transactions is List
          ? transactions
                .whereType<Map<String, dynamic>>()
                .map(CustomerLedgerTransaction.fromJson)
                .toList()
          : const [],
    );
  }
}

double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is bool || value == null) {
    return 0;
  }
  return double.tryParse(value.toString().trim()) ?? 0;
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _readDate(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}

class UploadedFileReference {
  final String fileId;
  final String? url;
  final String? fileName;

  const UploadedFileReference({required this.fileId, this.url, this.fileName});

  factory UploadedFileReference.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
      return null;
    }

    final fileId = readString(const ['file_id', 'fileId', 'id']);
    if (fileId == null) {
      throw const FormatException('Uploaded file id missing in response.');
    }

    return UploadedFileReference(
      fileId: fileId,
      url: readString(const ['url', 'file_url', 'fileUrl', 'path', 'location']),
      fileName: readString(const ['file_name', 'filename', 'name', 'title']),
    );
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
  final String? gstCertificateId;
  final String? panCardId;
  final String? businessRegistrationCertificateId;
  final String? addressProofId;
  final String? purchaseAgreementId;
  final List<String>? otherDocumentIds;

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
    this.gstCertificateId,
    this.panCardId,
    this.businessRegistrationCertificateId,
    this.addressProofId,
    this.purchaseAgreementId,
    this.otherDocumentIds,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    final documents = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    void putDocument(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List && value.isEmpty) return;
      documents[key] = value;
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
    putDocument('gst_certificate_id', gstCertificateId);
    putDocument('pan_card_id', panCardId);
    putDocument(
      'business_registration_certificate_id',
      businessRegistrationCertificateId,
    );
    putDocument('address_proof_id', addressProofId);
    putDocument('purchase_agreement_id', purchaseAgreementId);
    putDocument('other_document_ids', otherDocumentIds);
    if (documents.isNotEmpty) {
      json['documents'] = documents;
    }
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
  final String? gstCertificateId;
  final String? panCardId;
  final String? businessRegistrationCertificateId;
  final String? addressProofId;
  final String? purchaseAgreementId;
  final List<String>? otherDocumentIds;

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
    this.gstCertificateId,
    this.panCardId,
    this.businessRegistrationCertificateId,
    this.addressProofId,
    this.purchaseAgreementId,
    this.otherDocumentIds,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    final documents = <String, dynamic>{};
    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    void putDocument(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is List && value.isEmpty) return;
      documents[key] = value;
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
    putDocument('gst_certificate_id', gstCertificateId);
    putDocument('pan_card_id', panCardId);
    putDocument(
      'business_registration_certificate_id',
      businessRegistrationCertificateId,
    );
    putDocument('address_proof_id', addressProofId);
    putDocument('purchase_agreement_id', purchaseAgreementId);
    putDocument('other_document_ids', otherDocumentIds);
    if (documents.isNotEmpty) {
      json['documents'] = documents;
    }
    return json;
  }
}
