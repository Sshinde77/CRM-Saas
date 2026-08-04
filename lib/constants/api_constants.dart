class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://crm-saas-backend-9nom.onrender.com';
  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration loginRequestTimeout = Duration(seconds: 60);

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
    return {...defaultHeaders, authorizationHeader: '$bearerPrefix $token'};
  }
}

class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String plansList = '/plans';
  static const String rolesList = '/roles';

  static const String usersList = '/users';
  static const String usersCreate = '/users';
  static const String usersDetailTemplate = '/users/{user_id}';
  static const String usersUpdateTemplate = '/users/{user_id}';
  static const String usersStatusTemplate = '/users/{user_id}/status';
  static const String usersResetPasswordTemplate =
      '/users/{user_id}/reset-password';

  static const String plans = plansList;
  static const String roles = rolesList;
  static const String users = usersList;

  static String usersDetail(String userId) =>
      usersDetailTemplate.replaceFirst('{user_id}', userId);

  static String usersUpdate(String userId) =>
      usersUpdateTemplate.replaceFirst('{user_id}', userId);

  static String usersStatus(String userId) =>
      usersStatusTemplate.replaceFirst('{user_id}', userId);

  static String usersResetPassword(String userId) =>
      usersResetPasswordTemplate.replaceFirst('{user_id}', userId);
}
