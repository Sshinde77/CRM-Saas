import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../models/api_response.dart';
import '../models/customer_activity_models.dart';
import '../models/customer_model.dart';
import '../models/delivery_detail_model.dart';
import '../models/app_user.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';
import '../models/role_model.dart';

class ApiProvider extends ChangeNotifier {
  ApiProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  bool _isLoading = false;
  String? _errorMessage;
  AuthSession? _session;
  CurrentUserProfile? _currentUser;
  AuthMeResponse? _authMe;
  List<RoleModel>? _roles;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthSession? get session => _session;
  CurrentUserProfile? get currentUser => _currentUser;
  AuthMeResponse? get authMe => _authMe;
  List<RoleModel>? get roles => _roles;
  bool get isAuthenticated => (_session?.accessToken ?? '').trim().isNotEmpty;
  ApiService get service => _apiService;

  bool can(String module, String action) =>
      _authMe?.can(module, action) ?? true;
  bool canView(String module) => can(module, 'view');

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await _apiService.login(
        request: LoginRequest(email: email, password: password),
      );
      _session = session;
      _currentUser = session.user;
      final authMe = await _apiService.fetchAuthMeDetails();
      _authMe = authMe;
      _currentUser = authMe.user ?? session.user;
      notifyListeners();
      return session;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse<void>> registerOrganization({
    required RegisterOrganizationRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _apiService.registerOrganization(request: request);
      notifyListeners();
      return response;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CurrentUserProfile?> fetchCurrentUserProfile({
    bool force = false,
  }) async {
    if (!force && _currentUser != null) {
      return _currentUser;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final profile = await _apiService.fetchCurrentUserProfile();
      _currentUser = profile;
      notifyListeners();
      return profile;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthMeResponse?> fetchAuthMe({bool force = false}) async {
    if (!force && _authMe != null) {
      return _authMe;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final authMe = await _apiService.fetchAuthMeDetails();
      _authMe = authMe;
      _currentUser = authMe.user ?? _currentUser;
      notifyListeners();
      return authMe;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<RoleModel>> fetchRoles({bool force = false}) async {
    if (!force && _roles != null) {
      return _roles!;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final roles = await _apiService.fetchRoles();
      _roles = roles;
      notifyListeners();
      return roles;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<AppUser>> fetchAssignableUsers() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final users = await _apiService.fetchAssignableUsers();
      notifyListeners();
      return users;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<CustomerModel>> fetchCustomers({
    String? search,
    String? category,
    bool? isActive,
    String? assignedSalesOfficerId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final customers = await _apiService.fetchCustomers(
        search: search,
        category: category,
        isActive: isActive,
        assignedSalesOfficerId: assignedSalesOfficerId,
      );
      notifyListeners();
      return customers;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeads({String? status}) {
    return _apiService.fetchLeads(status: status);
  }

  Future<List<Map<String, dynamic>>> fetchDeliveryPartnerDeliveries({
    required String deliveryPartnerId,
  }) {
    return _apiService.fetchDeliveryPartnerDeliveries(
      deliveryPartnerId: deliveryPartnerId,
    );
  }

  Future<DeliveryDetail> fetchDeliveryById(String deliveryId) {
    return _apiService.fetchDeliveryById(deliveryId);
  }

  Future<List<int>> downloadDeliveryChallan(String deliveryId) {
    return _apiService.downloadDeliveryChallan(deliveryId);
  }

  Future<Map<String, dynamic>> acceptDelivery(String deliveryId) {
    return _apiService.acceptDelivery(deliveryId);
  }

  Future<Map<String, dynamic>> rejectDelivery({
    required String deliveryId,
    required String reason,
  }) {
    return _apiService.rejectDelivery(deliveryId: deliveryId, reason: reason);
  }

  Future<Map<String, dynamic>> confirmDelivery({
    required String deliveryId,
    required Map<String, dynamic> payload,
  }) {
    return _apiService.confirmDelivery(
      deliveryId: deliveryId,
      payload: payload,
    );
  }

  Future<Map<String, dynamic>?> fetchCurrentVehicleStock(
    String deliveryPartnerId,
  ) {
    return _apiService.fetchCurrentVehicleStock(deliveryPartnerId);
  }

  Future<List<Map<String, dynamic>>> fetchVehicleStockSessions() {
    return _apiService.fetchVehicleStockSessions();
  }

  Future<Map<String, dynamic>> submitEndOfDayReturn({
    required String sessionId,
    required List<Map<String, dynamic>> items,
  }) {
    return _apiService.submitEndOfDayReturn(sessionId: sessionId, items: items);
  }

  Future<Map<String, dynamic>> reconcileVehicleStock({
    required String sessionId,
    required Map<String, dynamic> payload,
  }) {
    return _apiService.reconcileVehicleStock(
      sessionId: sessionId,
      payload: payload,
    );
  }

  Future<List<Map<String, dynamic>>> fetchMyAttendance() {
    return _apiService.fetchMyAttendance();
  }

  Future<Map<String, dynamic>> checkInAttendance(String type) {
    return _apiService.checkInAttendance(type);
  }

  Future<void> shareMyLocation({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    String? label,
    DateTime? capturedAt,
  }) {
    return _apiService.shareMyLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      label: label,
      capturedAt: capturedAt,
    );
  }

  Future<Map<String, dynamic>> fetchLeadById(String leadId) {
    return _apiService.fetchLeadById(leadId);
  }

  Future<List<Map<String, dynamic>>> fetchQuotations() {
    return _apiService.fetchQuotations();
  }

  Future<Map<String, dynamic>> createQuotation({
    required Map<String, dynamic> request,
  }) {
    return _apiService.createQuotation(request: request);
  }

  Future<Map<String, dynamic>> fetchQuotationById(String quotationId) {
    return _apiService.fetchQuotationById(quotationId);
  }

  Future<Map<String, dynamic>> updateQuotationStatus({
    required String quotationId,
    required String status,
  }) {
    return _apiService.updateQuotationStatus(
      quotationId: quotationId,
      status: status,
    );
  }

  Future<List<int>> downloadQuotationPdf(String quotationId) {
    return _apiService.downloadQuotationPdf(quotationId);
  }

  Future<List<Map<String, dynamic>>> fetchWarehouses() {
    return _apiService.fetchWarehouses();
  }

  Future<Map<String, dynamic>> convertQuotationToOrder({
    required String quotationId,
    required Map<String, dynamic> request,
  }) {
    return _apiService.convertQuotationToOrder(
      quotationId: quotationId,
      request: request,
    );
  }

  Future<void> deleteQuotation(String quotationId) {
    return _apiService.deleteQuotation(quotationId);
  }

  Future<List<Map<String, dynamic>>> fetchSuppliers({
    String? search,
    String? category,
    bool? isActive,
  }) {
    return _apiService.fetchSuppliers(
      search: search,
      category: category,
      isActive: isActive,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories({String? search}) {
    return _apiService.fetchCategories(search: search);
  }

  Future<List<Map<String, dynamic>>> fetchBrands({String? search}) {
    return _apiService.fetchBrands(search: search);
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? search,
    String? categoryId,
    bool? isActive,
    String? barcode,
  }) {
    return _apiService.fetchProducts(
      search: search,
      categoryId: categoryId,
      isActive: isActive,
      barcode: barcode,
    );
  }

  Future<CustomerModel> fetchCustomerById(String customerId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final customer = await _apiService.fetchCustomerById(customerId);
      notifyListeners();
      return customer;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CustomerLedger> fetchCustomerLedger(String customerId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final ledger = await _apiService.fetchCustomerLedger(customerId);
      notifyListeners();
      return ledger;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<CustomerOrderRecord>> fetchCustomerOrders(
    String customerId,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final orders = await _apiService.fetchCustomerOrders(customerId);
      notifyListeners();
      return orders;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<CustomerPaymentRecord>> fetchCustomerPayments(
    String customerId,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final payments = await _apiService.fetchCustomerPayments(customerId);
      notifyListeners();
      return payments;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CustomerModel> createCustomer({
    required CustomerCreateRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final customer = await _apiService.createCustomer(request: request);
      notifyListeners();
      return customer;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<UploadedFileReference> uploadGenericFile({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final file = await _apiService.uploadGenericFile(
        fileBytes: fileBytes,
        fileName: fileName,
      );
      notifyListeners();
      return file;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CustomerModel> updateCustomer({
    required String customerId,
    required CustomerUpdateRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final customer = await _apiService.updateCustomer(
        customerId: customerId,
        request: request,
      );
      notifyListeners();
      return customer;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CustomerDocument> uploadCustomerDocument({
    required String customerId,
    required String documentType,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final document = await _apiService.uploadCustomerDocument(
        customerId: customerId,
        documentType: documentType,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      notifyListeners();
      return document;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<CustomerDocument>> fetchCustomerDocuments(
    String customerId, {
    String? documentType,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final documents = await _apiService.fetchCustomerDocuments(
        customerId,
        documentType: documentType,
      );
      notifyListeners();
      return documents;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiService.deleteCustomer(customerId);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AppUser> fetchUserById(String userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _apiService.fetchUserById(userId);
      notifyListeners();
      return user;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AppUser> updateUser({
    required String userId,
    required UpdateUserRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _apiService.updateUser(
        userId: userId,
        request: request,
      );
      notifyListeners();
      return user;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AppUser> updateUserStatus({
    required String userId,
    required UpdateUserStatusRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _apiService.updateUserStatus(
        userId: userId,
        request: request,
      );
      notifyListeners();
      return user;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetUserPassword({
    required String userId,
    required ResetUserPasswordRequest request,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiService.resetUserPassword(userId: userId, request: request);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiService.logout();
      _session = null;
      _currentUser = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }
}

class ApiProviderScope extends InheritedNotifier<ApiProvider> {
  const ApiProviderScope({
    super.key,
    required ApiProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ApiProvider of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ApiProviderScope>();
    assert(scope != null, 'ApiProviderScope not found in widget tree.');
    return scope!.notifier!;
  }

  static ApiProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ApiProviderScope>()
        ?.notifier;
  }
}
