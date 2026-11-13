import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationSearchResult {
  const LocationSearchResult({
    required this.name,
    required this.displayName,
    required this.location,
    this.addressLine,
    this.city,
    this.postcode,
  });

  final String name;
  final String displayName;
  final LatLng location;
  final String? addressLine;
  final String? city;
  final String? postcode;
}

class LocationSearchService {
  const LocationSearchService();

  static final Map<String, _LocationCacheEntry<List<LocationSearchResult>>>
  _searchCache = {};
  static final Map<String, Future<List<LocationSearchResult>>> _searchInFlight =
      {};
  static final Map<String, _LocationCacheEntry<LocationSearchResult?>>
  _reverseCache = {};
  static final Map<String, Future<LocationSearchResult?>> _reverseInFlight = {};
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _cacheLimit = 50;

  static const _baseUrl = String.fromEnvironment(
    'LOCATION_SEARCH_BASE_URL',
    defaultValue: 'https://photon.komoot.io',
  );

  Future<List<LocationSearchResult>> search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 3) return const [];

    final key = normalized.toLowerCase();
    final cached = _searchCache[key];
    if (cached != null && !cached.isExpired(_cacheTtl)) return cached.value;
    final inFlight = _searchInFlight[key];
    if (inFlight != null) return inFlight;

    final request = _searchRemote(normalized);
    _searchInFlight[key] = request;
    try {
      final results = await request;
      _storeCacheEntry(_searchCache, key, results);
      return results;
    } finally {
      _searchInFlight.remove(key);
    }
  }

  Future<List<LocationSearchResult>> _searchRemote(String normalized) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/api').replace(
            queryParameters: {'q': normalized, 'limit': '6', 'lang': 'en'},
          ),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Beassuite customer location search',
          },
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Location search failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    final features = decoded['features'];
    if (features is! List) return const [];

    return features
        .whereType<Map>()
        .map((feature) => _fromFeature(Map<String, dynamic>.from(feature)))
        .whereType<LocationSearchResult>()
        .toList(growable: false);
  }

  Future<LocationSearchResult?> reverseLookup(LatLng location) async {
    final key =
        '${location.latitude.toStringAsFixed(5)},'
        '${location.longitude.toStringAsFixed(5)}';
    final cached = _reverseCache[key];
    if (cached != null && !cached.isExpired(_cacheTtl)) return cached.value;
    final inFlight = _reverseInFlight[key];
    if (inFlight != null) return inFlight;

    final request = _reverseLookupRemote(location);
    _reverseInFlight[key] = request;
    try {
      final result = await request;
      _storeCacheEntry(_reverseCache, key, result);
      return result;
    } finally {
      _reverseInFlight.remove(key);
    }
  }

  Future<LocationSearchResult?> _reverseLookupRemote(LatLng location) async {
    final response = await http
        .get(
          Uri.parse('$_baseUrl/reverse').replace(
            queryParameters: {
              'lat': location.latitude.toString(),
              'lon': location.longitude.toString(),
              'lang': 'en',
            },
          ),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Beassuite customer location search',
          },
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Location lookup failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final features = decoded['features'];
    if (features is! List || features.isEmpty) return null;
    for (final feature in features.whereType<Map>()) {
      return _fromFeature(Map<String, dynamic>.from(feature));
    }
    return null;
  }

  LocationSearchResult? _fromFeature(Map<String, dynamic> feature) {
    final geometry = feature['geometry'];
    final properties = feature['properties'];
    if (geometry is! Map || properties is! Map) return null;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final longitude = _asDouble(coordinates[0]);
    final latitude = _asDouble(coordinates[1]);
    if (latitude == null || longitude == null) return null;

    final data = Map<String, dynamic>.from(properties);
    final name = _text(data['name']) ?? _text(data['street']) ?? 'Location';
    final streetLine = _joinHouseAndStreet(data);
    var addressLine = streetLine == null || streetLine == name
        ? name
        : '$name, $streetLine';

    // Use structured postcode first; fall back to extracting a 6-digit Indian
    // pincode from name/street fields (Photon sometimes omits the postcode
    // property and embeds it in the name instead).
    var postcode = _text(data['postcode']);
    if (postcode == null) {
      final candidateText = [
        _text(data['name']),
        _text(data['street']),
        _text(data['housenumber']),
      ].whereType<String>().join(' ');
      final m = RegExp(r'\b([1-9]\d{5})\b').firstMatch(candidateText);
      if (m != null) {
        postcode = m.group(1)!;
        // Strip the extracted pincode from the address line so it doesn't
        // duplicate into the Address field.
        addressLine = addressLine
            .replaceAll(RegExp(r'\b' + postcode + r'\b'), '')
            .replaceAll(RegExp(r',\s*,'), ',')
            .replaceAll(RegExp(r'(^[,\s]+|[,\s]+$)'), '')
            .trim();
        if (addressLine.isEmpty) addressLine = name;
      }
    }

    // Use structured city fields first. When all specific sub-state fields are
    // absent (common for Indian mandals / villages), fall back to scanning
    // name/street for a usable place name, excluding numbers (pincodes) and
    // known state/country values that are too broad to serve as a city.
    var city =
        _text(data['city']) ??
        _text(data['district']) ??
        _text(data['county']);
    if (city == null) {
      final stateText = _text(data['state']);
      final countryText = _text(data['country']);
      final excludeSet = <String>{
        if (postcode != null) postcode.toLowerCase(),
        if (stateText != null) stateText.toLowerCase(),
        if (countryText != null) countryText.toLowerCase(),
      };
      for (final key in const ['name', 'street']) {
        final v = _text(data[key]);
        if (v != null &&
            !RegExp(r'^\d+$').hasMatch(v) &&
            !excludeSet.contains(v.toLowerCase())) {
          city = v;
          break;
        }
      }
      city ??= stateText; // last resort: at least show the state
    }

    final parts = <String?>[
      addressLine,
      city,
      _text(data['state']),
      postcode,
      _text(data['country']),
    ];
    final seen = <String>{};
    final displayName = parts
        .whereType<String>()
        .where((part) => part.isNotEmpty && seen.add(part.toLowerCase()))
        .join(', ');

    return LocationSearchResult(
      name: name,
      displayName: displayName.isEmpty ? name : displayName,
      location: LatLng(latitude, longitude),
      addressLine: addressLine,
      city: city,
      postcode: postcode,
    );
  }

  String? _joinHouseAndStreet(Map<String, dynamic> data) {
    final street = _text(data['street']);
    final houseNumber = _text(data['housenumber']);
    if (street == null) return _text(data['name']);
    return houseNumber == null ? street : '$houseNumber $street';
  }

  String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  double? _asDouble(Object? value) => switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text),
    _ => null,
  };

  void _storeCacheEntry<T>(
    Map<String, _LocationCacheEntry<T>> cache,
    String key,
    T value,
  ) {
    cache.removeWhere((_, entry) => entry.isExpired(_cacheTtl));
    while (cache.length >= _cacheLimit) {
      cache.remove(cache.keys.first);
    }
    cache[key] = _LocationCacheEntry(value, DateTime.now());
  }
}

class _LocationCacheEntry<T> {
  const _LocationCacheEntry(this.value, this.storedAt);

  final T value;
  final DateTime storedAt;

  bool isExpired(Duration ttl) => DateTime.now().difference(storedAt) >= ttl;
}
