class ExtractedField<T> {
  const ExtractedField(this.value, this.confidence, {required this.wasSpoken});

  final T? value;
  final String confidence;
  final bool wasSpoken;

  bool get isHigh => confidence == 'high';
  bool get isMedium => confidence == 'medium';
  bool get isLow => confidence == 'low';
}

class VoiceExtractionResult {
  const VoiceExtractionResult({
    required this.shopName,
    required this.contactPerson,
    required this.mobileNumber,
    required this.gstin,
    required this.customerType,
    required this.address,
    required this.city,
    required this.pincode,
  });

  final ExtractedField<String> shopName;
  final ExtractedField<String> contactPerson;
  final ExtractedField<String> mobileNumber;
  final ExtractedField<String> gstin;
  final ExtractedField<String> customerType;
  final ExtractedField<String> address;
  final ExtractedField<String> city;
  final ExtractedField<String> pincode;
}

class ExtractionResult {
  const ExtractionResult(this.values, this.wasSpoken);

  final Map<String, String?> values;
  final Map<String, bool> wasSpoken;
}

class VoiceCustomerExtractionService {
  const VoiceCustomerExtractionService();

  Future<VoiceExtractionResult> extract({
    required String transcript,
    required List<String> customerTypes,
  }) async {
    final extractor = VoiceFieldExtractor(
      VoiceFieldExtractor.defaultFieldTriggers,
      customerTypes: customerTypes,
    );
    return extractor.extractVoiceResult(transcript);
  }
}

class VoiceFieldExtractor {
  VoiceFieldExtractor(this.fieldTriggers, {required this.customerTypes});

  final Map<String, List<String>> fieldTriggers;
  final List<String> customerTypes;

  static const defaultFieldTriggers = <String, List<String>>{
    // Keep specific name triggers before bare "name/naam"; bare forms are
    // useful for field staff but are more ambiguous.
    'shopName': [
      'shop name',
      'shop naam',
      'dukaan ka naam',
      'dukan ka naam',
      'dukaan naam',
      'dukan naam',
      'business name',
      'store name',
      'firm name',
      'company name',
      'outlet name',
    ],
    'contactPerson': [
      'contact person',
      'contact name',
      'contact naam',
      'person name',
      'person naam',
      'owner name',
      'owner naam',
      'malik ka naam',
      'malik naam',
      'naam',
      'name',
    ],
    'mobileNumber': [
      'mobile number',
      'mobile no',
      'mobile',
      'phone number',
      'phone no',
      'phone',
      'contact number',
      'contact no',
      'number',
      'mobile ka number',
      'phone ka number',
    ],
    'gstin': ['gstin', 'gst number', 'gst no', 'gst', 'gstin number'],
    'customerType': [
      'customer type',
      'customer category',
      'type',
      'category',
      'grahak type',
      'customer ka type',
    ],
    'address': [
      'address',
      'pata',
      'shop address',
      'dukaan ka pata',
      'dukan ka pata',
      'location address',
      'area',
    ],
    'city': ['city', 'shehar', 'shahar', 'town', 'nagar', 'district'],
    'pincode': [
      'pin code',
      'pincode',
      'pin number',
      'pin no',
      'postal code',
      'pin',
    ],
  };

  ExtractionResult extract(String rawTranscript) {
    final text = _normalize(rawTranscript);
    final matches = _findTriggerMatches(text);
    final values = <String, String?>{};
    final wasSpoken = <String, bool>{};

    for (final field in fieldTriggers.keys) {
      wasSpoken[field] = matches.any((match) => match.field == field);
    }

    for (var index = 0; index < matches.length; index++) {
      final current = matches[index];
      final end = index + 1 < matches.length
          ? matches[index + 1].start
          : text.length;
      var value = text.substring(current.end, end).trim();
      value = _stripLeadingConnectors(value);
      values[current.field] = _cleanFieldValue(current.field, value);
    }

    for (final field in fieldTriggers.keys) {
      values.putIfAbsent(field, () => null);
    }

    return ExtractionResult(values, wasSpoken);
  }

  VoiceExtractionResult extractVoiceResult(String rawTranscript) {
    final result = extract(rawTranscript);

    ExtractedField<String> field(String key) {
      final value = result.values[key];
      final spoken = result.wasSpoken[key] ?? false;
      return ExtractedField<String>(
        value,
        value == null ? 'low' : 'high',
        wasSpoken: spoken,
      );
    }

    return VoiceExtractionResult(
      shopName: field('shopName'),
      contactPerson: field('contactPerson'),
      mobileNumber: field('mobileNumber'),
      gstin: field('gstin'),
      customerType: field('customerType'),
      address: field('address'),
      city: field('city'),
      pincode: field('pincode'),
    );
  }

  List<_TriggerMatch> _findTriggerMatches(String text) {
    final all = <_TriggerMatch>[];
    fieldTriggers.forEach((field, triggers) {
      final sorted = [...triggers]
        ..sort((a, b) {
          final length = b.length.compareTo(a.length);
          return length == 0 ? a.compareTo(b) : length;
        });
      for (final trigger in sorted) {
        final pattern = RegExp(
          r'(^|[^a-z0-9])(' + RegExp.escape(trigger) + r')(?=$|[^a-z0-9])',
        );
        for (final match in pattern.allMatches(text)) {
          final prefix = match.group(1) ?? '';
          final start = match.start + prefix.length;
          all.add(_TriggerMatch(field, start, start + trigger.length));
        }
      }
    });

    all.sort((a, b) {
      final start = a.start.compareTo(b.start);
      if (start != 0) return start;
      return (b.end - b.start).compareTo(a.end - a.start);
    });

    final filtered = <_TriggerMatch>[];
    for (final match in all) {
      if (filtered.isEmpty || match.start >= filtered.last.end) {
        filtered.add(match);
      }
    }
    return filtered;
  }

  String _normalize(String value) {
    var text = value.toLowerCase().trim();
    const fillers = [
      'um',
      'uh',
      'umm',
      'hmm',
      'like',
      'matlab',
      'yaar',
      'basically',
      'actually',
      'please',
      'pls',
      'ji',
      'haan',
      'ha',
    ];
    for (final filler in fillers) {
      text = text.replaceAll(RegExp(r'\b' + filler + r'\b'), ' ');
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  String _stripLeadingConnectors(String value) {
    return value
        .replaceFirst(RegExp(r'^(is|hai|he|hain|ka|ki|ke|:|,|-|=|\s)+'), '')
        .trim();
  }

  String? _cleanFieldValue(String field, String value) {
    final trimmed = _trimPunctuation(value);
    if (trimmed.isEmpty) return null;
    return switch (field) {
      'mobileNumber' => _cleanMobile(trimmed),
      'pincode' => _cleanPincode(trimmed),
      'gstin' => _cleanGstin(trimmed),
      'customerType' => _cleanCustomerType(trimmed),
      'shopName' ||
      'contactPerson' ||
      'address' ||
      'city' => _titleCase(_capLength(_trimTrailingFillers(trimmed), field)),
      _ => trimmed,
    };
  }

  String? _cleanMobile(String value) {
    var digits = _wordsToDigits(value).replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) return digits;
    return null;
  }

  String? _cleanPincode(String value) {
    final digits = _wordsToDigits(value).replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^\d{6}$').hasMatch(digits) ? digits : null;
  }

  String? _cleanGstin(String value) {
    final gstin = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return RegExp(
          r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
        ).hasMatch(gstin)
        ? gstin
        : null;
  }

  String? _cleanCustomerType(String value) {
    final text = value.toLowerCase();
    final synonym = _customerTypeFromSynonym(text);
    if (synonym != null) return synonym;

    String? best;
    var bestDistance = 999;
    for (final option in customerTypes) {
      final distance = _levenshtein(text, option.toLowerCase());
      if (distance < bestDistance) {
        bestDistance = distance;
        best = option;
      }
    }
    if (best != null && bestDistance <= 3) return best;
    return null;
  }

  String? _customerTypeFromSynonym(String text) {
    String? findOption(List<String> needles) {
      if (!needles.any(text.contains)) return null;
      for (final option in customerTypes) {
        final normalized = option.toLowerCase();
        if (needles.any(normalized.contains)) return option;
      }
      return null;
    }

    return findOption(['retail', 'retailer', 'dukaan', 'dukan', 'shop']) ??
        findOption(['whole', 'wholesale', 'wholesaler']) ??
        findOption(['distrib', 'stockist']) ??
        findOption(['business', 'company']) ??
        findOption(['individual', 'person']) ??
        findOption(['general', 'trade']);
  }

  String _wordsToDigits(String value) {
    final map = <String, String>{
      'zero': '0',
      'oh': '0',
      'o': '0',
      'shunya': '0',
      'sunna': '0',
      'one': '1',
      'ek': '1',
      'two': '2',
      'do': '2',
      'too': '2',
      'three': '3',
      'teen': '3',
      'tin': '3',
      'four': '4',
      'for': '4',
      'char': '4',
      'chaar': '4',
      'five': '5',
      'panch': '5',
      'paanch': '5',
      'six': '6',
      'chhe': '6',
      'chhah': '6',
      'che': '6',
      'seven': '7',
      'saat': '7',
      'sat': '7',
      'eight': '8',
      'aath': '8',
      'ath': '8',
      'nine': '9',
      'nau': '9',
      'nav': '9',
    };

    return value
        .split(RegExp(r'(\s+|,|-)+'))
        .map((part) => map[part.trim().toLowerCase()] ?? part)
        .join(' ');
  }

  String _trimTrailingFillers(String value) {
    var text = value.trim();
    const trailing = ['hai', 'he', 'hain', 'please', 'ji'];
    var changed = true;
    while (changed) {
      changed = false;
      for (final word in trailing) {
        final next = text.replaceFirst(RegExp(r'\s+' + word + r'$'), '');
        if (next != text) {
          text = next.trim();
          changed = true;
        }
      }
    }
    return text;
  }

  String _capLength(String value, String field) {
    final max = field == 'address' ? 160 : 100;
    return value.length <= max ? value : value.substring(0, max).trim();
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          if (part.length == 1) return part.toUpperCase();
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }

  String _trimPunctuation(String value) {
    return value
        .replaceAll(RegExp(r'^[\s,.:;\-]+'), '')
        .replaceAll(RegExp(r'[\s,.:;\-]+$'), '')
        .trim();
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 0; i < a.length; i++) {
      final current = <int>[i + 1];
      for (var j = 0; j < b.length; j++) {
        final insert = current[j] + 1;
        final delete = previous[j + 1] + 1;
        final replace = previous[j] + (a[i] == b[j] ? 0 : 1);
        current.add([insert, delete, replace].reduce((x, y) => x < y ? x : y));
      }
      previous = current;
    }
    return previous.last;
  }
}

class _TriggerMatch {
  const _TriggerMatch(this.field, this.start, this.end);

  final String field;
  final int start;
  final int end;
}
