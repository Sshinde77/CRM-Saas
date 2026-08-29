import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/customer_activity_models.dart';
import '../models/customer_model.dart';
import '../models/auth_models.dart';
import '../models/app_user.dart';
import '../models/plan_model.dart';
import '../models/role_model.dart';

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
  static String? _refreshToken;
  static String? _savedRole;

  static const String _prefsAccessTokenKey = 'auth.access_token';
  static const String _prefsRefreshTokenKey = 'auth.refresh_token';
  static const String _prefsRoleKey = 'auth.role';

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
      timeout: ApiConstants.loginRequestTimeout,
      retryOnTimeout: true,
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
    final refreshToken = _extractRefreshToken(decoded);

    _accessToken = token;
    _refreshToken = refreshToken?.trim();
    _savedRole = _extractSavedRole(
      decoded: decoded,
      fallback: _extractUserRole(decoded),
    );
    await _persistAuthState(
      accessToken: token,
      refreshToken: refreshToken,
      role: _savedRole,
    );
    return AuthSession(
      accessToken: token,
      refreshToken: refreshToken,
      message: _extractSuccessMessage(decoded, 'Login successful.'),
      user: _extractUserProfile(decoded),
    );
  }

  Future<ApiResponse<void>> registerOrganization({
    required RegisterOrganizationRequest request,
  }) async {
    http.Response response;
    try {
      response = await _send(
        method: 'POST',
        endpoint: ApiEndpoints.authRegister,
        requiresAuth: false,
        body: request.toJson(),
        timeout: ApiConstants.loginRequestTimeout,
        retryOnTimeout: true,
      );
    } on ApiException catch (error) {
      if (!_shouldRetryRegisterWithLegacyPayload(error, request)) {
        rethrow;
      }

      response = await _send(
        method: 'POST',
        endpoint: ApiEndpoints.authRegister,
        requiresAuth: false,
        body: request.toJson(includeExtendedFields: false),
        timeout: ApiConstants.loginRequestTimeout,
        retryOnTimeout: true,
      );
    }

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

  bool _shouldRetryRegisterWithLegacyPayload(
    ApiException error,
    RegisterOrganizationRequest request,
  ) {
    final statusCode = error.statusCode;
    if (!request.hasExtendedFields) {
      return false;
    }

    return statusCode == 400 || statusCode == 422;
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

  Future<TrialStatus> fetchTrialStatus() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.authMe,
      requiresAuth: true,
    );
    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid trial status response.',
    );
    return TrialStatus.fromAuthMeJson(decoded);
  }

  Future<AuthMeResponse> fetchAuthMeDetails() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.authMe,
      requiresAuth: true,
    );
    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid profile response.',
    );
    return AuthMeResponse.fromJson(decoded);
  }

  Future<Map<String, dynamic>> fetchOrganizationMe() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.organizationsMe,
      requiresAuth: true,
    );
    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiException(message: 'Invalid organization me response.');
  }

  Future<Map<String, dynamic>> fetchOrganizationSettings() async {
    final token = _accessToken;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(message: 'Missing access token.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.organizationsSettings,
      requiresAuth: true,
    );
    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiException(
      message: 'Invalid organization settings response.',
    );
  }

  Future<Map<String, dynamic>> fetchOrganizationSettingsView() async {
    final results = await Future.wait([
      fetchOrganizationMe(),
      fetchOrganizationSettings(),
    ]);

    final merged = <String, dynamic>{};
    for (final result in results) {
      merged.addAll(result);
    }
    return merged;
  }

  Future<String?> uploadOrganizationSettingsFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final response = await _sendMultipart(
      method: 'POST',
      endpoint: ApiEndpoints.organizationsSettingsUploadFile,
      requiresAuth: true,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return _extractUploadedUrl(_tryDecodeBody(response.body.trim()));
  }

  Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final response = await _sendMultipart(
      method: 'POST',
      endpoint: ApiEndpoints.filesUpload,
      requiresAuth: true,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return _extractUploadedUrl(_tryDecodeBody(response.body.trim()));
  }

  Future<UploadedFileReference> uploadGenericFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final response = await _sendMultipart(
      method: 'POST',
      endpoint: ApiEndpoints.filesUpload,
      requiresAuth: true,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid file upload response.',
    );
    return _extractUploadedFileReference(decoded);
  }

  Future<CustomerDocument> uploadCustomerDocument({
    required String customerId,
    required String documentType,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _sendMultipart(
      method: 'POST',
      endpoint: ApiEndpoints.customersDocuments(id),
      requiresAuth: true,
      fileBytes: fileBytes,
      fileName: fileName,
      fields: {'document_type': documentType},
    );
    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid customer document upload response.',
    );
    return CustomerDocument.fromJson(decoded);
  }

  Future<List<CustomerDocument>> fetchCustomerDocuments(
    String customerId, {
    String? documentType,
  }) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final type = documentType?.trim();
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.customersDocuments(id),
      requiresAuth: true,
      queryParameters: type == null || type.isEmpty
          ? null
          : {'document_type': type},
    );

    final decoded = _tryDecodeBody(response.body.trim());
    final rawDocuments = _extractGenericList(decoded, const [
      'documents',
      'data',
      'items',
      'results',
    ], fallbackMessage: 'Invalid customer documents response.');

    return rawDocuments
        .whereType<Map<String, dynamic>>()
        .map(CustomerDocument.fromJson)
        .toList();
  }

  Future<String?> uploadOrganizationLogo({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final response = await _sendMultipart(
      method: 'POST',
      endpoint: ApiEndpoints.organizationsSettingsLogo,
      requiresAuth: true,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return _extractUploadedUrl(_tryDecodeBody(response.body.trim()));
  }

  Future<List<PlanModel>> fetchPlans() async {
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.plansList,
      requiresAuth: true,
    );

    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is! List) {
      throw const ApiException(message: 'Invalid plans response.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PlanModel.fromJson)
        .toList();
  }

  Future<List<RoleModel>> fetchRoles() async {
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.rolesList,
      requiresAuth: true,
    );

    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is! List) {
      throw const ApiException(message: 'Invalid roles response.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RoleModel.fromJson)
        .where(
          (role) => role.id.trim().isNotEmpty && role.name.trim().isNotEmpty,
        )
        .toList();
  }

  Future<List<AppUser>> fetchAssignableUsers() async {
    final users = await fetchUsers();
    return users.where((user) {
      final role = (user.role ?? '').trim().toLowerCase();
      final systemRole = (user.systemRole ?? '').trim().toLowerCase();
      final roleName = user.roleDetail?.name.trim().toLowerCase();
      return role == 'sales_officer' ||
          systemRole == 'staff' ||
          roleName == 'sales officer' ||
          roleName == 'staff';
    }).toList();
  }

  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async {
    final query = CustomerListQuery(
      search: search,
      category: category,
      isActive: isActive,
      assignedSalesOfficerId: assignedSalesOfficerId,
    ).toQueryParameters();

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.customersList,
      requiresAuth: true,
      queryParameters: query.isEmpty ? null : query,
    );

    final decoded = _tryDecodeBody(response.body.trim());
    final rawCustomers = _extractCustomersList(decoded);

    return rawCustomers
        .whereType<Map<String, dynamic>>()
        .map(CustomerModel.fromJson)
        .where((customer) => customer.name.trim().isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchRawList({
    required String endpoint,
    Map<String, String>? queryParameters,
    List<String> candidateKeys = const ['data', 'items', 'results'],
    String fallbackMessage = 'Invalid list response.',
  }) async {
    final response = await _send(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: true,
      queryParameters: queryParameters,
    );
    final decoded = _tryDecodeBody(response.body.trim());
    final rawItems = _extractGenericList(
      decoded,
      candidateKeys,
      fallbackMessage: fallbackMessage,
    );
    return rawItems.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> fetchDeliveryPartnerDeliveries({
    required String deliveryPartnerId,
  }) {
    return fetchRawList(
      endpoint: ApiEndpoints.deliveriesList,
      queryParameters: _cleanQuery({
        'delivery_partner_id': deliveryPartnerId,
      }),
      candidateKeys: const ['deliveries', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid deliveries response.',
    );
  }

  Future<Map<String, dynamic>?> fetchCurrentVehicleStock(
    String deliveryPartnerId,
  ) async {
    final id = deliveryPartnerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing delivery partner id.');
    }

    http.Response response;
    try {
      response = await _send(
        method: 'GET',
        endpoint: ApiEndpoints.vehicleStockCurrent(id),
        requiresAuth: true,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded == null) return null;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      final session = decoded['session'];
      if (session is Map<String, dynamic>) return session;
      final stock = decoded['vehicle_stock'];
      if (stock is Map<String, dynamic>) return stock;
      return decoded;
    }
    throw const ApiException(message: 'Invalid vehicle stock response.');
  }

  Future<List<Map<String, dynamic>>> fetchMyAttendance() async {
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.attendanceMe,
      requiresAuth: true,
    );
    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    if (decoded is Map<String, dynamic>) {
      for (final key in const [
        'attendance',
        'records',
        'data',
        'items',
        'results',
      ]) {
        final value = decoded[key];
        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
        if (value is Map<String, dynamic>) {
          return [value];
        }
      }
      return [decoded];
    }
    throw const ApiException(message: 'Invalid attendance response.');
  }

  Future<void> shareMyLocation({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    String? label,
    DateTime? capturedAt,
  }) async {
    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (accuracyMeters != null) {
      payload['accuracy_meters'] = accuracyMeters;
    }
    final trimmedLabel = label?.trim();
    if (trimmedLabel != null && trimmedLabel.isNotEmpty) {
      payload['label'] = trimmedLabel;
    }
    if (capturedAt != null) {
      payload['captured_at'] = capturedAt.toUtc().toIso8601String();
    }

    await _send(
      method: 'POST',
      endpoint: ApiEndpoints.usersMeLocation,
      requiresAuth: true,
      body: payload,
    );
  }

  Future<List<Map<String, dynamic>>> fetchLeads({String? status}) {
    return fetchRawList(
      endpoint: ApiEndpoints.leadsList,
      queryParameters: _cleanQuery({'status': status}),
      candidateKeys: const ['leads', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid leads response.',
    );
  }

  Future<Map<String, dynamic>> fetchLeadById(String leadId) async {
    final id = leadId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing lead id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.leadsDetail(id),
      requiresAuth: true,
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid lead detail response.',
    );

    final leadPayload = decoded['lead'];
    if (leadPayload is Map<String, dynamic>) {
      return leadPayload;
    }

    final dataPayload = decoded['data'];
    if (dataPayload is Map<String, dynamic>) {
      return dataPayload;
    }

    return decoded;
  }

  Future<List<Map<String, dynamic>>> fetchQuotations() {
    return fetchRawList(
      endpoint: ApiEndpoints.quotationsList,
      candidateKeys: const ['quotations', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid quotations response.',
    );
  }

  Future<Map<String, dynamic>> createQuotation({
    required Map<String, dynamic> request,
  }) async {
    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.quotationsList,
      requiresAuth: true,
      body: request,
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid quotation create response.',
    );

    return decoded;
  }

  Future<Map<String, dynamic>> fetchQuotationById(String quotationId) async {
    final id = quotationId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing quotation id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.quotationsDetail(id),
      requiresAuth: true,
    );

    return _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid quotation detail response.',
    );
  }

  Future<Map<String, dynamic>> updateQuotationStatus({
    required String quotationId,
    required String status,
  }) async {
    final id = quotationId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing quotation id.');
    }

    final response = await _send(
      method: 'PATCH',
      endpoint: ApiEndpoints.quotationsDetail(id),
      requiresAuth: true,
      body: {'status': status},
    );

    return _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid quotation status response.',
    );
  }

  Future<List<int>> downloadQuotationPdf(String quotationId) async {
    final id = quotationId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing quotation id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.quotationsPdf(id),
      requiresAuth: true,
    );

    return response.bodyBytes;
  }

  Future<List<Map<String, dynamic>>> fetchWarehouses() {
    return fetchRawList(
      endpoint: ApiEndpoints.warehousesList,
      candidateKeys: const ['warehouses', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid warehouses response.',
    );
  }

  Future<Map<String, dynamic>> convertQuotationToOrder({
    required String quotationId,
    required Map<String, dynamic> request,
  }) async {
    final id = quotationId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing quotation id.');
    }

    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.quotationsConvert(id),
      requiresAuth: true,
      body: request,
    );

    return _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid quotation conversion response.',
    );
  }

  Future<void> deleteQuotation(String quotationId) async {
    final id = quotationId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing quotation id.');
    }

    await _send(
      method: 'DELETE',
      endpoint: ApiEndpoints.quotationsDetail(id),
      requiresAuth: true,
    );
  }

  Future<List<Map<String, dynamic>>> fetchSuppliers({
    String? search,
    String? category,
    bool? isActive,
  }) {
    return fetchRawList(
      endpoint: ApiEndpoints.suppliersList,
      queryParameters: _cleanQuery({
        'search': search,
        'category': category,
        'is_active': isActive?.toString(),
      }),
      candidateKeys: const ['suppliers', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid suppliers response.',
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories({String? search}) {
    return fetchRawList(
      endpoint: ApiEndpoints.categoriesList,
      queryParameters: _cleanQuery({'search': search}),
      candidateKeys: const ['categories', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid categories response.',
    );
  }

  Future<List<Map<String, dynamic>>> fetchBrands({String? search}) {
    return fetchRawList(
      endpoint: ApiEndpoints.brandsList,
      queryParameters: _cleanQuery({'search': search}),
      candidateKeys: const ['brands', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid brands response.',
    );
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    String? barcode,
  }) {
    return fetchRawList(
      endpoint: ApiEndpoints.productsList,
      queryParameters: _cleanQuery({
        'search': search,
        'category_id': categoryId,
        'is_active': isActive?.toString(),
        'barcode': barcode,
      }),
      candidateKeys: const ['products', 'data', 'items', 'results'],
      fallbackMessage: 'Invalid products response.',
    );
  }

  Future<CustomerModel> fetchCustomerById(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.customersDetail(id),
      requiresAuth: true,
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid customer response.',
    );

    return CustomerModel.fromJson(decoded);
  }

  Future<CustomerLedger> fetchCustomerLedger(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.customersLedger(id),
      requiresAuth: true,
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid customer ledger response.',
    );

    return CustomerLedger.fromJson(decoded);
  }

  Future<List<CustomerOrderRecord>> fetchCustomerOrders(
    String customerId,
  ) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.ordersList,
      requiresAuth: true,
      queryParameters: {'customer_id': id},
    );

    final decoded = _tryDecodeBody(response.body.trim());
    final rawOrders = _extractGenericList(decoded, const [
      'orders',
      'data',
      'results',
      'items',
    ], fallbackMessage: 'Invalid customer orders response.');

    return rawOrders
        .whereType<Map<String, dynamic>>()
        .map(CustomerOrderRecord.fromJson)
        .toList();
  }

  Future<List<CustomerPaymentRecord>> fetchCustomerPayments(
    String customerId,
  ) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.customersPayments(id),
      requiresAuth: true,
    );

    final decoded = _tryDecodeBody(response.body.trim());
    final rawPayments = _extractGenericList(decoded, const [
      'payments',
      'data',
      'results',
      'items',
    ], fallbackMessage: 'Invalid customer payments response.');

    return rawPayments
        .whereType<Map<String, dynamic>>()
        .map(CustomerPaymentRecord.fromJson)
        .toList();
  }

  Future<CustomerModel> createCustomer({
    required CustomerCreateRequest request,
  }) async {
    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.customersCreate,
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid customer create response.',
    );

    return CustomerModel.fromJson(decoded);
  }

  Future<CustomerModel> updateCustomer({
    required String customerId,
    required CustomerUpdateRequest request,
  }) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    final response = await _send(
      method: 'PATCH',
      endpoint: ApiEndpoints.customersUpdate(id),
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid customer update response.',
    );

    return CustomerModel.fromJson(decoded);
  }

  Future<void> deleteCustomer(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing customer id.');
    }

    await _send(
      method: 'DELETE',
      endpoint: ApiEndpoints.customersDelete(id),
      requiresAuth: true,
    );
  }

  Future<void> deleteUser(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing user id.');
    }

    await _send(
      method: 'DELETE',
      endpoint: ApiEndpoints.usersDelete(id),
      requiresAuth: true,
    );
  }

  Future<List<AppUser>> fetchUsers() async {
    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.usersList,
      requiresAuth: true,
    );

    final decoded = _tryDecodeBody(response.body.trim());
    final rawUsers = _extractUsersList(decoded);

    return rawUsers
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .where(
          (user) => user.name.trim().isNotEmpty || user.email.trim().isNotEmpty,
        )
        .toList();
  }

  Future<AppUser> fetchUserById(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing user id.');
    }

    final response = await _send(
      method: 'GET',
      endpoint: ApiEndpoints.usersDetail(id),
      requiresAuth: true,
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid user response.',
    );

    return AppUser.fromJson(decoded);
  }

  Future<AppUser> createUser({required CreateUserRequest request}) async {
    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.usersCreate,
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid create user response.',
    );

    return AppUser.fromJson(decoded);
  }

  Future<Map<String, dynamic>> updateOrganizationSettings({
    required OrganizationSettingsRequest request,
  }) async {
    final response = await _send(
      method: 'PUT',
      endpoint: ApiEndpoints.organizationsSettings,
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _tryDecodeBody(response.body.trim());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const {};
  }

  Future<AppUser> updateUser({
    required String userId,
    required UpdateUserRequest request,
  }) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing user id.');
    }

    final response = await _send(
      method: 'PATCH',
      endpoint: ApiEndpoints.usersUpdate(id),
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid update user response.',
    );

    return AppUser.fromJson(decoded);
  }

  Future<AppUser> updateUserStatus({
    required String userId,
    required UpdateUserStatusRequest request,
  }) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing user id.');
    }

    final response = await _send(
      method: 'PATCH',
      endpoint: ApiEndpoints.usersStatus(id),
      requiresAuth: true,
      body: request.toJson(),
    );

    final decoded = _requireDecodedMap(
      response.body.trim(),
      fallbackMessage: 'Invalid status update response.',
    );

    return AppUser.fromJson(decoded);
  }

  Future<void> resetUserPassword({
    required String userId,
    required ResetUserPasswordRequest request,
  }) async {
    final id = userId.trim();
    if (id.isEmpty) {
      throw const ApiException(message: 'Missing user id.');
    }

    final response = await _send(
      method: 'POST',
      endpoint: ApiEndpoints.usersResetPassword(id),
      requiresAuth: true,
      body: request.toJson(),
    );

    final body = response.body.trim();
    if (body.isEmpty) {
      return;
    }

    final decoded = _tryDecodeBody(body);
    if (decoded is Map<String, dynamic>) {
      return;
    }
  }

  Future<void> changePassword({required ChangePasswordRequest request}) async {
    await _send(
      method: 'POST',
      endpoint: ApiEndpoints.authChangePassword,
      requiresAuth: true,
      body: request.toJson(),
    );
  }

  Future<void> logout() async {
    final accessToken = _accessToken?.trim();
    final refreshToken = (_refreshToken ?? _accessToken)?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      _clearTokens();
      return;
    }

    await _send(
      method: 'POST',
      endpoint: ApiEndpoints.authLogout,
      requiresAuth: true,
      body: <String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken ?? accessToken,
      },
    );
    _clearTokens();
    await _clearPersistedAuthState();
  }

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get savedRole => _savedRole;
  static void clearAccessToken() => _clearTokens();
  static void setAccessToken(String? token) => _accessToken = token?.trim();
  static void setRefreshToken(String? token) => _refreshToken = token?.trim();

  static Future<bool> restorePersistedAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_prefsAccessTokenKey)?.trim();
    final refreshToken = prefs.getString(_prefsRefreshTokenKey)?.trim();
    final role = prefs.getString(_prefsRoleKey)?.trim();

    _accessToken = accessToken?.isEmpty == true ? null : accessToken;
    _refreshToken = refreshToken?.isEmpty == true ? null : refreshToken;
    _savedRole = role?.isEmpty == true ? null : role;
    return (_accessToken ?? '').isNotEmpty;
  }

  static void _clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _savedRole = null;
  }

  static Future<void> _persistAuthState({
    required String accessToken,
    String? refreshToken,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenValue = accessToken.trim();
    if (tokenValue.isEmpty) {
      await _clearPersistedAuthState();
      return;
    }

    await prefs.setString(_prefsAccessTokenKey, tokenValue);
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await prefs.setString(_prefsRefreshTokenKey, refreshToken.trim());
    } else {
      await prefs.remove(_prefsRefreshTokenKey);
    }

    if (role != null && role.trim().isNotEmpty) {
      await prefs.setString(_prefsRoleKey, role.trim());
    } else {
      await prefs.remove(_prefsRoleKey);
    }
  }

  static Future<void> _clearPersistedAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsAccessTokenKey);
    await prefs.remove(_prefsRefreshTokenKey);
    await prefs.remove(_prefsRoleKey);
  }

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

    final nestedTokens = decoded['tokens'];
    if (nestedTokens is Map<String, dynamic>) {
      final tokenCandidates = [
        nestedTokens['token'],
        nestedTokens['access_token'],
        nestedTokens['accessToken'],
      ];
      for (final candidate in tokenCandidates) {
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

    final nestedTokens = decoded['tokens'];
    if (nestedTokens is Map<String, dynamic>) {
      final tokenCandidates = [
        nestedTokens['refresh_token'],
        nestedTokens['refreshToken'],
      ];
      for (final candidate in tokenCandidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    }

    return null;
  }

  static String? _extractUserRole(Map<String, dynamic> decoded) {
    final candidates = [decoded['user'], decoded['data'], decoded];

    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        final nestedUser = candidate['user'];
        if (nestedUser is Map<String, dynamic>) {
          final role = nestedUser['role']?.toString().trim();
          if (role != null && role.isNotEmpty) {
            return role;
          }
        }

        final role = candidate['role']?.toString().trim();
        if (role != null && role.isNotEmpty) {
          return role;
        }
      }
    }

    return null;
  }

  static String? _extractSavedRole({
    required Map<String, dynamic> decoded,
    String? fallback,
  }) {
    final direct = _extractUserRole(decoded);
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim();
    }
    final fallbackValue = fallback?.trim();
    return fallbackValue == null || fallbackValue.isEmpty
        ? null
        : fallbackValue;
  }

  static String? _extractUploadedUrl(dynamic decoded) {
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['url'],
        decoded['file_url'],
        decoded['fileUrl'],
        decoded['path'],
        decoded['location'],
      ];

      for (final candidate in candidates) {
        final value = candidate?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }

      final nestedData = decoded['data'];
      if (nestedData is Map<String, dynamic>) {
        return _extractUploadedUrl(nestedData);
      }
    }

    return null;
  }

  static UploadedFileReference _extractUploadedFileReference(
    Map<String, dynamic> decoded,
  ) {
    try {
      return UploadedFileReference.fromJson(decoded);
    } on FormatException {
      final nestedData = decoded['data'];
      if (nestedData is Map<String, dynamic>) {
        return _extractUploadedFileReference(nestedData);
      }
      rethrow;
    }
  }

  CurrentUserProfile? _extractUserProfile(Map<String, dynamic> decoded) {
    final candidates = [decoded['user'], decoded['data'], decoded];

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

  String _extractSuccessMessage(Map<String, dynamic> decoded, String fallback) {
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

  Map<String, String>? _cleanQuery(Map<String, String?> values) {
    final query = <String, String>{};
    for (final entry in values.entries) {
      final value = entry.value?.trim();
      if (value != null && value.isNotEmpty) {
        query[entry.key] = value;
      }
    }
    return query.isEmpty ? null : query;
  }

  List<dynamic> _extractUsersList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['users'],
        decoded['data'],
        decoded['results'],
        decoded['items'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    throw const ApiException(message: 'Invalid users response.');
  }

  List<dynamic> _extractCustomersList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['customers'],
        decoded['data'],
        decoded['results'],
        decoded['items'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    throw const ApiException(message: 'Invalid customers response.');
  }

  List<dynamic> _extractGenericList(
    dynamic decoded,
    List<String> candidateKeys, {
    required String fallbackMessage,
  }) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      for (final key in candidateKeys) {
        final candidate = decoded[key];
        if (candidate is List) {
          return candidate;
        }
      }
    }

    throw ApiException(message: fallbackMessage);
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
    Map<String, String>? queryParameters,
    Duration? timeout,
    bool retryOnTimeout = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );
    final encodedBody = body == null ? null : jsonEncode(body);

    final attempts = retryOnTimeout ? 2 : 1;
    final effectiveTimeout = timeout ?? ApiConstants.requestTimeout;
    var headers = _buildHeaders(requiresAuth: requiresAuth);
    var unauthorizedRetryUsed = false;

    var attempt = 1;
    while (attempt <= attempts) {
      _logRequest(
        method: method,
        uri: uri,
        headers: headers,
        body: encodedBody,
        attempt: attempt,
        timeout: effectiveTimeout,
      );

      try {
        final response = await _dispatch(
          method: method,
          uri: uri,
          headers: headers,
          body: encodedBody,
        ).timeout(effectiveTimeout);

        _logResponse(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          body: response.body,
          attempt: attempt,
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          if (response.statusCode == 401 &&
              requiresAuth &&
              !unauthorizedRetryUsed) {
            unauthorizedRetryUsed = true;
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              headers = _buildHeaders(requiresAuth: requiresAuth);
              debugPrint(
                '[API RETRY] $method $uri -> retrying after token refresh',
              );
              continue;
            }
          }

          throw ApiException(
            statusCode: response.statusCode,
            message: _extractErrorMessage(response.body.trim()),
          );
        }

        return response;
      } on TimeoutException catch (error) {
        _logTransportError(
          method: method,
          uri: uri,
          error: error,
          attempt: attempt,
        );

        if (attempt < attempts) {
          debugPrint('[API RETRY] $method $uri -> retrying after timeout');
          attempt++;
          continue;
        }

        throw const ApiException(
          message:
              'The server is still starting. Please wait while we retry your login.',
        );
      } catch (error) {
        _logTransportError(
          method: method,
          uri: uri,
          error: error,
          attempt: attempt,
        );
        if (error is ApiException) {
          rethrow;
        }
        throw ApiException(message: 'Network request failed: $error');
      }
    }

    throw const ApiException(message: 'API request failed.');
  }

  Future<http.Response> _sendMultipart({
    required String method,
    required String endpoint,
    required bool requiresAuth,
    required Uint8List fileBytes,
    required String fileName,
    Map<String, String>? fields,
    Duration? timeout,
    bool retryOnTimeout = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final attempts = retryOnTimeout ? 2 : 1;
    final effectiveTimeout = timeout ?? ApiConstants.requestTimeout;
    var headers = _buildMultipartHeaders(requiresAuth: requiresAuth);
    var unauthorizedRetryUsed = false;

    var attempt = 1;
    while (attempt <= attempts) {
      _logMultipartRequest(
        method: method,
        uri: uri,
        headers: headers,
        attempt: attempt,
        timeout: effectiveTimeout,
        fields: fields,
        fileName: fileName,
      );

      try {
        final request = http.MultipartRequest(method.toUpperCase(), uri);
        request.headers.addAll(headers);
        if (fields != null && fields.isNotEmpty) {
          request.fields.addAll(fields);
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
            contentType: _mediaTypeForFileName(fileName),
          ),
        );

        final streamedResponse = await request.send().timeout(effectiveTimeout);
        final response = await http.Response.fromStream(streamedResponse);

        _logResponse(
          method: method,
          uri: uri,
          statusCode: response.statusCode,
          body: response.body,
          attempt: attempt,
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          if (response.statusCode == 401 &&
              requiresAuth &&
              !unauthorizedRetryUsed) {
            unauthorizedRetryUsed = true;
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              headers = _buildMultipartHeaders(requiresAuth: requiresAuth);
              debugPrint(
                '[API RETRY] $method $uri -> retrying after token refresh',
              );
              continue;
            }
          }

          throw ApiException(
            statusCode: response.statusCode,
            message: _extractErrorMessage(response.body.trim()),
          );
        }

        return response;
      } on TimeoutException catch (error) {
        _logTransportError(
          method: method,
          uri: uri,
          error: error,
          attempt: attempt,
        );

        if (attempt < attempts) {
          debugPrint('[API RETRY] $method $uri -> retrying after timeout');
          attempt++;
          continue;
        }

        throw const ApiException(
          message:
              'The server is still starting. Please wait while we retry your login.',
        );
      } catch (error) {
        _logTransportError(
          method: method,
          uri: uri,
          error: error,
          attempt: attempt,
        );
        if (error is ApiException) {
          rethrow;
        }
        throw ApiException(message: 'Network request failed: $error');
      }
    }

    throw const ApiException(message: 'API request failed.');
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = _refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      _clearTokens();
      return false;
    }

    final uri = Uri.parse('$baseUrl${ApiEndpoints.authRefresh}');
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    final body = jsonEncode(<String, dynamic>{'refresh_token': refreshToken});

    _logRequest(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: body,
      attempt: 1,
      timeout: ApiConstants.requestTimeout,
    );

    try {
      final response = await _dispatch(
        method: 'POST',
        uri: uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.requestTimeout);

      _logResponse(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        body: response.body,
        attempt: 1,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _clearTokens();
        return false;
      }

      final decoded = _requireDecodedMap(
        response.body.trim(),
        fallbackMessage: 'Invalid refresh token response.',
      );
      final newAccessToken = _extractToken(decoded);
      if (newAccessToken == null || newAccessToken.isEmpty) {
        _clearTokens();
        return false;
      }

      final newRefreshToken = _extractRefreshToken(decoded);
      _accessToken = newAccessToken;
      _refreshToken = (newRefreshToken ?? refreshToken).trim();
      return true;
    } on TimeoutException catch (error) {
      _logTransportError(method: 'POST', uri: uri, error: error, attempt: 1);
      return false;
    } catch (error) {
      _logTransportError(method: 'POST', uri: uri, error: error, attempt: 1);
      if (error is ApiException) {
        return false;
      }
      return false;
    }
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

  Map<String, String> _buildMultipartHeaders({required bool requiresAuth}) {
    final headers = <String, String>{
      ApiConstants.acceptHeader: ApiConstants.jsonMimeType,
    };
    if (requiresAuth) {
      final token = _accessToken;
      if (token == null || token.trim().isEmpty) {
        throw const ApiException(message: 'Missing access token.');
      }
      headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix} $token';
    }
    return headers;
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

  MediaType _mediaTypeForFileName(String fileName) {
    final extension = fileName.trim().split('.').last.toLowerCase();
    return switch (extension) {
      'png' => MediaType('image', 'png'),
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'webp' => MediaType('image', 'webp'),
      'gif' => MediaType('image', 'gif'),
      'bmp' => MediaType('image', 'bmp'),
      'svg' => MediaType('image', 'svg+xml'),
      'pdf' => MediaType('application', 'pdf'),
      'doc' => MediaType('application', 'msword'),
      'docx' => MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      ),
      'xls' => MediaType('application', 'vnd.ms-excel'),
      'xlsx' => MediaType(
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
      'txt' => MediaType('text', 'plain'),
      'csv' => MediaType('text', 'csv'),
      _ => MediaType('application', 'octet-stream'),
    };
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
    required int attempt,
    required Duration timeout,
  }) {
    debugPrint(
      '[API REQUEST] $method $uri (attempt $attempt, timeout ${timeout.inSeconds}s)',
    );
    debugPrint('[API REQUEST HEADERS] ${_sanitizeHeaders(headers)}');
    if (body != null && body.trim().isNotEmpty) {
      debugPrint('[API REQUEST BODY] $body');
    }
  }

  void _logMultipartRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required int attempt,
    required Duration timeout,
    Map<String, String>? fields,
    required String fileName,
  }) {
    debugPrint(
      '[API REQUEST] $method $uri (multipart, attempt $attempt, timeout ${timeout.inSeconds}s)',
    );
    debugPrint('[API REQUEST HEADERS] ${_sanitizeHeaders(headers)}');
    if (fields != null && fields.isNotEmpty) {
      debugPrint('[API REQUEST FIELDS] ${jsonEncode(fields)}');
    }
    debugPrint('[API REQUEST FILE] $fileName');
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required String body,
    required int attempt,
  }) {
    debugPrint('[API RESPONSE] $method $uri -> $statusCode (attempt $attempt)');
    debugPrint(
      '[API RESPONSE BODY] ${body.trim().isEmpty ? '<empty>' : body.trim()}',
    );
  }

  void _logTransportError({
    required String method,
    required Uri uri,
    required Object error,
    required int attempt,
  }) {
    debugPrint('[API ERROR] $method $uri -> $error (attempt $attempt)');
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
