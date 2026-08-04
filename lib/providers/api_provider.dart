import 'package:flutter/widgets.dart';

import '../models/api_response.dart';
import '../models/customer_model.dart';
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
  List<RoleModel>? _roles;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthSession? get session => _session;
  CurrentUserProfile? get currentUser => _currentUser;
  List<RoleModel>? get roles => _roles;
  bool get isAuthenticated => (_session?.accessToken ?? '').trim().isNotEmpty;
  ApiService get service => _apiService;

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
