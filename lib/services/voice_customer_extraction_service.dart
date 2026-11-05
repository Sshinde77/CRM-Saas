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
    // ── Shop / business name ──────────────────────────────────────────────
    'shopName': [
      'shop name',
      'shop naam',
      'dukaan ka naam',
      'dukan ka naam',
      'dukaan naam',
      'dukan naam',
      'dukaan ka name',
      'dukan ka name',
      'firm ka naam',
      'firm naam',
      'firm name',
      'company ka naam',
      'company naam',
      'company name',
      'business name',
      'business naam',
      'trade name',
      'trade naam',
      'store name',
      'store naam',
      'outlet name',
      'outlet naam',
      'agency name',
      'agency naam',
      'brand name',
      'brand naam',
      'proprietorship name',
    ],

    // ── Contact / owner name ──────────────────────────────────────────────
    'contactPerson': [
      'contact person',
      'contact naam',
      'contact name',
      'owner name',
      'owner naam',
      'malik ka naam',
      'malik naam',
      'malik name',
      'proprietor name',
      'proprietor naam',
      'person name',
      'person naam',
      'mera naam',
      'apna naam',
      'naam',
      'name',
    ],

    // ── Mobile / phone ────────────────────────────────────────────────────
    'mobileNumber': [
      'mobile number',
      'mobile no',
      'mobile num',
      'mobile',
      'mob number',
      'mob no',
      'mob',
      'phone number',
      'phone no',
      'phone num',
      'phone',
      'contact number',
      'contact no',
      'contact num',
      'whatsapp number',
      'whatsapp no',
      'whatsapp',
      'number',
      'no',
      'mobile ka number',
      'phone ka number',
      'number hai',
      'mob hai',
    ],

    // ── GSTIN ─────────────────────────────────────────────────────────────
    'gstin': [
      'gstin number',
      'gstin no',
      'gstin',
      'gst number',
      'gst no',
      'gst num',
      'gst',
      'gst registration',
    ],

    // ── Customer type / category ──────────────────────────────────────────
    'customerType': [
      'customer type',
      'customer category',
      'grahak type',
      'grahak category',
      'customer ka type',
      'customer ka category',
      'type of customer',
      'category of customer',
      'type',
      'category',
    ],

    // ── Address ───────────────────────────────────────────────────────────
    'address': [
      'shop address',
      'dukaan ka pata',
      'dukan ka pata',
      'dukaan address',
      'dukan address',
      'delivery address',
      'billing address',
      'full address',
      'pura pata',
      'address hai',
      'address',
      'pata',
      'location',
      'locality',
      'street',
      'gali',
      'mohalla',
      'area',
      'sector',
      'ward',
    ],

    // ── City ──────────────────────────────────────────────────────────────
    'city': [
      'city name',
      'shehar ka naam',
      'shahar ka naam',
      'city',
      'shehar',
      'shahar',
      'town',
      'nagar',
      'tehsil',
      'taluka',
      'zila',
      'jila',
      'district',
    ],

    // ── Pincode ───────────────────────────────────────────────────────────
    'pincode': [
      'pin code',
      'pincode',
      'pin number',
      'pin no',
      'pin num',
      'postal code',
      'zip code',
      'zip',
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
      // Trim trailing segment after "aur"/"and" that looks like a new field
      // but wasn't detected as a keyword (avoids polluting values).
      value = _trimAfterFieldSeparator(value);
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
          final len = b.length.compareTo(a.length);
          return len == 0 ? a.compareTo(b) : len;
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

    // Keep only the first match at each position (longest trigger wins).
    final filtered = <_TriggerMatch>[];
    for (final match in all) {
      if (filtered.isEmpty || match.start >= filtered.last.end) {
        filtered.add(match);
      }
    }
    return filtered;
  }

  // ── Normalisation ────────────────────────────────────────────────────────

  String _normalize(String value) {
    var text = value.trim();

    // Convert Indic script digits to ASCII so Hindi/Gujarati/Bengali STT output
    // is handled correctly.
    text = _indicToAsciiDigits(text);

    text = text.toLowerCase();

    // Collapse spaced-out digit strings like "9 8 7 6 5 4 3 2 1 0" → "9876543210"
    text = text.replaceAllMapped(
      RegExp(r'(?<!\d)(\d)(\s+\d)+(?!\d)'),
      (m) => m.group(0)!.replaceAll(RegExp(r'\s+'), ''),
    );

    // Remove common filler / discourse words (Hinglish + Indian English).
    const fillers = [
      'um',
      'uh',
      'umm',
      'hmm',
      'arre',
      'arey',
      'yaar',
      'like',
      'basically',
      'actually',
      'please',
      'pls',
      'ji',
      'haan',
      'ha',
      'theek',
      'theek hai',
      'achha',
      'accha',
      'okay',
      'ok',
      'right',
      'so',
      'then',
      'matlab',
      'matalab',
      'samjhe',
      'bas',
      'sunno',
      'bolo',
      'batao',
    ];
    for (final filler in fillers) {
      text = text.replaceAll(
        RegExp(r'\b' + RegExp.escape(filler) + r'\b'),
        ' ',
      );
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Convert Devanagari (Hindi/Marathi), Gujarati, Bengali, and other common
  /// Indic script digit characters to ASCII 0–9.
  String _indicToAsciiDigits(String text) {
    // Each Unicode block of Indic digits starts at a known code point.
    const blocks = [
      0x0966, // Devanagari ०–९
      0x0AE6, // Gujarati ૦–૯
      0x09E6, // Bengali ০–৯
      0x0966, // Devanagari (already listed, harmless duplicate)
      0x0C66, // Telugu ౦–౯
      0x0CE6, // Kannada ೦–೯
      0x0B66, // Odia ୦–୯
      0x0D66, // Malayalam ൦–൯
      0x0A66, // Gurmukhi ੦–੯
      0x0BE6, // Tamil ௦–௯
    ];

    var out = text;
    for (final base in blocks) {
      out = out.replaceAllMapped(
        RegExp(
          '[${String.fromCharCode(base)}-${String.fromCharCode(base + 9)}]',
        ),
        (m) {
          final offset = m.group(0)!.codeUnitAt(0) - base;
          return offset.toString();
        },
      );
    }
    return out;
  }

  String _stripLeadingConnectors(String value) {
    return value
        .replaceFirst(
          RegExp(
            r'^(is|hai|he|hain|ka|ki|ke|toh|to|bhi|se|mein|me|ko|aur|and|wala|wali|hoga|tha|hain|:|,|-|=|\s)+',
          ),
          '',
        )
        .trim();
  }

  /// Remove trailing content that starts with a field-separator word when no
  /// field keyword was detected there (keeps values clean).
  String _trimAfterFieldSeparator(String value) {
    return value.replaceFirst(RegExp(r'\s+(aur|and)\s+\S+.*$'), '').trim();
  }

  // ── Field-value cleaning ─────────────────────────────────────────────────

  String? _cleanFieldValue(String field, String value) {
    final trimmed = _trimPunctuation(value);
    if (trimmed.isEmpty) return null;
    return switch (field) {
      'mobileNumber' => _cleanMobile(trimmed),
      'pincode' => _cleanPincode(trimmed),
      'gstin' => _cleanGstin(trimmed),
      'customerType' => _cleanCustomerType(trimmed),
      'city' => _cleanCity(trimmed),
      'shopName' ||
      'contactPerson' ||
      'address' => _titleCase(_capLength(_trimTrailingFillers(trimmed), field)),
      _ => trimmed,
    };
  }

  String? _cleanMobile(String value) {
    var digits = _wordsToDigits(value).replaceAll(RegExp(r'\D'), '');
    // Strip leading country code 91 / +91
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (digits.length == 13 && digits.startsWith('091')) {
      digits = digits.substring(3);
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
        final norm = option.toLowerCase();
        if (needles.any(norm.contains)) return option;
      }
      return null;
    }

    return findOption(['retail', 'retailer', 'dukaan', 'dukan', 'shop']) ??
        findOption(['whole', 'wholesale', 'wholesaler']) ??
        findOption(['distrib', 'stockist']) ??
        findOption(['business', 'company', 'firm']) ??
        findOption(['individual', 'person', 'proprietor']) ??
        findOption(['general', 'trade']);
  }

  /// Normalise common alternate Indian city names to their current official
  /// spellings so downstream lookups succeed.
  String? _cleanCity(String value) {
    final cleaned = _titleCase(_capLength(_trimTrailingFillers(value), 'city'));
    if (cleaned.isEmpty) return null;
    const aliases = <String, String>{
      'bombay': 'Mumbai',
      'madras': 'Chennai',
      'calcutta': 'Kolkata',
      'poona': 'Pune',
      'baroda': 'Vadodara',
      'benares': 'Varanasi',
      'kashi': 'Varanasi',
      'benaras': 'Varanasi',
      'simla': 'Shimla',
      'mussoorie': 'Mussoorie',
      'pondicherry': 'Puducherry',
      'ooty': 'Udhagamandalam',
    };
    final lower = cleaned.toLowerCase();
    return aliases[lower] ?? cleaned;
  }

  // ── Number word → digit conversion ──────────────────────────────────────

  /// Converts spoken digit words to ASCII digits (0–9).
  /// Handles English, Hindi, Gujarati, Marathi, and common Hinglish variants.
  String _wordsToDigits(String value) {
    const map = <String, String>{
      // ── zero ──
      'zero': '0', 'oh': '0', 'o': '0',
      'shunya': '0', 'sunna': '0', 'sifar': '0',
      // ── one ──
      'one': '1', 'ek': '1', 'ak': '1', 'ik': '1',
      // ── two ──
      'two': '2', 'do': '2', 'too': '2', 'be': '2',
      // ── three ──
      'three': '3', 'teen': '3', 'tin': '3', 'tran': '3', 'tri': '3',
      // ── four ──
      'four': '4', 'for': '4', 'char': '4', 'chaar': '4',
      // ── five ──
      'five': '5', 'panch': '5', 'paanch': '5', 'panj': '5',
      // ── six ──
      'six': '6', 'chhe': '6', 'chhah': '6', 'che': '6', 'chha': '6',
      'saha': '6',
      // ── seven ──
      'seven': '7', 'saat': '7', 'sat': '7', 'saath': '7',
      // ── eight ──
      'eight': '8', 'aath': '8', 'ath': '8', 'aat': '8',
      // ── nine ──
      'nine': '9', 'nau': '9', 'nav': '9', 'nao': '9',
    };

    return value
        .split(RegExp(r'(\s+|,|-)+'))
        .map((part) => map[part.trim().toLowerCase()] ?? part)
        .join(' ');
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  String _trimTrailingFillers(String value) {
    var text = value.trim();
    const trailing = ['hai', 'he', 'hain', 'please', 'ji', 'hoga', 'tha'];
    var changed = true;
    while (changed) {
      changed = false;
      for (final word in trailing) {
        final next = text.replaceFirst(
          RegExp(r'\s+' + RegExp.escape(word) + r'$'),
          '',
        );
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
