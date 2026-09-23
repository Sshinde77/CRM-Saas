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

  static const _baseUrl = String.fromEnvironment(
    'LOCATION_SEARCH_BASE_URL',
    defaultValue: 'https://photon.komoot.io',
  );

  Future<List<LocationSearchResult>> search(String query) async {
    final normalized = query.trim();
    if (normalized.length < 3) return const [];

    final response = await http
        .get(
          Uri.parse('$_baseUrl/api').replace(
            queryParameters: {'q': normalized, 'limit': '6', 'lang': 'en'},
          ),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'CRM-SaaS customer location search',
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
    final city =
        _text(data['city']) ??
        _text(data['district']) ??
        _text(data['county']) ??
        _text(data['state']);
    final streetLine = _joinHouseAndStreet(data);
    final addressLine = streetLine == null || streetLine == name
        ? name
        : '$name, $streetLine';
    final parts = <String?>[
      addressLine,
      city,
      _text(data['state']),
      _text(data['postcode']),
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
      postcode: _text(data['postcode']),
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
}
