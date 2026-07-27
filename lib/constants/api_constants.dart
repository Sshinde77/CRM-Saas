class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://crm-saas-backend-9nom.onrender.com';
  static const Duration requestTimeout = Duration(seconds: 20);

  static const String acceptHeader = 'accept';
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String jsonMimeType = 'application/json';
  static const String bearerPrefix = 'Bearer';

  static const Map<String, String> defaultHeaders = {
    acceptHeader: jsonMimeType,
    contentTypeHeader: jsonMimeType,
  };

  static Map<String, String> authorizedHeaders(String token) {
    return {
      ...defaultHeaders,
      authorizationHeader: '$bearerPrefix $token',
    };
  }
}

class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String invoices = '/invoices';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';
  static const String deliveries = '/deliveries';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String companySettings = '/settings/company';
  static const String adminSettings = '/settings/admin';
  static const String auditLogs = '/audit-logs';
}
