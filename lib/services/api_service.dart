import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';

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
  static String? _accessToken;

  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, this.baseUrl = ApiConstants.baseUrl})
    : _client = client ?? http.Client();

  void close() {
    _client.close();
  }

  Future<String> fetchHealthStatus() async {
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.health,
      requiresAuth: false,
    );

    final decoded = _tryDecodeBody(response.body);
    if (decoded is Map<String, dynamic>) {
      final status = decoded['status']?.toString().trim();
      if (status != null && status.isNotEmpty) {
        return status;
      }
    }

    return response.body.trim().isEmpty ? 'ok' : response.body.trim();
  }

  Future<AuthSession> login({required LoginRequest request}) async {
    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.authLogin,
      requiresAuth: false,
      body: request.toJson(),
    );

    final responseBody = response.body.trim();
    final decoded = _requireDecodedMap(
      responseBody,
      fallbackMessage: 'Invalid login response.',
    );

    final token = _extractToken(decoded);
    if (token == null || token.isEmpty) {
      throw const ApiException(message: 'Login token missing in response.');
    }

    _accessToken = token;
    return AuthSession(
      accessToken: token,
      refreshToken: _extractRefreshToken(decoded),
      message: _extractSuccessMessage(decoded, 'Login successful.'),
      user: _extractUserProfile(decoded),
    );
  }

  Future<ApiResponse<void>> registerOrganization({
    required RegisterOrganizationRequest request,
  }) async {
    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.authRegister,
      requiresAuth: false,
      body: request.toJson(),
    );

    final responseBody = response.body.trim();
    final decoded = _tryDecodeBody(responseBody);
    final message = decoded is Map<String, dynamic>
        ? _extractSuccessMessage(decoded, 'Organization created successfully.')
        : 'Organization created successfully.';

    return ApiResponse<void>(
      success: true,
      statusCode: response.statusCode,
      message: message,
      rawBody: responseBody,
    );
  }

  Future<CurrentUserProfile> fetchCurrentUserProfile() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.authMe,
      requiresAuth: true,
    );
    final responseBody = response.body.trim();
    final decoded = _requireDecodedMap(
      responseBody,
      fallbackMessage: 'Invalid profile response.',
    );
    final profile = _extractUserProfile(decoded);
    if (profile == null) {
      throw const ApiException(message: 'Invalid profile response.');
    }
    return profile;
  }

  Future<void> logout() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      _accessToken = null;
      return;
    }

    await _send(
      method: 'POST',
      endpoint: ApiEndpoints.authLogout,
      requiresAuth: true,
    );
    _accessToken = null;
  }

  static String? get accessToken => _accessToken;
  static void clearAccessToken() => _accessToken = null;
  static void setAccessToken(String? token) => _accessToken = token?.trim();

  static String? _extractToken(Map<String, dynamic> decoded) {
    final directCandidates = [
      decoded['token'],
      decoded['access_token'],
      decoded['accessToken'],
    ];

    for (final candidate in directCandidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    final nestedData = decoded['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedCandidates = [
        nestedData['token'],
        nestedData['access_token'],
        nestedData['accessToken'],
      ];
      for (final candidate in nestedCandidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    }

    return null;
  }

  static String? _extractRefreshToken(Map<String, dynamic> decoded) {
    final directCandidates = [
      decoded['refresh_token'],
      decoded['refreshToken'],
    ];

    for (final candidate in directCandidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    final nestedData = decoded['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedCandidates = [
        nestedData['refresh_token'],
        nestedData['refreshToken'],
      ];
      for (final candidate in nestedCandidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    }

    return null;
  }

  CurrentUserProfile? _extractUserProfile(Map<String, dynamic> decoded) {
    final candidates = [
      decoded['user'],
      decoded['data'],
      decoded,
    ];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        final nestedUser = candidate['user'];
        if (nestedUser is Map<String, dynamic>) {
          return CurrentUserProfile.fromJson(nestedUser);
        }

        final hasName =
            candidate['name'] != null ||
            candidate['full_name'] != null ||
            candidate['admin_name'] != null;
        if (hasName) {
          return CurrentUserProfile.fromJson(candidate);
        }
      }
    }

    return null;
  }

  String _extractSuccessMessage(
    Map<String, dynamic> decoded,
    String fallback,
  ) {
    final candidates = [
      decoded['message'],
      decoded['detail'],
      decoded['status'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return fallback;
  }

  Map<String, dynamic> _requireDecodedMap(
    String body, {
    required String fallbackMessage,
  }) {
    final decoded = _tryDecodeBody(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException(message: fallbackMessage);
  }

  dynamic _tryDecodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  Future<http.Response> _send({
    required String method,
    required String endpoint,
    bool requiresAuth = false,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _buildHeaders(requiresAuth: requiresAuth);
    final encodedBody = body == null ? null : jsonEncode(body);

    _logRequest(method: method, uri: uri, headers: headers, body: encodedBody);

    late final http.Response response;
    try {
      response = await _dispatch(
        method: method,
        uri: uri,
        headers: headers,
        body: encodedBody,
      ).timeout(ApiConstants.requestTimeout);
    } catch (error) {
      _logTransportError(method: method, uri: uri, error: error);
      throw ApiException(message: 'Network request failed: $error');
    }

    _logResponse(
      method: method,
      uri: uri,
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body.trim()),
      );
    }

    return response;
  }

  Map<String, String> _buildHeaders({required bool requiresAuth}) {
    if (!requiresAuth) {
      return Map<String, String>.from(ApiConstants.defaultHeaders);
    }

    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    return ApiConstants.authorizedHeaders(token);
  }

  Future<http.Response> _dispatch({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) {
    switch (method.toUpperCase()) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: body);
      case 'PUT':
        return _client.put(uri, headers: headers, body: body);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: body);
      default:
        throw ApiException(message: 'Unsupported HTTP method: $method');
    }
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) {
    debugPrint('[API REQUEST] $method $uri');
    debugPrint('[API REQUEST HEADERS] ${_sanitizeHeaders(headers)}');
    if (body != null && body.trim().isNotEmpty) {
      debugPrint('[API REQUEST BODY] $body');
    }
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
  }) {
    debugPrint('[API RESPONSE] $method $uri -> $statusCode');
    debugPrint(
      '[API RESPONSE BODY] ${body.trim().isEmpty ? '<empty>' : body.trim()}',
    );
  }

  void _logTransportError({
    required String method,
    required Uri uri,
    required Object error,
  }) {
    debugPrint('[API ERROR] $method $uri -> $error');
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == ApiConstants.authorizationHeader.toLowerCase()) {
        return MapEntry(key, value.isEmpty ? value : 'Bearer ***');
      }
      return MapEntry(key, value);
    });
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) return 'API request failed.';

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
