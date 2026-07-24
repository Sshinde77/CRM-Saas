import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({this.statusCode, required this.message});

  @override
  String toString() {
    if (statusCode == null) return 'ApiException: $message';
    return 'ApiException($statusCode): $message';
  }
}

class ApiService {
  static const String _defaultBaseUrl =
      'https://crm-saas-backend-9nom.onrender.com';

  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, this.baseUrl = _defaultBaseUrl})
      : _client = client ?? http.Client();

  void close() {
    _client.close();
  }

  Future<String> fetchHealthStatus() async {
    return 'ok';
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final response = await _client
        .post(
          uri,
          headers: const {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final responseBody = response.body.trim();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(responseBody),
      );
    }

    if (responseBody.isEmpty) {
      return 'Login successful.';
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }

        final token = decoded['token'];
        if (token is String && token.trim().isNotEmpty) {
          return 'Login successful.';
        }
      }
    } catch (_) {
      // If the backend returns plain text or a different JSON shape,
      // fall back to a generic success message.
    }

    return 'Login successful.';
  }

  Future<String> registerOrganization({
    required String organizationName,
    required String businessType,
    required String gstNumber,
    required String panNumber,
    required String address,
    required String phone,
    required String email,
    required String financialYear,
    required String logoUrl,
    required String adminName,
    required String password,
    String role = 'admin',
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final response = await _client
        .post(
          uri,
          headers: const {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'organization_name': organizationName,
            'business_type': businessType,
            'gst_number': gstNumber,
            'pan_number': panNumber,
            'address': address,
            'phone': phone,
            'email': email,
            'financial_year': financialYear,
            'logo_url': logoUrl,
            'admin_name': adminName,
            'password': password,
            'role': role,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final responseBody = response.body.trim();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(responseBody),
      );
    }

    if (responseBody.isEmpty) {
      return 'Organization created successfully.';
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to a generic success message if the backend response is not JSON.
    }

    return 'Organization created successfully.';
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) return 'Registration failed.';

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final candidates = [
          decoded['message'],
          decoded['detail'],
          decoded['error'],
        ];
        for (final candidate in candidates) {
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate;
          }
        }
      }
    } catch (_) {
      // If the backend doesn't return JSON, surface the raw body when useful.
    }

    return body;
  }
}
